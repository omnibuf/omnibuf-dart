import '../descriptor.dart';
import 'context.dart';
import 'naming.dart';

/// Emits the eager message class (fields, constructor, reset, sizing, schema
/// metadata, encode, decode, equality, hashCode, and toString).
void emitEagerMessage(
  StringBuffer sb,
  String className,
  String fullName,
  List<ProtoFieldDescriptor> sortedFields,
  Map<int, String> fieldNames,
  List<int> realOneofIndices,
  Map<int, String> oneofNames,
  Map<int, List<ProtoFieldDescriptor>> oneofFields,
  CodegenContext ctx,
) {
  sb.writeln('class $className {');
  _emitFields(
    sb,
    sortedFields,
    fieldNames,
    realOneofIndices,
    oneofNames,
    oneofFields,
    ctx,
  );
  _emitConstructor(sb, className, sortedFields, fieldNames, ctx);
  _emitReset(sb, sortedFields, fieldNames, realOneofIndices, oneofNames, ctx);
  _emitEstimateBodyBytes(sb, sortedFields, fieldNames, oneofNames, ctx);
  _emitBuildSchemaMeta(sb, fullName, sortedFields, ctx);
  _emitEncode(sb);
  _emitEncodeInto(sb, sortedFields, fieldNames, oneofNames, ctx);
  _emitDecode(sb, className);
  _emitDecodeBody(sb, sortedFields, fieldNames, oneofNames, ctx);
  _emitEqualityAndToString(
    sb,
    className,
    sortedFields,
    fieldNames,
    realOneofIndices,
    oneofNames,
    ctx,
  );
  sb.writeln('}');
  sb.writeln();
}

