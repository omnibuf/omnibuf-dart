import 'descriptor.dart';

/// Protobuf `FieldDescriptorProto.Type` numeric constants.
abstract final class _PbType {
  static const int doubleType = 1;
  static const int floatType = 2;
  static const int int64Type = 3;
  static const int uint64Type = 4;
  static const int int32Type = 5;
  static const int fixed64Type = 6;
  static const int fixed32Type = 7;
  static const int boolType = 8;
  static const int stringType = 9;
  static const int messageType = 11;
  static const int bytesType = 12;
  static const int uint32Type = 13;
  static const int enumType = 14;
  static const int sfixed32Type = 15;
  static const int sfixed64Type = 16;
  static const int sint32Type = 17;
  static const int sint64Type = 18;
}

const Set<String> _dartKeywords = <String>{
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'base',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'Function',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'of',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'sealed',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'typedef',
  'var',
  'void',
  'when',
  'while',
  'with',
  'yield',
};

const Set<String> _reservedFieldNames = <String>{
  ..._dartKeywords,
  // Object members
  'hashCode',
  'runtimeType',
  'toString',
  'noSuchMethod',
  // Generated eager message members
  'reset',
  'estimateBodyBytes',
  'buildSchemaMeta',
  'encode',
  'encodeInto',
  'decode',
  'decodeInto',
  'decodeBody',
  // OpaqueMessage base class members
  'rawBytes',
  'setPatch',
  'hasPatch',
  'getPatch',
  'clearPatches',
  'marshalAppend',
  'marshalInto',
};

const Set<String> _reservedTypeNames = <String>{
  ..._dartKeywords,
  'Object',
  'String',
  'int',
  'double',
  'bool',
  'num',
  'List',
  'Map',
  'Set',
  'Uint8List',
  'ob',
};

const Set<String> _reservedEnumValueNames = <String>{
  ..._dartKeywords,
  'hashCode',
  'runtimeType',
  'toString',
  'noSuchMethod',
};

class _TypeRef {
  final String fileName;
  final String dartName;
  final String opaqueName;

  const _TypeRef({
    required this.fileName,
    required this.dartName,
    required this.opaqueName,
  });
}

String _normalizeFqn(String fqn) => fqn.startsWith('.') ? fqn : '.$fqn';

String _escapeTypeName(String raw) {
  var name = raw.replaceAll(RegExp(r'^_+'), '');
  if (name.isEmpty) name = 'Message';
  if (RegExp(r'^[0-9]').hasMatch(name)) {
    name = 'T$name';
  }
  if (_reservedTypeNames.contains(name)) {
    name = '${name}_';
  }
  return name;
}

String _escapeEnumValueName(String raw, int index) {
  var name = raw.replaceAll(RegExp(r'^_+'), '');
  if (name.isEmpty) name = 'VALUE_$index';
  if (RegExp(r'^[0-9]').hasMatch(name)) {
    name = 'V_$name';
  }
  if (_reservedEnumValueNames.contains(name)) {
    name = '${name}_';
  }
  return name;
}

/// Generates idiomatic OmniBuf Dart source code for a [CodeGeneratorRequest].
CodeGeneratorResponse generateOmniBufDart(CodeGeneratorRequest req) {
  final resp = CodeGeneratorResponse();
  final targetSet = req.fileToGenerate.toSet();

  final mapEntries = <String, ProtoMessageDescriptor>{};
  final typeRegistry = <String, _TypeRef>{};
  final knownFiles = <String>{};

  void collectFile(ProtoFileDescriptor f) {
    knownFiles.add(f.name);
    final pkgScope = f.packageName.isEmpty ? '' : '.${f.packageName}';

    void collectEnum(ProtoEnumDescriptor e, String scope, String dartPrefix) {
      final fqn = '$scope.${e.name}';
      final dartName = _escapeTypeName(
        dartPrefix.isEmpty ? e.name : '${dartPrefix}_${e.name}',
      );
      typeRegistry[fqn] = _TypeRef(
        fileName: f.name,
        dartName: dartName,
        opaqueName: 'Opaque$dartName',
      );
    }

    void collectMsg(ProtoMessageDescriptor m, String scope, String dartPrefix) {
      final fqn = '$scope.${m.name}';
      if (m.isMapEntry) {
        mapEntries[fqn] = m;
        return;
      }
      final dartName = _escapeTypeName(
        dartPrefix.isEmpty ? m.name : '${dartPrefix}_${m.name}',
      );
      typeRegistry[fqn] = _TypeRef(
        fileName: f.name,
        dartName: dartName,
        opaqueName: 'Opaque$dartName',
      );
      for (final e in m.enumTypes) {
        collectEnum(e, fqn, dartName);
      }
      for (final nested in m.nestedTypes) {
        collectMsg(nested, fqn, dartName);
      }
    }

    for (final e in f.enums) {
      collectEnum(e, pkgScope, '');
    }
    for (final m in f.messages) {
      collectMsg(m, pkgScope, '');
    }
  }

  for (final f in req.protoFiles) {
    collectFile(f);
  }

  for (final f in req.protoFiles) {
    if (targetSet.isNotEmpty && !targetSet.contains(f.name)) continue;
    final outName = _outputFileName(f.name);
    final content = _generateFile(f, mapEntries, typeRegistry, knownFiles);
    resp.files.add(CodeGeneratorResponseFile(name: outName, content: content));
  }
  return resp;
}

String _outputFileName(String protoName) {
  final base = protoName.endsWith('.proto')
      ? protoName.substring(0, protoName.length - 6)
      : protoName;
  return '$base.omnibuf.dart';
}

String _relativeImportPath(String fromProto, String toProto) {
  final fromOut = _outputFileName(fromProto);
  final toOut = _outputFileName(toProto);
  final fromParts = fromOut.split('/')..removeLast();
  final toParts = toOut.split('/');
  var common = 0;
  while (common < fromParts.length &&
      common < toParts.length - 1 &&
      fromParts[common] == toParts[common]) {
    common++;
  }
  final ups = fromParts.length - common;
  final rel = <String>[
    for (var i = 0; i < ups; i++) '..',
    ...toParts.sublist(common),
  ];
  return rel.join('/');
}

String _toCamelCase(String snake, {int fieldNumber = 0}) {
  final parts = snake.split('_').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) {
    return fieldNumber > 0 ? 'field$fieldNumber' : 'field';
  }
  final sb = StringBuffer(parts.first);
  for (var i = 1; i < parts.length; i++) {
    final p = parts[i];
    sb.write(p[0].toUpperCase());
    if (p.length > 1) sb.write(p.substring(1));
  }
  var name = sb.toString();
  if (RegExp(r'^[0-9]').hasMatch(name)) {
    name = 'f$name';
  }
  if (_reservedFieldNames.contains(name)) {
    name = '${name}_';
  }
  return name;
}

Map<int, String> _assignFieldNames(List<ProtoFieldDescriptor> sortedFields) {
  final used = <String>{};
  final names = <int, String>{};
  for (final f in sortedFields) {
    var candidate = _toCamelCase(f.name, fieldNumber: f.number);
    while (used.contains(candidate)) {
      candidate = '${candidate}_${f.number}';
    }
    used.add(candidate);
    names[f.number] = candidate;
  }
  return names;
}

