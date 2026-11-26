import 'dart:convert';
import 'dart:typed_data';

/// Minimal self-contained Protobuf binary decoder/encoder for
/// `google.protobuf.compiler.CodeGeneratorRequest`,
/// `google.protobuf.compiler.CodeGeneratorResponse`, and
/// `google.protobuf.FileDescriptorSet`.
///
/// Allows `protoc-gen-omnibuf-dart` and `FileDescriptorSet`-backed codecs to
/// parse descriptors without requiring generated descriptor stubs.

/// Protobuf `google.protobuf.Edition` enum constants.
abstract final class ProtoEdition {
  static const int unknown = 0;
  static const int proto2 = 998;
  static const int proto3 = 999;
  static const int edition2023 = 1000;
  static const int edition2024 = 1001;
  static const int edition2026 = 1002;
}

/// Protobuf `google.protobuf.FeatureSet` field numbers and enum values.
abstract final class ProtoFeature {
  static const int fieldPresence = 1;
  static const int enumType = 2;
  static const int repeatedFieldEncoding = 3;
  static const int utf8Validation = 4;
  static const int messageEncoding = 5;
  static const int jsonFormat = 6;
  static const int enforceNamingStyle = 7;
  static const int defaultSymbolVisibility = 8;
  static const int enforceProtoLimits = 9;

  static const int fieldPresenceExplicit = 1;
  static const int fieldPresenceImplicit = 2;
  static const int fieldPresenceLegacyRequired = 3;

  static const int enumTypeOpen = 1;
  static const int enumTypeClosed = 2;

  static const int repeatedFieldEncodingPacked = 1;
  static const int repeatedFieldEncodingExpanded = 2;

  static const int utf8ValidationVerify = 2;
  static const int utf8ValidationNone = 3;

  static const int messageEncodingLengthPrefixed = 1;
  static const int messageEncodingDelimited = 2;

  static const int jsonFormatAllow = 1;
  static const int jsonFormatLegacyBestEffort = 2;
}

const Map<int, int> _editionsDefaultFeatures = <int, int>{
  ProtoFeature.fieldPresence: ProtoFeature.fieldPresenceExplicit,
  ProtoFeature.enumType: ProtoFeature.enumTypeOpen,
  ProtoFeature.repeatedFieldEncoding: ProtoFeature.repeatedFieldEncodingPacked,
  ProtoFeature.utf8Validation: ProtoFeature.utf8ValidationVerify,
  ProtoFeature.messageEncoding: ProtoFeature.messageEncodingLengthPrefixed,
  ProtoFeature.jsonFormat: ProtoFeature.jsonFormatAllow,
};

const Set<String> _optionExtendees = <String>{
  '.google.protobuf.FileOptions',
  '.google.protobuf.MessageOptions',
  '.google.protobuf.FieldOptions',
  '.google.protobuf.OneofOptions',
  '.google.protobuf.EnumOptions',
  '.google.protobuf.EnumValueOptions',
  '.google.protobuf.ServiceOptions',
  '.google.protobuf.MethodOptions',
  '.google.protobuf.ExtensionRangeOptions',
  '.google.protobuf.FeatureSet',
};

class ProtoFileDescriptor {
  String syntax = '';
  int edition = 0;
  Map<int, int> features = <int, int>{};
  String name = '';
  String packageName = '';
  final List<String> dependencies = <String>[];
  final List<ProtoMessageDescriptor> messages = <ProtoMessageDescriptor>[];
  final List<ProtoEnumDescriptor> enums = <ProtoEnumDescriptor>[];
  final List<ProtoFieldDescriptor> extensions = <ProtoFieldDescriptor>[];
}

class ProtoMessageDescriptor {
  Map<int, int> features = <int, int>{};
  String name = '';
  final List<ProtoFieldDescriptor> fields = <ProtoFieldDescriptor>[];
  final List<ProtoFieldDescriptor> extensions = <ProtoFieldDescriptor>[];
  final List<(int, int)> extensionRanges = <(int, int)>[];
  final List<ProtoMessageDescriptor> nestedTypes = <ProtoMessageDescriptor>[];
  final List<ProtoEnumDescriptor> enumTypes = <ProtoEnumDescriptor>[];
  final List<ProtoOneofDescriptor> oneofs = <ProtoOneofDescriptor>[];
  bool isMapEntry = false;
}

