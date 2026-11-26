import '../descriptor.dart';
import 'context.dart';
import 'naming.dart';

/// Emits the lazy `Opaque<ClassName>` zero-decode view class.
void emitOpaqueMessage(
  StringBuffer sb,
  String className,
  List<ProtoFieldDescriptor> sortedFields,
  Map<int, String> fieldNames,
  List<int> realOneofIndices,
  Map<int, String> oneofNames,
  Map<int, List<ProtoFieldDescriptor>> oneofFields,
  CodegenContext ctx,
) {
  sb.writeln('class Opaque$className extends ob.OpaqueMessage {');
  sb.writeln('  Opaque$className(super.rawBytes);');
  sb.writeln();

  for (final idx in realOneofIndices) {
    final oname = oneofNames[idx]!;
    final members = oneofFields[idx]!;
    sb.writeln('  static const Map<int, int> _oneof_$oname = <int, int>{');
    for (final f in members) {
      final wt =
          ctx.isMessageType(f) ? 'ob.WireType.subMsg' : wireTypeConst(f.type);
      sb.writeln('    ${f.number}: $wt,');
    }
    sb.writeln('  };');
    sb.writeln();
    sb.writeln('  int get which_$oname {');
    sb.writeln('    var anyPatch = false;');
    sb.writeln('    for (final fnum in _oneof_$oname.keys) {');
    sb.writeln('      if (hasPatch(fnum)) {');
    sb.writeln('        anyPatch = true;');
    sb.writeln('        final p = getPatch(fnum);');
    sb.writeln('        if (p != null && p.isNotEmpty) return fnum;');
    sb.writeln('      }');
    sb.writeln('    }');
    sb.writeln('    if (anyPatch) return 0;');
    sb.writeln('    return ob.findLastOneofField(rawBytes, _oneof_$oname);');
    sb.writeln('  }');
    sb.writeln();
    sb.writeln('  void clear_$oname() {');
    for (final f in members) {
      sb.writeln('    setPatch(${f.number}, null);');
    }
    sb.writeln('  }');
    sb.writeln();
  }

  for (final f in sortedFields) {
    final fname = fieldNames[f.number]!;
    final oneofName = f.isRealOneof ? oneofNames[f.oneofIndex!] : null;
    if (ctx.isMapField(f)) {
      _emitOpaqueMapAccessors(sb, className, f, fname, ctx);
    } else if (f.label == 3) {
      _emitOpaqueRepeatedAccessors(sb, className, f, fname, ctx);
    } else if (ctx.isMessageType(f)) {
      _emitOpaqueSubMsgAccessors(sb, f, fname, oneofName, ctx);
    } else {
      _emitOpaqueScalarAccessors(sb, f, fname, oneofName);
    }
  }

  sb.writeln('}');
  sb.writeln();
}

void _emitOpaqueMapAccessors(
  StringBuffer sb,
  String className,
  ProtoFieldDescriptor f,
  String fname,
  CodegenContext ctx,
) {
  final (kf, vf) = ctx.mapEntryFor(f);
  final kt = dartScalarType(kf.type);
  final vt =
      ctx.isMessageType(vf) ? ctx.typeOf(vf.typeName) : dartScalarType(vf.type);

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
    '      if (kWt != ${wireTypeConst(kf.type)} || vWt != ${wireTypeConst(vf.type)}) {',
  );
  sb.writeln(
    "        throw ob.OmniBufTypeMismatchException('${f.name} WireMap header mismatch');",
  );
  sb.writeln('      }');
  sb.writeln('      for (var j = 0; j < count; j++) {');
  sb.writeln(
    '        final k = ${readScalarExpr('body', kf.type, inCollection: true)};',
  );
  if (ctx.isMessageType(vf)) {
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
      '        out[k] = ${readScalarExpr('body', vf.type, inCollection: true)};',
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
  sb.writeln('    w.writeByte(${wireTypeConst(kf.type)});');
  sb.writeln('    w.writeByte(${wireTypeConst(vf.type)});');
  sb.writeln('    final keys = value.keys.toList();');
  sb.writeln('    ${mapKeySortStmt('keys', kf.type)}');
  sb.writeln('    w.writeVarint(keys.length);');
  sb.writeln('    for (var i = 0; i < keys.length; i++) {');
  sb.writeln('      final k = keys[i];');
  sb.writeln('      final v = value[k]!;');
  sb.writeln('      ${writeScalarCall('w', kf.type, 'k')};');
  if (ctx.isMessageType(vf)) {
    sb.writeln('      final vSlot = w.reserveLen2();');
    sb.writeln('      v.encodeInto(w, depth: 2);');
    sb.writeln('      w.patchLen2(vSlot);');
  } else {
    sb.writeln('      ${writeScalarCall('w', vf.type, 'v')};');
  }
  sb.writeln('    }');
  sb.writeln('    w.patchLen2(slot);');
  sb.writeln('    setPatch(${f.number}, w.toBytes());');
  sb.writeln('  }');
  sb.writeln();
}