void _emitFields(
  StringBuffer sb,
  List<ProtoFieldDescriptor> sortedFields,
  Map<int, String> fieldNames,
  List<int> realOneofIndices,
  Map<int, String> oneofNames,
  Map<int, List<ProtoFieldDescriptor>> oneofFields,
  CodegenContext ctx,
) {
  for (final idx in realOneofIndices) {
    final oname = oneofNames[idx]!;
    final members = oneofFields[idx]!;
    sb.writeln('  int _which_$oname = 0;');
    sb.writeln('  int get which_$oname => _which_$oname;');
    sb.writeln('  void clear_$oname() {');
    sb.writeln('    switch (_which_$oname) {');
    for (final f in members) {
      final fname = fieldNames[f.number]!;
      sb.writeln('      case ${f.number}:');
      if (ctx.isMessageType(f)) {
        sb.writeln('        _$fname = null;');
      } else {
        sb.writeln('        _$fname = ${defaultScalarExpr(f.type)};');
      }
    }
    sb.writeln('    }');
    sb.writeln('    _which_$oname = 0;');
    sb.writeln('  }');
  }

  for (final f in sortedFields) {
    final fname = fieldNames[f.number]!;
    if (ctx.isMapField(f)) {
      final (kf, vf) = ctx.mapEntryFor(f);
      final kt = dartScalarType(kf.type);
      final vt = ctx.isMessageType(vf)
          ? ctx.typeOf(vf.typeName)
          : dartScalarType(vf.type);
      sb.writeln('  Map<$kt, $vt> $fname;');
    } else if (f.label == 3) {
      final et = ctx.isMessageType(f)
          ? ctx.typeOf(f.typeName)
          : dartScalarType(f.type);
      sb.writeln('  List<$et> $fname;');
    } else if (f.isRealOneof) {
      final oname = oneofNames[f.oneofIndex!]!;
      if (ctx.isMessageType(f)) {
        final mt = ctx.typeOf(f.typeName);
        sb.writeln('  $mt? _$fname;');
        sb.writeln('  bool get has_$fname => _which_$oname == ${f.number};');
        sb.writeln('  $mt? get $fname => _$fname;');
        sb.writeln('  set $fname($mt? value) {');
        sb.writeln('    if (value == null) {');
        sb.writeln('      clear_$fname();');
        sb.writeln('      return;');
        sb.writeln('    }');
        sb.writeln('    if (_which_$oname != ${f.number}) {');
        sb.writeln('      clear_$oname();');
        sb.writeln('      _which_$oname = ${f.number};');
        sb.writeln('    }');
        sb.writeln('    _$fname = value;');
        sb.writeln('  }');
        sb.writeln('  void clear_$fname() {');
        sb.writeln('    if (_which_$oname == ${f.number}) {');
        sb.writeln('      _$fname = null;');
        sb.writeln('      _which_$oname = 0;');
        sb.writeln('    }');
        sb.writeln('  }');
      } else {
        final type = dartScalarType(f.type);
        sb.writeln('  $type _$fname;');
        sb.writeln('  bool get has_$fname => _which_$oname == ${f.number};');
        sb.writeln('  $type get $fname => _$fname;');
        sb.writeln('  set $fname($type value) {');
        sb.writeln('    if (_which_$oname != ${f.number}) {');
        sb.writeln('      clear_$oname();');
        sb.writeln('      _which_$oname = ${f.number};');
        sb.writeln('    }');
        sb.writeln('    _$fname = value;');
        sb.writeln('  }');
        sb.writeln('  void clear_$fname() {');
        sb.writeln('    if (_which_$oname == ${f.number}) {');
        sb.writeln('      _$fname = ${defaultScalarExpr(f.type)};');
        sb.writeln('      _which_$oname = 0;');
        sb.writeln('    }');
        sb.writeln('  }');
      }
    } else if (ctx.isMessageType(f)) {
      final mt = ctx.typeOf(f.typeName);
      sb.writeln('  $mt? $fname;');
    } else if (f.explicitPresence) {
      final type = dartScalarType(f.type);
      sb.writeln('  $type _$fname;');
      sb.writeln('  bool _has_$fname;');
      sb.writeln('  bool get has_$fname => _has_$fname;');
      sb.writeln('  $type get $fname => _$fname;');
      sb.writeln(
        '  set $fname($type value) { _$fname = value; _has_$fname = true; }',
      );
      sb.writeln(
        '  void clear_$fname() { _$fname = ${defaultScalarExpr(f.type)}; _has_$fname = false; }',
      );
    } else {
      sb.writeln('  ${dartScalarType(f.type)} $fname;');
    }
  }
  sb.writeln();
}

