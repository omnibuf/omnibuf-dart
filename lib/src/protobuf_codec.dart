import 'dart:typed_data';

import 'package:fixnum/fixnum.dart' show Int64;
import 'package:protobuf/protobuf.dart';

import 'errors.dart';
import 'options.dart';
import 'schema_meta.dart';
import 'wire.dart';

// Public type bitmasks derived from package:protobuf's PbFieldType constants.
// Intersecting optional (O*) and repeated (P*) variants isolates the exact base type bit.
const int _pbBool = PbFieldType.OB & PbFieldType.PB;
const int _pbBytes = PbFieldType.OY & PbFieldType.PY;
const int _pbString = PbFieldType.OS & PbFieldType.PS;
const int _pbDouble = PbFieldType.OD & PbFieldType.PD;
const int _pbFloat = PbFieldType.OF & PbFieldType.PF;
const int _pbEnum = PbFieldType.OE & PbFieldType.PE;
const int _pbInt32 = PbFieldType.O3 & PbFieldType.P3;
const int _pbSint32 = PbFieldType.OS3 & PbFieldType.PS3;
const int _pbUint32 = PbFieldType.OU3 & PbFieldType.PU3;
const int _pbInt64 = PbFieldType.O6 & PbFieldType.P6;
const int _pbSint64 = PbFieldType.OS6 & PbFieldType.PS6;
const int _pbUint64 = PbFieldType.OU6 & PbFieldType.PU6;
const int _pbFixed32 = PbFieldType.OF3 & PbFieldType.PF3;
const int _pbFixed64 = PbFieldType.OF6 & PbFieldType.PF6;
const int _pbSfixed32 = PbFieldType.OSF3 & PbFieldType.PSF3;
const int _pbSfixed64 = PbFieldType.OSF6 & PbFieldType.PSF6;
const int _pbMessage = PbFieldType.OM & PbFieldType.PM;
const int _pbGroup = PbFieldType.OG & PbFieldType.PG;

const int _pbAllBaseMask = _pbBool |
    _pbBytes |
    _pbString |
    _pbDouble |
    _pbFloat |
    _pbEnum |
    _pbInt32 |
    _pbSint32 |
    _pbUint32 |
    _pbInt64 |
    _pbSint64 |
    _pbUint64 |
    _pbFixed32 |
    _pbFixed64 |
    _pbSfixed32 |
    _pbSfixed64 |
    _pbMessage |
    _pbGroup;

int _pbBaseType(int fieldType) => fieldType & _pbAllBaseMask;

/// Tier 2 codec: serializes and deserializes standard `package:protobuf`
/// [GeneratedMessage] instances directly via their [BuilderInfo] metadata.
///
/// Works with any `protoc --dart_out` generated message or dynamic
/// [GeneratedMessage] subclass with zero OmniBuf plugin dependency.
abstract final class ProtobufOmniBufCodec {
  /// Encodes a `package:protobuf` [GeneratedMessage] to OmniBuf wire bytes.
  static Uint8List encode(
    GeneratedMessage msg, {
    EncodeOptions options = EncodeOptions.defaults,
  }) {
    final w = OmniBufWriter(256);
    if (options.selfDescribing) {
      buildSchemaMeta(msg.info_).writeField0(w);
    }
    encodeInto(w, msg, options: options);
    return w.toBytes();
  }

  /// Appends [msg]'s fields into [w] without an outer length prefix.
  static void encodeInto(
    OmniBufWriter w,
    GeneratedMessage msg, {
    EncodeOptions options = EncodeOptions.defaults,
  }) {
    _encodeInto(w, msg, options, 0);
  }