class ProtoOneofDescriptor {
  String name = '';
  Map<int, int> features = <int, int>{};
}

class ProtoFieldDescriptor {
  bool explicitPresence = false;
  bool isDelimitedMessage = false;
  bool proto3Optional = false;
  int? oneofIndex;
  Map<int, int> features = <int, int>{};
  String name = '';
  String extendee = '';
  String? defaultValue;
  int number = 0;
  int label = 1; // 1=OPTIONAL, 2=REQUIRED, 3=REPEATED
  int type = 0; // google.protobuf.FieldDescriptorProto.Type
  String typeName = '';
  String jsonName = '';

  /// Whether this field belongs to a real (non-synthetic) `oneof`.
  bool get isRealOneof => oneofIndex != null && !proto3Optional;
}

class ProtoEnumDescriptor {
  Map<int, int> features = <int, int>{};
  String name = '';
  final List<(String, int)> values = <(String, int)>[];
}

class CodeGeneratorRequest {
  final List<String> fileToGenerate = <String>[];
  String parameter = '';
  final List<ProtoFileDescriptor> protoFiles = <ProtoFileDescriptor>[];

  static CodeGeneratorRequest decode(Uint8List bytes) {
    final req = CodeGeneratorRequest();
    final r = _PbReader(bytes);
    while (r.hasMore) {
      final tag = r.readVarint();
      final fnum = tag >> 3;
      final wt = tag & 7;
      switch (fnum) {
        case 1: // file_to_generate
          req.fileToGenerate.add(r.readString());
        case 2: // parameter
          req.parameter = r.readString();
        case 15: // proto_file
          req.protoFiles.add(_decodeFileDescriptor(r.readBytes()));
        default:
          r.skip(wt);
      }
    }
    return req;
  }
}

class CodeGeneratorResponseFile {
  final String name;
  final String content;
  const CodeGeneratorResponseFile({required this.name, required this.content});
}

class CodeGeneratorResponse {
  String error = '';
  int supportedFeatures = 3; // PROTO3_OPTIONAL | SUPPORTS_EDITIONS
  int minimumEdition = ProtoEdition.edition2023;
  int maximumEdition = ProtoEdition.edition2026;
  final List<CodeGeneratorResponseFile> files = <CodeGeneratorResponseFile>[];

  Uint8List encode() {
    final w = _PbWriter();
    if (error.isNotEmpty) {
      w.writeString(1, error);
    }
    if (supportedFeatures != 0) {
      w.writeVarintField(2, supportedFeatures);
    }
    if ((supportedFeatures & 2) != 0) {
      w.writeVarintField(3, minimumEdition);
      w.writeVarintField(4, maximumEdition);
    }
    for (final f in files) {
      final fw = _PbWriter();
      fw.writeString(1, f.name);
      fw.writeString(15, f.content);
      w.writeBytes(15, fw.toBytes());
    }
    return w.toBytes();
  }
}

/// Decodes a `google.protobuf.FileDescriptorSet` binary blob.
List<ProtoFileDescriptor> decodeFileDescriptorSet(Uint8List bytes) {
  final files = <ProtoFileDescriptor>[];
  final r = _PbReader(bytes);
  while (r.hasMore) {
    final tag = r.readVarint();
    final fnum = tag >> 3;
    final wt = tag & 7;
    if (fnum == 1 && wt == 2) {
      files.add(_decodeFileDescriptor(r.readBytes()));
    } else {
      r.skip(wt);
    }
  }
  return files;
}

