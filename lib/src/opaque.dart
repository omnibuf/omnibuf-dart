import 'dart:typed_data';

import 'wire.dart';

/// A field-level wire patch used by [spliceFields] to replace, insert, or delete
/// specific field numbers in-place without decoding untouched fields.
class FieldPatch {
  /// Target field number (`1..536870911`).
  final int fieldNumber;

  /// Complete encoded `[Tag][Value]` bytes for the replacement field,
  /// or `null` / empty to remove all occurrences of [fieldNumber].
  final Uint8List? encodedField;

  const FieldPatch(this.fieldNumber, this.encodedField);
}

/// Scans [src] in `O(fields)` time without decoding untouched containers and
/// returns the `(valueStart, valueEnd, wireType)` of the **last** occurrence of
/// [targetFieldNumber], or `null` if absent.
///
/// Validates prefix-varint tags and container length bounds along the scan.
(int, int, int)? findLastField(Uint8List src, int targetFieldNumber) {
  final r = OmniBufReader(src);
  (int, int, int)? found;
  while (r.hasMore) {
    final tag = r.readTag();
    final fnum = tag >> 4;
    final wt = tag & 0x0F;
    final valStart = r.pos;
    final valEnd = fastSkipValue(r, wt);
    if (fnum == targetFieldNumber) {
      found = (valStart, valEnd, wt);
    }
  }
  return found;
}

/// Scans [src] and returns a list of `(valueStart, valueEnd, wireType)` for
/// every occurrence of [targetFieldNumber] (needed for repeated/merged fields).
List<(int, int, int)> findAllFields(Uint8List src, int targetFieldNumber) {
  final r = OmniBufReader(src);
  final found = <(int, int, int)>[];
  while (r.hasMore) {
    final tag = r.readTag();
    final fnum = tag >> 4;
    final wt = tag & 0x0F;
    final valStart = r.pos;
    final valEnd = fastSkipValue(r, wt);
    if (fnum == targetFieldNumber) {
      found.add((valStart, valEnd, wt));
    }
  }
  return found;
}

/// Scans [src] and returns the `(valueStart, valueEnd, wireType)` of the **last**
/// occurrence of [targetFieldNumber] whose wire type equals [expectedWt].
(int, int, int)? findLastFieldWithWireType(
  Uint8List src,
  int targetFieldNumber,
  int expectedWt,
) {
  final r = OmniBufReader(src);
  (int, int, int)? found;
  while (r.hasMore) {
    final tag = r.readTag();
    final fnum = tag >> 4;
    final wt = tag & 0x0F;
    final valStart = r.pos;
    final valEnd = fastSkipValue(r, wt);
    if (fnum == targetFieldNumber && wt == expectedWt) {
      found = (valStart, valEnd, wt);
    }
  }
  return found;
}

/// Scans [src] and returns the wire type of the **last** boolean occurrence
/// (`WireBoolFalse` or `WireBoolTrue`) of [targetFieldNumber], or `null` if absent.
int? findLastBoolField(Uint8List src, int targetFieldNumber) {
  final r = OmniBufReader(src);
  int? found;
  while (r.hasMore) {
    final tag = r.readTag();
    final fnum = tag >> 4;
    final wt = tag & 0x0F;
    fastSkipValue(r, wt);
    if (fnum == targetFieldNumber &&
        (wt == WireType.boolFalse || wt == WireType.boolTrue)) {
      found = wt;
    }
  }
  return found;
}

/// Splices [patches] into [src] without decoding untouched fields, appending
/// the resulting packet into [dst] (preserving any existing prefix in [dst]).
///
/// Never mutates [src]. Validates structural framing and UTF-8 of [src] when
/// [validate] is `true` (default).
Uint8List spliceFields(
  Uint8List src,
  List<FieldPatch> patches, {
  OmniBufWriter? writer,
  Uint8List? prefix,
  bool validate = true,
}) {
  if (validate) {
    validatePacket(src, validateStrings: true);
  }
  if (patches.isEmpty) {
    // Still validate structural framing of src when full validation was skipped.
    if (!validate) {
      final r = OmniBufReader(src);
      while (r.hasMore) {
        final tag = r.readTag();
        fastSkipValue(r, tag & 0x0F);
      }
    }
    if (writer != null) {
      if (prefix != null && prefix.isNotEmpty) {
        writer.writeRawBytes(prefix);
      }
      writer.writeRawBytes(src);
      return writer.toBytes();
    }
    if (prefix != null && prefix.isNotEmpty) {
      final out = Uint8List(prefix.length + src.length);
      out.setRange(0, prefix.length, prefix);
      out.setRange(prefix.length, out.length, src);
      return out;
    }
    return Uint8List.fromList(src);
  }

  // Index patches by field number (last patch wins if duplicate in patches list).
  final patchMap = <int, Uint8List?>{};
  for (final p in patches) {
    patchMap[p.fieldNumber] = p.encodedField;
  }

  final w = writer ?? OmniBufWriter(src.length + 64);
  if (prefix != null && prefix.isNotEmpty) {
    w.writeRawBytes(prefix);
  }

  final emitted = <int>{};
  final r = OmniBufReader(src);
  var copyStart = 0;

  while (r.hasMore) {
    final fieldStart = r.pos;
    final tag = r.readTag();
    final fnum = tag >> 4;
    final wt = tag & 0x0F;
    final fieldEnd = fastSkipValue(r, wt);

    if (patchMap.containsKey(fnum)) {
      if (fieldStart > copyStart) {
        w.writeRawSlice(src, copyStart, fieldStart);
      }
      if (!emitted.contains(fnum)) {
        emitted.add(fnum);
        final replacement = patchMap[fnum];
        if (replacement != null && replacement.isNotEmpty) {
          w.writeRawBytes(replacement);
        }
      }
      copyStart = fieldEnd;
    }
  }

  if (src.length > copyStart) {
    w.writeRawSlice(src, copyStart, src.length);
  }

  // Emit any patched fields that were not present in src in ascending field number order.
  final remainingFields = <int>[];
  for (final fnum in patchMap.keys) {
    if (!emitted.contains(fnum)) {
      remainingFields.add(fnum);
    }
  }
  remainingFields.sort();
  for (final fnum in remainingFields) {
    final replacement = patchMap[fnum];
    if (replacement != null && replacement.isNotEmpty) {
      w.writeRawBytes(replacement);
    }
  }

  return w.toBytes();
}