  static void _encodeInto(
    OmniBufWriter w,
    GeneratedMessage msg,
    EncodeOptions options,
    int depth,
  ) {
    if (depth > DecodeOptions.defaultMaxDepth) {
      throw const OmniBufSerializeException(
        'message encoding depth exceeded limit of ${DecodeOptions.defaultMaxDepth}',
      );
    }
    final info = msg.info_;
    final sortedFields = info.byTagAsString.values.toList()
      ..sort((a, b) => a.tagNumber.compareTo(b.tagNumber));

    for (final fi in sortedFields) {
      final tag = fi.tagNumber;
      if (fi.isMapField) {
        final mfi = fi as MapFieldInfo<dynamic, dynamic>;
        final map = msg.getFieldOrNull(tag) as Map<dynamic, dynamic>?;
        if (map == null || map.isEmpty) continue;
        final kBase = _pbBaseType(mfi.keyFieldType);
        final vBase = _pbBaseType(mfi.valueFieldType);
        final kWt = _pbBaseToWireType(kBase);
        final vWt = _pbBaseToWireType(vBase);
        w.writeTag(tag, WireType.map);
        final slot = w.reserveLen2();
        w.writeByte(kWt);
        w.writeByte(vWt);
        final keys = map.keys.toList();
        if (options.deterministicMaps) {
          _sortPbMapKeys(keys, kBase);
        }
        w.writeVarint(keys.length);
        for (final k in keys) {
          _writePbCollectionValue(w, kBase, k, options, depth + 1);
          _writePbCollectionValue(w, vBase, map[k], options, depth + 1);
        }
        w.patchLen2(slot);
        continue;
      }

      if (fi.isRepeated) {
        final list = msg.getFieldOrNull(tag) as List<dynamic>?;
        if (list == null || list.isEmpty) continue;
        final baseType = _pbBaseType(fi.type);
        final elemWt = _pbBaseToWireType(baseType);
        w.writeTag(tag, WireType.array);
        final slot = w.reserveLen2();
        w.writeByte(elemWt);
        w.writeVarint(list.length);
        for (final item in list) {
          _writePbCollectionValue(w, baseType, item, options, depth + 1);
        }
        w.patchLen2(slot);
        continue;
      }

      final val = msg.getFieldOrNull(tag) as Object?;
      if (val == null) {
        if (_pbBaseType(fi.type) == _pbEnum &&
            msg.unknownFields.hasField(tag)) {
          final uf = msg.unknownFields.getField(tag)!;
          if (uf.varints.isNotEmpty) {
            w.writeTag(tag, WireType.sint);
            w.writeSint32(uf.varints.last.toInt());
          }
        }
        continue;
      }
      _writePbSingularField(w, fi, val, options, depth);
    }
  }

  /// Decodes OmniBuf wire bytes into [dst] (a `package:protobuf` [GeneratedMessage]).
  /// In replace mode (`options.merge == false`), calls `dst.clear()` first.
  static void decodeInto(
    Uint8List data,
    GeneratedMessage dst, {
    DecodeOptions options = DecodeOptions.defaults,
  }) {
    options.validatedMaxDepth();
    if (data.length > options.maxMessageBytes) {
      throw OmniBufAllocationLimitException(
        'packet size ${data.length} exceeds maxMessageBytes ${options.maxMessageBytes}',
      );
    }
    if (!options.merge) {
      dst.clear();
    }
    final budget = DecodeBudget(
      options.maxCollectionElements,
      maxAllocBytes: options.maxAllocBytes,
    );
    final r = OmniBufReader(data);
    _decodeBody(r, dst, 0, options, budget);
  }

  /// Builds Field #0 [SchemaMeta] from a `package:protobuf` [BuilderInfo].
  static SchemaMeta buildSchemaMeta(BuilderInfo info, {int maxDepth = 16}) {
    return _buildMeta(info, 0, maxDepth);
  }

  static SchemaMeta _buildMeta(BuilderInfo info, int depth, int maxDepth) {
    final fields = <int, String>{};
    final children = <int, SchemaMeta>{};
    for (final fi in info.byTagAsString.values) {
      fields[fi.tagNumber] = fi.protoName;
      if (depth + 2 <= maxDepth) {
        if (fi.isMapField) {
          final mfi = fi as MapFieldInfo<dynamic, dynamic>;
          if (mfi.valueCreator != null) {
            final sample = mfi.valueCreator!();
            children[fi.tagNumber] =
                _buildMeta(sample.info_, depth + 2, maxDepth);
          }
        } else if (fi.subBuilder != null) {
          final sample = fi.subBuilder!();
          children[fi.tagNumber] =
              _buildMeta(sample.info_, depth + 2, maxDepth);
        }
      }
    }
    return SchemaMeta(
      typeName: info.qualifiedMessageName,
      fields: fields,
      children: children,
    );
  }