String _shortTypeName(String fqn) {
  final idx = fqn.lastIndexOf('.');
  return _escapeTypeName(idx >= 0 ? fqn.substring(idx + 1) : fqn);
}

String _resolveTypeName(
  String fqn,
  String currentFile,
  Map<String, _TypeRef> typeRegistry,
  Map<String, String> depAliases,
) {
  final ref = typeRegistry[_normalizeFqn(fqn)];
  if (ref == null) return _shortTypeName(fqn);
  if (ref.fileName == currentFile) return ref.dartName;
  final alias = depAliases[ref.fileName];
  if (alias != null) return '$alias.${ref.dartName}';
  return ref.dartName;
}

String _resolveOpaqueTypeName(
  String fqn,
  String currentFile,
  Map<String, _TypeRef> typeRegistry,
  Map<String, String> depAliases,
) {
  final ref = typeRegistry[_normalizeFqn(fqn)];
  if (ref == null) return 'Opaque${_shortTypeName(fqn)}';
  if (ref.fileName == currentFile) return ref.opaqueName;
  final alias = depAliases[ref.fileName];
  if (alias != null) return '$alias.${ref.opaqueName}';
  return ref.opaqueName;
}

String _dartScalarType(int pbType) {
  switch (pbType) {
    case _PbType.boolType:
      return 'bool';
    case _PbType.floatType:
    case _PbType.doubleType:
      return 'double';
    case _PbType.stringType:
      return 'String';
    case _PbType.bytesType:
      return 'Uint8List';
    default:
      return 'int';
  }
}

String _defaultScalarExpr(int pbType) {
  switch (pbType) {
    case _PbType.boolType:
      return 'false';
    case _PbType.floatType:
    case _PbType.doubleType:
      return '0.0';
    case _PbType.stringType:
      return "''";
    case _PbType.bytesType:
      return 'Uint8List(0)';
    default:
      return '0';
  }
}

String _wireTypeConst(int pbType) {
  switch (pbType) {
    case _PbType.uint32Type:
    case _PbType.uint64Type:
      return 'ob.WireType.uint';
    case _PbType.int32Type:
    case _PbType.int64Type:
    case _PbType.sint32Type:
    case _PbType.sint64Type:
    case _PbType.enumType:
      return 'ob.WireType.sint';
    case _PbType.boolType:
      return 'ob.WireType.boolFalse';
    case _PbType.fixed32Type:
      return 'ob.WireType.fixed32';
    case _PbType.fixed64Type:
      return 'ob.WireType.fixed64';
    case _PbType.sfixed32Type:
      return 'ob.WireType.sfixed32';
    case _PbType.sfixed64Type:
      return 'ob.WireType.sfixed64';
    case _PbType.floatType:
      return 'ob.WireType.float32';
    case _PbType.doubleType:
      return 'ob.WireType.float64';
    case _PbType.stringType:
      return 'ob.WireType.string';
    case _PbType.bytesType:
      return 'ob.WireType.bytes';
    case _PbType.messageType:
      return 'ob.WireType.subMsg';
    default:
      return 'ob.WireType.uint';
  }
}

String _writeScalarCall(String w, int pbType, String expr) {
  switch (pbType) {
    case _PbType.uint32Type:
      return '$w.writeVarint($expr & 0xFFFFFFFF)';
    case _PbType.uint64Type:
      return '$w.writeVarint($expr)';
    case _PbType.int32Type:
    case _PbType.sint32Type:
    case _PbType.enumType:
      return '$w.writeSint32($expr)';
    case _PbType.int64Type:
    case _PbType.sint64Type:
      return '$w.writeSint($expr)';
    case _PbType.boolType:
      return '$w.writeByte($expr ? 1 : 0)';
    case _PbType.fixed32Type:
      return '$w.writeFixed32($expr & 0xFFFFFFFF)';
    case _PbType.fixed64Type:
      return '$w.writeFixed64($expr)';
    case _PbType.sfixed32Type:
      return '$w.writeSfixed32($expr)';
    case _PbType.sfixed64Type:
      return '$w.writeSfixed64($expr)';
    case _PbType.floatType:
      return '$w.writeFloat32($expr)';
    case _PbType.doubleType:
      return '$w.writeFloat64($expr)';
    case _PbType.stringType:
      return '$w.writeString($expr)';
    case _PbType.bytesType:
      return '$w.writeBytes($expr)';
    default:
      return '$w.writeVarint($expr)';
  }
}

String _readScalarExpr(String r, int pbType, {bool inCollection = false}) {
  switch (pbType) {
    case _PbType.uint32Type:
      return '$r.readUint32()';
    case _PbType.uint64Type:
      return '$r.readVarint()';
    case _PbType.int32Type:
    case _PbType.sint32Type:
    case _PbType.enumType:
      return '$r.readSint32()';
    case _PbType.int64Type:
    case _PbType.sint64Type:
      return '$r.readSint()';
    case _PbType.boolType:
      return inCollection
          ? '$r.readCollectionBool()'
          : '(wt == ob.WireType.boolTrue)';
    case _PbType.fixed32Type:
      return '$r.readFixed32()';
    case _PbType.fixed64Type:
      return '$r.readFixed64()';
    case _PbType.sfixed32Type:
      return '$r.readSfixed32()';
    case _PbType.sfixed64Type:
      return '$r.readSfixed64()';
    case _PbType.floatType:
      return '$r.readFloat32()';
    case _PbType.doubleType:
      return '$r.readFloat64()';
    case _PbType.stringType:
      return '$r.readString()';
    case _PbType.bytesType:
      return '$r.readBytes()';
    default:
      return '$r.readVarint()';
  }
}

String _nonZeroCond(int pbType, String expr) {
  switch (pbType) {
    case _PbType.boolType:
      return expr;
    case _PbType.floatType:
    case _PbType.doubleType:
      return '$expr != 0.0 || $expr.isNegative';
    case _PbType.stringType:
    case _PbType.bytesType:
      return '$expr.isNotEmpty';
    default:
      return '$expr != 0';
  }
}

String _mapKeySortStmt(String keysVar, int pbType) {
  switch (pbType) {
    case _PbType.stringType:
      return '$keysVar.sort(ob.compareUtf8);';
    case _PbType.uint32Type:
    case _PbType.fixed32Type:
      return '$keysVar.sort((a, b) => (a & 0xFFFFFFFF).compareTo(b & 0xFFFFFFFF));';
    case _PbType.uint64Type:
    case _PbType.fixed64Type:
      return '$keysVar.sort(ob.compareUint64);';
    case _PbType.int32Type:
    case _PbType.sint32Type:
    case _PbType.sfixed32Type:
      return '$keysVar.sort((a, b) => a.toSigned(32).compareTo(b.toSigned(32)));';
    case _PbType.boolType:
      return '$keysVar.sort((a, b) => (a ? 1 : 0) - (b ? 1 : 0));';
    default:
      return '$keysVar.sort();';
  }
}