void _emitConstructor(
  StringBuffer sb,
  String className,
  List<ProtoFieldDescriptor> sortedFields,
  Map<int, String> fieldNames,
  CodegenContext ctx,
) {
  if (sortedFields.isEmpty) {
    sb.writeln('  $className();');
    sb.writeln();
    return;
  }
  final inits = <String>[];
  final bodyStmts = <String>[];
  sb.writeln('  $className({');
  for (final f in sortedFields) {
    final fname = fieldNames[f.number]!;
    if (ctx.isMapField(f)) {
      final (kf, vf) = ctx.mapEntryFor(f);
      final kt = dartScalarType(kf.type);
      final vt = ctx.isMessageType(vf)
          ? ctx.typeOf(vf.typeName)
          : dartScalarType(vf.type);
      sb.writeln('    Map<$kt, $vt>? $fname,');
      inits.add('this.$fname = $fname ?? <$kt, $vt>{}');
    } else if (f.label == 3) {
      final et = ctx.isMessageType(f)
          ? ctx.typeOf(f.typeName)
          : dartScalarType(f.type);
      sb.writeln('    List<$et>? $fname,');
      inits.add('this.$fname = $fname ?? <$et>[]');
    } else if (f.isRealOneof) {
      if (ctx.isMessageType(f)) {
        final mt = ctx.typeOf(f.typeName);
        sb.writeln('    $mt? $fname,');
      } else {
        sb.writeln('    ${dartScalarType(f.type)}? $fname,');
        inits.add('_$fname = ${defaultScalarExpr(f.type)}');
      }
      bodyStmts.add('if ($fname != null) { this.$fname = $fname; }');
    } else if (ctx.isMessageType(f)) {
      sb.writeln('    this.$fname,');
    } else if (f.explicitPresence) {
      sb.writeln('    ${dartScalarType(f.type)}? $fname,');
      inits.add('_$fname = $fname ?? ${defaultScalarExpr(f.type)}');
      inits.add('_has_$fname = $fname != null');
    } else if (f.type == PbType.bytesType) {
      sb.writeln('    Uint8List? $fname,');
      inits.add('this.$fname = $fname ?? Uint8List(0)');
    } else {
      sb.writeln('    this.$fname = ${defaultScalarExpr(f.type)},');
    }
  }
  if (inits.isEmpty && bodyStmts.isEmpty) {
    sb.writeln('  });');
  } else if (inits.isNotEmpty && bodyStmts.isEmpty) {
    sb.writeln('  }) : ${inits.join(',\n       ')};');
  } else if (inits.isEmpty) {
    sb.writeln('  }) {');
    for (final stmt in bodyStmts) {
      sb.writeln('    $stmt');
    }
    sb.writeln('  }');
  } else {
    sb.writeln('  }) : ${inits.join(',\n       ')} {');
    for (final stmt in bodyStmts) {
      sb.writeln('    $stmt');
    }
    sb.writeln('  }');
  }
  sb.writeln();
}

void _emitReset(
  StringBuffer sb,
  List<ProtoFieldDescriptor> sortedFields,
  Map<int, String> fieldNames,
  List<int> realOneofIndices,
  Map<int, String> oneofNames,
  CodegenContext ctx,
) {
  sb.writeln('  void reset() {');
  for (final idx in realOneofIndices) {
    sb.writeln('    clear_${oneofNames[idx]!}();');
  }
  for (final f in sortedFields) {
    if (f.isRealOneof) continue;
    final fname = fieldNames[f.number]!;
    if (f.explicitPresence) {
      sb.writeln('    clear_$fname();');
    } else if (ctx.isMapField(f)) {
      sb.writeln('    this.$fname.clear();');
    } else if (f.label == 3) {
      sb.writeln('    this.$fname.clear();');
    } else if (ctx.isMessageType(f)) {
      sb.writeln('    this.$fname = null;');
    } else if (f.type == PbType.bytesType) {
      sb.writeln('    this.$fname = Uint8List(0);');
    } else {
      sb.writeln('    this.$fname = ${defaultScalarExpr(f.type)};');
    }
  }
  sb.writeln('  }');
  sb.writeln();
}