/// Base class for generated lazy `Opaque` message views.
///
/// Holds the raw wire bytes [rawBytes] and a map of dirty field patches.
/// Unmodified fields are read directly from [rawBytes] in `O(fields)` time
/// without allocating or decoding sibling fields. Calling [marshalAppend]
/// splices only dirty fields into [rawBytes].
abstract class OpaqueMessage {
  final Uint8List rawBytes;
  final Map<int, Uint8List?> _dirty = <int, Uint8List?>{};

  OpaqueMessage(this.rawBytes);

  /// Records a raw encoded `[Tag][Value]` patch for [fieldNumber].
  void setPatch(int fieldNumber, Uint8List? encodedField) {
    _dirty[fieldNumber] = encodedField;
  }

  /// Whether [fieldNumber] has a pending local mutation.
  bool hasPatch(int fieldNumber) => _dirty.containsKey(fieldNumber);

  /// Returns the pending patch bytes for [fieldNumber], if any.
  Uint8List? getPatch(int fieldNumber) => _dirty[fieldNumber];

  /// Clears all pending mutations, reverting to [rawBytes].
  void clearPatches() => _dirty.clear();

  /// Splices all pending mutations into [rawBytes], optionally prepending [prefix].
  /// Set [validate] to `true` (or use [tryMarshal]) to run full packet and UTF-8 validation.
  Uint8List marshalAppend([Uint8List? prefix, bool validate = false]) {
    if (_dirty.isEmpty) {
      return spliceFields(rawBytes, const [], prefix: prefix, validate: validate);
    }
    final patches = <FieldPatch>[
      for (final e in _dirty.entries) FieldPatch(e.key, e.value),
    ];
    return spliceFields(rawBytes, patches, prefix: prefix, validate: validate);
  }

  /// Validated alias for [marshalAppend] that runs full packet and UTF-8 validation.
  Uint8List tryMarshal([Uint8List? prefix]) => marshalAppend(prefix, true);

  /// Fast single-field splice into a reusable [OmniBufWriter] (zero extra copy when using [writer.viewBytes]).
  /// Validates structural framing and UTF-8 of [rawBytes] when [validate] is `true` (default).
  void marshalInto(OmniBufWriter writer, {bool validate = true}) {
    if (validate) {
      validatePacket(rawBytes, validateStrings: true);
    }
    if (_dirty.isEmpty) {
      if (!validate) {
        final r = OmniBufReader(rawBytes);
        while (r.hasMore) {
          final tag = r.readTag();
          fastSkipValue(r, tag & 0x0F);
        }
      }
      writer.writeRawBytes(rawBytes);
      return;
    }
    final emitted = <int>{};
    final r = OmniBufReader(rawBytes);
    var copyStart = 0;
    while (r.hasMore) {
      final fieldStart = r.pos;
      final tag = r.readTag();
      final fnum = tag >> 4;
      final wt = tag & 0x0F;
      final fieldEnd = fastSkipValue(r, wt);
      if (_dirty.containsKey(fnum)) {
        if (fieldStart > copyStart) {
          writer.writeRawSlice(rawBytes, copyStart, fieldStart);
        }
        if (!emitted.contains(fnum)) {
          emitted.add(fnum);
          final replacement = _dirty[fnum];
          if (replacement != null && replacement.isNotEmpty) {
            writer.writeRawBytes(replacement);
          }
        }
        copyStart = fieldEnd;
      }
    }
    if (rawBytes.length > copyStart) {
      writer.writeRawSlice(rawBytes, copyStart, rawBytes.length);
    }
    if (emitted.length < _dirty.length) {
      final remainingFields = <int>[];
      for (final fnum in _dirty.keys) {
        if (!emitted.contains(fnum)) {
          remainingFields.add(fnum);
        }
      }
      remainingFields.sort();
      for (final fnum in remainingFields) {
        final replacement = _dirty[fnum];
        if (replacement != null && replacement.isNotEmpty) {
          writer.writeRawBytes(replacement);
        }
      }
    }
  }
}