String _generateFile(
  ProtoFileDescriptor file,
  Map<String, ProtoMessageDescriptor> mapEntries,
  Map<String, _TypeRef> typeRegistry,
  Set<String> knownFiles,
) {
  final sb = StringBuffer();
  sb.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.');
  sb.writeln('// Source: ${file.name}');
  sb.writeln(
    '// ignore_for_file: unused_import, constant_identifier_names, non_constant_identifier_names, prefer_final_locals, unnecessary_this, camel_case_types',
  );
  sb.writeln();
  sb.writeln("import 'dart:typed_data';");
  sb.writeln();
  sb.writeln("import 'package:omnibuf/omnibuf.dart' as ob;");

  final depAliases = <String, String>{};
  final depImports = <String>[];
  var depIndex = 0;
  for (final dep in file.dependencies) {
    if (dep == file.name) continue;
    final relPath = _relativeImportPath(file.name, dep);
    if (knownFiles.contains(dep)) {
      final alias = 'dep_${depIndex++}';
      depAliases[dep] = alias;
      depImports.add("import '$relPath' as $alias;");
    } else {
      depImports.add("import '$relPath';");
    }
  }
  if (depImports.isNotEmpty) {
    depImports.sort();
    sb.writeln();
    for (final line in depImports) {
      sb.writeln(line);
    }
  }
  sb.writeln();

  final pkgScope = file.packageName.isEmpty ? '' : '.${file.packageName}';
  for (final e in file.enums) {
    _generateEnum(sb, e, _escapeTypeName(e.name));
  }

  for (final m in file.messages) {
    if (m.isMapEntry) continue;
    _generateMessageTree(
      sb,
      m,
      file.name,
      pkgScope,
      '',
      mapEntries,
      typeRegistry,
      depAliases,
    );
  }

  return sb.toString();
}

void _generateEnum(StringBuffer sb, ProtoEnumDescriptor e, String enumName) {
  sb.writeln('abstract final class $enumName {');
  final used = <String>{};
  for (var i = 0; i < e.values.length; i++) {
    final (rawName, value) = e.values[i];
    var vName = _escapeEnumValueName(rawName, i);
    while (used.contains(vName)) {
      vName = '${vName}_$i';
    }
    used.add(vName);
    sb.writeln('  static const int $vName = $value;');
  }
  sb.writeln('}');
  sb.writeln();
}

void _generateMessageTree(
  StringBuffer sb,
  ProtoMessageDescriptor m,
  String currentFile,
  String scope,
  String dartPrefix,
  Map<String, ProtoMessageDescriptor> mapEntries,
  Map<String, _TypeRef> typeRegistry,
  Map<String, String> depAliases,
) {
  final fqn = '$scope.${m.name}';
  final className = _escapeTypeName(
    dartPrefix.isEmpty ? m.name : '${dartPrefix}_${m.name}',
  );
  final fullName = fqn.startsWith('.') ? fqn.substring(1) : fqn;

  for (final e in m.enumTypes) {
    final nestedEnumName = _escapeTypeName('${className}_${e.name}');
    _generateEnum(sb, e, nestedEnumName);
  }

  _generateMessage(
    sb,
    m,
    className,
    fullName,
    currentFile,
    mapEntries,
    typeRegistry,
    depAliases,
  );

  for (final nested in m.nestedTypes) {
    if (nested.isMapEntry) continue;
    _generateMessageTree(
      sb,
      nested,
      currentFile,
      fqn,
      className,
      mapEntries,
      typeRegistry,
      depAliases,
    );
  }
}