ProtoFileDescriptor _decodeFileDescriptor(Uint8List bytes) {
  final fd = ProtoFileDescriptor();
  final r = _PbReader(bytes);
  while (r.hasMore) {
    final tag = r.readVarint();
    final fnum = tag >> 3;
    final wt = tag & 7;
    switch (fnum) {
      case 1:
        fd.name = r.readString();
      case 2:
        fd.packageName = r.readString();
      case 3:
        fd.dependencies.add(r.readString());
      case 4:
        fd.messages.add(_decodeMessageDescriptor(r.readBytes()));
      case 5:
        fd.enums.add(_decodeEnumDescriptor(r.readBytes()));
      case 7:
        fd.extensions.add(_decodeFieldDescriptor(r.readBytes()));
      case 8:
        fd.features = _features(r.readBytes(), 50);
      case 12:
        fd.syntax = r.readString();
      case 14:
        fd.edition = r.readVarint();
      default:
        r.skip(wt);
    }
  }
  return fd;
}

ProtoMessageDescriptor _decodeMessageDescriptor(Uint8List bytes) {
  final md = ProtoMessageDescriptor();
  final r = _PbReader(bytes);
  while (r.hasMore) {
    final tag = r.readVarint();
    final fnum = tag >> 3;
    final wt = tag & 7;
    switch (fnum) {
      case 1:
        md.name = r.readString();
      case 2:
        md.fields.add(_decodeFieldDescriptor(r.readBytes()));
      case 3:
        md.nestedTypes.add(_decodeMessageDescriptor(r.readBytes()));
      case 4:
        md.enumTypes.add(_decodeEnumDescriptor(r.readBytes()));
      case 5: // extension_range
        md.extensionRanges.add(_decodeExtensionRange(r.readBytes()));
      case 6: // extension
        md.extensions.add(_decodeFieldDescriptor(r.readBytes()));
      case 7: // options (MessageOptions)
        final optBytes = r.readBytes();
        md.features = _features(optBytes, 12);
        final or = _PbReader(optBytes);
        while (or.hasMore) {
          final oTag = or.readVarint();
          final oNum = oTag >> 3;
          final oWt = oTag & 7;
          if (oNum == 7 && oWt == 0) {
            md.isMapEntry = or.readVarint() != 0;
          } else {
            or.skip(oWt);
          }
        }
      case 8: // oneof_decl
        md.oneofs.add(_decodeOneofDescriptor(r.readBytes()));
      default:
        r.skip(wt);
    }
  }
  return md;
}

(int, int) _decodeExtensionRange(Uint8List bytes) {
  var start = 0;
  var end = 0;
  final r = _PbReader(bytes);
  while (r.hasMore) {
    final tag = r.readVarint();
    final fnum = tag >> 3;
    final wt = tag & 7;
    switch (fnum) {
      case 1:
        start = r.readVarint().toSigned(32);
      case 2:
        end = r.readVarint().toSigned(32);
      default:
        r.skip(wt);
    }
  }
  return (start, end);
}

ProtoOneofDescriptor _decodeOneofDescriptor(Uint8List bytes) {
  final od = ProtoOneofDescriptor();
  final r = _PbReader(bytes);
  while (r.hasMore) {
    final tag = r.readVarint();
    final fnum = tag >> 3;
    final wt = tag & 7;
    switch (fnum) {
      case 1:
        od.name = r.readString();
      case 2: // OneofOptions -> features is field #1
        od.features = _features(r.readBytes(), 1);
      default:
        r.skip(wt);
    }
  }
  return od;
}

ProtoFieldDescriptor _decodeFieldDescriptor(Uint8List bytes) {
  final f = ProtoFieldDescriptor();
  final r = _PbReader(bytes);
  while (r.hasMore) {
    final tag = r.readVarint();
    final fnum = tag >> 3;
    final wt = tag & 7;
    switch (fnum) {
      case 1:
        f.name = r.readString();
      case 2:
        f.extendee = r.readString();
      case 3:
        f.number = r.readVarint();
      case 4:
        f.label = r.readVarint();
      case 5:
        f.type = r.readVarint();
      case 6:
        f.typeName = r.readString();
      case 7:
        f.defaultValue = r.readString();
      case 8:
        f.features = _features(r.readBytes(), 21);
      case 9:
        f.oneofIndex = r.readVarint();
      case 10:
        f.jsonName = r.readString();
      case 17:
        f.proto3Optional = r.readVarint() != 0;
      default:
        r.skip(wt);
    }
  }
  return f;
}