  static void _decodeBody(
    OmniBufReader r,
    GeneratedMessage dst,
    int depth,
    DecodeOptions options,
    DecodeBudget budget,
  ) {
    final info = dst.info_;
    while (r.hasMore) {
      final tag = r.readTag();
      final fnum = tag >> 4;
      final wt = tag & 0x0F;
      if (fnum == 0) {
        validateField0SubMsg(
          r,
          depth,
          options.maxDepth,
          maxElements: options.maxCollectionElements,
          budget: budget,
        );
        continue;
      }
      final fi = info.fieldInfo[fnum];
      if (fi == null) {
        skipAndValidateValue(
          r,
          wt,
          depth,
          options.maxDepth,
          maxElements: options.maxCollectionElements,
          budget: budget,
        );
        continue;
      }
      if (fi.isMapField) {
        if (wt != WireType.map) {
          skipAndValidateValue(
            r,
            wt,
            depth,
            options.maxDepth,
            maxElements: options.maxCollectionElements,
            budget: budget,
          );
          continue;
        }
        final nextDepth = depth + 1;
        if (nextDepth > options.maxDepth) {
          throw OmniBufDepthLimitException(options.maxDepth);
        }
        final mfi = fi as MapFieldInfo<dynamic, dynamic>;
        final len = r.readCheckedLength();
        final bodyEnd = r.pos + len;
        final body = r.subReader(r.pos, bodyEnd);
        final (kWt, vWt, count) = body.readMapHeader(
          maxElements: options.maxCollectionElements,
        );
        budget.consume(count);
        final kBase = _pbBaseType(mfi.keyFieldType);
        final vBase = _pbBaseType(mfi.valueFieldType);
        final expKWt = _pbBaseToWireType(kBase);
        final expVWt = _pbBaseToWireType(vBase);
        if (kWt != expKWt || vWt != expVWt) {
          throw OmniBufTypeMismatchException(
            'protobuf map field ${fi.protoName} expects <$expKWt, $expVWt>, got <$kWt, $vWt>',
          );
        }
        final map = dst.getField(fnum) as Map<dynamic, dynamic>;
        final valValueOf =
            mfi.valueOf ?? mfi.mapEntryBuilderInfo.fieldInfo[2]?.valueOf;
        for (var i = 0; i < count; i++) {
          final k = _readPbCollectionValue(
            body,
            kBase,
            null,
            null,
            nextDepth,
            options,
            budget,
          );
          final v = _readPbCollectionValue(
            body,
            vBase,
            mfi.valueCreator,
            valValueOf,
            nextDepth,
            options,
            budget,
          );
          if (vBase == _pbEnum && valValueOf != null && v == null) {
            continue;
          }
          map[k] = v;
        }
        if (body.pos != bodyEnd) {
          throw const OmniBufParseException('WireMap trailing bytes');
        }
        r.pos = bodyEnd;
        continue;
      }

      if (fi.isRepeated) {
        if (wt != WireType.array) {
          skipAndValidateValue(
            r,
            wt,
            depth,
            options.maxDepth,
            maxElements: options.maxCollectionElements,
            budget: budget,
          );
          continue;
        }
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
        budget.consume(count);
        final baseType = _pbBaseType(fi.type);
        final expWt = _pbBaseToWireType(baseType);
        if (elemWt != expWt) {
          throw OmniBufTypeMismatchException(
            'protobuf repeated field ${fi.protoName} expects ElementType $expWt, got $elemWt',
          );
        }
        final list = dst.getField(fnum) as List<dynamic>;
        for (var i = 0; i < count; i++) {
          final v = _readPbCollectionValue(
            body,
            baseType,
            fi.subBuilder,
            fi.valueOf,
            nextDepth,
            options,
            budget,
          );
          if (baseType == _pbEnum && fi.valueOf != null && v == null) {
            continue;
          }
          list.add(v);
        }
        if (body.pos != bodyEnd) {
          throw const OmniBufParseException('WireArray trailing bytes');
        }
        r.pos = bodyEnd;
        continue;
      }

      final baseType = _pbBaseType(fi.type);
      if (!_matchesPbTagWireType(baseType, wt)) {
        skipAndValidateValue(
          r,
          wt,
          depth,
          options.maxDepth,
          maxElements: options.maxCollectionElements,
          budget: budget,
        );
        continue;
      }
      _readPbSingularField(r, dst, fi, baseType, wt, depth, options, budget);
    }
  }

