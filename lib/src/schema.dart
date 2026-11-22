import 'dart:typed_data';

import 'package:fixnum/fixnum.dart' show Int64;

import 'errors.dart';
import 'options.dart';
import 'schema_meta.dart';
import 'wire.dart';

/// Metadata annotation for declaring an OmniBuf message class.
class OmniBufMessage {
  final String name;
  const OmniBufMessage(this.name);
}

/// Metadata annotation for declaring an OmniBuf field on a Dart class.
class OmniBufField {
  final int id;
  final String? name;
  final OmniFieldKind kind;

  const OmniBufField(this.id, {this.name, this.kind = OmniFieldKind.uint32});
}

/// Logical field types supported by [OmniBufSchema] (Tier 3).
enum OmniFieldKind {
  uint32,
  uint64,
  sint32,
  sint64,
  boolType,
  fixed32,
  fixed64,
  sfixed32,
  sfixed64,
  float32,
  float64,
  string,
  bytes,
  message,
  repeated,
  map,
}

/// Returns the OmniBuf wire type code for a scalar or container [OmniFieldKind].
int wireTypeForKind(OmniFieldKind kind) {
  switch (kind) {
    case OmniFieldKind.uint32:
    case OmniFieldKind.uint64:
      return WireType.uint;
    case OmniFieldKind.sint32:
    case OmniFieldKind.sint64:
      return WireType.sint;
    case OmniFieldKind.boolType:
      return WireType.boolFalse;
    case OmniFieldKind.fixed32:
      return WireType.fixed32;
    case OmniFieldKind.fixed64:
      return WireType.fixed64;
    case OmniFieldKind.sfixed32:
      return WireType.sfixed32;
    case OmniFieldKind.sfixed64:
      return WireType.sfixed64;
    case OmniFieldKind.float32:
      return WireType.float32;
    case OmniFieldKind.float64:
      return WireType.float64;
    case OmniFieldKind.string:
      return WireType.string;
    case OmniFieldKind.bytes:
      return WireType.bytes;
    case OmniFieldKind.message:
      return WireType.subMsg;
    case OmniFieldKind.repeated:
      return WireType.array;
    case OmniFieldKind.map:
      return WireType.map;
  }
}

/// Descriptor for a single field in an [OmniBufSchema].
class OmniFieldDef<T> {
  final int id;
  final String name;
  final OmniFieldKind kind;
  final OmniFieldKind? elementKind;
  final OmniFieldKind? keyKind;
  final OmniFieldKind? valueKind;
  final OmniBufSchema<dynamic> Function()? subSchema;
  final Object? Function(T msg) get;
  final void Function(T msg, Object? value) set;
  final bool preserveEmpty;

  const OmniFieldDef({
    required this.id,
    required this.name,
    required this.kind,
    required this.get,
    required this.set,
    this.elementKind,
    this.keyKind,
    this.valueKind,
    this.subSchema,
    this.preserveEmpty = false,
  });

  int get expectedWireType => wireTypeForKind(kind);
}

/// Declarative schema codec for plain Dart classes (Tier 3).
class OmniBufSchema<T> {
  final String name;
  final T Function() create;
  final void Function(T msg)? reset;
  final List<OmniFieldDef<T>> fields;
  late final Map<int, OmniFieldDef<T>> _byId = {
    for (final f in fields) f.id: f,
  };
  late final List<OmniFieldDef<T>> _sortedFields = List<OmniFieldDef<T>>.of(
    fields,
  )..sort((a, b) => a.id.compareTo(b.id));

  OmniBufSchema({
    required this.name,
    required this.create,
    required this.fields,
    this.reset,
  });

  /// Builds Field #0 [SchemaMeta] for this schema, avoiding infinite cycles on recursive types.
  SchemaMeta buildSchemaMeta({int maxDepth = 16}) {
    return _buildMeta(0, maxDepth);
  }

  SchemaMeta _buildMeta(int depth, int maxDepth) {
    final fieldNames = <int, String>{};
    final childMetas = <int, SchemaMeta>{};
    for (final f in _sortedFields) {
      fieldNames[f.id] = f.name;
      if (f.subSchema != null && depth + 2 <= maxDepth) {
        childMetas[f.id] = f.subSchema!()._buildMeta(depth + 2, maxDepth);
      }
    }
    return SchemaMeta(typeName: name, fields: fieldNames, children: childMetas);
  }