void _emitEstimateBodyBytes(
  StringBuffer sb,
  List<ProtoFieldDescriptor> sortedFields,
  Map<int, String> fieldNames,
  Map<int, String> oneofNames,
  CodegenContext ctx,
) {
  sb.writeln('  int estimateBodyBytes([int depth = 0]) {');
  sb.writeln('    if (depth > ob.DecodeOptions.defaultMaxDepth) {');
  sb.writeln(
    "      throw const ob.OmniBufSerializeException('message encoding depth exceeded limit of \${ob.DecodeOptions.defaultMaxDepth}');",
  );
  sb.writeln('    }');
  sb.writeln('    var n = 32;');
  for (final f in sortedFields) {
    final fname = fieldNames[f.number]!;
    if (ctx.isMapField(f)) {
      final (_, vf) = ctx.mapEntryFor(f);
      if (ctx.isMessageType(vf)) {
        sb.writeln(
          '    for (final v in this.$fname.values) { n += v.estimateBodyBytes(depth + 2); }',
        );
      }
    } else if (f.isRealOneof) {
      final oname = oneofNames[f.oneofIndex!]!;
      if (ctx.isMessageType(f)) {
        sb.writeln(
          '    if (this._which_$oname == ${f.number} && this._$fname != null) { n += this._$fname!.estimateBodyBytes(depth + 1); }',
        );
      } else if (f.type == PbType.stringType || f.type == PbType.bytesType) {
        sb.writeln(
          '    if (this._which_$oname == ${f.number}) { n += this._$fname.length; }',
        );
      }
    } else if (f.label != 3 &&
        (f.type == PbType.stringType || f.type == PbType.bytesType)) {
      sb.writeln('    n += this.$fname.length;');
    } else if (f.label != 3 && ctx.isMessageType(f)) {
      sb.writeln(
        '    if (this.$fname != null) { n += this.$fname!.estimateBodyBytes(depth + 1); }',
      );
    } else if (f.label == 3 && !ctx.isMapField(f) && ctx.isMessageType(f)) {
      sb.writeln(
        '    for (var i = 0; i < this.$fname.length; i++) { n += this.$fname[i].estimateBodyBytes(depth + 2); }',
      );
    } else if (f.label == 3 &&
        !ctx.isMapField(f) &&
        (f.type == PbType.stringType || f.type == PbType.bytesType)) {
      sb.writeln(
        '    for (var i = 0; i < this.$fname.length; i++) { n += this.$fname[i].length + 4; }',
      );
    }
  }
  sb.writeln('    return n;');
  sb.writeln('  }');
  sb.writeln();
}

void _emitBuildSchemaMeta(
  StringBuffer sb,
  String fullName,
  List<ProtoFieldDescriptor> sortedFields,
  CodegenContext ctx,
) {
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
    if (ctx.isMapField(f)) {
      final (_, vf) = ctx.mapEntryFor(f);
      if (ctx.isMessageType(vf)) {
        final vt = ctx.typeOf(vf.typeName);
        sb.writeln(
          '      children[${f.number}] = $vt.buildSchemaMeta(maxDepth: maxDepth - depth - 2);',
        );
      }
    } else if (ctx.isMessageType(f)) {
      final mt = ctx.typeOf(f.typeName);
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
}

void _emitEncode(StringBuffer sb) {
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
}

void _emitEncodeInto(
  StringBuffer sb,
  List<ProtoFieldDescriptor> sortedFields,
  Map<int, String> fieldNames,
  Map<int, String> oneofNames,
  CodegenContext ctx,
) {
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
    if (ctx.isMapField(f)) {
      _emitEncodeMapField(sb, f, fname, ctx);
    } else if (f.label == 3) {
      _emitEncodeRepeatedField(sb, f, fname, ctx);
    } else if (f.isRealOneof) {
      final oname = oneofNames[f.oneofIndex!]!;
      if (ctx.isMessageType(f)) {
        sb.writeln(
          '    if (this._which_$oname == ${f.number} && this._$fname != null) {',
        );
        sb.writeln('      final sub = this._$fname!;');
        sb.writeln('      w.writeTag(${f.number}, ob.WireType.subMsg);');
        sb.writeln('      final slot = w.reserveLen2();');
        sb.writeln(
          '      sub.encodeInto(w, options: options, depth: depth + 1);',
        );
        sb.writeln('      w.patchLen2(slot);');
        sb.writeln('    }');
      } else {
        sb.writeln('    if (this._which_$oname == ${f.number}) {');
        if (f.type == PbType.boolType) {
          sb.writeln(
            '      w.writeTag(${f.number}, this._$fname ? ob.WireType.boolTrue : ob.WireType.boolFalse);',
          );
        } else {
          sb.writeln(
              '      w.writeTag(${f.number}, ${wireTypeConst(f.type)});');
          sb.writeln('      ${writeScalarCall('w', f.type, 'this._$fname')};');
        }
        sb.writeln('    }');
      }
    } else if (ctx.isMessageType(f)) {
      _emitEncodeSubMsgField(sb, f, fname);
    } else if (f.explicitPresence) {
      sb.writeln('    if (this._has_$fname) {');
      if (f.type == PbType.boolType) {
        sb.writeln(
          '      w.writeTag(${f.number}, this._$fname ? ob.WireType.boolTrue : ob.WireType.boolFalse);',
        );
      } else {
        sb.writeln('      w.writeTag(${f.number}, ${wireTypeConst(f.type)});');
        sb.writeln('      ${writeScalarCall('w', f.type, 'this._$fname')};');
      }
      sb.writeln('    }');
    } else if (f.type == PbType.boolType) {
      sb.writeln('    if (this.$fname) {');
      sb.writeln('      w.writeTag(${f.number}, ob.WireType.boolTrue);');
      sb.writeln('    }');
    } else {
      sb.writeln('    if (${nonZeroCond(f.type, 'this.$fname')}) {');
      sb.writeln('      w.writeTag(${f.number}, ${wireTypeConst(f.type)});');
      sb.writeln('      ${writeScalarCall('w', f.type, 'this.$fname')};');
      sb.writeln('    }');
    }
  }
  sb.writeln('  }');
  sb.writeln();
}

