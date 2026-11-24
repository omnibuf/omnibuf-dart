import 'dart:convert';
import 'dart:typed_data';

import 'errors.dart';
import 'options.dart';
import 'schema_meta.dart';
import 'wire.dart';

/// Wrapper distinguishing a `WireFloat32` from `WireFloat64` in [decodeBlind]
/// so JSON serialization preserves single-precision formatting (e.g. `1e-45`, `3.4028235e+38`).
class BlindFloat32 {
  final double value;
  const BlindFloat32(this.value);

  @override
  bool operator ==(Object other) =>
      other is BlindFloat32 && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Wrapper distinguishing an unsigned 64-bit integer (`WireUint` / `WireFixed64`)
/// so values >= `2^63` serialize losslessly as unsigned JSON integers.
class BlindUint64 {
  final int rawBits;
  const BlindUint64(this.rawBits);

  BigInt toBigInt() => uint64ToBigInt(rawBits);

  @override
  bool operator ==(Object other) =>
      other is BlindUint64 && other.rawBits == rawBits;

  @override
  int get hashCode => rawBits.hashCode;

  @override
  String toString() => uint64ToDecimal(rawBits);
}

/// Internal numeric-keyed message representation during blind decoding so
/// numeric merging happens before Field #0 presentation names are applied.
class _BlindMsg {
  SchemaMeta? meta;
  final Map<int, Object?> fields = <int, Object?>{};
  final Map<int, int> wireTypes = <int, int>{};
  final Map<int, String> shapeSignatures = <int, String>{};

  _BlindMsg();

  Map<String, Object?> resolveNames(SchemaMeta? inherited) {
    SchemaMeta? effective;
    if (inherited != null) {
      effective = inherited.clone();
      if (meta != null) {
        effective.mergeFrom(meta!);
      }
    } else if (meta != null) {
      effective = SchemaMeta()..mergeFrom(meta!);
    }

    // Check for duplicate non-empty Field #0 names assigned to distinct field numbers.
    if (effective != null && effective.fields.length > 1) {
      final seenNames = <String, int>{};
      for (final entry in effective.fields.entries) {
        final name = entry.value;
        if (name.isEmpty) continue;
        final prev = seenNames[name];
        if (prev != null && prev != entry.key) {
          throw OmniBufParseException(
            'Field #0 name collision: "$name" assigned to fields #$prev and #${entry.key}',
          );
        }
        seenNames[name] = entry.key;
      }
    }

    final result = <String, Object?>{};
    final sortedNums = fields.keys.toList()..sort();
    for (final fnum in sortedNums) {
      final declared = effective?.fields[fnum];
      final key =
          (declared != null && declared.isNotEmpty) ? declared : 'field_$fnum';
      final childMeta = effective?.children[fnum];
      final resolved = _resolveValue(fields[fnum], childMeta);
      if (result.containsKey(key)) {
        throw OmniBufParseException(
          'Field #0 resolved key collision on "$key" (field #$fnum)',
        );
      }
      result[key] = resolved;
    }
    return result;
  }