  /// Encodes [msg] to OmniBuf wire bytes.
  Uint8List encode(T msg, {EncodeOptions options = EncodeOptions.defaults}) {
    final w = OmniBufWriter(256);
    if (options.selfDescribing) {
      buildSchemaMeta().writeField0(w);
    }
    encodeInto(w, msg, options: options);
    return w.toBytes();
  }

  /// Appends [msg]'s encoded fields into [w] (without a length prefix).
  void encodeInto(
    OmniBufWriter w,
    T msg, {
    EncodeOptions options = EncodeOptions.defaults,
  }) {
    for (final f in _sortedFields) {
      final val = f.get(msg);
      if (val == null) continue;
      _encodeField(w, f, val, options);
    }
  }

  void _encodeField(
    OmniBufWriter w,
    OmniFieldDef<T> f,
    Object val,
    EncodeOptions options,
  ) {
    switch (f.kind) {
      case OmniFieldKind.uint32:
        final v = _toInt(val) & 0xFFFFFFFF;
        if (v != 0) {
          w.writeTag(f.id, WireType.uint);
          w.writeVarint(v);
        }
      case OmniFieldKind.uint64:
        final v = _toInt(val);
        if (v != 0) {
          w.writeTag(f.id, WireType.uint);
          w.writeVarint(v);
        }
      case OmniFieldKind.sint32:
        final v = _toInt(val).toSigned(32);
        if (v != 0) {
          w.writeTag(f.id, WireType.sint);
          w.writeSint32(v);
        }
      case OmniFieldKind.sint64:
        final v = _toInt(val);
        if (v != 0) {
          w.writeTag(f.id, WireType.sint);
          w.writeSint(v);
        }
      case OmniFieldKind.boolType:
        if (val == true) {
          w.writeTag(f.id, WireType.boolTrue);
        }
      case OmniFieldKind.fixed32:
        final v = _toInt(val) & 0xFFFFFFFF;
        if (v != 0) {
          w.writeTag(f.id, WireType.fixed32);
          w.writeFixed32(v);
        }
      case OmniFieldKind.fixed64:
        final v = _toInt(val);
        if (v != 0) {
          w.writeTag(f.id, WireType.fixed64);
          w.writeFixed64(v);
        }
      case OmniFieldKind.sfixed32:
        final v = _toInt(val).toSigned(32);
        if (v != 0) {
          w.writeTag(f.id, WireType.sfixed32);
          w.writeSfixed32(v);
        }
      case OmniFieldKind.sfixed64:
        final v = _toInt(val);
        if (v != 0) {
          w.writeTag(f.id, WireType.sfixed64);
          w.writeSfixed64(v);
        }
      case OmniFieldKind.float32:
        final v = (val as num).toDouble();
        if (v != 0.0 || v.isNegative) {
          w.writeTag(f.id, WireType.float32);
          w.writeFloat32(v);
        }
      case OmniFieldKind.float64:
        final v = (val as num).toDouble();
        if (v != 0.0 || v.isNegative) {
          w.writeTag(f.id, WireType.float64);
          w.writeFloat64(v);
        }
      case OmniFieldKind.string:
        final s = val as String;
        if (s.isNotEmpty) {
          w.writeTag(f.id, WireType.string);
          w.writeString(s);
        }
      case OmniFieldKind.bytes:
        final b = val as Uint8List;
        if (b.isNotEmpty) {
          w.writeTag(f.id, WireType.bytes);
          w.writeBytes(b);
        }
      case OmniFieldKind.message:
        final sub = f.subSchema!();
        w.writeTag(f.id, WireType.subMsg);
        final slot = w.reserveLen2();
        sub.encodeInto(w, val, options: options);
        w.patchLen2(slot);
      case OmniFieldKind.repeated:
        final list = val as List<dynamic>;
        if (list.isEmpty && !f.preserveEmpty) return;
        final elemKind = f.elementKind!;
        final elemWt = wireTypeForKind(elemKind);
        w.writeTag(f.id, WireType.array);
        final slot = w.reserveLen2();
        w.writeByte(elemWt);
        w.writeVarint(list.length);
        for (final item in list) {
          _writeCollectionValue(w, elemKind, item, f.subSchema, options);
        }
        w.patchLen2(slot);
      case OmniFieldKind.map:
        final map = val as Map<dynamic, dynamic>;
        if (map.isEmpty && !f.preserveEmpty) return;
        final kKind = f.keyKind!;
        final vKind = f.valueKind!;
        final kWt = wireTypeForKind(kKind);
        final vWt = wireTypeForKind(vKind);
        w.writeTag(f.id, WireType.map);
        final slot = w.reserveLen2();
        w.writeByte(kWt);
        w.writeByte(vWt);
        final keys = map.keys.toList();
        if (options.deterministicMaps) {
          _sortMapKeys(keys, kKind);
        }
        w.writeVarint(keys.length);
        for (final k in keys) {
          _writeCollectionValue(w, kKind, k, null, options);
          _writeCollectionValue(w, vKind, map[k], f.subSchema, options);
        }
        w.patchLen2(slot);
    }
  }