ProtoEnumDescriptor _decodeEnumDescriptor(Uint8List bytes) {
  final ed = ProtoEnumDescriptor();
  final r = _PbReader(bytes);
  while (r.hasMore) {
    final tag = r.readVarint();
    final fnum = tag >> 3;
    final wt = tag & 7;
    switch (fnum) {
      case 1:
        ed.name = r.readString();
      case 2:
        final vr = _PbReader(r.readBytes());
        var vName = '';
        var vNum = 0;
        while (vr.hasMore) {
          final vTag = vr.readVarint();
          final vFnum = vTag >> 3;
          final vWt = vTag & 7;
          if (vFnum == 1) {
            vName = vr.readString();
          } else if (vFnum == 2) {
            vNum = vr.readVarint().toSigned(32);
          } else {
            vr.skip(vWt);
          }
        }
        ed.values.add((vName, vNum));
      case 3:
        ed.features = _features(r.readBytes(), 7);
      default:
        r.skip(wt);
    }
  }
  return ed;
}

class _PbReader {
  final Uint8List buf;
  int pos = 0;

  _PbReader(this.buf);

  bool get hasMore => pos < buf.length;

  int readVarint() {
    var result = 0;
    var shift = 0;
    while (pos < buf.length) {
      if (shift >= 64) {
        throw const FormatException('protobuf varint overflow');
      }
      final b = buf[pos++];
      result |= (b & 0x7F) << shift;
      if ((b & 0x80) == 0) return result;
      shift += 7;
    }
    throw const FormatException('truncated protobuf varint');
  }

  Uint8List readBytes() {
    final len = readVarint();
    if (len < 0 || len > buf.length - pos) {
      throw const FormatException('protobuf length exceeds buffer bounds');
    }
    final end = pos + len;
    final slice = Uint8List.sublistView(buf, pos, end);
    pos = end;
    return slice;
  }

  String readString() => utf8.decode(readBytes());

  void skip(int wt) {
    switch (wt) {
      case 0:
        readVarint();
      case 1:
        if (8 > buf.length - pos) {
          throw const FormatException('truncated protobuf fixed64');
        }
        pos += 8;
      case 2:
        final len = readVarint();
        if (len < 0 || len > buf.length - pos) {
          throw const FormatException('protobuf length exceeds buffer bounds');
        }
        pos += len;
      case 5:
        if (4 > buf.length - pos) {
          throw const FormatException('truncated protobuf fixed32');
        }
        pos += 4;
      default:
        throw FormatException('unsupported protobuf wire type $wt');
    }
  }
}

class _PbWriter {
  final BytesBuilder _b = BytesBuilder(copy: false);

  void _writeVarint(int v) {
    var u = v;
    while (true) {
      if ((u & ~0x7F) == 0) {
        _b.addByte(u);
        return;
      }
      _b.addByte((u & 0x7F) | 0x80);
      u >>>= 7;
    }
  }

  void writeVarintField(int fieldNumber, int v) {
    _writeVarint((fieldNumber << 3) | 0);
    _writeVarint(v);
  }

  void writeBytes(int fieldNumber, Uint8List data) {
    _writeVarint((fieldNumber << 3) | 2);
    _writeVarint(data.length);
    _b.add(data);
  }

  void writeString(int fieldNumber, String s) {
    final bytes = Uint8List.fromList(utf8.encode(s));
    writeBytes(fieldNumber, bytes);
  }

  Uint8List toBytes() => _b.takeBytes();
}