void _emitOpaqueRepeatedAccessors(
  StringBuffer sb,
  String className,
  ProtoFieldDescriptor f,
  String fname,
  CodegenContext ctx,
) {
  final et =
      ctx.isMessageType(f) ? ctx.typeOf(f.typeName) : dartScalarType(f.type);

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
  sb.writeln('      if (elemWt != ${wireTypeConst(f.type)}) {');
  sb.writeln(
    "        throw ob.OmniBufTypeMismatchException('${f.name} WireArray ElementType mismatch');",
  );
  sb.writeln('      }');
  sb.writeln('      for (var j = 0; j < count; j++) {');
  if (ctx.isMessageType(f)) {
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
      '        out.add(${readScalarExpr('body', f.type, inCollection: true)});',
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
  sb.writeln('    w.writeByte(${wireTypeConst(f.type)});');
  sb.writeln('    w.writeVarint(value.length);');
  sb.writeln('    for (var i = 0; i < value.length; i++) {');
  if (ctx.isMessageType(f)) {
    sb.writeln('      final item = value[i];');
    sb.writeln('      final iSlot = w.reserveLen2();');
    sb.writeln('      item.encodeInto(w, depth: 2);');
    sb.writeln('      w.patchLen2(iSlot);');
  } else {
    sb.writeln('      ${writeScalarCall('w', f.type, 'value[i]')};');
  }
  sb.writeln('    }');
  sb.writeln('    w.patchLen2(slot);');
  sb.writeln('    setPatch(${f.number}, w.toBytes());');
  sb.writeln('  }');
  sb.writeln();
}

void _emitOpaqueSubMsgAccessors(
  StringBuffer sb,
  ProtoFieldDescriptor f,
  String fname,
  String? oneofName,
  CodegenContext ctx,
) {
  final mt = ctx.typeOf(f.typeName);
  final omt = ctx.opaqueTypeOf(f.typeName);

  if (oneofName != null) {
    sb.writeln('  bool get has_$fname => which_$oneofName == ${f.number};');
    sb.writeln(
      '  void clear_$fname() { if (which_$oneofName == ${f.number}) { clear_$oneofName(); } }',
    );
  }

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
  if (oneofName != null) {
    sb.writeln('    if (which_$oneofName != ${f.number}) { return null; }');
    sb.writeln(
      '    final occs = ob.findActiveOneofSubMsgFields(rawBytes, ${f.number}, _oneof_$oneofName);',
    );
    sb.writeln('    if (occs.isEmpty) return null;');
    sb.writeln('    if (occs.length == 1) {');
    sb.writeln('      final (start, end) = occs[0];');
    sb.writeln('      final r = ob.OmniBufReader(rawBytes, start, end);');
    sb.writeln('      final len = r.readCheckedLength();');
    sb.writeln(
      '      return $omt(Uint8List.sublistView(rawBytes, r.pos, r.pos + len));',
    );
    sb.writeln('    }');
    sb.writeln('    final w = ob.OmniBufWriter(64);');
    sb.writeln('    for (var i = 0; i < occs.length; i++) {');
    sb.writeln('      final (start, end) = occs[i];');
    sb.writeln('      final r = ob.OmniBufReader(rawBytes, start, end);');
    sb.writeln('      final len = r.readCheckedLength();');
    sb.writeln('      w.writeRawSlice(rawBytes, r.pos, r.pos + len);');
    sb.writeln('    }');
    sb.writeln('    return $omt(w.toBytes());');
  } else {
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
  }
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
  if (oneofName != null) {
    sb.writeln('      clear_$fname();');
  } else {
    sb.writeln('      setPatch(${f.number}, null);');
  }
  sb.writeln('      return;');
  sb.writeln('    }');
  if (oneofName != null) {
    sb.writeln('    clear_$oneofName();');
  }
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
  if (oneofName != null) {
    sb.writeln('    clear_$oneofName();');
  }
  sb.writeln('    final body = value.marshalAppend();');
  sb.writeln('    final w = ob.OmniBufWriter(body.length + 8);');
  sb.writeln('    w.writeTag(${f.number}, ob.WireType.subMsg);');
  sb.writeln('    w.writeVarint(body.length);');
  sb.writeln('    w.writeRawBytes(body);');
  sb.writeln('    setPatch(${f.number}, w.toBytes());');
  sb.writeln('  }');
  sb.writeln();
}

void _emitOpaqueScalarAccessors(
  StringBuffer sb,
  ProtoFieldDescriptor f,
  String fname,
  String? oneofName,
) {
  final dt = dartScalarType(f.type);

  if (oneofName != null) {
    sb.writeln('  bool get has_$fname => which_$oneofName == ${f.number};');
    sb.writeln(
      '  void clear_$fname() { if (which_$oneofName == ${f.number}) { clear_$oneofName(); } }',
    );
  } else if (f.explicitPresence) {
    final wireCheck = f.type == PbType.boolType
        ? 'ob.findLastBoolField(rawBytes, ${f.number}) != null'
        : 'ob.findLastFieldWithWireType(rawBytes, ${f.number}, ${wireTypeConst(f.type)}) != null';
    sb.writeln(
      '  bool get has_$fname => hasPatch(${f.number}) ? (getPatch(${f.number})?.isNotEmpty ?? false) : $wireCheck;',
    );
    sb.writeln('  void clear_$fname() => setPatch(${f.number}, null);');
  }

  // Getter
  sb.writeln('  $dt get $fname {');
  sb.writeln('    if (hasPatch(${f.number})) {');
  sb.writeln('      final p = getPatch(${f.number});');
  sb.writeln(
    '      if (p == null || p.isEmpty) return ${defaultScalarExpr(f.type)};',
  );
  sb.writeln('      final r = ob.OmniBufReader(p);');
  sb.writeln('      final tag = r.readTag();');
  sb.writeln('      final wt = tag & 0x0F;');
  if (f.type == PbType.boolType) {
    sb.writeln('      return wt == ob.WireType.boolTrue;');
  } else {
    sb.writeln(
      '      if (wt != ${wireTypeConst(f.type)}) { return ${defaultScalarExpr(f.type)}; }',
    );
    sb.writeln('      return ${readScalarExpr('r', f.type)};');
  }
  sb.writeln('    }');
  if (oneofName != null) {
    sb.writeln(
      '    if (which_$oneofName != ${f.number}) { return ${defaultScalarExpr(f.type)}; }',
    );
  }
  if (f.type == PbType.boolType) {
    sb.writeln(
      '    final wt = ob.findLastBoolField(rawBytes, ${f.number});',
    );
    sb.writeln('    return wt == ob.WireType.boolTrue;');
  } else {
    sb.writeln(
      '    final hit = ob.findLastFieldWithWireType(rawBytes, ${f.number}, ${wireTypeConst(f.type)});',
    );
    sb.writeln(
      '    if (hit == null) return ${defaultScalarExpr(f.type)};',
    );
    sb.writeln('    final (start, end, _) = hit;');
    sb.writeln('    final r = ob.OmniBufReader(rawBytes, start, end);');
    sb.writeln('    return ${readScalarExpr('r', f.type)};');
  }
  sb.writeln('  }');
  sb.writeln();

  // Setter
  sb.writeln('  set $fname($dt value) {');
  if (oneofName != null) {
    sb.writeln('    clear_$oneofName();');
  }
  final keepZero = oneofName != null || f.explicitPresence;
  if (f.type == PbType.boolType) {
    if (!keepZero) {
      sb.writeln('    if (!value) {');
      sb.writeln('      setPatch(${f.number}, null);');
      sb.writeln('      return;');
      sb.writeln('    }');
    }
    sb.writeln('    final w = ob.OmniBufWriter(8);');
    sb.writeln(
      '    w.writeTag(${f.number}, value ? ob.WireType.boolTrue : ob.WireType.boolFalse);',
    );
    sb.writeln('    setPatch(${f.number}, w.toBytes());');
  } else {
    if (!keepZero) {
      sb.writeln('    if (!(${nonZeroCond(f.type, 'value')})) {');
      sb.writeln('      setPatch(${f.number}, null);');
      sb.writeln('      return;');
      sb.writeln('    }');
    }
    sb.writeln('    final w = ob.OmniBufWriter(32);');
    sb.writeln('    w.writeTag(${f.number}, ${wireTypeConst(f.type)});');
    sb.writeln('    ${writeScalarCall('w', f.type, 'value')};');
    sb.writeln('    setPatch(${f.number}, w.toBytes());');
  }
  sb.writeln('  }');
  sb.writeln();
}