  /// Decodes OmniBuf bytes into a newly allocated [T].
  T decode(Uint8List data, {DecodeOptions options = DecodeOptions.defaults}) {
    final msg = create();
    decodeInto(data, msg, options: options);
    return msg;
  }

  /// Decodes OmniBuf bytes into an existing [dst] instance.
  /// In replace mode (`options.merge == false`), resets omitted fields first.
  void decodeInto(
    Uint8List data,
    T dst, {
    DecodeOptions options = DecodeOptions.defaults,
  }) {
    if (data.length > options.maxMessageBytes) {
      throw OmniBufAllocationLimitException(
        'packet size ${data.length} exceeds maxMessageBytes ${options.maxMessageBytes}',
      );
    }
    if (!options.merge) {
      _resetMessage(dst);
    }
    final r = OmniBufReader(data);
    _decodeBody(r, dst, 0, options);
  }

  void _resetMessage(T dst) {
    if (reset != null) {
      reset!(dst);
      return;
    }
    for (final f in fields) {
      switch (f.kind) {
        case OmniFieldKind.uint32:
        case OmniFieldKind.uint64:
        case OmniFieldKind.sint32:
        case OmniFieldKind.sint64:
        case OmniFieldKind.fixed32:
        case OmniFieldKind.fixed64:
        case OmniFieldKind.sfixed32:
        case OmniFieldKind.sfixed64:
          f.set(dst, 0);
        case OmniFieldKind.boolType:
          f.set(dst, false);
        case OmniFieldKind.float32:
        case OmniFieldKind.float64:
          f.set(dst, 0.0);
        case OmniFieldKind.string:
          f.set(dst, '');
        case OmniFieldKind.bytes:
          f.set(dst, Uint8List(0));
        case OmniFieldKind.message:
          f.set(dst, null);
        case OmniFieldKind.repeated:
          f.set(dst, <dynamic>[]);
        case OmniFieldKind.map:
          f.set(dst, <dynamic, dynamic>{});
      }
    }
  }

  void _decodeBody(
    OmniBufReader r,
    T dst,
    int depth,
    DecodeOptions options,
  ) {
    while (r.hasMore) {
      final tag = r.readTag();
      final fnum = tag >> 4;
      final wt = tag & 0x0F;
      if (fnum == 0) {
        validateField0SubMsg(r, depth, options.maxDepth);
        continue;
      }
      final f = _byId[fnum];
      if (f == null) {
        skipAndValidateValue(
          r,
          wt,
          depth,
          options.maxDepth,
          maxElements: options.maxCollectionElements,
        );
        continue;
      }
      if (!_matchesTagWireType(f.kind, wt)) {
        // Known field number with unexpected tag wire type -> handle as unknown field.
        skipAndValidateValue(
          r,
          wt,
          depth,
          options.maxDepth,
          maxElements: options.maxCollectionElements,
        );
        continue;
      }
      _decodeField(r, dst, f, wt, depth, options);
    }
  }