void _emitEncodeMapField(
  StringBuffer sb,
  ProtoFieldDescriptor f,
  String fname,
  CodegenContext ctx,
) {
  final (kf, vf) = ctx.mapEntryFor(f);
  sb.writeln('    if (this.$fname.isNotEmpty) {');
  sb.writeln('      w.writeTag(${f.number}, ob.WireType.map);');
  sb.writeln('      final slot = w.reserveLen2();');
  sb.writeln('      w.writeByte(${wireTypeConst(kf.type)});');
  sb.writeln('      w.writeByte(${wireTypeConst(vf.type)});');
  sb.writeln('      final keys = this.$fname.keys.toList();');
  sb.writeln('      if (options.deterministicMaps) {');
  sb.writeln('        ${mapKeySortStmt('keys', kf.type)}');
  sb.writeln('      }');
  sb.writeln('      w.writeVarint(keys.length);');
  sb.writeln('      for (var i = 0; i < keys.length; i++) {');
  sb.writeln('        final k = keys[i];');
  sb.writeln('        final v = this.$fname[k]!;');
  sb.writeln('        ${writeScalarCall('w', kf.type, 'k')};');
  if (ctx.isMessageType(vf)) {
    sb.writeln('        final vSlot = w.reserveLen2();');
    sb.writeln(
      '        v.encodeInto(w, options: options, depth: depth + 2);',
    );
    sb.writeln('        w.patchLen2(vSlot);');
  } else {
    sb.writeln('        ${writeScalarCall('w', vf.type, 'v')};');
  }
  sb.writeln('      }');
  sb.writeln('      w.patchLen2(slot);');
  sb.writeln('    }');
}

void _emitEncodeRepeatedField(
  StringBuffer sb,
  ProtoFieldDescriptor f,
  String fname,
  CodegenContext ctx,
) {
  sb.writeln('    if (this.$fname.isNotEmpty) {');
  sb.writeln('      w.writeTag(${f.number}, ob.WireType.array);');
  sb.writeln('      final slot = w.reserveLen2();');
  sb.writeln('      w.writeByte(${wireTypeConst(f.type)});');
  sb.writeln('      w.writeVarint(this.$fname.length);');
  sb.writeln('      for (var i = 0; i < this.$fname.length; i++) {');
  if (ctx.isMessageType(f)) {
    sb.writeln('        final item = this.$fname[i];');
    sb.writeln('        final iSlot = w.reserveLen2();');
    sb.writeln(
      '        item.encodeInto(w, options: options, depth: depth + 2);',
    );
    sb.writeln('        w.patchLen2(iSlot);');
  } else {
    sb.writeln(
      '        ${writeScalarCall('w', f.type, 'this.$fname[i]')};',
    );
  }
  sb.writeln('      }');
  sb.writeln('      w.patchLen2(slot);');
  sb.writeln('    }');
}

