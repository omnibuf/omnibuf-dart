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

/// Generates idiomatic OmniBuf Dart source code for a [CodeGeneratorRequest].
CodeGeneratorResponse generateOmniBufDart(CodeGeneratorRequest req) {
  final resp = CodeGeneratorResponse();
  final targetSet = req.fileToGenerate.toSet();

  final mapEntries = <String, ProtoMessageDescriptor>{};

  void collectFile(ProtoFileDescriptor f) {
    final prefix = f.packageName.isEmpty ? '' : '.${f.packageName}';
    void collectMsg(ProtoMessageDescriptor m, String scope) {
      final fqn = '$scope.${m.name}';
      if (m.isMapEntry) {
        mapEntries[fqn] = m;
      }
      for (final nested in m.nestedTypes) {
        collectMsg(nested, fqn);
      }
    }

    for (final m in f.messages) {
      collectMsg(m, prefix);
    }
  }

  for (final f in req.protoFiles) {
    collectFile(f);
  }

  for (final f in req.protoFiles) {
    if (targetSet.isNotEmpty && !targetSet.contains(f.name)) continue;
    final outName = _outputFileName(f.name);
    final content = _generateFile(f, mapEntries);
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

String _toCamelCase(String snake) {
  final parts = snake.split('_');
  if (parts.isEmpty) return snake;
  final sb = StringBuffer(parts.first);
  for (var i = 1; i < parts.length; i++) {
    final p = parts[i];
    if (p.isEmpty) continue;
    sb.write(p[0].toUpperCase());
    if (p.length > 1) sb.write(p.substring(1));
  }
  return sb.toString();
}

String _shortTypeName(String fqn) {
  final idx = fqn.lastIndexOf('.');
  return idx >= 0 ? fqn.substring(idx + 1) : fqn;
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
    case _PbType.uint64Type:
    case _PbType.fixed32Type:
    case _PbType.fixed64Type:
      return '$keysVar.sort(ob.compareUint64);';
    case _PbType.boolType:
      return '$keysVar.sort((a, b) => (a ? 1 : 0) - (b ? 1 : 0));';
    default:
      return '$keysVar.sort();';
  }
}

String _generateFile(
  ProtoFileDescriptor file,
  Map<String, ProtoMessageDescriptor> mapEntries,
) {
  final sb = StringBuffer();
  sb.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.');
  sb.writeln('// Source: ${file.name}');
  sb.writeln(
    '// ignore_for_file: unused_import, constant_identifier_names, non_constant_identifier_names, prefer_final_locals',
  );
  sb.writeln();
  sb.writeln("import 'dart:typed_data';");
  sb.writeln();
  sb.writeln("import 'package:omnibuf/omnibuf.dart' as ob;");
  sb.writeln();

  for (final e in file.enums) {
    sb.writeln('abstract final class ${e.name} {');
    for (final (name, value) in e.values) {
      sb.writeln('  static const int $name = $value;');
    }
    sb.writeln('}');
    sb.writeln();
  }

  final pkgPrefix = file.packageName.isEmpty ? '' : '.${file.packageName}';
  for (final m in file.messages) {
    if (m.isMapEntry) continue;
    _generateMessage(sb, m, pkgPrefix, mapEntries);
  }

  return sb.toString();
}

void _generateMessage(
  StringBuffer sb,
  ProtoMessageDescriptor m,
  String pkgPrefix,
  Map<String, ProtoMessageDescriptor> mapEntries,
) {
  final className = m.name;
  final fullName =
      pkgPrefix.isEmpty ? className : '${pkgPrefix.substring(1)}.$className';
  final sortedFields = List<ProtoFieldDescriptor>.of(m.fields)
    ..sort((a, b) => a.number.compareTo(b.number));

  bool isMapField(ProtoFieldDescriptor f) =>
      f.label == 3 &&
      f.type == _PbType.messageType &&
      mapEntries.containsKey(f.typeName);

  // ==========================================================================
  // 1. Eager Message Class
  // ==========================================================================
  sb.writeln('class $className {');
  for (final f in sortedFields) {
    final fname = _toCamelCase(f.name);
    if (isMapField(f)) {
      final entry = mapEntries[f.typeName]!;
      final kf = entry.fields.firstWhere((e) => e.number == 1);
      final vf = entry.fields.firstWhere((e) => e.number == 2);
      final kt = _dartScalarType(kf.type);
      final vt = vf.type == _PbType.messageType
          ? _shortTypeName(vf.typeName)
          : _dartScalarType(vf.type);
      sb.writeln('  Map<$kt, $vt> $fname;');
    } else if (f.label == 3) {
      final et = f.type == _PbType.messageType
          ? _shortTypeName(f.typeName)
          : _dartScalarType(f.type);
      sb.writeln('  List<$et> $fname;');
    } else if (f.type == _PbType.messageType) {
      final mt = _shortTypeName(f.typeName);
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
      final fname = _toCamelCase(f.name);
      if (isMapField(f)) {
        final entry = mapEntries[f.typeName]!;
        final kf = entry.fields.firstWhere((e) => e.number == 1);
        final vf = entry.fields.firstWhere((e) => e.number == 2);
        final kt = _dartScalarType(kf.type);
        final vt = vf.type == _PbType.messageType
            ? _shortTypeName(vf.typeName)
            : _dartScalarType(vf.type);
        sb.writeln('    Map<$kt, $vt>? $fname,');
        inits.add('$fname = $fname ?? <$kt, $vt>{}');
      } else if (f.label == 3) {
        final et = f.type == _PbType.messageType
            ? _shortTypeName(f.typeName)
            : _dartScalarType(f.type);
        sb.writeln('    List<$et>? $fname,');
        inits.add('$fname = $fname ?? <$et>[]');
      } else if (f.type == _PbType.bytesType) {
        sb.writeln('    Uint8List? $fname,');
        inits.add('$fname = $fname ?? Uint8List(0)');
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
    final fname = _toCamelCase(f.name);
    if (isMapField(f)) {
      sb.writeln('    $fname.clear();');
    } else if (f.label == 3) {
      sb.writeln('    $fname.clear();');
    } else if (f.type == _PbType.messageType) {
      sb.writeln('    $fname = null;');
    } else if (f.type == _PbType.bytesType) {
      sb.writeln('    $fname = Uint8List(0);');
    } else {
      sb.writeln('    $fname = ${_defaultScalarExpr(f.type)};');
    }
  }
  sb.writeln('  }');
  sb.writeln();

  // estimateBodyBytes() for 4B container pre-sizing
  sb.writeln('  int estimateBodyBytes() {');
  sb.writeln('    var n = 32;');
  for (final f in sortedFields) {
    final fname = _toCamelCase(f.name);
    if (f.label != 3 &&
        (f.type == _PbType.stringType || f.type == _PbType.bytesType)) {
      sb.writeln('    n += $fname.length;');
    } else if (f.label != 3 && f.type == _PbType.messageType) {
      sb.writeln('    if ($fname != null) n += $fname!.estimateBodyBytes();');
    } else if (f.label == 3 &&
        !isMapField(f) &&
        f.type == _PbType.messageType) {
      sb.writeln(
        '    for (var i = 0; i < $fname.length; i++) { n += $fname[i].estimateBodyBytes(); }',
      );
    } else if (f.label == 3 &&
        !isMapField(f) &&
        (f.type == _PbType.stringType || f.type == _PbType.bytesType)) {
      sb.writeln(
        '    for (var i = 0; i < $fname.length; i++) { n += $fname[i].length + 4; }',
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
      '  static ob.SchemaMeta _buildSchemaMeta(int depth, int maxDepth) {');
  sb.writeln('    final fields = <int, String>{');
  for (final f in sortedFields) {
    sb.writeln("      ${f.number}: '${f.name}',");
  }
  sb.writeln('    };');
  sb.writeln('    final children = <int, ob.SchemaMeta>{};');
  sb.writeln('    if (depth + 2 <= maxDepth) {');
  for (final f in sortedFields) {
    if (isMapField(f)) {
      final entry = mapEntries[f.typeName]!;
      final vf = entry.fields.firstWhere((e) => e.number == 2);
      if (vf.type == _PbType.messageType) {
        final vt = _shortTypeName(vf.typeName);
        sb.writeln(
          '      children[${f.number}] = $vt._buildSchemaMeta(depth + 2, maxDepth);',
        );
      }
    } else if (f.type == _PbType.messageType) {
      final mt = _shortTypeName(f.typeName);
      sb.writeln(
        '      children[${f.number}] = $mt._buildSchemaMeta(depth + 2, maxDepth);',
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
    '  void encodeInto(ob.OmniBufWriter w, {ob.EncodeOptions options = ob.EncodeOptions.defaults}) {',
  );
  for (final f in sortedFields) {
    final fname = _toCamelCase(f.name);
    if (isMapField(f)) {
      final entry = mapEntries[f.typeName]!;
      final kf = entry.fields.firstWhere((e) => e.number == 1);
      final vf = entry.fields.firstWhere((e) => e.number == 2);
      sb.writeln('    if ($fname.isNotEmpty) {');
      sb.writeln('      w.writeTag(${f.number}, ob.WireType.map);');
      sb.writeln('      final slot = w.reserveLen2();');
      sb.writeln('      w.writeByte(${_wireTypeConst(kf.type)});');
      sb.writeln('      w.writeByte(${_wireTypeConst(vf.type)});');
      sb.writeln('      final keys = $fname.keys.toList();');
      sb.writeln('      if (options.deterministicMaps) {');
      sb.writeln('        ${_mapKeySortStmt('keys', kf.type)}');
      sb.writeln('      }');
      sb.writeln('      w.writeVarint(keys.length);');
      sb.writeln('      for (var i = 0; i < keys.length; i++) {');
      sb.writeln('        final k = keys[i];');
      sb.writeln('        final v = $fname[k]!;');
      sb.writeln('        ${_writeScalarCall('w', kf.type, 'k')};');
      if (vf.type == _PbType.messageType) {
        sb.writeln(
          '        final vSlot = w.reserveLenAuto(v.estimateBodyBytes());',
        );
        sb.writeln('        v.encodeInto(w, options: options);');
        sb.writeln('        w.patchLenAuto(vSlot);');
      } else {
        sb.writeln('        ${_writeScalarCall('w', vf.type, 'v')};');
      }
      sb.writeln('      }');
      sb.writeln('      w.patchLen2(slot);');
      sb.writeln('    }');
    } else if (f.label == 3) {
      sb.writeln('    if ($fname.isNotEmpty) {');
      sb.writeln('      w.writeTag(${f.number}, ob.WireType.array);');
      if (f.type == _PbType.messageType) {
        sb.writeln('      var est = 8;');
        sb.writeln(
          '      for (var i = 0; i < $fname.length; i++) { est += $fname[i].estimateBodyBytes(); }',
        );
        sb.writeln('      final slot = w.reserveLenAuto(est);');
      } else {
        sb.writeln('      final slot = w.reserveLen2();');
      }
      sb.writeln('      w.writeByte(${_wireTypeConst(f.type)});');
      sb.writeln('      w.writeVarint($fname.length);');
      sb.writeln('      for (var i = 0; i < $fname.length; i++) {');
      if (f.type == _PbType.messageType) {
        sb.writeln('        final item = $fname[i];');
        sb.writeln(
          '        final iSlot = w.reserveLenAuto(item.estimateBodyBytes());',
        );
        sb.writeln('        item.encodeInto(w, options: options);');
        sb.writeln('        w.patchLenAuto(iSlot);');
      } else {
        sb.writeln('        ${_writeScalarCall('w', f.type, '$fname[i]')};');
      }
      sb.writeln('      }');
      if (f.type == _PbType.messageType) {
        sb.writeln('      w.patchLenAuto(slot);');
      } else {
        sb.writeln('      w.patchLen2(slot);');
      }
      sb.writeln('    }');
    } else if (f.type == _PbType.messageType) {
      sb.writeln('    if ($fname != null) {');
      sb.writeln('      final sub = $fname!;');
      sb.writeln('      w.writeTag(${f.number}, ob.WireType.subMsg);');
      sb.writeln(
          '      final slot = w.reserveLenAuto(sub.estimateBodyBytes());');
      sb.writeln('      sub.encodeInto(w, options: options);');
      sb.writeln('      w.patchLenAuto(slot);');
      sb.writeln('    }');
    } else if (f.type == _PbType.boolType) {
      sb.writeln('    if ($fname) {');
      sb.writeln('      w.writeTag(${f.number}, ob.WireType.boolTrue);');
      sb.writeln('    }');
    } else {
      sb.writeln('    if (${_nonZeroCond(f.type, fname)}) {');
      sb.writeln('      w.writeTag(${f.number}, ${_wireTypeConst(f.type)});');
      sb.writeln('      ${_writeScalarCall('w', f.type, fname)};');
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
  sb.writeln('    final r = ob.OmniBufReader(data);');
  sb.writeln('    decodeBody(r, 0, options);');
  sb.writeln('  }');
  sb.writeln();

  // decodeBody()
  sb.writeln(
    '  void decodeBody(ob.OmniBufReader r, int depth, ob.DecodeOptions options) {',
  );
  sb.writeln('    while (r.hasMore) {');
  sb.writeln('      final tag = r.readTag();');
  sb.writeln('      final fnum = tag >> 4;');
  sb.writeln('      final wt = tag & 0x0F;');
  sb.writeln('      if (fnum == 0) {');
  sb.writeln('        ob.validateField0SubMsg(r, depth, options.maxDepth);');
  sb.writeln('        continue;');
  sb.writeln('      }');
  sb.writeln('      switch (fnum) {');
  for (final f in sortedFields) {
    final fname = _toCamelCase(f.name);
    sb.writeln('        case ${f.number}:');
    if (isMapField(f)) {
      final entry = mapEntries[f.typeName]!;
      final kf = entry.fields.firstWhere((e) => e.number == 1);
      final vf = entry.fields.firstWhere((e) => e.number == 2);
      sb.writeln('          if (wt != ob.WireType.map) {');
      sb.writeln(
        '            ob.skipAndValidateValue(r, wt, depth, options.maxDepth, maxElements: options.maxCollectionElements);',
      );
      sb.writeln('            break;');
      sb.writeln('          }');
      sb.writeln('          final nextDepth = depth + 1;');
      sb.writeln('          if (nextDepth > options.maxDepth) {');
      sb.writeln(
          '            throw ob.OmniBufDepthLimitException(options.maxDepth);');
      sb.writeln('          }');
      sb.writeln('          final len = r.readCheckedLength();');
      sb.writeln('          final bodyEnd = r.pos + len;');
      sb.writeln('          final body = r.subReader(r.pos, bodyEnd);');
      sb.writeln(
        '          final (kWt, vWt, count) = body.readMapHeader(maxElements: options.maxCollectionElements);',
      );
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
        final vt = _shortTypeName(vf.typeName);
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
        sb.writeln('            v.decodeBody(vSub, vDepth, options);');
        sb.writeln('            body.pos = vEnd;');
        sb.writeln('            $fname[k] = v;');
      } else {
        sb.writeln(
          '            $fname[k] = ${_readScalarExpr('body', vf.type, inCollection: true)};',
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
        '            ob.skipAndValidateValue(r, wt, depth, options.maxDepth, maxElements: options.maxCollectionElements);',
      );
      sb.writeln('            break;');
      sb.writeln('          }');
      sb.writeln('          final nextDepth = depth + 1;');
      sb.writeln('          if (nextDepth > options.maxDepth) {');
      sb.writeln(
          '            throw ob.OmniBufDepthLimitException(options.maxDepth);');
      sb.writeln('          }');
      sb.writeln('          final len = r.readCheckedLength();');
      sb.writeln('          final bodyEnd = r.pos + len;');
      sb.writeln('          final body = r.subReader(r.pos, bodyEnd);');
      sb.writeln(
        '          final (elemWt, count) = body.readArrayHeader(maxElements: options.maxCollectionElements);',
      );
      sb.writeln('          if (elemWt != ${_wireTypeConst(f.type)}) {');
      sb.writeln(
        "            throw ob.OmniBufTypeMismatchException('${f.name} WireArray ElementType mismatch: \$elemWt');",
      );
      sb.writeln('          }');
      sb.writeln('          for (var i = 0; i < count; i++) {');
      if (f.type == _PbType.messageType) {
        final mt = _shortTypeName(f.typeName);
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
        sb.writeln('            item.decodeBody(iSub, itemDepth, options);');
        sb.writeln('            body.pos = iEnd;');
        sb.writeln('            $fname.add(item);');
      } else {
        sb.writeln(
          '            $fname.add(${_readScalarExpr('body', f.type, inCollection: true)});',
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
      final mt = _shortTypeName(f.typeName);
      sb.writeln('          if (wt != ob.WireType.subMsg) {');
      sb.writeln(
        '            ob.skipAndValidateValue(r, wt, depth, options.maxDepth, maxElements: options.maxCollectionElements);',
      );
      sb.writeln('            break;');
      sb.writeln('          }');
      sb.writeln('          final nextDepth = depth + 1;');
      sb.writeln('          if (nextDepth > options.maxDepth) {');
      sb.writeln(
          '            throw ob.OmniBufDepthLimitException(options.maxDepth);');
      sb.writeln('          }');
      sb.writeln('          final len = r.readCheckedLength();');
      sb.writeln('          final subEnd = r.pos + len;');
      sb.writeln('          final sub = r.subReader(r.pos, subEnd);');
      sb.writeln('          final target = $fname ??= $mt();');
      sb.writeln('          target.decodeBody(sub, nextDepth, options);');
      sb.writeln('          r.pos = subEnd;');
    } else if (f.type == _PbType.boolType) {
      sb.writeln(
        '          if (wt != ob.WireType.boolFalse && wt != ob.WireType.boolTrue) {',
      );
      sb.writeln(
        '            ob.skipAndValidateValue(r, wt, depth, options.maxDepth, maxElements: options.maxCollectionElements);',
      );
      sb.writeln('            break;');
      sb.writeln('          }');
      sb.writeln('          $fname = wt == ob.WireType.boolTrue;');
    } else {
      sb.writeln('          if (wt != ${_wireTypeConst(f.type)}) {');
      sb.writeln(
        '            ob.skipAndValidateValue(r, wt, depth, options.maxDepth, maxElements: options.maxCollectionElements);',
      );
      sb.writeln('            break;');
      sb.writeln('          }');
      sb.writeln('          $fname = ${_readScalarExpr('r', f.type)};');
    }
  }
  sb.writeln('        default:');
  sb.writeln(
    '          ob.skipAndValidateValue(r, wt, depth, options.maxDepth, maxElements: options.maxCollectionElements);',
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
    final fname = _toCamelCase(f.name);
    if (isMapField(f)) {
      final entry = mapEntries[f.typeName]!;
      final kf = entry.fields.firstWhere((e) => e.number == 1);
      final vf = entry.fields.firstWhere((e) => e.number == 2);
      final kt = _dartScalarType(kf.type);
      final vt = vf.type == _PbType.messageType
          ? _shortTypeName(vf.typeName)
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
      sb.writeln('    final occs = ob.findAllFields(rawBytes, ${f.number});');
      sb.writeln('    for (var i = 0; i < occs.length; i++) {');
      sb.writeln('      final (start, end, wt) = occs[i];');
      sb.writeln('      if (wt != ob.WireType.map) continue;');
      sb.writeln('      final r = ob.OmniBufReader(rawBytes, start, end);');
      sb.writeln('      final len = r.readCheckedLength();');
      sb.writeln('      final body = r.subReader(r.pos, r.pos + len);');
      sb.writeln('      final (kWt, vWt, count) = body.readMapHeader();');
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
        sb.writeln(
          '        final vSub = body.subReader(body.pos, body.pos + vLen);',
        );
        sb.writeln('        final v = $vt();');
        sb.writeln('        v.decodeBody(vSub, 2, ob.DecodeOptions.defaults);');
        sb.writeln('        body.pos += vLen;');
        sb.writeln('        out[k] = v;');
      } else {
        sb.writeln(
          '        out[k] = ${_readScalarExpr('body', vf.type, inCollection: true)};',
        );
      }
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
          '      final vSlot = w.reserveLenAuto(v.estimateBodyBytes());',
        );
        sb.writeln('      v.encodeInto(w);');
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
          ? _shortTypeName(f.typeName)
          : _dartScalarType(f.type);
      // Getter
      sb.writeln('  List<$et> get $fname {');
      sb.writeln('    final out = <$et>[];');
      sb.writeln('    if (hasPatch(${f.number})) {');
      sb.writeln('      final p = getPatch(${f.number});');
      sb.writeln('      if (p == null || p.isEmpty) return out;');
      sb.writeln('      return $className.decode(p).$fname;');
      sb.writeln('    }');
      sb.writeln('    final occs = ob.findAllFields(rawBytes, ${f.number});');
      sb.writeln('    for (var i = 0; i < occs.length; i++) {');
      sb.writeln('      final (start, end, wt) = occs[i];');
      sb.writeln('      if (wt != ob.WireType.array) continue;');
      sb.writeln('      final r = ob.OmniBufReader(rawBytes, start, end);');
      sb.writeln('      final len = r.readCheckedLength();');
      sb.writeln('      final body = r.subReader(r.pos, r.pos + len);');
      sb.writeln('      final (elemWt, count) = body.readArrayHeader();');
      sb.writeln('      if (elemWt != ${_wireTypeConst(f.type)}) {');
      sb.writeln(
        "        throw ob.OmniBufTypeMismatchException('${f.name} WireArray ElementType mismatch');",
      );
      sb.writeln('      }');
      sb.writeln('      for (var j = 0; j < count; j++) {');
      if (f.type == _PbType.messageType) {
        sb.writeln('        final iLen = body.readCheckedLength();');
        sb.writeln(
          '        final iSub = body.subReader(body.pos, body.pos + iLen);',
        );
        sb.writeln('        final item = $et();');
        sb.writeln(
            '        item.decodeBody(iSub, 2, ob.DecodeOptions.defaults);');
        sb.writeln('        body.pos += iLen;');
        sb.writeln('        out.add(item);');
      } else {
        sb.writeln(
          '        out.add(${_readScalarExpr('body', f.type, inCollection: true)});',
        );
      }
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
          '      final iSlot = w.reserveLenAuto(item.estimateBodyBytes());',
        );
        sb.writeln('      item.encodeInto(w);');
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
      final mt = _shortTypeName(f.typeName);
      // Zero-decode Opaque submessage getter
      sb.writeln('  Opaque$mt? get ${fname}Opaque {');
      sb.writeln('    if (hasPatch(${f.number})) {');
      sb.writeln('      final p = getPatch(${f.number});');
      sb.writeln('      if (p == null || p.isEmpty) return null;');
      sb.writeln('      final r = ob.OmniBufReader(p);');
      sb.writeln('      r.readTag();');
      sb.writeln('      final len = r.readCheckedLength();');
      sb.writeln(
        '      return Opaque$mt(Uint8List.sublistView(p, r.pos, r.pos + len));',
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
        '      return Opaque$mt(Uint8List.sublistView(rawBytes, r.pos, r.pos + len));',
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
      sb.writeln('    return found ? Opaque$mt(w.toBytes()) : null;');
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
      sb.writeln('    final est = value.estimateBodyBytes();');
      sb.writeln('    final w = ob.OmniBufWriter(est + 8);');
      sb.writeln('    w.writeTag(${f.number}, ob.WireType.subMsg);');
      sb.writeln('    final slot = w.reserveLenAuto(est);');
      sb.writeln('    value.encodeInto(w);');
      sb.writeln('    w.patchLenAuto(slot);');
      sb.writeln('    setPatch(${f.number}, w.toBytes());');
      sb.writeln('  }');
      sb.writeln();
      // Opaque submessage setter
      sb.writeln(
          '  void set${fname[0].toUpperCase()}${fname.substring(1)}Opaque(Opaque$mt value) {');
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
            '      if (wt != ${_wireTypeConst(f.type)}) return ${_defaultScalarExpr(f.type)};');
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
            '    if (hit == null) return ${_defaultScalarExpr(f.type)};');
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