void _generateMessage(
  StringBuffer sb,
  ProtoMessageDescriptor m,
  String className,
  String fullName,
  String currentFile,
  Map<String, ProtoMessageDescriptor> mapEntries,
  Map<String, _TypeRef> typeRegistry,
  Map<String, String> depAliases,
) {
  final sortedFields = List<ProtoFieldDescriptor>.of(m.fields)
    ..sort((a, b) => a.number.compareTo(b.number));
  final fieldNames = _assignFieldNames(sortedFields);

  bool isMapField(ProtoFieldDescriptor f) =>
      f.label == 3 &&
      f.type == _PbType.messageType &&
      mapEntries.containsKey(_normalizeFqn(f.typeName));

  String typeOf(String fqn) =>
      _resolveTypeName(fqn, currentFile, typeRegistry, depAliases);

  String opaqueTypeOf(String fqn) =>
      _resolveOpaqueTypeName(fqn, currentFile, typeRegistry, depAliases);

  // ==========================================================================
  // 1. Eager Message Class
  // ==========================================================================
  sb.writeln('class $className {');
  for (final f in sortedFields) {
    final fname = fieldNames[f.number]!;
    if (isMapField(f)) {
      final entry = mapEntries[_normalizeFqn(f.typeName)]!;
      final kf = entry.fields.firstWhere((e) => e.number == 1);
      final vf = entry.fields.firstWhere((e) => e.number == 2);
      final kt = _dartScalarType(kf.type);
      final vt = vf.type == _PbType.messageType
          ? typeOf(vf.typeName)
          : _dartScalarType(vf.type);
      sb.writeln('  Map<$kt, $vt> $fname;');
    } else if (f.label == 3) {
      final et = f.type == _PbType.messageType
          ? typeOf(f.typeName)
          : _dartScalarType(f.type);
      sb.writeln('  List<$et> $fname;');
    } else if (f.type == _PbType.messageType) {
      final mt = typeOf(f.typeName);
      sb.writeln('  $mt? $fname;');
    } else {
      sb.writeln('  ${_dartScalarType(f.type)} $fname;');
    }
  }
  sb.writeln();

  // Constructor
  if (sortedFields.isEmpty) {
    sb.writeln('  $className();');
  } else {
    final inits = <String>[];
    sb.writeln('  $className({');
    for (final f in sortedFields) {
      final fname = fieldNames[f.number]!;
      if (isMapField(f)) {
        final entry = mapEntries[_normalizeFqn(f.typeName)]!;
        final kf = entry.fields.firstWhere((e) => e.number == 1);
        final vf = entry.fields.firstWhere((e) => e.number == 2);
        final kt = _dartScalarType(kf.type);
        final vt = vf.type == _PbType.messageType
            ? typeOf(vf.typeName)
            : _dartScalarType(vf.type);
        sb.writeln('    Map<$kt, $vt>? $fname,');
        inits.add('this.$fname = $fname ?? <$kt, $vt>{}');
      } else if (f.label == 3) {
        final et = f.type == _PbType.messageType
            ? typeOf(f.typeName)
            : _dartScalarType(f.type);
        sb.writeln('    List<$et>? $fname,');
        inits.add('this.$fname = $fname ?? <$et>[]');
      } else if (f.type == _PbType.bytesType) {
        sb.writeln('    Uint8List? $fname,');
        inits.add('this.$fname = $fname ?? Uint8List(0)');
      } else if (f.type == _PbType.messageType) {
        sb.writeln('    this.$fname,');
      } else {
        sb.writeln('    this.$fname = ${_defaultScalarExpr(f.type)},');
      }
    }
    if (inits.isEmpty) {
      sb.writeln('  });');
    } else {
      sb.writeln('  }) : ${inits.join(',\n       ')};');
    }
  }
  sb.writeln();

  // reset()
  sb.writeln('  void reset() {');
  for (final f in sortedFields) {
    final fname = fieldNames[f.number]!;
    if (isMapField(f)) {
      sb.writeln('    this.$fname.clear();');
    } else if (f.label == 3) {
      sb.writeln('    this.$fname.clear();');
    } else if (f.type == _PbType.messageType) {
      sb.writeln('    this.$fname = null;');
    } else if (f.type == _PbType.bytesType) {
      sb.writeln('    this.$fname = Uint8List(0);');
    } else {
      sb.writeln('    this.$fname = ${_defaultScalarExpr(f.type)};');
    }
  }
  sb.writeln('  }');
  sb.writeln();

  // estimateBodyBytes() for 4B container pre-sizing
  sb.writeln('  int estimateBodyBytes([int depth = 0]) {');
  sb.writeln('    if (depth > ob.DecodeOptions.defaultMaxDepth) {');
  sb.writeln(
    "      throw const ob.OmniBufSerializeException('message encoding depth exceeded limit of \${ob.DecodeOptions.defaultMaxDepth}');",
  );
  sb.writeln('    }');
  sb.writeln('    var n = 32;');
  for (final f in sortedFields) {
    final fname = fieldNames[f.number]!;
    if (isMapField(f)) {
      final entry = mapEntries[_normalizeFqn(f.typeName)]!;
      final vf = entry.fields.firstWhere((e) => e.number == 2);
      if (vf.type == _PbType.messageType) {
        sb.writeln(
          '    for (final v in this.$fname.values) { n += v.estimateBodyBytes(depth + 2); }',
        );
      }
    } else if (f.label != 3 &&
        (f.type == _PbType.stringType || f.type == _PbType.bytesType)) {
      sb.writeln('    n += this.$fname.length;');
    } else if (f.label != 3 && f.type == _PbType.messageType) {
      sb.writeln(
        '    if (this.$fname != null) n += this.$fname!.estimateBodyBytes(depth + 1);',
      );
    } else if (f.label == 3 &&
        !isMapField(f) &&
        f.type == _PbType.messageType) {
      sb.writeln(
        '    for (var i = 0; i < this.$fname.length; i++) { n += this.$fname[i].estimateBodyBytes(depth + 2); }',
      );
    } else if (f.label == 3 &&
        !isMapField(f) &&
        (f.type == _PbType.stringType || f.type == _PbType.bytesType)) {
      sb.writeln(
        '    for (var i = 0; i < this.$fname.length; i++) { n += this.$fname[i].length + 4; }',
      );
    }
  }
  sb.writeln('    return n;');
  sb.writeln('  }');
  sb.writeln();

  // schemaMeta
  sb.writeln('  static ob.SchemaMeta buildSchemaMeta({int maxDepth = 16}) {');
  sb.writeln('    return _buildSchemaMeta(0, maxDepth);');
  sb.writeln('  }');
  sb.writeln();
  sb.writeln(
    '  static ob.SchemaMeta _buildSchemaMeta(int depth, int maxDepth) {',
  );
  sb.writeln('    final fields = <int, String>{');
  for (final f in sortedFields) {
    sb.writeln("      ${f.number}: '${f.name}',");
  }
  sb.writeln('    };');
  sb.writeln('    final children = <int, ob.SchemaMeta>{};');
  sb.writeln('    if (depth + 2 <= maxDepth) {');
  for (final f in sortedFields) {
    if (isMapField(f)) {
      final entry = mapEntries[_normalizeFqn(f.typeName)]!;
      final vf = entry.fields.firstWhere((e) => e.number == 2);
      if (vf.type == _PbType.messageType) {
        final vt = typeOf(vf.typeName);
        sb.writeln(
          '      children[${f.number}] = $vt.buildSchemaMeta(maxDepth: maxDepth - depth - 2);',
        );
      }
    } else if (f.type == _PbType.messageType) {
      final mt = typeOf(f.typeName);
      sb.writeln(
        '      children[${f.number}] = $mt.buildSchemaMeta(maxDepth: maxDepth - depth - 2);',
      );
    }
  }
  sb.writeln('    }');
  sb.writeln(
    "    return ob.SchemaMeta(typeName: '$fullName', fields: fields, children: children);",
  );
  sb.writeln('  }');
  sb.writeln();

  // encode()
  sb.writeln(
    '  Uint8List encode({ob.EncodeOptions options = ob.EncodeOptions.defaults}) {',
  );
  sb.writeln('    final w = ob.OmniBufWriter(estimateBodyBytes());');
  sb.writeln('    if (options.selfDescribing) {');
  sb.writeln('      buildSchemaMeta().writeField0(w);');
  sb.writeln('    }');
  sb.writeln('    encodeInto(w, options: options);');
  sb.writeln('    return w.toBytes();');
  sb.writeln('  }');
  sb.writeln();

  // encodeInto()
  sb.writeln(
    '  void encodeInto(ob.OmniBufWriter w, {ob.EncodeOptions options = ob.EncodeOptions.defaults, int depth = 0}) {',
  );
  sb.writeln('    if (depth > ob.DecodeOptions.defaultMaxDepth) {');
  sb.writeln(
    "      throw const ob.OmniBufSerializeException('message encoding depth exceeded limit of \${ob.DecodeOptions.defaultMaxDepth}');",
  );
  sb.writeln('    }');
  for (final f in sortedFields) {
    final fname = fieldNames[f.number]!;
    if (isMapField(f)) {
      final entry = mapEntries[_normalizeFqn(f.typeName)]!;
      final kf = entry.fields.firstWhere((e) => e.number == 1);
      final vf = entry.fields.firstWhere((e) => e.number == 2);
      sb.writeln('    if (this.$fname.isNotEmpty) {');
      sb.writeln('      w.writeTag(${f.number}, ob.WireType.map);');
      sb.writeln('      final slot = w.reserveLen2();');
      sb.writeln('      w.writeByte(${_wireTypeConst(kf.type)});');
      sb.writeln('      w.writeByte(${_wireTypeConst(vf.type)});');
      sb.writeln('      final keys = this.$fname.keys.toList();');
      sb.writeln('      if (options.deterministicMaps) {');
      sb.writeln('        ${_mapKeySortStmt('keys', kf.type)}');
      sb.writeln('      }');
      sb.writeln('      w.writeVarint(keys.length);');
      sb.writeln('      for (var i = 0; i < keys.length; i++) {');
      sb.writeln('        final k = keys[i];');
      sb.writeln('        final v = this.$fname[k]!;');
      sb.writeln('        ${_writeScalarCall('w', kf.type, 'k')};');
      if (vf.type == _PbType.messageType) {
        sb.writeln(
          '        final vSlot = w.reserveLenAuto(v.estimateBodyBytes(depth + 2));',
        );
        sb.writeln(
          '        v.encodeInto(w, options: options, depth: depth + 2);',
        );
        sb.writeln('        w.patchLenAuto(vSlot);');
      } else {
        sb.writeln('        ${_writeScalarCall('w', vf.type, 'v')};');
      }
      sb.writeln('      }');
      sb.writeln('      w.patchLen2(slot);');
      sb.writeln('    }');
    } else if (f.label == 3) {
      sb.writeln('    if (this.$fname.isNotEmpty) {');
      sb.writeln('      w.writeTag(${f.number}, ob.WireType.array);');
      if (f.type == _PbType.messageType) {
        sb.writeln('      var est = 8;');
        sb.writeln(
          '      for (var i = 0; i < this.$fname.length; i++) { est += this.$fname[i].estimateBodyBytes(depth + 2); }',
        );
        sb.writeln('      final slot = w.reserveLenAuto(est);');
      } else {
        sb.writeln('      final slot = w.reserveLen2();');
      }
      sb.writeln('      w.writeByte(${_wireTypeConst(f.type)});');
      sb.writeln('      w.writeVarint(this.$fname.length);');
      sb.writeln('      for (var i = 0; i < this.$fname.length; i++) {');
      if (f.type == _PbType.messageType) {
        sb.writeln('        final item = this.$fname[i];');
        sb.writeln(
          '        final iSlot = w.reserveLenAuto(item.estimateBodyBytes(depth + 2));',
        );
        sb.writeln(
          '        item.encodeInto(w, options: options, depth: depth + 2);',
        );
        sb.writeln('        w.patchLenAuto(iSlot);');
      } else {
        sb.writeln(
          '        ${_writeScalarCall('w', f.type, 'this.$fname[i]')};',
        );
      }
      sb.writeln('      }');
      if (f.type == _PbType.messageType) {
        sb.writeln('      w.patchLenAuto(slot);');
      } else {
        sb.writeln('      w.patchLen2(slot);');
      }
      sb.writeln('    }');
    } else if (f.type == _PbType.messageType) {
      sb.writeln('    if (this.$fname != null) {');
      sb.writeln('      final sub = this.$fname!;');
      sb.writeln('      w.writeTag(${f.number}, ob.WireType.subMsg);');
      sb.writeln(
        '      final slot = w.reserveLenAuto(sub.estimateBodyBytes(depth + 1));',
      );
      sb.writeln(
        '      sub.encodeInto(w, options: options, depth: depth + 1);',
      );
      sb.writeln('      w.patchLenAuto(slot);');
      sb.writeln('    }');
    } else if (f.type == _PbType.boolType) {
      sb.writeln('    if (this.$fname) {');
      sb.writeln('      w.writeTag(${f.number}, ob.WireType.boolTrue);');
      sb.writeln('    }');
    } else {
      sb.writeln('    if (${_nonZeroCond(f.type, 'this.$fname')}) {');
      sb.writeln('      w.writeTag(${f.number}, ${_wireTypeConst(f.type)});');
      sb.writeln('      ${_writeScalarCall('w', f.type, 'this.$fname')};');
      sb.writeln('    }');
    }
  }
  sb.writeln('  }');
  sb.writeln();

  // static decode()
  sb.writeln(
    '  static $className decode(Uint8List data, {ob.DecodeOptions options = ob.DecodeOptions.defaults}) {',
  );
  sb.writeln('    final msg = $className();');
  sb.writeln('    msg.decodeInto(data, options: options);');
  sb.writeln('    return msg;');
  sb.writeln('  }');
  sb.writeln();

  // decodeInto()
  sb.writeln(
    '  void decodeInto(Uint8List data, {ob.DecodeOptions options = ob.DecodeOptions.defaults}) {',
  );
  sb.writeln('    if (data.length > options.maxMessageBytes) {');
  sb.writeln(
    "      throw ob.OmniBufAllocationLimitException('packet size \${data.length} exceeds maxMessageBytes \${options.maxMessageBytes}');",
  );
  sb.writeln('    }');
  sb.writeln('    if (!options.merge) {');
  sb.writeln('      reset();');
  sb.writeln('    }');
  sb.writeln(
      '    final budget = ob.DecodeBudget(options.maxCollectionElements);');
  sb.writeln('    final r = ob.OmniBufReader(data);');
  sb.writeln('    decodeBody(r, 0, options, budget);');
  sb.writeln('  }');
  sb.writeln();

  // decodeBody()
  sb.writeln(
    '  void decodeBody(ob.OmniBufReader r, int depth, ob.DecodeOptions options, [ob.DecodeBudget? budget]) {',
  );
  sb.writeln(
    '    final activeBudget = budget ?? ob.DecodeBudget(options.maxCollectionElements);',
  );
  sb.writeln('    while (r.hasMore) {');
  sb.writeln('      final tag = r.readTag();');
  sb.writeln('      final fnum = tag >> 4;');
  sb.writeln('      final wt = tag & 0x0F;');
  sb.writeln('      if (fnum == 0) {');
  sb.writeln(
    '        ob.validateField0SubMsg(r, depth, options.maxDepth, maxElements: options.maxCollectionElements, budget: activeBudget);',
  );
  sb.writeln('        continue;');
  sb.writeln('      }');
  sb.writeln('      switch (fnum) {');
  for (final f in sortedFields) {
    final fname = fieldNames[f.number]!;
    sb.writeln('        case ${f.number}:');
    if (isMapField(f)) {
      final entry = mapEntries[_normalizeFqn(f.typeName)]!;
      final kf = entry.fields.firstWhere((e) => e.number == 1);
      final vf = entry.fields.firstWhere((e) => e.number == 2);
      sb.writeln('          if (wt != ob.WireType.map) {');
      sb.writeln(
        '            ob.skipAndValidateValue(r, wt, depth, options.maxDepth, maxElements: options.maxCollectionElements, budget: activeBudget);',
      );
      sb.writeln('            break;');
      sb.writeln('          }');
      sb.writeln('          final nextDepth = depth + 1;');
      sb.writeln('          if (nextDepth > options.maxDepth) {');
      sb.writeln(
        '            throw ob.OmniBufDepthLimitException(options.maxDepth);',
      );
      sb.writeln('          }');
      sb.writeln('          final len = r.readCheckedLength();');
      sb.writeln('          final bodyEnd = r.pos + len;');
      sb.writeln('          final body = r.subReader(r.pos, bodyEnd);');
      sb.writeln(
        '          final (kWt, vWt, count) = body.readMapHeader(maxElements: options.maxCollectionElements);',
      );
      sb.writeln('          activeBudget.consume(count);');
      sb.writeln(
        '          if (kWt != ${_wireTypeConst(kf.type)} || vWt != ${_wireTypeConst(vf.type)}) {',
      );
      sb.writeln(
        "            throw ob.OmniBufTypeMismatchException('${f.name} WireMap header mismatch: <\$kWt, \$vWt>');",
      );
      sb.writeln('          }');
      sb.writeln('          for (var i = 0; i < count; i++) {');
      sb.writeln(
        '            final k = ${_readScalarExpr('body', kf.type, inCollection: true)};',
      );
      if (vf.type == _PbType.messageType) {
        final vt = typeOf(vf.typeName);
        sb.writeln('            final vDepth = nextDepth + 1;');
        sb.writeln('            if (vDepth > options.maxDepth) {');
        sb.writeln(
          '              throw ob.OmniBufDepthLimitException(options.maxDepth);',
        );
        sb.writeln('            }');
        sb.writeln('            final vLen = body.readCheckedLength();');
        sb.writeln('            final vEnd = body.pos + vLen;');
        sb.writeln(
          '            final vSub = body.subReader(body.pos, vEnd);',
        );
        sb.writeln('            final v = $vt();');
        sb.writeln(
            '            v.decodeBody(vSub, vDepth, options, activeBudget);');
        sb.writeln('            body.pos = vEnd;');
        sb.writeln('            this.$fname[k] = v;');
      } else {
        sb.writeln(
          '            this.$fname[k] = ${_readScalarExpr('body', vf.type, inCollection: true)};',
        );
      }
      sb.writeln('          }');
      sb.writeln('          if (body.pos != bodyEnd) {');
      sb.writeln(
        "            throw const ob.OmniBufParseException('WireMap trailing bytes');",
      );
      sb.writeln('          }');
      sb.writeln('          r.pos = bodyEnd;');
    } else if (f.label == 3) {
      sb.writeln('          if (wt != ob.WireType.array) {');
      sb.writeln(
        '            ob.skipAndValidateValue(r, wt, depth, options.maxDepth, maxElements: options.maxCollectionElements, budget: activeBudget);',
      );
      sb.writeln('            break;');
      sb.writeln('          }');
      sb.writeln('          final nextDepth = depth + 1;');
      sb.writeln('          if (nextDepth > options.maxDepth) {');
      sb.writeln(
        '            throw ob.OmniBufDepthLimitException(options.maxDepth);',
      );
      sb.writeln('          }');
      sb.writeln('          final len = r.readCheckedLength();');
      sb.writeln('          final bodyEnd = r.pos + len;');
      sb.writeln('          final body = r.subReader(r.pos, bodyEnd);');
      sb.writeln(
        '          final (elemWt, count) = body.readArrayHeader(maxElements: options.maxCollectionElements);',
      );
      sb.writeln('          activeBudget.consume(count);');
      sb.writeln('          if (elemWt != ${_wireTypeConst(f.type)}) {');
      sb.writeln(
        "            throw ob.OmniBufTypeMismatchException('${f.name} WireArray ElementType mismatch: \$elemWt');",
      );
      sb.writeln('          }');
      sb.writeln('          for (var i = 0; i < count; i++) {');
      if (f.type == _PbType.messageType) {
        final mt = typeOf(f.typeName);
        sb.writeln('            final itemDepth = nextDepth + 1;');
        sb.writeln('            if (itemDepth > options.maxDepth) {');
        sb.writeln(
          '              throw ob.OmniBufDepthLimitException(options.maxDepth);',
        );
        sb.writeln('            }');
        sb.writeln('            final iLen = body.readCheckedLength();');
        sb.writeln('            final iEnd = body.pos + iLen;');
        sb.writeln(
          '            final iSub = body.subReader(body.pos, iEnd);',
        );
        sb.writeln('            final item = $mt();');
        sb.writeln(
          '            item.decodeBody(iSub, itemDepth, options, activeBudget);',
        );
        sb.writeln('            body.pos = iEnd;');
        sb.writeln('            this.$fname.add(item);');
      } else {
        sb.writeln(
          '            this.$fname.add(${_readScalarExpr('body', f.type, inCollection: true)});',
        );
      }
      sb.writeln('          }');
      sb.writeln('          if (body.pos != bodyEnd) {');
      sb.writeln(
        "            throw const ob.OmniBufParseException('WireArray trailing bytes');",
      );
      sb.writeln('          }');
      sb.writeln('          r.pos = bodyEnd;');
    } else if (f.type == _PbType.messageType) {
      final mt = typeOf(f.typeName);
      sb.writeln('          if (wt != ob.WireType.subMsg) {');
      sb.writeln(
        '            ob.skipAndValidateValue(r, wt, depth, options.maxDepth, maxElements: options.maxCollectionElements, budget: activeBudget);',
      );
      sb.writeln('            break;');
      sb.writeln('          }');
      sb.writeln('          final nextDepth = depth + 1;');
      sb.writeln('          if (nextDepth > options.maxDepth) {');
      sb.writeln(
        '            throw ob.OmniBufDepthLimitException(options.maxDepth);',
      );
      sb.writeln('          }');
      sb.writeln('          final len = r.readCheckedLength();');
      sb.writeln('          final subEnd = r.pos + len;');
      sb.writeln('          final sub = r.subReader(r.pos, subEnd);');
      sb.writeln('          final target = this.$fname ??= $mt();');
      sb.writeln(
        '          target.decodeBody(sub, nextDepth, options, activeBudget);',
      );
      sb.writeln('          r.pos = subEnd;');
    } else if (f.type == _PbType.boolType) {
      sb.writeln(
        '          if (wt != ob.WireType.boolFalse && wt != ob.WireType.boolTrue) {',
      );
      sb.writeln(
        '            ob.skipAndValidateValue(r, wt, depth, options.maxDepth, maxElements: options.maxCollectionElements, budget: activeBudget);',
      );
      sb.writeln('            break;');
      sb.writeln('          }');
      sb.writeln('          this.$fname = wt == ob.WireType.boolTrue;');
    } else {
      sb.writeln('          if (wt != ${_wireTypeConst(f.type)}) {');
      sb.writeln(
        '            ob.skipAndValidateValue(r, wt, depth, options.maxDepth, maxElements: options.maxCollectionElements, budget: activeBudget);',
      );
      sb.writeln('            break;');
      sb.writeln('          }');
      sb.writeln('          this.$fname = ${_readScalarExpr('r', f.type)};');
    }
  }
  sb.writeln('        default:');
  sb.writeln(
    '          ob.skipAndValidateValue(r, wt, depth, options.maxDepth, maxElements: options.maxCollectionElements, budget: activeBudget);',
  );
  sb.writeln('      }');
  sb.writeln('    }');
  sb.writeln('  }');
  sb.writeln('}');
  sb.writeln();

  // ==========================================================================
  // 2. Lazy Opaque<Message> View Class
  // ==========================================================================
  sb.writeln('class Opaque$className extends ob.OpaqueMessage {');
  sb.writeln('  Opaque$className(super.rawBytes);');
  sb.writeln();

  for (final f in sortedFields) {
    final fname = fieldNames[f.number]!;
    if (isMapField(f)) {
      final entry = mapEntries[_normalizeFqn(f.typeName)]!;
      final kf = entry.fields.firstWhere((e) => e.number == 1);
      final vf = entry.fields.firstWhere((e) => e.number == 2);
      final kt = _dartScalarType(kf.type);
      final vt = vf.type == _PbType.messageType
          ? typeOf(vf.typeName)
          : _dartScalarType(vf.type);
      // Getter
      sb.writeln('  Map<$kt, $vt> get $fname {');
      sb.writeln('    final out = <$kt, $vt>{};');
      sb.writeln('    if (hasPatch(${f.number})) {');
      sb.writeln('      final p = getPatch(${f.number});');
      sb.writeln('      if (p == null || p.isEmpty) return out;');
      sb.writeln('      final tmp = $className.decode(p);');
      sb.writeln('      return tmp.$fname;');
      sb.writeln('    }');
      sb.writeln(
        '    final budget = ob.DecodeBudget(ob.DecodeOptions.defaultMaxCollectionElements);',
      );
      sb.writeln('    final occs = ob.findAllFields(rawBytes, ${f.number});');
      sb.writeln('    for (var i = 0; i < occs.length; i++) {');
      sb.writeln('      final (start, end, wt) = occs[i];');
      sb.writeln('      if (wt != ob.WireType.map) continue;');
      sb.writeln('      final r = ob.OmniBufReader(rawBytes, start, end);');
      sb.writeln('      final len = r.readCheckedLength();');
      sb.writeln('      final bodyEnd = r.pos + len;');
      sb.writeln('      final body = r.subReader(r.pos, bodyEnd);');
      sb.writeln('      final (kWt, vWt, count) = body.readMapHeader();');
      sb.writeln('      budget.consume(count);');
      sb.writeln(
        '      if (kWt != ${_wireTypeConst(kf.type)} || vWt != ${_wireTypeConst(vf.type)}) {',
      );
      sb.writeln(
        "        throw ob.OmniBufTypeMismatchException('${f.name} WireMap header mismatch');",
      );
      sb.writeln('      }');
      sb.writeln('      for (var j = 0; j < count; j++) {');
      sb.writeln(
        '        final k = ${_readScalarExpr('body', kf.type, inCollection: true)};',
      );
      if (vf.type == _PbType.messageType) {
        sb.writeln('        final vLen = body.readCheckedLength();');
        sb.writeln('        final vEnd = body.pos + vLen;');
        sb.writeln('        final vSub = body.subReader(body.pos, vEnd);');
        sb.writeln('        final v = $vt();');
        sb.writeln(
          '        v.decodeBody(vSub, 2, ob.DecodeOptions.defaults, budget);',
        );
        sb.writeln('        body.pos = vEnd;');
        sb.writeln('        out[k] = v;');
      } else {
        sb.writeln(
          '        out[k] = ${_readScalarExpr('body', vf.type, inCollection: true)};',
        );
      }
      sb.writeln('      }');
      sb.writeln('      if (body.pos != bodyEnd) {');
      sb.writeln(
        "        throw const ob.OmniBufParseException('WireMap trailing bytes');",
      );
      sb.writeln('      }');
      sb.writeln('    }');
      sb.writeln('    return out;');
      sb.writeln('  }');
      sb.writeln();
      // Setter
      sb.writeln('  set $fname(Map<$kt, $vt> value) {');
      sb.writeln('    if (value.isEmpty) {');
      sb.writeln('      setPatch(${f.number}, null);');
      sb.writeln('      return;');
      sb.writeln('    }');
      sb.writeln('    final w = ob.OmniBufWriter(64);');
      sb.writeln('    w.writeTag(${f.number}, ob.WireType.map);');
      sb.writeln('    final slot = w.reserveLen2();');
      sb.writeln('    w.writeByte(${_wireTypeConst(kf.type)});');
      sb.writeln('    w.writeByte(${_wireTypeConst(vf.type)});');
      sb.writeln('    final keys = value.keys.toList();');
      sb.writeln('    ${_mapKeySortStmt('keys', kf.type)}');
      sb.writeln('    w.writeVarint(keys.length);');
      sb.writeln('    for (var i = 0; i < keys.length; i++) {');
      sb.writeln('      final k = keys[i];');
      sb.writeln('      final v = value[k]!;');
      sb.writeln('      ${_writeScalarCall('w', kf.type, 'k')};');
      if (vf.type == _PbType.messageType) {
        sb.writeln(
          '      final vSlot = w.reserveLenAuto(v.estimateBodyBytes(2));',
        );
        sb.writeln('      v.encodeInto(w, depth: 2);');
        sb.writeln('      w.patchLenAuto(vSlot);');
      } else {
        sb.writeln('      ${_writeScalarCall('w', vf.type, 'v')};');
      }
      sb.writeln('    }');
      sb.writeln('    w.patchLen2(slot);');
      sb.writeln('    setPatch(${f.number}, w.toBytes());');
      sb.writeln('  }');
      sb.writeln();
    } else if (f.label == 3) {
      final et = f.type == _PbType.messageType
          ? typeOf(f.typeName)
          : _dartScalarType(f.type);
      // Getter
      sb.writeln('  List<$et> get $fname {');
      sb.writeln('    final out = <$et>[];');
      sb.writeln('    if (hasPatch(${f.number})) {');
      sb.writeln('      final p = getPatch(${f.number});');
      sb.writeln('      if (p == null || p.isEmpty) return out;');
      sb.writeln('      return $className.decode(p).$fname;');
      sb.writeln('    }');
      sb.writeln(
        '    final budget = ob.DecodeBudget(ob.DecodeOptions.defaultMaxCollectionElements);',
      );
      sb.writeln('    final occs = ob.findAllFields(rawBytes, ${f.number});');
      sb.writeln('    for (var i = 0; i < occs.length; i++) {');
      sb.writeln('      final (start, end, wt) = occs[i];');
      sb.writeln('      if (wt != ob.WireType.array) continue;');
      sb.writeln('      final r = ob.OmniBufReader(rawBytes, start, end);');
      sb.writeln('      final len = r.readCheckedLength();');
      sb.writeln('      final bodyEnd = r.pos + len;');
      sb.writeln('      final body = r.subReader(r.pos, bodyEnd);');
      sb.writeln('      final (elemWt, count) = body.readArrayHeader();');
      sb.writeln('      budget.consume(count);');
      sb.writeln('      if (elemWt != ${_wireTypeConst(f.type)}) {');
      sb.writeln(
        "        throw ob.OmniBufTypeMismatchException('${f.name} WireArray ElementType mismatch');",
      );
      sb.writeln('      }');
      sb.writeln('      for (var j = 0; j < count; j++) {');
      if (f.type == _PbType.messageType) {
        sb.writeln('        final iLen = body.readCheckedLength();');
        sb.writeln('        final iEnd = body.pos + iLen;');
        sb.writeln('        final iSub = body.subReader(body.pos, iEnd);');
        sb.writeln('        final item = $et();');
        sb.writeln(
          '        item.decodeBody(iSub, 2, ob.DecodeOptions.defaults, budget);',
        );
        sb.writeln('        body.pos = iEnd;');
        sb.writeln('        out.add(item);');
      } else {
        sb.writeln(
          '        out.add(${_readScalarExpr('body', f.type, inCollection: true)});',
        );
      }
      sb.writeln('      }');
      sb.writeln('      if (body.pos != bodyEnd) {');
      sb.writeln(
        "        throw const ob.OmniBufParseException('WireArray trailing bytes');",
      );
      sb.writeln('      }');
      sb.writeln('    }');
      sb.writeln('    return out;');
      sb.writeln('  }');
      sb.writeln();
      // Setter
      sb.writeln('  set $fname(List<$et> value) {');
      sb.writeln('    if (value.isEmpty) {');
      sb.writeln('      setPatch(${f.number}, null);');
      sb.writeln('      return;');
      sb.writeln('    }');
      sb.writeln('    final w = ob.OmniBufWriter(64);');
      sb.writeln('    w.writeTag(${f.number}, ob.WireType.array);');
      sb.writeln('    final slot = w.reserveLen2();');
      sb.writeln('    w.writeByte(${_wireTypeConst(f.type)});');
      sb.writeln('    w.writeVarint(value.length);');
      sb.writeln('    for (var i = 0; i < value.length; i++) {');
      if (f.type == _PbType.messageType) {
        sb.writeln('      final item = value[i];');
        sb.writeln(
          '      final iSlot = w.reserveLenAuto(item.estimateBodyBytes(2));',
        );
        sb.writeln('      item.encodeInto(w, depth: 2);');
        sb.writeln('      w.patchLenAuto(iSlot);');
      } else {
        sb.writeln('      ${_writeScalarCall('w', f.type, 'value[i]')};');
      }
      sb.writeln('    }');
      sb.writeln('    w.patchLen2(slot);');
      sb.writeln('    setPatch(${f.number}, w.toBytes());');
      sb.writeln('  }');
      sb.writeln();
    } else if (f.type == _PbType.messageType) {
      final mt = typeOf(f.typeName);
      final omt = opaqueTypeOf(f.typeName);
      // Zero-decode Opaque submessage getter
      sb.writeln('  $omt? get ${fname}Opaque {');
      sb.writeln('    if (hasPatch(${f.number})) {');
      sb.writeln('      final p = getPatch(${f.number});');
      sb.writeln('      if (p == null || p.isEmpty) return null;');
      sb.writeln('      final r = ob.OmniBufReader(p);');
      sb.writeln('      r.readTag();');
      sb.writeln('      final len = r.readCheckedLength();');
      sb.writeln(
        '      return $omt(Uint8List.sublistView(p, r.pos, r.pos + len));',
      );
      sb.writeln('    }');
      sb.writeln('    final occs = ob.findAllFields(rawBytes, ${f.number});');
      sb.writeln('    if (occs.isEmpty) return null;');
      sb.writeln('    if (occs.length == 1) {');
      sb.writeln('      final (start, end, wt) = occs[0];');
      sb.writeln('      if (wt != ob.WireType.subMsg) return null;');
      sb.writeln('      final r = ob.OmniBufReader(rawBytes, start, end);');
      sb.writeln('      final len = r.readCheckedLength();');
      sb.writeln(
        '      return $omt(Uint8List.sublistView(rawBytes, r.pos, r.pos + len));',
      );
      sb.writeln('    }');
      sb.writeln('    final w = ob.OmniBufWriter(64);');
      sb.writeln('    var found = false;');
      sb.writeln('    for (var i = 0; i < occs.length; i++) {');
      sb.writeln('      final (start, end, wt) = occs[i];');
      sb.writeln('      if (wt != ob.WireType.subMsg) continue;');
      sb.writeln('      found = true;');
      sb.writeln('      final r = ob.OmniBufReader(rawBytes, start, end);');
      sb.writeln('      final len = r.readCheckedLength();');
      sb.writeln('      w.writeRawSlice(rawBytes, r.pos, r.pos + len);');
      sb.writeln('    }');
      sb.writeln('    return found ? $omt(w.toBytes()) : null;');
      sb.writeln('  }');
      sb.writeln();
      // Eager submessage getter
      sb.writeln('  $mt? get $fname {');
      sb.writeln('    final op = ${fname}Opaque;');
      sb.writeln('    if (op == null) return null;');
      sb.writeln('    return $mt.decode(op.rawBytes);');
      sb.writeln('  }');
      sb.writeln();
      // Setter
      sb.writeln('  set $fname($mt? value) {');
      sb.writeln('    if (value == null) {');
      sb.writeln('      setPatch(${f.number}, null);');
      sb.writeln('      return;');
      sb.writeln('    }');
      sb.writeln('    final est = value.estimateBodyBytes(1);');
      sb.writeln('    final w = ob.OmniBufWriter(est + 8);');
      sb.writeln('    w.writeTag(${f.number}, ob.WireType.subMsg);');
      sb.writeln('    final slot = w.reserveLenAuto(est);');
      sb.writeln('    value.encodeInto(w, depth: 1);');
      sb.writeln('    w.patchLenAuto(slot);');
      sb.writeln('    setPatch(${f.number}, w.toBytes());');
      sb.writeln('  }');
      sb.writeln();
      // Opaque submessage setter
      sb.writeln(
        '  void set${fname[0].toUpperCase()}${fname.substring(1)}Opaque($omt value) {',
      );
      sb.writeln('    final body = value.marshalAppend();');
      sb.writeln('    final w = ob.OmniBufWriter(body.length + 8);');
      sb.writeln('    w.writeTag(${f.number}, ob.WireType.subMsg);');
      sb.writeln('    w.writeVarint(body.length);');
      sb.writeln('    w.writeRawBytes(body);');
      sb.writeln('    setPatch(${f.number}, w.toBytes());');
      sb.writeln('  }');
      sb.writeln();
    } else {
      final dt = _dartScalarType(f.type);
      // Getter
      sb.writeln('  $dt get $fname {');
      sb.writeln('    if (hasPatch(${f.number})) {');
      sb.writeln('      final p = getPatch(${f.number});');
      sb.writeln(
        '      if (p == null || p.isEmpty) return ${_defaultScalarExpr(f.type)};',
      );
      sb.writeln('      final r = ob.OmniBufReader(p);');
      sb.writeln('      final tag = r.readTag();');
      sb.writeln('      final wt = tag & 0x0F;');
      if (f.type == _PbType.boolType) {
        sb.writeln('      return wt == ob.WireType.boolTrue;');
      } else {
        sb.writeln(
          '      if (wt != ${_wireTypeConst(f.type)}) return ${_defaultScalarExpr(f.type)};',
        );
        sb.writeln('      return ${_readScalarExpr('r', f.type)};');
      }
      sb.writeln('    }');
      if (f.type == _PbType.boolType) {
        sb.writeln(
          '    final wt = ob.findLastBoolField(rawBytes, ${f.number});',
        );
        sb.writeln('    return wt == ob.WireType.boolTrue;');
      } else {
        sb.writeln(
          '    final hit = ob.findLastFieldWithWireType(rawBytes, ${f.number}, ${_wireTypeConst(f.type)});',
        );
        sb.writeln(
          '    if (hit == null) return ${_defaultScalarExpr(f.type)};',
        );
        sb.writeln('    final (start, end, _) = hit;');
        sb.writeln('    final r = ob.OmniBufReader(rawBytes, start, end);');
        sb.writeln('    return ${_readScalarExpr('r', f.type)};');
      }
      sb.writeln('  }');
      sb.writeln();
      // Setter
      sb.writeln('  set $fname($dt value) {');
      if (f.type == _PbType.boolType) {
        sb.writeln('    if (!value) {');
        sb.writeln('      setPatch(${f.number}, null);');
        sb.writeln('      return;');
        sb.writeln('    }');
        sb.writeln('    final w = ob.OmniBufWriter(8);');
        sb.writeln('    w.writeTag(${f.number}, ob.WireType.boolTrue);');
        sb.writeln('    setPatch(${f.number}, w.toBytes());');
      } else {
        sb.writeln('    if (!(${_nonZeroCond(f.type, 'value')})) {');
        sb.writeln('      setPatch(${f.number}, null);');
        sb.writeln('      return;');
        sb.writeln('    }');
        sb.writeln('    final w = ob.OmniBufWriter(32);');
        sb.writeln('    w.writeTag(${f.number}, ${_wireTypeConst(f.type)});');
        sb.writeln('    ${_writeScalarCall('w', f.type, 'value')};');
        sb.writeln('    setPatch(${f.number}, w.toBytes());');
      }
      sb.writeln('  }');
      sb.writeln();
    }
  }

  sb.writeln('}');
  sb.writeln();
}