  void _decodeField(
    OmniBufReader r,
    T dst,
    OmniFieldDef<T> f,
    int wt,
    int depth,
    DecodeOptions options,
  ) {
    switch (f.kind) {
      case OmniFieldKind.uint32:
        f.set(dst, r.readUint32());
      case OmniFieldKind.uint64:
        f.set(dst, r.readVarint());
      case OmniFieldKind.sint32:
        f.set(dst, r.readSint32());
      case OmniFieldKind.sint64:
        f.set(dst, r.readSint());
      case OmniFieldKind.boolType:
        f.set(dst, wt == WireType.boolTrue);
      case OmniFieldKind.fixed32:
        f.set(dst, r.readFixed32());
      case OmniFieldKind.fixed64:
        f.set(dst, r.readFixed64());
      case OmniFieldKind.sfixed32:
        f.set(dst, r.readSfixed32());
      case OmniFieldKind.sfixed64:
        f.set(dst, r.readSfixed64());
      case OmniFieldKind.float32:
        f.set(dst, r.readFloat32());
      case OmniFieldKind.float64:
        f.set(dst, r.readFloat64());
      case OmniFieldKind.string:
        f.set(dst, r.readString());
      case OmniFieldKind.bytes:
        f.set(dst, r.readBytes());
      case OmniFieldKind.message:
        final nextDepth = depth + 1;
        if (nextDepth > options.maxDepth) {
          throw OmniBufDepthLimitException(options.maxDepth);
        }
        final len = r.readCheckedLength();
        final subEnd = r.pos + len;
        final subReader = r.subReader(r.pos, subEnd);
        final subSchema = f.subSchema!();
        var subObj = f.get(dst);
        if (subObj == null) {
          subObj = subSchema.create();
          f.set(dst, subObj);
        }
        subSchema._decodeBody(subReader, subObj, nextDepth, options);
        r.pos = subEnd;
      case OmniFieldKind.repeated:
        final nextDepth = depth + 1;
        if (nextDepth > options.maxDepth) {
          throw OmniBufDepthLimitException(options.maxDepth);
        }
        final len = r.readCheckedLength();
        final bodyEnd = r.pos + len;
        final body = r.subReader(r.pos, bodyEnd);
        final (elemWt, count) = body.readArrayHeader(
          maxElements: options.maxCollectionElements,
        );
        final expectedElemWt = wireTypeForKind(f.elementKind!);
        if (elemWt != expectedElemWt) {
          throw OmniBufTypeMismatchException(
            'field ${f.name} (#${f.id}) WireArray expects ElementType $expectedElemWt, got $elemWt',
          );
        }
        final existing = f.get(dst);
        final list = (existing is List) ? existing : <dynamic>[];
        if (existing == null) f.set(dst, list);
        for (var i = 0; i < count; i++) {
          list.add(
            _readCollectionValue(
              body,
              f.elementKind!,
              f.subSchema,
              nextDepth,
              options,
            ),
          );
        }
        if (body.pos != bodyEnd) {
          throw const OmniBufParseException('WireArray trailing bytes');
        }
        r.pos = bodyEnd;
      case OmniFieldKind.map:
        final nextDepth = depth + 1;
        if (nextDepth > options.maxDepth) {
          throw OmniBufDepthLimitException(options.maxDepth);
        }
        final len = r.readCheckedLength();
        final bodyEnd = r.pos + len;
        final body = r.subReader(r.pos, bodyEnd);
        final (kWt, vWt, count) = body.readMapHeader(
          maxElements: options.maxCollectionElements,
        );
        final expectedKWt = wireTypeForKind(f.keyKind!);
        final expectedVWt = wireTypeForKind(f.valueKind!);
        if (kWt != expectedKWt || vWt != expectedVWt) {
          throw OmniBufTypeMismatchException(
            'field ${f.name} (#${f.id}) WireMap expects <$expectedKWt, $expectedVWt>, got <$kWt, $vWt>',
          );
        }
        final existing = f.get(dst);
        final map = (existing is Map) ? existing : <dynamic, dynamic>{};
        if (existing == null) f.set(dst, map);
        for (var i = 0; i < count; i++) {
          final k = _readCollectionValue(
            body,
            f.keyKind!,
            null,
            nextDepth,
            options,
          );
          final v = _readCollectionValue(
            body,
            f.valueKind!,
            f.subSchema,
            nextDepth,
            options,
          );
          map[k] = v;
        }
        if (body.pos != bodyEnd) {
          throw const OmniBufParseException('WireMap trailing bytes');
        }
        r.pos = bodyEnd;
    }
  }
}

bool _matchesTagWireType(OmniFieldKind kind, int wt) {
  if (kind == OmniFieldKind.boolType) {
    return wt == WireType.boolFalse || wt == WireType.boolTrue;
  }
  return wt == wireTypeForKind(kind);
}

int _toInt(Object val) {
  if (val is int) return val;
  if (val is Int64) return val.toInt();
  if (val is BigInt) return bigIntToUint64(val);
  throw OmniBufSerializeException(
      'expected integer value, got ${val.runtimeType}');
}