Map<int, int> _features(Uint8List bytes, int option) {
  final result = <int, int>{};
  final r = _PbReader(bytes);
  while (r.hasMore) {
    final tag = r.readVarint();
    if (tag >> 3 == option && tag & 7 == 2) {
      final f = _PbReader(r.readBytes());
      while (f.hasMore) {
        final ft = f.readVarint();
        if (ft & 7 == 0) {
          final v = f.readVarint();
          if (v != 0) {
            result[ft >> 3] = v;
          }
        } else {
          f.skip(ft & 7);
        }
      }
    } else {
      r.skip(tag & 7);
    }
  }
  return result;
}

Map<int, int> _mergeFeatures(Map<int, int> parent, Map<int, int> child) {
  final merged = Map<int, int>.of(parent);
  for (final e in child.entries) {
    if (e.value != 0) {
      merged[e.key] = e.value;
    }
  }
  return merged;
}

String _normalizeFqn(String fqn) => fqn.startsWith('.') ? fqn : '.$fqn';

bool _isOptionExtendee(String extendee) {
  if (extendee.isEmpty) return false;
  return _optionExtendees.contains(_normalizeFqn(extendee));
}

bool _isEditionsFile(ProtoFileDescriptor file) =>
    file.syntax == 'editions' ||
    (file.edition != 0 && file.syntax != 'proto2' && file.syntax != 'proto3');

/// Collects whether each fully-qualified enum across [files] has CLOSED
/// semantics (`proto2` enums or Editions enums with `enum_type = CLOSED`).
Map<String, bool> collectEnumClosedMap(List<ProtoFileDescriptor> files) {
  final closed = <String, bool>{};
  for (final file in files) {
    final pkgScope = file.packageName.isEmpty ? '' : '.${file.packageName}';
    final isEditions = _isEditionsFile(file);
    final fileBase = isEditions
        ? _mergeFeatures(_editionsDefaultFeatures, file.features)
        : const <int, int>{};

    void recordEnum(ProtoEnumDescriptor e, String scope, Map<int, int> parent) {
      final fqn = '$scope.${e.name}';
      if (isEditions) {
        final resolved = _mergeFeatures(parent, e.features);
        closed[fqn] =
            resolved[ProtoFeature.enumType] != ProtoFeature.enumTypeOpen;
      } else {
        closed[fqn] = file.syntax == 'proto2' || file.syntax.isEmpty;
      }
    }

    void walkMsg(ProtoMessageDescriptor m, String scope, Map<int, int> parent) {
      final fqn = '$scope.${m.name}';
      final features =
          isEditions ? _mergeFeatures(parent, m.features) : const <int, int>{};
      for (final e in m.enumTypes) {
        recordEnum(e, fqn, features);
      }
      for (final n in m.nestedTypes) {
        walkMsg(n, fqn, features);
      }
    }

    for (final e in file.enums) {
      recordEnum(e, pkgScope, fileBase);
    }
    for (final m in file.messages) {
      walkMsg(m, pkgScope, fileBase);
    }
  }
  return closed;
}

/// Collects enum value name-to-number maps across [files] for validating
/// explicit `[default = ...]` enum defaults.
Map<String, Map<String, int>> collectEnumValuesMap(
  List<ProtoFileDescriptor> files,
) {
  final out = <String, Map<String, int>>{};
  for (final file in files) {
    final pkgScope = file.packageName.isEmpty ? '' : '.${file.packageName}';

    void recordEnum(ProtoEnumDescriptor e, String scope) {
      final fqn = '$scope.${e.name}';
      out[fqn] = <String, int>{
        for (final (vName, vNum) in e.values) vName: vNum,
      };
    }

    void walkMsg(ProtoMessageDescriptor m, String scope) {
      final fqn = '$scope.${m.name}';
      for (final e in m.enumTypes) {
        recordEnum(e, fqn);
      }
      for (final n in m.nestedTypes) {
        walkMsg(n, fqn);
      }
    }

    for (final e in file.enums) {
      recordEnum(e, pkgScope);
    }
    for (final m in file.messages) {
      walkMsg(m, pkgScope);
    }
  }
  return out;
}