void _emitEncodeSubMsgField(
  StringBuffer sb,
  ProtoFieldDescriptor f,
  String fname,
) {
  sb.writeln('    if (this.$fname != null) {');
  sb.writeln('      final sub = this.$fname!;');
  sb.writeln('      w.writeTag(${f.number}, ob.WireType.subMsg);');
  sb.writeln('      final slot = w.reserveLen2();');
  sb.writeln(
    '      sub.encodeInto(w, options: options, depth: depth + 1);',
  );
  sb.writeln('      w.patchLen2(slot);');
  sb.writeln('    }');
}

void _emitDecode(StringBuffer sb, String className) {
  sb.writeln(
    '  static $className decode(Uint8List data, {ob.DecodeOptions options = ob.DecodeOptions.defaults}) {',
  );
  sb.writeln('    final msg = $className();');
  sb.writeln('    msg.decodeInto(data, options: options);');
  sb.writeln('    return msg;');
  sb.writeln('  }');
  sb.writeln();
  sb.writeln(
    '  void decodeInto(Uint8List data, {ob.DecodeOptions options = ob.DecodeOptions.defaults}) {',
  );
  sb.writeln('    options.validatedMaxDepth();');
  sb.writeln('    if (data.length > options.maxMessageBytes) {');
  sb.writeln(
    "      throw ob.OmniBufAllocationLimitException('packet size \${data.length} exceeds maxMessageBytes \${options.maxMessageBytes}');",
  );
  sb.writeln('    }');
  sb.writeln('    if (!options.merge) {');
  sb.writeln('      reset();');
  sb.writeln('    }');
  sb.writeln(
    '    final budget = ob.DecodeBudget(options.maxCollectionElements, maxAllocBytes: options.maxAllocBytes);',
  );
  sb.writeln('    final r = ob.OmniBufReader(data);');
  sb.writeln('    decodeBody(r, 0, options, budget);');
  sb.writeln('  }');
  sb.writeln();
}

void _emitDecodeBody(
  StringBuffer sb,
  List<ProtoFieldDescriptor> sortedFields,
  Map<int, String> fieldNames,
  Map<int, String> oneofNames,
  CodegenContext ctx,
) {
  sb.writeln(
    '  void decodeBody(ob.OmniBufReader r, int depth, ob.DecodeOptions options, [ob.DecodeBudget? budget]) {',
  );
  sb.writeln(
    '    final activeBudget = budget ?? ob.DecodeBudget(options.maxCollectionElements, maxAllocBytes: options.maxAllocBytes);',
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
    if (ctx.isMapField(f)) {
      _emitDecodeMapField(sb, f, fname, ctx);
    } else if (f.label == 3) {
      _emitDecodeRepeatedField(sb, f, fname, ctx);
    } else if (ctx.isMessageType(f)) {
      _emitDecodeSubMsgField(
        sb,
        f,
        fname,
        f.isRealOneof ? oneofNames[f.oneofIndex!] : null,
        ctx,
      );
    } else if (f.type == PbType.boolType) {
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
      sb.writeln('          if (wt != ${wireTypeConst(f.type)}) {');
      sb.writeln(
        '            ob.skipAndValidateValue(r, wt, depth, options.maxDepth, maxElements: options.maxCollectionElements, budget: activeBudget);',
      );
      sb.writeln('            break;');
      sb.writeln('          }');
      sb.writeln(
        '          this.$fname = ${readScalarExpr('r', f.type, budgetVar: 'activeBudget')};',
      );
    }
  }
  sb.writeln('        default:');
  sb.writeln(
    '          ob.skipAndValidateValue(r, wt, depth, options.maxDepth, maxElements: options.maxCollectionElements, budget: activeBudget);',
  );
  sb.writeln('      }');
  sb.writeln('    }');
  sb.writeln('  }');
  sb.writeln();
}