void _writeCollectionValue(
  OmniBufWriter w,
  OmniFieldKind kind,
  Object? val,
  OmniBufSchema<dynamic> Function()? subSchema,
  EncodeOptions options,
) {
  switch (kind) {
    case OmniFieldKind.uint32:
      w.writeVarint(_toInt(val!) & 0xFFFFFFFF);
    case OmniFieldKind.uint64:
      w.writeVarint(_toInt(val!));
    case OmniFieldKind.sint32:
      w.writeSint32(_toInt(val!));
    case OmniFieldKind.sint64:
      w.writeSint(_toInt(val!));
    case OmniFieldKind.boolType:
      w.writeByte(val == true ? 1 : 0);
    case OmniFieldKind.fixed32:
      w.writeFixed32(_toInt(val!) & 0xFFFFFFFF);
    case OmniFieldKind.fixed64:
      w.writeFixed64(_toInt(val!));
    case OmniFieldKind.sfixed32:
      w.writeSfixed32(_toInt(val!).toSigned(32));
    case OmniFieldKind.sfixed64:
      w.writeSfixed64(_toInt(val!));
    case OmniFieldKind.float32:
      w.writeFloat32((val as num).toDouble());
    case OmniFieldKind.float64:
      w.writeFloat64((val as num).toDouble());
    case OmniFieldKind.string:
      w.writeString(val as String);
    case OmniFieldKind.bytes:
      w.writeBytes(val as Uint8List);
    case OmniFieldKind.message:
      final schema = subSchema!();
      final slot = w.reserveLen2();
      if (val != null) {
        schema.encodeInto(w, val, options: options);
      }
      w.patchLen2(slot);
    case OmniFieldKind.repeated:
    case OmniFieldKind.map:
      throw OmniBufSerializeException(
        'nested collection kind $kind requires explicit nested schema',
      );
  }
}

Object? _readCollectionValue(
  OmniBufReader r,
  OmniFieldKind kind,
  OmniBufSchema<dynamic> Function()? subSchema,
  int depth,
  DecodeOptions options,
) {
  switch (kind) {
    case OmniFieldKind.uint32:
      return r.readUint32();
    case OmniFieldKind.uint64:
      return r.readVarint();
    case OmniFieldKind.sint32:
      return r.readSint32();
    case OmniFieldKind.sint64:
      return r.readSint();
    case OmniFieldKind.boolType:
      return r.readCollectionBool();
    case OmniFieldKind.fixed32:
      return r.readFixed32();
    case OmniFieldKind.fixed64:
      return r.readFixed64();
    case OmniFieldKind.sfixed32:
      return r.readSfixed32();
    case OmniFieldKind.sfixed64:
      return r.readSfixed64();
    case OmniFieldKind.float32:
      return r.readFloat32();
    case OmniFieldKind.float64:
      return r.readFloat64();
    case OmniFieldKind.string:
      return r.readString();
    case OmniFieldKind.bytes:
      return r.readBytes();
    case OmniFieldKind.message:
      final nextDepth = depth + 1;
      if (nextDepth > options.maxDepth) {
        throw OmniBufDepthLimitException(options.maxDepth);
      }
      final len = r.readCheckedLength();
      final subEnd = r.pos + len;
      final subReader = r.subReader(r.pos, subEnd);
      final schema = subSchema!();
      final obj = schema.create();
      schema._decodeBody(subReader, obj, nextDepth, options);
      r.pos = subEnd;
      return obj;
    case OmniFieldKind.repeated:
    case OmniFieldKind.map:
      throw OmniBufParseException('unsupported nested collection kind $kind');
  }
}

void _sortMapKeys(List<dynamic> keys, OmniFieldKind keyKind) {
  switch (keyKind) {
    case OmniFieldKind.string:
      keys.sort((a, b) => compareUtf8(a as String, b as String));
    case OmniFieldKind.uint32:
    case OmniFieldKind.uint64:
    case OmniFieldKind.fixed32:
    case OmniFieldKind.fixed64:
      keys.sort(
          (a, b) => compareUint64(_toInt(a as Object), _toInt(b as Object)));
    case OmniFieldKind.sint32:
    case OmniFieldKind.sint64:
    case OmniFieldKind.sfixed32:
    case OmniFieldKind.sfixed64:
      keys.sort((a, b) => _toInt(a as Object).compareTo(_toInt(b as Object)));
    case OmniFieldKind.boolType:
      keys.sort((a, b) => (a == true ? 1 : 0) - (b == true ? 1 : 0));
    default:
      break;
  }
}