bool _isZeroDefault(
  ProtoFieldDescriptor f,
  Map<String, Map<String, int>> enumValues,
) {
  final dv = f.defaultValue;
  if (dv == null) return true;
  switch (f.type) {
    case 8: // TYPE_BOOL
      return dv == 'false';
    case 9: // TYPE_STRING
    case 12: // TYPE_BYTES
      return dv.isEmpty;
    case 1: // TYPE_DOUBLE
    case 2: // TYPE_FLOAT
      final parsed = double.tryParse(dv);
      return parsed != null && parsed == 0.0 && !parsed.isNegative;
    case 3: // TYPE_INT64
    case 4: // TYPE_UINT64
    case 5: // TYPE_INT32
    case 6: // TYPE_FIXED64
    case 7: // TYPE_FIXED32
    case 13: // TYPE_UINT32
    case 15: // TYPE_SFIXED32
    case 16: // TYPE_SFIXED64
    case 17: // TYPE_SINT32
    case 18: // TYPE_SINT64
      return int.tryParse(dv) == 0;
    case 14: // TYPE_ENUM
      final numeric = int.tryParse(dv);
      if (numeric != null) return numeric == 0;
      final byName = enumValues[_normalizeFqn(f.typeName)];
      if (byName != null && byName.containsKey(dv)) {
        return byName[dv] == 0;
      }
      return false;
    default:
      return false;
  }
}