void _emitDecodeMapField(
  StringBuffer sb,
  ProtoFieldDescriptor f,
  String fname,
  CodegenContext ctx,
) {
  final (kf, vf) = ctx.mapEntryFor(f);
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
    '          if (kWt != ${wireTypeConst(kf.type)} || vWt != ${wireTypeConst(vf.type)}) {',
  );
  sb.writeln(
    "            throw ob.OmniBufTypeMismatchException('${f.name} WireMap header mismatch: <\$kWt, \$vWt>');",
  );
  sb.writeln('          }');
  sb.writeln('          for (var i = 0; i < count; i++) {');
  sb.writeln(
    '            final k = ${readScalarExpr('body', kf.type, inCollection: true, budgetVar: 'activeBudget')};',
  );
  if (ctx.isMessageType(vf)) {
    final vt = ctx.typeOf(vf.typeName);
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
      '            v.decodeBody(vSub, vDepth, options, activeBudget);',
    );
    sb.writeln('            body.pos = vEnd;');
    sb.writeln('            this.$fname[k] = v;');
  } else {
    sb.writeln(
      '            this.$fname[k] = ${readScalarExpr('body', vf.type, inCollection: true, budgetVar: 'activeBudget')};',
    );
  }
  sb.writeln('          }');
  sb.writeln('          if (body.pos != bodyEnd) {');
  sb.writeln(
    "            throw const ob.OmniBufParseException('WireMap trailing bytes');",
  );
  sb.writeln('          }');
  sb.writeln('          r.pos = bodyEnd;');
}

void _emitDecodeRepeatedField(
  StringBuffer sb,
  ProtoFieldDescriptor f,
  String fname,
  CodegenContext ctx,
) {
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
  sb.writeln('          if (elemWt != ${wireTypeConst(f.type)}) {');
  sb.writeln(
    "            throw ob.OmniBufTypeMismatchException('${f.name} WireArray ElementType mismatch: \$elemWt');",
  );
  sb.writeln('          }');
  sb.writeln('          for (var i = 0; i < count; i++) {');
  if (ctx.isMessageType(f)) {
    final mt = ctx.typeOf(f.typeName);
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
      '            this.$fname.add(${readScalarExpr('body', f.type, inCollection: true, budgetVar: 'activeBudget')});',
    );
  }
  sb.writeln('          }');
  sb.writeln('          if (body.pos != bodyEnd) {');
  sb.writeln(
    "            throw const ob.OmniBufParseException('WireArray trailing bytes');",
  );
  sb.writeln('          }');
  sb.writeln('          r.pos = bodyEnd;');
}

void _emitDecodeSubMsgField(
  StringBuffer sb,
  ProtoFieldDescriptor f,
  String fname,
  String? oneofName,
  CodegenContext ctx,
) {
  final mt = ctx.typeOf(f.typeName);
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
  if (oneofName != null) {
    sb.writeln('          final $mt target;');
    sb.writeln(
      '          if (this._which_$oneofName == ${f.number} && this._$fname != null) {',
    );
    sb.writeln('            target = this._$fname!;');
    sb.writeln('          } else {');
    sb.writeln('            target = $mt();');
    sb.writeln('            this.$fname = target;');
    sb.writeln('          }');
  } else {
    sb.writeln('          final target = this.$fname ??= $mt();');
  }
  sb.writeln(
    '          target.decodeBody(sub, nextDepth, options, activeBudget);',
  );
  sb.writeln('          r.pos = subEnd;');
}