  static void _writePbSingularField(
    OmniBufWriter w,
    FieldInfo<dynamic> fi,
    Object val,
    EncodeOptions options,
    int depth,
  ) {
    final tag = fi.tagNumber;
    final base = _pbBaseType(fi.type);
    if (base == _pbBool) {
      final b = val as bool;
      w.writeTag(tag, b ? WireType.boolTrue : WireType.boolFalse);
    } else if (base == _pbBytes) {
      final raw = val is Uint8List ? val : Uint8List.fromList(val as List<int>);
      w.writeTag(tag, WireType.bytes);
      w.writeBytes(raw);
    } else if (base == _pbString) {
      w.writeTag(tag, WireType.string);
      w.writeString(val as String);
    } else if (base == _pbDouble) {
      w.writeTag(tag, WireType.float64);
      w.writeFloat64((val as num).toDouble());
    } else if (base == _pbFloat) {
      w.writeTag(tag, WireType.float32);
      w.writeFloat32((val as num).toDouble());
    } else if (base == _pbEnum) {
      final e = val as ProtobufEnum;
      w.writeTag(tag, WireType.sint);
      w.writeSint32(e.value);
    } else if (base == _pbInt32 || base == _pbSint32) {
      w.writeTag(tag, WireType.sint);
      w.writeSint32(val as int);
    } else if (base == _pbUint32) {
      w.writeTag(tag, WireType.uint);
      w.writeVarint((val as int) & 0xFFFFFFFF);
    } else if (base == _pbInt64 || base == _pbSint64) {
      w.writeTag(tag, WireType.sint);
      w.writeSint((val as Int64).toInt());
    } else if (base == _pbUint64) {
      w.writeTag(tag, WireType.uint);
      w.writeVarint((val as Int64).toInt());
    } else if (base == _pbFixed32) {
      w.writeTag(tag, WireType.fixed32);
      w.writeFixed32((val as int) & 0xFFFFFFFF);
    } else if (base == _pbFixed64) {
      w.writeTag(tag, WireType.fixed64);
      w.writeFixed64((val as Int64).toInt());
    } else if (base == _pbSfixed32) {
      w.writeTag(tag, WireType.sfixed32);
      w.writeSfixed32((val as int).toSigned(32));
    } else if (base == _pbSfixed64) {
      w.writeTag(tag, WireType.sfixed64);
      w.writeSfixed64((val as Int64).toInt());
    } else if (base == _pbMessage || base == _pbGroup) {
      w.writeTag(tag, WireType.subMsg);
      final slot = w.reserveLen2();
      _encodeInto(w, val as GeneratedMessage, options, depth + 1);
      w.patchLen2(slot);
    } else {
      throw OmniBufSerializeException(
        'unsupported protobuf field type ${fi.type} on ${fi.protoName}',
      );
    }
  }

  static void _clearOneofUnknownEnums(GeneratedMessage dst, int tag) {
    final oneofIndex = dst.info_.oneofs[tag];
    if (oneofIndex == null) return;
    for (final entry in dst.info_.oneofs.entries) {
      if (entry.value == oneofIndex && dst.unknownFields.hasField(entry.key)) {
        dst.unknownFields.clearField(entry.key);
      }
    }
  }

  static void _clearOneofFields(GeneratedMessage dst, int tag) {
    final oneofIndex = dst.info_.oneofs[tag];
    if (oneofIndex == null) {
      dst.clearField(tag);
      return;
    }
    for (final entry in dst.info_.oneofs.entries) {
      if (entry.value == oneofIndex) {
        dst.clearField(entry.key);
        if (dst.unknownFields.hasField(entry.key)) {
          dst.unknownFields.clearField(entry.key);
        }
      }
    }
  }

