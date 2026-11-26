import '../descriptor.dart';

/// Protobuf `FieldDescriptorProto.Type` numeric constants.
abstract final class PbType {
  static const int doubleType = 1;
  static const int floatType = 2;
  static const int int64Type = 3;
  static const int uint64Type = 4;
  static const int int32Type = 5;
  static const int fixed64Type = 6;
  static const int fixed32Type = 7;
  static const int boolType = 8;
  static const int stringType = 9;
  static const int groupType = 10;
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

class TypeRef {
  final String fileName;
  final String dartName;
  final String opaqueName;

  const TypeRef({
    required this.fileName,
    required this.dartName,
    required this.opaqueName,
  });
}

String normalizeFqn(String fqn) => fqn.startsWith('.') ? fqn : '.$fqn';

String escapeTypeName(String raw) {
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

String escapeEnumValueName(String raw, int index) {
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

String outputFileName(String protoName) {
  final base = protoName.endsWith('.proto')
      ? protoName.substring(0, protoName.length - 6)
      : protoName;
  return '$base.omnibuf.dart';
}

String relativeImportPath(String fromProto, String toProto) {
  final fromOut = outputFileName(fromProto);
  final toOut = outputFileName(toProto);
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

String toCamelCase(String snake, {int fieldNumber = 0}) {
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

Map<int, String> assignFieldNames(List<ProtoFieldDescriptor> sortedFields) {
  final used = <String>{};
  final names = <int, String>{};
  for (final f in sortedFields) {
    var candidate = toCamelCase(f.name, fieldNumber: f.number);
    while (used.contains(candidate)) {
      candidate = '${candidate}_${f.number}';
    }
    used.add(candidate);
    names[f.number] = candidate;
  }
  return names;
}

Map<int, String> assignOneofNames(
  List<int> realOneofIndices,
  List<ProtoOneofDescriptor> oneofs,
  Set<String> usedFieldNames,
) {
  final used = Set<String>.of(usedFieldNames);
  final names = <int, String>{};
  for (final idx in realOneofIndices) {
    final raw = (idx >= 0 && idx < oneofs.length && oneofs[idx].name.isNotEmpty)
        ? oneofs[idx].name
        : 'oneof_$idx';
    var candidate = toCamelCase(raw, fieldNumber: idx + 1);
    while (used.contains(candidate)) {
      candidate = '${candidate}_oneof_$idx';
    }
    used.add(candidate);
    names[idx] = candidate;
  }
  return names;
}

String shortTypeName(String fqn) {
  final idx = fqn.lastIndexOf('.');
  return escapeTypeName(idx >= 0 ? fqn.substring(idx + 1) : fqn);
}

String resolveTypeName(
  String fqn,
  String currentFile,
  Map<String, TypeRef> typeRegistry,
  Map<String, String> depAliases,
) {
  final ref = typeRegistry[normalizeFqn(fqn)];
  if (ref == null) return shortTypeName(fqn);
  if (ref.fileName == currentFile) return ref.dartName;
  final alias = depAliases[ref.fileName];
  if (alias != null) return '$alias.${ref.dartName}';
  return ref.dartName;
}

String resolveOpaqueTypeName(
  String fqn,
  String currentFile,
  Map<String, TypeRef> typeRegistry,
  Map<String, String> depAliases,
) {
  final ref = typeRegistry[normalizeFqn(fqn)];
  if (ref == null) return 'Opaque${shortTypeName(fqn)}';
  if (ref.fileName == currentFile) return ref.opaqueName;
  final alias = depAliases[ref.fileName];
  if (alias != null) return '$alias.${ref.opaqueName}';
  return ref.opaqueName;
}

String dartScalarType(int pbType) {
  switch (pbType) {
    case PbType.boolType:
      return 'bool';
    case PbType.floatType:
    case PbType.doubleType:
      return 'double';
    case PbType.stringType:
      return 'String';
    case PbType.bytesType:
      return 'Uint8List';
    default:
      return 'int';
  }
}

String defaultScalarExpr(int pbType) {
  switch (pbType) {
    case PbType.boolType:
      return 'false';
    case PbType.floatType:
    case PbType.doubleType:
      return '0.0';
    case PbType.stringType:
      return "''";
    case PbType.bytesType:
      return 'Uint8List(0)';
    default:
      return '0';
  }
}

String wireTypeConst(int pbType) {
  switch (pbType) {
    case PbType.uint32Type:
    case PbType.uint64Type:
      return 'ob.WireType.uint';
    case PbType.int32Type:
    case PbType.int64Type:
    case PbType.sint32Type:
    case PbType.sint64Type:
    case PbType.enumType:
      return 'ob.WireType.sint';
    case PbType.boolType:
      return 'ob.WireType.boolFalse';
    case PbType.fixed32Type:
      return 'ob.WireType.fixed32';
    case PbType.fixed64Type:
      return 'ob.WireType.fixed64';
    case PbType.sfixed32Type:
      return 'ob.WireType.sfixed32';
    case PbType.sfixed64Type:
      return 'ob.WireType.sfixed64';
    case PbType.floatType:
      return 'ob.WireType.float32';
    case PbType.doubleType:
      return 'ob.WireType.float64';
    case PbType.stringType:
      return 'ob.WireType.string';
    case PbType.bytesType:
      return 'ob.WireType.bytes';
    case PbType.groupType:
    case PbType.messageType:
      return 'ob.WireType.subMsg';
    default:
      return 'ob.WireType.uint';
  }
}

String writeScalarCall(String w, int pbType, String expr) {
  switch (pbType) {
    case PbType.uint32Type:
      return '$w.writeVarint($expr & 0xFFFFFFFF)';
    case PbType.uint64Type:
      return '$w.writeVarint($expr)';
    case PbType.int32Type:
    case PbType.sint32Type:
    case PbType.enumType:
      return '$w.writeSint32($expr)';
    case PbType.int64Type:
    case PbType.sint64Type:
      return '$w.writeSint($expr)';
    case PbType.boolType:
      return '$w.writeByte($expr ? 1 : 0)';
    case PbType.fixed32Type:
      return '$w.writeFixed32($expr & 0xFFFFFFFF)';
    case PbType.fixed64Type:
      return '$w.writeFixed64($expr)';
    case PbType.sfixed32Type:
      return '$w.writeSfixed32($expr)';
    case PbType.sfixed64Type:
      return '$w.writeSfixed64($expr)';
    case PbType.floatType:
      return '$w.writeFloat32($expr)';
    case PbType.doubleType:
      return '$w.writeFloat64($expr)';
    case PbType.stringType:
      return '$w.writeString($expr)';
    case PbType.bytesType:
      return '$w.writeBytes($expr)';
    default:
      return '$w.writeVarint($expr)';
  }
}

String readScalarExpr(
  String r,
  int pbType, {
  bool inCollection = false,
  String? budgetVar,
}) {
  final budgetArg = budgetVar != null ? 'budget: $budgetVar' : '';
  switch (pbType) {
    case PbType.uint32Type:
      return '$r.readUint32()';
    case PbType.uint64Type:
      return '$r.readVarint()';
    case PbType.int32Type:
    case PbType.sint32Type:
    case PbType.enumType:
      return '$r.readSint32()';
    case PbType.int64Type:
    case PbType.sint64Type:
      return '$r.readSint()';
    case PbType.boolType:
      return inCollection
          ? '$r.readCollectionBool()'
          : '(wt == ob.WireType.boolTrue)';
    case PbType.fixed32Type:
      return '$r.readFixed32()';
    case PbType.fixed64Type:
      return '$r.readFixed64()';
    case PbType.sfixed32Type:
      return '$r.readSfixed32()';
    case PbType.sfixed64Type:
      return '$r.readSfixed64()';
    case PbType.floatType:
      return '$r.readFloat32()';
    case PbType.doubleType:
      return '$r.readFloat64()';
    case PbType.stringType:
      return '$r.readString($budgetArg)';
    case PbType.bytesType:
      return '$r.readBytes($budgetArg)';
    default:
      return '$r.readVarint()';
  }
}

String nonZeroCond(int pbType, String expr) {
  switch (pbType) {
    case PbType.boolType:
      return expr;
    case PbType.floatType:
    case PbType.doubleType:
      return '$expr != 0.0 || $expr.isNegative';
    case PbType.stringType:
    case PbType.bytesType:
      return '$expr.isNotEmpty';
    default:
      return '$expr != 0';
  }
}

String mapKeySortStmt(String keysVar, int pbType) {
  switch (pbType) {
    case PbType.stringType:
      return '$keysVar.sort(ob.compareUtf8);';
    case PbType.uint32Type:
    case PbType.fixed32Type:
      return '$keysVar.sort((a, b) => (a & 0xFFFFFFFF).compareTo(b & 0xFFFFFFFF));';
    case PbType.uint64Type:
    case PbType.fixed64Type:
      return '$keysVar.sort(ob.compareUint64);';
    case PbType.int32Type:
    case PbType.sint32Type:
    case PbType.sfixed32Type:
      return '$keysVar.sort((a, b) => a.toSigned(32).compareTo(b.toSigned(32)));';
    case PbType.boolType:
      return '$keysVar.sort((a, b) => (a ? 1 : 0) - (b ? 1 : 0));';
    default:
      return '$keysVar.sort();';
  }
}