void _emitEqualityAndToString(
  StringBuffer sb,
  String className,
  List<ProtoFieldDescriptor> sortedFields,
  Map<int, String> fieldNames,
  List<int> realOneofIndices,
  Map<int, String> oneofNames,
  CodegenContext ctx,
) {
  sb.writeln('  @override');
  sb.writeln('  bool operator ==(Object other) {');
  sb.writeln('    if (identical(this, other)) return true;');
  sb.writeln('    if (other is! $className) return false;');
  if (sortedFields.isEmpty) {
    sb.writeln('    return true;');
  } else {
    final checks = <String>[];
    for (final idx in realOneofIndices) {
      final oname = oneofNames[idx]!;
      checks.add('this._which_$oname == other._which_$oname');
    }
    for (final f in sortedFields) {
      final fname = fieldNames[f.number]!;
      if (ctx.isMapField(f)) {
        checks.add('ob.mapEquals(this.$fname, other.$fname)');
      } else if (f.label == 3) {
        checks.add('ob.listEquals(this.$fname, other.$fname)');
      } else if (f.isRealOneof) {
        if (f.type == PbType.bytesType) {
          checks.add('ob.bytesEquals(this._$fname, other._$fname)');
        } else {
          checks.add('this._$fname == other._$fname');
        }
      } else if (f.explicitPresence) {
        if (f.type == PbType.bytesType) {
          checks.add(
            'this._has_$fname == other._has_$fname && (!this._has_$fname || ob.bytesEquals(this._$fname, other._$fname))',
          );
        } else {
          checks.add(
            'this._has_$fname == other._has_$fname && (!this._has_$fname || this._$fname == other._$fname)',
          );
        }
      } else if (f.type == PbType.bytesType) {
        checks.add('ob.bytesEquals(this.$fname, other.$fname)');
      } else {
        checks.add('this.$fname == other.$fname');
      }
    }
    sb.writeln('    return ${checks.join(' &&\n        ')};');
  }
  sb.writeln('  }');
  sb.writeln();

  sb.writeln('  @override');
  if (sortedFields.isEmpty) {
    sb.writeln('  int get hashCode => 0;');
  } else {
    final hashExprs = <String>[];
    for (final idx in realOneofIndices) {
      final oname = oneofNames[idx]!;
      hashExprs.add('this._which_$oname');
    }
    for (final f in sortedFields) {
      final fname = fieldNames[f.number]!;
      if (ctx.isMapField(f)) {
        hashExprs.add('ob.mapHash(this.$fname)');
      } else if (f.label == 3) {
        hashExprs.add('ob.listHash(this.$fname)');
      } else if (f.isRealOneof) {
        if (f.type == PbType.bytesType) {
          hashExprs.add('ob.bytesHash(this._$fname)');
        } else {
          hashExprs.add('this._$fname');
        }
      } else if (f.explicitPresence) {
        hashExprs.add('this._has_$fname');
        if (f.type == PbType.bytesType) {
          hashExprs.add('ob.bytesHash(this._$fname)');
        } else {
          hashExprs.add('this._$fname');
        }
      } else if (f.type == PbType.bytesType) {
        hashExprs.add('ob.bytesHash(this.$fname)');
      } else {
        hashExprs.add('this.$fname');
      }
    }
    sb.writeln(
      '  int get hashCode => Object.hashAll([${hashExprs.join(', ')}]);',
    );
  }
  sb.writeln();

  sb.writeln('  @override');
  if (sortedFields.isEmpty) {
    sb.writeln("  String toString() => '$className()';");
  } else {
    final parts = <String>[];
    for (final f in sortedFields) {
      final fname = fieldNames[f.number]!;
      if (f.isRealOneof) {
        final oname = oneofNames[f.oneofIndex!]!;
        parts.add(
          '$fname: \${this._which_$oname == ${f.number} ? this._$fname : null}',
        );
      } else if (f.explicitPresence) {
        parts.add('$fname: \${this._has_$fname ? this._$fname : null}');
      } else {
        parts.add('$fname: \${this.$fname}');
      }
    }
    sb.writeln("  String toString() => '$className(${parts.join(', ')})';");
  }
}