  static void _readPbSingularField(
    OmniBufReader r,
    GeneratedMessage dst,
    FieldInfo<dynamic> fi,
    int base,
    int wt,
    int depth,
    DecodeOptions options,
    DecodeBudget budget,
  ) {
    final tag = fi.tagNumber;
    if (base == _pbEnum) {
      final raw = r.readSint32();
      final ev = fi.valueOf?.call(raw);
      if (ev != null) {
        _clearOneofUnknownEnums(dst, tag);
        dst.setField(tag, ev);
        if (dst.unknownFields.hasField(tag)) {
          dst.unknownFields.clearField(tag);
        }
      } else {
        _clearOneofFields(dst, tag);
        dst.unknownFields.clearField(tag);
        dst.unknownFields.mergeVarintField(tag, Int64(raw));
      }
      return;
    }
    _clearOneofUnknownEnums(dst, tag);
    if (base == _pbBool) {
      dst.setField(tag, wt == WireType.boolTrue);
    } else if (base == _pbBytes) {
      dst.setField(tag, r.readBytes(budget: budget));
    } else if (base == _pbString) {
      dst.setField(tag, r.readString(budget: budget));
    } else if (base == _pbDouble) {
      dst.setField(tag, r.readFloat64());
    } else if (base == _pbFloat) {
      dst.setField(tag, r.readFloat32());
    } else if (base == _pbInt32 || base == _pbSint32) {
      dst.setField(tag, r.readSint32());
    } else if (base == _pbUint32) {
      dst.setField(tag, r.readUint32());
    } else if (base == _pbInt64 || base == _pbSint64) {
      dst.setField(tag, Int64(r.readSint()));
    } else if (base == _pbUint64) {
      dst.setField(tag, Int64(r.readVarint()));
    } else if (base == _pbFixed32) {
      dst.setField(tag, r.readFixed32());
    } else if (base == _pbFixed64) {
      dst.setField(tag, Int64(r.readFixed64()));
    } else if (base == _pbSfixed32) {
      dst.setField(tag, r.readSfixed32());
    } else if (base == _pbSfixed64) {
      dst.setField(tag, Int64(r.readSfixed64()));
    } else if (base == _pbMessage || base == _pbGroup) {
      final nextDepth = depth + 1;
      if (nextDepth > options.maxDepth) {
        throw OmniBufDepthLimitException(options.maxDepth);
      }
      final len = r.readCheckedLength();
      final subEnd = r.pos + len;
      final subReader = r.subReader(r.pos, subEnd);
      GeneratedMessage subMsg;
      if (dst.hasField(tag)) {
        subMsg = dst.getField(tag) as GeneratedMessage;
      } else {
        subMsg = fi.subBuilder!();
        dst.setField(tag, subMsg);
      }
      _decodeBody(subReader, subMsg, nextDepth, options, budget);
      r.pos = subEnd;
    } else {
      throw OmniBufParseException(
        'unsupported protobuf field type ${fi.type} on ${fi.protoName}',
      );
    }
  }

  static void _writePbCollectionValue(
    OmniBufWriter w,
    int base,
    Object? val,
    EncodeOptions options,
    int depth,
  ) {
    if (base == _pbBool) {
      w.writeByte(val == true ? 1 : 0);
    } else if (base == _pbBytes) {
      final raw = val is Uint8List ? val : Uint8List.fromList(val as List<int>);
      w.writeBytes(raw);
    } else if (base == _pbString) {
      w.writeString(val as String);
    } else if (base == _pbDouble) {
      w.writeFloat64((val as num).toDouble());
    } else if (base == _pbFloat) {
      w.writeFloat32((val as num).toDouble());
    } else if (base == _pbEnum) {
      w.writeSint32((val as ProtobufEnum).value);
    } else if (base == _pbInt32 || base == _pbSint32) {
      w.writeSint32(val as int);
    } else if (base == _pbUint32) {
      w.writeVarint((val as int) & 0xFFFFFFFF);
    } else if (base == _pbInt64 || base == _pbSint64) {
      w.writeSint((val as Int64).toInt());
    } else if (base == _pbUint64) {
      w.writeVarint((val as Int64).toInt());
    } else if (base == _pbFixed32) {
      w.writeFixed32((val as int) & 0xFFFFFFFF);
    } else if (base == _pbFixed64) {
      w.writeFixed64((val as Int64).toInt());
    } else if (base == _pbSfixed32) {
      w.writeSfixed32((val as int).toSigned(32));
    } else if (base == _pbSfixed64) {
      w.writeSfixed64((val as Int64).toInt());
    } else if (base == _pbMessage || base == _pbGroup) {
      final slot = w.reserveLen2();
      if (val != null) {
        _encodeInto(w, val as GeneratedMessage, options, depth + 1);
      }
      w.patchLen2(slot);
    } else {
      throw OmniBufSerializeException(
        'unsupported protobuf collection type $base',
      );
    }
  }