/// Validates and resolves Protobuf Editions 2023/2024/2026 (and proto2/proto3)
/// features on [file] without destroying `file.syntax`, `file.edition`, or
/// raw `FieldDescriptorProto.type`. Safe to call multiple times (idempotent).
void resolveEditions(
  ProtoFileDescriptor file, {
  Map<String, bool>? closedEnums,
  Map<String, Map<String, int>>? enumValues,
}) {
  if (!_isEditionsFile(file)) {
    void visitLegacy(ProtoMessageDescriptor m) {
      for (final f in m.fields) {
        if (f.type == 10) {
          throw FormatException(
            'omnibuf: proto2 groups are not supported (${f.name})',
          );
        }
        f.isDelimitedMessage = false;
        if (m.isMapEntry || f.label == 3 || f.type == 11) {
          f.explicitPresence = false;
        } else if (f.isRealOneof) {
          f.explicitPresence = true;
        } else if (file.syntax == 'proto2') {
          f.explicitPresence = true;
        } else {
          f.explicitPresence = f.proto3Optional;
        }
      }
      for (final n in m.nestedTypes) {
        visitLegacy(n);
      }
    }

    for (final m in file.messages) {
      visitLegacy(m);
    }
    return;
  }

  if (file.edition != ProtoEdition.edition2023 &&
      file.edition != ProtoEdition.edition2024 &&
      file.edition != ProtoEdition.edition2026) {
    throw FormatException(
      'omnibuf: unsupported protobuf edition ${file.edition}',
    );
  }

  for (final ext in file.extensions) {
    if (!_isOptionExtendee(ext.extendee)) {
      throw FormatException(
        'omnibuf: editions extensions are not supported (${ext.name})',
      );
    }
  }

  final closedMap =
      closedEnums ?? collectEnumClosedMap(<ProtoFileDescriptor>[file]);
  final enumVals =
      enumValues ?? collectEnumValuesMap(<ProtoFileDescriptor>[file]);
  final base = _mergeFeatures(_editionsDefaultFeatures, file.features);
  final pkgScope = file.packageName.isEmpty ? '' : '.${file.packageName}';

  void checkEnums(List<ProtoEnumDescriptor> values, Map<int, int> parent) {
    for (final e in values) {
      final resolved = _mergeFeatures(parent, e.features);
      if (resolved[ProtoFeature.enumType] != ProtoFeature.enumTypeOpen) {
        throw FormatException(
          'omnibuf: editions CLOSED enums are not supported (${e.name})',
        );
      }
    }
  }

  void visit(ProtoMessageDescriptor m, String scope, Map<int, int> parent) {
    final fqn = '$scope.${m.name}';
    for (final ext in m.extensions) {
      if (!_isOptionExtendee(ext.extendee)) {
        throw FormatException(
          'omnibuf: editions extensions are not supported (${ext.name})',
        );
      }
    }
    if (m.extensionRanges.isNotEmpty) {
      throw FormatException(
        'omnibuf: editions extension ranges are not supported (${m.name})',
      );
    }

    final features = _mergeFeatures(parent, m.features);
    checkEnums(m.enumTypes, features);

    final nestedMapEntries = <String, ProtoMessageDescriptor>{
      for (final n in m.nestedTypes)
        if (n.isMapEntry) '$fqn.${n.name}': n,
    };

    for (final f in m.fields) {
      final oneofFeatures = (f.oneofIndex != null &&
              f.oneofIndex! >= 0 &&
              f.oneofIndex! < m.oneofs.length)
          ? _mergeFeatures(features, m.oneofs[f.oneofIndex!].features)
          : features;
      final resolved = _mergeFeatures(oneofFeatures, f.features);

      if (f.label == 2) {
        throw FormatException(
          'omnibuf: editions LEGACY_REQUIRED fields are not supported (${f.name})',
        );
      }
      if (!m.isMapEntry) {
        final explicitFieldPresence = f.features[ProtoFeature.fieldPresence];
        final effectivePresence = resolved[ProtoFeature.fieldPresence];
        if (explicitFieldPresence == ProtoFeature.fieldPresenceLegacyRequired ||
            (f.label != 3 &&
                !f.isRealOneof &&
                effectivePresence != ProtoFeature.fieldPresenceExplicit &&
                effectivePresence != ProtoFeature.fieldPresenceImplicit)) {
          throw FormatException(
            'omnibuf: editions LEGACY_REQUIRED fields are not supported (${f.name})',
          );
        }
      }

      if (f.type == 9 &&
          resolved[ProtoFeature.utf8Validation] !=
              ProtoFeature.utf8ValidationVerify) {
        throw FormatException(
          'omnibuf: editions UTF-8 NONE is not supported (${f.name})',
        );
      }

      // Check map fields that carry field-level utf8_validation overrides.
      if (f.label == 3 && (f.type == 11 || f.type == 10)) {
        final entry = nestedMapEntries[_normalizeFqn(f.typeName)];
        if (entry != null) {
          final entryBase = _mergeFeatures(resolved, entry.features);
          for (final ef in entry.fields) {
            final efResolved = _mergeFeatures(entryBase, ef.features);
            if (ef.type == 9 &&
                efResolved[ProtoFeature.utf8Validation] !=
                    ProtoFeature.utf8ValidationVerify) {
              throw FormatException(
                'omnibuf: editions UTF-8 NONE is not supported (${f.name}.${ef.name})',
              );
            }
          }
        }
      }

      if (f.type == 14 && f.typeName.isNotEmpty) {
        final targetClosed = closedMap[_normalizeFqn(f.typeName)];
        if (targetClosed == true) {
          throw FormatException(
            'omnibuf: editions CLOSED enums are not supported (${f.name} -> ${f.typeName})',
          );
        }
      }

      if (f.defaultValue != null && !_isZeroDefault(f, enumVals)) {
        throw FormatException(
          'omnibuf: editions non-zero default value is not supported (${f.name} = ${f.defaultValue})',
        );
      }

      f.isDelimitedMessage = f.type == 10;
      if (m.isMapEntry || f.label == 3 || f.type == 11 || f.type == 10) {
        f.explicitPresence = false;
      } else if (f.isRealOneof) {
        f.explicitPresence = true;
      } else {
        f.explicitPresence = resolved[ProtoFeature.fieldPresence] ==
            ProtoFeature.fieldPresenceExplicit;
      }
    }

    for (final n in m.nestedTypes) {
      visit(n, fqn, features);
    }
  }

  checkEnums(file.enums, base);
  for (final m in file.messages) {
    visit(m, pkgScope, base);
  }
}