  static Object? _resolveValue(Object? val, SchemaMeta? childMeta) {
    if (val is Uint8List) {
      return val;
    }
    if (val is _BlindMsg) {
      return val.resolveNames(childMeta);
    }
    if (val is List<Object?>) {
      return [for (final item in val) _resolveValue(item, childMeta)];
    }
    if (val is Map<String, Object?>) {
      final out = <String, Object?>{};
      for (final e in val.entries) {
        out[e.key] = _resolveValue(e.value, childMeta);
      }
      return out;
    }
    return val;
  }
}

/// Unifies two container shape signatures, treating a less-specific signature
/// from an empty inner container (e.g. `A(13)`) as compatible with a
/// more-specific signature (e.g. `A(13:A(0))`) and returning the more-specific
/// signature. Returns `null` if the two signatures conflict.
String? _unifyShapeSignature(String a, String b) {
  if (a == b) return a;
  if (a.length < 4 || b.length < 4 || a[0] != b[0]) return null;
  final aBody = a.substring(2, a.length - 1);
  final bBody = b.substring(2, b.length - 1);
  final aColon = aBody.indexOf(':');
  final bColon = bBody.indexOf(':');
  final aHead = aColon >= 0 ? aBody.substring(0, aColon) : aBody;
  final bHead = bColon >= 0 ? bBody.substring(0, bColon) : bBody;
  if (aHead != bHead) return null;
  if (aColon < 0) return b;
  if (bColon < 0) return a;
  final aInner = aBody.substring(aColon + 1);
  final bInner = bBody.substring(bColon + 1);
  final unifiedInner = _unifyShapeSignature(aInner, bInner);
  if (unifiedInner == null) return null;
  return '${a[0]}($aHead:$unifiedInner)';
}

/// Decodes an arbitrary OmniBuf packet without an external schema (Tier 4).
///
/// Resolves Field #0 (`SchemaMeta`) names across nested messages, arrays, and
/// maps, falling back to `field_<N>` when unnamed.
Map<String, Object?> decodeBlind(
  Uint8List data, {
  DecodeOptions options = DecodeOptions.defaults,
  SchemaMeta? inheritedSchema,
}) {
  final maxDepth = options.validatedMaxDepth();
  if (data.length > options.maxMessageBytes) {
    throw OmniBufAllocationLimitException(
      'packet size ${data.length} exceeds maxMessageBytes ${options.maxMessageBytes}',
    );
  }
  final budget = DecodeBudget(
    options.maxCollectionElements,
    maxAllocBytes: options.maxAllocBytes,
  );
  final r = OmniBufReader(data);
  final msg = _decodeBlindMsg(r, 0, maxDepth, budget);
  return msg.resolveNames(inheritedSchema);
}

/// Decodes an arbitrary OmniBuf packet without an external schema and serializes
/// it to canonical JSON with unsigned UTF-8 byte-order map keys and lossless
/// 64-bit integer formatting.
String decodeBlindJson(
  Uint8List data, {
  DecodeOptions options = DecodeOptions.defaults,
  SchemaMeta? inheritedSchema,
}) {
  final map = decodeBlind(
    data,
    options: options,
    inheritedSchema: inheritedSchema,
  );
  final sb = StringBuffer();
  _writeJsonValue(sb, map);
  return sb.toString();
}

bool _sameLogicalWireType(int a, int b) {
  if (a == b) return true;
  if ((a == WireType.boolFalse || a == WireType.boolTrue) &&
      (b == WireType.boolFalse || b == WireType.boolTrue)) {
    return true;
  }
  return false;
}

class _BlindArrayResult {
  final String signature;
  final List<Object?> items;
  const _BlindArrayResult(this.signature, this.items);
}

class _BlindMapResult {
  final String signature;
  final Map<String, Object?> entries;
  const _BlindMapResult(this.signature, this.entries);
}

_BlindMsg _decodeBlindMsg(
  OmniBufReader r,
  int depth,
  int maxDepth,
  DecodeBudget budget,
) {
  final msg = _BlindMsg();
  while (r.hasMore) {
    final tag = r.readTag();
    final fnum = tag >> 4;
    final wt = tag & 0x0F;
    if (fnum == 0) {
      final block = SchemaMeta.decodeSubMsg(
        r,
        depth,
        maxDepth,
        maxElements: budget.maxElements,
        budget: budget,
      );
      if (msg.meta == null) {
        msg.meta = block;
      } else {
        msg.meta!.mergeFrom(block, preserveEmpty: true);
      }
      continue;
    }
    if (wt == WireType.extended) {
      final len = r.readCheckedLength();
      if (len < 1) {
        throw const OmniBufParseException(
          'WireExtended requires ByteLen >= 1',
        );
      }
      throw const OmniBufParseException(
        'unsupported WireExtended type in blind decode',
      );
    }
    budget.consume(1);
    final prevWt = msg.wireTypes[fnum];
    if (prevWt != null && !_sameLogicalWireType(prevWt, wt)) {
      throw OmniBufParseException(
        'wire type shape change on field #$fnum: $prevWt -> $wt',
      );
    }
    final rawVal = _decodeBlindValue(r, wt, depth, maxDepth, budget, false);
    if (wt == WireType.array) {
      final arr = rawVal as _BlindArrayResult;
      final prevSig = msg.shapeSignatures[fnum];
      if (prevSig != null) {
        final unified = _unifyShapeSignature(prevSig, arr.signature);
        if (unified == null) {
          throw OmniBufParseException(
            'WireArray shape change on field #$fnum: $prevSig -> ${arr.signature}',
          );
        }
        msg.shapeSignatures[fnum] = unified;
      } else {
        msg.shapeSignatures[fnum] = arr.signature;
      }
      if (prevWt != null) {
        (msg.fields[fnum] as List<Object?>).addAll(arr.items);
      } else {
        msg.fields[fnum] = arr.items;
        msg.wireTypes[fnum] = wt;
      }
      continue;
    }
    if (wt == WireType.map) {
      final mapRes = rawVal as _BlindMapResult;
      final prevSig = msg.shapeSignatures[fnum];
      if (prevSig != null) {
        final unified = _unifyShapeSignature(prevSig, mapRes.signature);
        if (unified == null) {
          throw OmniBufParseException(
            'WireMap shape change on field #$fnum: $prevSig -> ${mapRes.signature}',
          );
        }
        msg.shapeSignatures[fnum] = unified;
      } else {
        msg.shapeSignatures[fnum] = mapRes.signature;
      }
      if (prevWt != null) {
        (msg.fields[fnum] as Map<String, Object?>).addAll(mapRes.entries);
      } else {
        msg.fields[fnum] = mapRes.entries;
        msg.wireTypes[fnum] = wt;
      }
      continue;
    }
    if (wt == WireType.subMsg && prevWt != null) {
      _mergeBlindMsg(msg.fields[fnum] as _BlindMsg, rawVal as _BlindMsg);
      continue;
    }
    msg.fields[fnum] = rawVal;
    msg.wireTypes[fnum] = wt;
  }
  return msg;
}

void _mergeBlindMsg(_BlindMsg dst, _BlindMsg src) {
  if (src.meta != null) {
    if (dst.meta == null) {
      dst.meta = src.meta!.clone();
    } else {
      dst.meta!.mergeFrom(src.meta!, preserveEmpty: true);
    }
  }
  for (final entry in src.fields.entries) {
    final fnum = entry.key;
    final wt = src.wireTypes[fnum]!;
    final prevWt = dst.wireTypes[fnum];
    if (prevWt != null && !_sameLogicalWireType(prevWt, wt)) {
      throw OmniBufParseException(
        'wire type shape change on merged field #$fnum: $prevWt -> $wt',
      );
    }
    if (prevWt != null) {
      final prevSig = dst.shapeSignatures[fnum];
      final srcSig = src.shapeSignatures[fnum];
      if (prevSig != null && srcSig != null) {
        final unified = _unifyShapeSignature(prevSig, srcSig);
        if (unified == null) {
          throw OmniBufParseException(
            'container shape change on merged field #$fnum: $prevSig -> $srcSig',
          );
        }
        dst.shapeSignatures[fnum] = unified;
      }
      if (wt == WireType.array) {
        (dst.fields[fnum] as List<Object?>)
            .addAll(entry.value as List<Object?>);
        continue;
      }
      if (wt == WireType.subMsg) {
        _mergeBlindMsg(dst.fields[fnum] as _BlindMsg, entry.value as _BlindMsg);
        continue;
      }
      if (wt == WireType.map) {
        (dst.fields[fnum] as Map<String, Object?>)
            .addAll(entry.value as Map<String, Object?>);
        continue;
      }
    }
    dst.fields[fnum] = entry.value;
    dst.wireTypes[fnum] = wt;
    if (src.shapeSignatures.containsKey(fnum)) {
      dst.shapeSignatures[fnum] = src.shapeSignatures[fnum]!;
    }
  }
}

Object? _decodeBlindValue(
  OmniBufReader r,
  int wt,
  int depth,
  int maxDepth,
  DecodeBudget budget,
  bool inCollection,
) {
  switch (wt) {
    case WireType.uint:
      final v = r.readVarint();
      return v < 0 ? BlindUint64(v) : v;
    case WireType.sint:
      return r.readSint();
    case WireType.boolFalse:
      return inCollection ? r.readCollectionBool() : false;
    case WireType.boolTrue:
      if (inCollection) {
        throw const OmniBufParseException(
          'WireBoolTrue (3) is invalid inside collections',
        );
      }
      return true;
    case WireType.fixed32:
      return r.readFixed32();
    case WireType.fixed64:
      final v = r.readFixed64();
      return v < 0 ? BlindUint64(v) : v;
    case WireType.sfixed32:
      return r.readSfixed32();
    case WireType.sfixed64:
      return r.readSfixed64();
    case WireType.float32:
      return BlindFloat32(r.readFloat32());
    case WireType.float64:
      return r.readFloat64();
    case WireType.string:
      return r.readString(budget: budget);
    case WireType.bytes:
      return r.readBytes(budget: budget);
    case WireType.subMsg:
      final nextDepth = depth + 1;
      if (nextDepth > maxDepth) {
        throw OmniBufDepthLimitException(maxDepth);
      }
      final len = r.readCheckedLength();
      final subEnd = r.pos + len;
      final sub = r.subReader(r.pos, subEnd);
      final res = _decodeBlindMsg(sub, nextDepth, maxDepth, budget);
      r.pos = subEnd;
      return res;
    case WireType.array:
      final nextDepth = depth + 1;
      if (nextDepth > maxDepth) {
        throw OmniBufDepthLimitException(maxDepth);
      }
      final len = r.readCheckedLength();
      final bodyEnd = r.pos + len;
      final body = r.subReader(r.pos, bodyEnd);
      final (elemType, count) =
          body.readArrayHeader(maxElements: budget.maxElements);
      budget.consume(count);
      final list = <Object?>[];
      String? innerSig;
      for (var i = 0; i < count; i++) {
        if (elemType == WireType.extended) {
          final eLen = body.readCheckedLength();
          if (eLen < 1) {
            throw const OmniBufParseException(
              'WireExtended requires ByteLen >= 1',
            );
          }
          throw const OmniBufParseException(
            'unsupported WireExtended type in blind decode',
          );
        }
        final item = _decodeBlindValue(
            body, elemType, nextDepth, maxDepth, budget, true);
        if (item is _BlindArrayResult) {
          if (innerSig != null) {
            final unified = _unifyShapeSignature(innerSig, item.signature);
            if (unified == null) {
              throw const OmniBufParseException(
                'nested WireArray inner ElementType conflict',
              );
            }
            innerSig = unified;
          } else {
            innerSig = item.signature;
          }
          list.add(item.items);
        } else if (item is _BlindMapResult) {
          if (innerSig != null) {
            final unified = _unifyShapeSignature(innerSig, item.signature);
            if (unified == null) {
              throw const OmniBufParseException(
                'nested WireMap inner type conflict',
              );
            }
            innerSig = unified;
          } else {
            innerSig = item.signature;
          }
          list.add(item.entries);
        } else {
          list.add(item);
        }
      }
      if (body.pos != bodyEnd) {
        throw const OmniBufParseException('WireArray trailing bytes');
      }
      r.pos = bodyEnd;
      final sig = innerSig != null ? 'A($elemType:$innerSig)' : 'A($elemType)';
      return _BlindArrayResult(sig, list);
    case WireType.map:
      final nextDepth = depth + 1;
      if (nextDepth > maxDepth) {
        throw OmniBufDepthLimitException(maxDepth);
      }
      final len = r.readCheckedLength();
      final bodyEnd = r.pos + len;
      final body = r.subReader(r.pos, bodyEnd);
      final (keyType, valType, count) =
          body.readMapHeader(maxElements: budget.maxElements);
      budget.consume(count);
      final map = <String, Object?>{};
      String? valInnerSig;
      for (var i = 0; i < count; i++) {
        final keyStr = _decodeBlindMapKey(body, keyType, budget);
        if (valType == WireType.extended) {
          final eLen = body.readCheckedLength();
          if (eLen < 1) {
            throw const OmniBufParseException(
              'WireExtended requires ByteLen >= 1',
            );
          }
          throw const OmniBufParseException(
            'unsupported WireExtended type in blind decode',
          );
        }
        final val =
            _decodeBlindValue(body, valType, nextDepth, maxDepth, budget, true);
        if (val is _BlindArrayResult) {
          if (valInnerSig != null) {
            final unified = _unifyShapeSignature(valInnerSig, val.signature);
            if (unified == null) {
              throw const OmniBufParseException(
                'nested WireMap value array type conflict',
              );
            }
            valInnerSig = unified;
          } else {
            valInnerSig = val.signature;
          }
          map[keyStr] = val.items;
        } else if (val is _BlindMapResult) {
          if (valInnerSig != null) {
            final unified = _unifyShapeSignature(valInnerSig, val.signature);
            if (unified == null) {
              throw const OmniBufParseException(
                'nested WireMap value map type conflict',
              );
            }
            valInnerSig = unified;
          } else {
            valInnerSig = val.signature;
          }
          map[keyStr] = val.entries;
        } else {
          map[keyStr] = val;
        }
      }
      if (body.pos != bodyEnd) {
        throw const OmniBufParseException('WireMap trailing bytes');
      }
      r.pos = bodyEnd;
      final sig = valInnerSig != null
          ? 'M($keyType,$valType:$valInnerSig)'
          : 'M($keyType,$valType)';
      return _BlindMapResult(sig, map);
    case WireType.extended:
      final len = r.readCheckedLength();
      if (len < 1) {
        throw const OmniBufParseException(
          'WireExtended requires ByteLen >= 1',
        );
      }
      throw const OmniBufParseException(
        'unsupported WireExtended type in blind decode',
      );
    default:
      throw OmniBufParseException('unknown wire type $wt');
  }
}

String _decodeBlindMapKey(OmniBufReader r, int keyType, DecodeBudget budget) {
  switch (keyType) {
    case WireType.uint:
      return uint64ToDecimal(r.readVarint());
    case WireType.sint:
      return r.readSint().toString();
    case WireType.boolFalse:
      return r.readCollectionBool() ? 'true' : 'false';
    case WireType.fixed32:
      return r.readFixed32().toString();
    case WireType.fixed64:
      return uint64ToDecimal(r.readFixed64());
    case WireType.sfixed32:
      return r.readSfixed32().toString();
    case WireType.sfixed64:
      return r.readSfixed64().toString();
    case WireType.string:
      return r.readString(budget: budget);
    default:
      throw OmniBufParseException('invalid WireMap KeyType $keyType');
  }
}

void _writeJsonValue(StringBuffer sb, Object? val) {
  if (val == null) {
    sb.write('null');
  } else if (val is bool) {
    sb.write(val ? 'true' : 'false');
  } else if (val is int) {
    sb.write(val);
  } else if (val is BlindUint64) {
    sb.write(uint64ToDecimal(val.rawBits));
  } else if (val is BigInt) {
    sb.write(val.toString());
  } else if (val is BlindFloat32) {
    _writeJsonFloat(sb, val.value, isFloat32: true);
  } else if (val is double) {
    _writeJsonFloat(sb, val, isFloat32: false);
  } else if (val is String) {
    sb.write(jsonEncode(val));
  } else if (val is Uint8List) {
    sb.write('"');
    sb.write(base64Encode(val));
    sb.write('"');
  } else if (val is List<Object?>) {
    sb.write('[');
    for (var i = 0; i < val.length; i++) {
      if (i > 0) sb.write(',');
      _writeJsonValue(sb, val[i]);
    }
    sb.write(']');
  } else if (val is Map<String, Object?>) {
    sb.write('{');
    // Sort keys in unsigned UTF-8 byte order (NOT UTF-16 String.compareTo).
    final keys = val.keys.toList()..sort(compareUtf8);
    for (var i = 0; i < keys.length; i++) {
      if (i > 0) sb.write(',');
      final k = keys[i];
      sb.write(jsonEncode(k));
      sb.write(':');
      _writeJsonValue(sb, val[k]);
    }
    sb.write('}');
  } else {
    sb.write(jsonEncode(val.toString()));
  }
}

void _writeJsonFloat(StringBuffer sb, double v, {required bool isFloat32}) {
  if (v.isNaN) {
    sb.write('"NaN"');
    return;
  }
  if (v == double.infinity) {
    sb.write('"Infinity"');
    return;
  }
  if (v == double.negativeInfinity) {
    sb.write('"-Infinity"');
    return;
  }
  if (v == 0.0) {
    sb.write(v.isNegative ? '-0' : '0');
    return;
  }
  final absV = v.abs();
  // Keep numbers inside [1e-6, 1e21) in non-scientific decimal notation (matching Go/JS).
  if (absV >= 1e-6 && absV < 1e21) {
    if (v == v.truncateToDouble() && absV < 9007199254740992.0) {
      sb.write(v.truncate());
      return;
    }
    final s = isFloat32 ? _formatFloat32(v) : v.toString();
    if (!s.contains('e') && !s.contains('E')) {
      sb.write(_stripTrailingDotZero(s));
      return;
    }
    // Expand scientific notation for [1e-6, 1e-4) where Dart's double.toString uses e-5 / e-6.
    sb.write(_expandScientific(s));
    return;
  }
  if (isFloat32) {
    sb.write(_formatFloat32(v));
  } else {
    sb.write(v.toString());
  }
}

final ByteData _f32Scratch = ByteData(4);

String _formatFloat32(double v) {
  // Find shortest decimal representation that round-trips to the exact float32 bit pattern.
  _f32Scratch.setFloat32(0, v, Endian.little);
  final targetBits = _f32Scratch.getUint32(0, Endian.little);
  for (var digits = 1; digits <= 9; digits++) {
    final cand = v.toStringAsPrecision(digits);
    final parsed = double.parse(cand);
    _f32Scratch.setFloat32(0, parsed, Endian.little);
    if (_f32Scratch.getUint32(0, Endian.little) == targetBits) {
      return _stripTrailingDotZero(cand);
    }
  }
  return v.toString();
}

String _stripTrailingDotZero(String s) {
  if (s.contains('e') || s.contains('E') || !s.contains('.')) return s;
  var end = s.length;
  while (end > 0 && s.codeUnitAt(end - 1) == 48 /* '0' */) {
    end--;
  }
  if (end > 0 && s.codeUnitAt(end - 1) == 46 /* '.' */) {
    end--;
  }
  return s.substring(0, end);
}

String _expandScientific(String s) {
  final neg = s.startsWith('-');
  final body = neg ? s.substring(1) : s;
  final eIdx = body.indexOf(RegExp('[eE]'));
  if (eIdx < 0) return s;
  final mantissa = body.substring(0, eIdx);
  final exp = int.parse(body.substring(eIdx + 1));
  final dotIdx = mantissa.indexOf('.');
  final digits = dotIdx < 0
      ? mantissa
      : mantissa.substring(0, dotIdx) + mantissa.substring(dotIdx + 1);
  final intDigits = dotIdx < 0 ? mantissa.length : dotIdx;
  final newDot = intDigits + exp;
  final prefix = neg ? '-' : '';
  if (newDot <= 0) {
    return '${prefix}0.${'0' * (-newDot)}$digits';
  }
  if (newDot >= digits.length) {
    return '$prefix$digits${'0' * (newDot - digits.length)}';
  }
  return _stripTrailingDotZero(
    '$prefix${digits.substring(0, newDot)}.${digits.substring(newDot)}',
  );
}