  static Object? _readPbCollectionValue(
    OmniBufReader r,
    int base,
    CreateBuilderFunc? subBuilder,
    ValueOfFunc? valueOf,
    int depth,
    DecodeOptions options,
    DecodeBudget budget,
  ) {
    if (base == _pbBool) {
      return r.readCollectionBool();
    } else if (base == _pbBytes) {
      return r.readBytes(budget: budget);
    } else if (base == _pbString) {
      return r.readString(budget: budget);
    } else if (base == _pbDouble) {
      return r.readFloat64();
    } else if (base == _pbFloat) {
      return r.readFloat32();
    } else if (base == _pbEnum) {
      final raw = r.readSint32();
      if (valueOf != null) {
        return valueOf(raw);
      }
      return raw;
    } else if (base == _pbInt32 || base == _pbSint32) {
      return r.readSint32();
    } else if (base == _pbUint32) {
      return r.readUint32();
    } else if (base == _pbInt64 || base == _pbSint64) {
      return Int64(r.readSint());
    } else if (base == _pbUint64) {
      return Int64(r.readVarint());
    } else if (base == _pbFixed32) {
      return r.readFixed32();
    } else if (base == _pbFixed64) {
      return Int64(r.readFixed64());
    } else if (base == _pbSfixed32) {
      return r.readSfixed32();
    } else if (base == _pbSfixed64) {
      return Int64(r.readSfixed64());
    } else if (base == _pbMessage || base == _pbGroup) {
      final nextDepth = depth + 1;
      if (nextDepth > options.maxDepth) {
        throw OmniBufDepthLimitException(options.maxDepth);
      }
      final len = r.readCheckedLength();
      final subEnd = r.pos + len;
      final subReader = r.subReader(r.pos, subEnd);
      final subMsg = subBuilder!();
      _decodeBody(subReader, subMsg, nextDepth, options, budget);
      r.pos = subEnd;
      return subMsg;
    }
    throw OmniBufParseException('unsupported protobuf collection type $base');
  }

  static void _sortPbMapKeys(List<dynamic> keys, int keyBase) {
    if (keyBase == _pbString) {
      keys.sort((a, b) => compareUtf8(a as String, b as String));
    } else if (keyBase == _pbBool) {
      keys.sort((a, b) => (a == true ? 1 : 0) - (b == true ? 1 : 0));
    } else if (keyBase == _pbUint64 || keyBase == _pbFixed64) {
      keys.sort(
        (a, b) => compareUint64((a as Int64).toInt(), (b as Int64).toInt()),
      );
    } else if (keyBase == _pbUint32 || keyBase == _pbFixed32) {
      keys.sort(
        (a, b) =>
            compareUint64((a as int) & 0xFFFFFFFF, (b as int) & 0xFFFFFFFF),
      );
    } else if (keyBase == _pbInt64 ||
        keyBase == _pbSint64 ||
        keyBase == _pbSfixed64) {
      keys.sort((a, b) => (a as Int64).compareTo(b as Int64));
    } else {
      keys.sort(
        (a, b) => (a as int).toSigned(32).compareTo((b as int).toSigned(32)),
      );
    }
  }
}

int _pbBaseToWireType(int base) {
  if (base == _pbBool) return WireType.boolFalse;
  if (base == _pbBytes) return WireType.bytes;
  if (base == _pbString) return WireType.string;
  if (base == _pbDouble) return WireType.float64;
  if (base == _pbFloat) return WireType.float32;
  if (base == _pbEnum ||
      base == _pbInt32 ||
      base == _pbSint32 ||
      base == _pbInt64 ||
      base == _pbSint64) {
    return WireType.sint;
  }
  if (base == _pbUint32 || base == _pbUint64) return WireType.uint;
  if (base == _pbFixed32) return WireType.fixed32;
  if (base == _pbFixed64) return WireType.fixed64;
  if (base == _pbSfixed32) return WireType.sfixed32;
  if (base == _pbSfixed64) return WireType.sfixed64;
  if (base == _pbMessage || base == _pbGroup) return WireType.subMsg;
  throw OmniBufParseException('unsupported protobuf base type $base');
}

bool _matchesPbTagWireType(int base, int wt) {
  if (base == _pbBool) {
    return wt == WireType.boolFalse || wt == WireType.boolTrue;
  }
  return wt == _pbBaseToWireType(base);
}
