// GENERATED CODE - DO NOT MODIFY BY HAND.
// Source: omnibuf/v1/meta.proto
// ignore_for_file: unused_import, constant_identifier_names, non_constant_identifier_names, prefer_final_locals

import 'dart:typed_data';

import 'package:omnibuf/omnibuf.dart' as ob;

class SchemaMeta {
  String typeName;
  Map<int, String> fields;
  Map<int, SchemaMeta> children;

  SchemaMeta({
    this.typeName = '',
    Map<int, String>? fields,
    Map<int, SchemaMeta>? children,
  })  : fields = fields ?? <int, String>{},
        children = children ?? <int, SchemaMeta>{};

  void reset() {
    typeName = '';
    fields.clear();
    children.clear();
  }

  int estimateBodyBytes() {
    var n = 32;
    n += typeName.length;
    return n;
  }

  static ob.SchemaMeta buildSchemaMeta({int maxDepth = 16}) {
    return _buildSchemaMeta(0, maxDepth);
  }

  static ob.SchemaMeta _buildSchemaMeta(int depth, int maxDepth) {
    final fields = <int, String>{
      1: 'type_name',
      2: 'fields',
      3: 'children',
    };
    final children = <int, ob.SchemaMeta>{};
    if (depth + 2 <= maxDepth) {
      children[3] = SchemaMeta._buildSchemaMeta(depth + 2, maxDepth);
    }
    return ob.SchemaMeta(
        typeName: 'omnibuf.v1.SchemaMeta', fields: fields, children: children);
  }

  Uint8List encode({ob.EncodeOptions options = ob.EncodeOptions.defaults}) {
    final w = ob.OmniBufWriter(estimateBodyBytes());
    if (options.selfDescribing) {
      buildSchemaMeta().writeField0(w);
    }
    encodeInto(w, options: options);
    return w.toBytes();
  }

  void encodeInto(ob.OmniBufWriter w,
      {ob.EncodeOptions options = ob.EncodeOptions.defaults}) {
    if (typeName.isNotEmpty) {
      w.writeTag(1, ob.WireType.string);
      w.writeString(typeName);
    }
    if (fields.isNotEmpty) {
      w.writeTag(2, ob.WireType.map);
      final slot = w.reserveLen2();
      w.writeByte(ob.WireType.uint);
      w.writeByte(ob.WireType.string);
      final keys = fields.keys.toList();
      if (options.deterministicMaps) {
        keys.sort(ob.compareUint64);
      }
      w.writeVarint(keys.length);
      for (var i = 0; i < keys.length; i++) {
        final k = keys[i];
        final v = fields[k]!;
        w.writeVarint(k & 0xFFFFFFFF);
        w.writeString(v);
      }
      w.patchLen2(slot);
    }
    if (children.isNotEmpty) {
      w.writeTag(3, ob.WireType.map);
      final slot = w.reserveLen2();
      w.writeByte(ob.WireType.uint);
      w.writeByte(ob.WireType.subMsg);
      final keys = children.keys.toList();
      if (options.deterministicMaps) {
        keys.sort(ob.compareUint64);
      }
      w.writeVarint(keys.length);
      for (var i = 0; i < keys.length; i++) {
        final k = keys[i];
        final v = children[k]!;
        w.writeVarint(k & 0xFFFFFFFF);
        final vSlot = w.reserveLenAuto(v.estimateBodyBytes());
        v.encodeInto(w, options: options);
        w.patchLenAuto(vSlot);
      }
      w.patchLen2(slot);
    }
  }

  static SchemaMeta decode(Uint8List data,
      {ob.DecodeOptions options = ob.DecodeOptions.defaults}) {
    final msg = SchemaMeta();
    msg.decodeInto(data, options: options);
    return msg;
  }

  void decodeInto(Uint8List data,
      {ob.DecodeOptions options = ob.DecodeOptions.defaults}) {
    if (data.length > options.maxMessageBytes) {
      throw ob.OmniBufAllocationLimitException(
          'packet size ${data.length} exceeds maxMessageBytes ${options.maxMessageBytes}');
    }
    if (!options.merge) {
      reset();
    }
    final r = ob.OmniBufReader(data);
    decodeBody(r, 0, options);
  }

  void decodeBody(ob.OmniBufReader r, int depth, ob.DecodeOptions options) {
    while (r.hasMore) {
      final tag = r.readTag();
      final fnum = tag >> 4;
      final wt = tag & 0x0F;
      if (fnum == 0) {
        ob.validateField0SubMsg(r, depth, options.maxDepth);
        continue;
      }
      switch (fnum) {
        case 1:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements);
            break;
          }
          typeName = r.readString();
        case 2:
          if (wt != ob.WireType.map) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements);
            break;
          }
          final nextDepth = depth + 1;
          if (nextDepth > options.maxDepth) {
            throw ob.OmniBufDepthLimitException(options.maxDepth);
          }
          final len = r.readCheckedLength();
          final bodyEnd = r.pos + len;
          final body = r.subReader(r.pos, bodyEnd);
          final (kWt, vWt, count) =
              body.readMapHeader(maxElements: options.maxCollectionElements);
          if (kWt != ob.WireType.uint || vWt != ob.WireType.string) {
            throw ob.OmniBufTypeMismatchException(
                'fields WireMap header mismatch: <$kWt, $vWt>');
          }
          for (var i = 0; i < count; i++) {
            final k = body.readUint32();
            fields[k] = body.readString();
          }
          if (body.pos != bodyEnd) {
            throw const ob.OmniBufParseException('WireMap trailing bytes');
          }
          r.pos = bodyEnd;
        case 3:
          if (wt != ob.WireType.map) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements);
            break;
          }
          final nextDepth = depth + 1;
          if (nextDepth > options.maxDepth) {
            throw ob.OmniBufDepthLimitException(options.maxDepth);
          }
          final len = r.readCheckedLength();
          final bodyEnd = r.pos + len;
          final body = r.subReader(r.pos, bodyEnd);
          final (kWt, vWt, count) =
              body.readMapHeader(maxElements: options.maxCollectionElements);
          if (kWt != ob.WireType.uint || vWt != ob.WireType.subMsg) {
            throw ob.OmniBufTypeMismatchException(
                'children WireMap header mismatch: <$kWt, $vWt>');
          }
          for (var i = 0; i < count; i++) {
            final k = body.readUint32();
            final vDepth = nextDepth + 1;
            if (vDepth > options.maxDepth) {
              throw ob.OmniBufDepthLimitException(options.maxDepth);
            }
            final vLen = body.readCheckedLength();
            final vEnd = body.pos + vLen;
            final vSub = body.subReader(body.pos, vEnd);
            final v = SchemaMeta();
            v.decodeBody(vSub, vDepth, options);
            body.pos = vEnd;
            children[k] = v;
          }
          if (body.pos != bodyEnd) {
            throw const ob.OmniBufParseException('WireMap trailing bytes');
          }
          r.pos = bodyEnd;
        default:
          ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
              maxElements: options.maxCollectionElements);
      }
    }
  }
}

class OpaqueSchemaMeta extends ob.OpaqueMessage {
  OpaqueSchemaMeta(super.rawBytes);

  String get typeName {
    if (hasPatch(1)) {
      final p = getPatch(1);
      if (p == null || p.isEmpty) return '';
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.string) return '';
      return r.readString();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 1, ob.WireType.string);
    if (hit == null) return '';
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readString();
  }

  set typeName(String value) {
    if (!(value.isNotEmpty)) {
      setPatch(1, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(1, ob.WireType.string);
    w.writeString(value);
    setPatch(1, w.toBytes());
  }

  Map<int, String> get fields {
    final out = <int, String>{};
    if (hasPatch(2)) {
      final p = getPatch(2);
      if (p == null || p.isEmpty) return out;
      final tmp = SchemaMeta.decode(p);
      return tmp.fields;
    }
    final occs = ob.findAllFields(rawBytes, 2);
    for (var i = 0; i < occs.length; i++) {
      final (start, end, wt) = occs[i];
      if (wt != ob.WireType.map) continue;
      final r = ob.OmniBufReader(rawBytes, start, end);
      final len = r.readCheckedLength();
      final body = r.subReader(r.pos, r.pos + len);
      final (kWt, vWt, count) = body.readMapHeader();
      if (kWt != ob.WireType.uint || vWt != ob.WireType.string) {
        throw ob.OmniBufTypeMismatchException('fields WireMap header mismatch');
      }
      for (var j = 0; j < count; j++) {
        final k = body.readUint32();
        out[k] = body.readString();
      }
    }
    return out;
  }

  set fields(Map<int, String> value) {
    if (value.isEmpty) {
      setPatch(2, null);
      return;
    }
    final w = ob.OmniBufWriter(64);
    w.writeTag(2, ob.WireType.map);
    final slot = w.reserveLen2();
    w.writeByte(ob.WireType.uint);
    w.writeByte(ob.WireType.string);
    final keys = value.keys.toList();
    keys.sort(ob.compareUint64);
    w.writeVarint(keys.length);
    for (var i = 0; i < keys.length; i++) {
      final k = keys[i];
      final v = value[k]!;
      w.writeVarint(k & 0xFFFFFFFF);
      w.writeString(v);
    }
    w.patchLen2(slot);
    setPatch(2, w.toBytes());
  }

  Map<int, SchemaMeta> get children {
    final out = <int, SchemaMeta>{};
    if (hasPatch(3)) {
      final p = getPatch(3);
      if (p == null || p.isEmpty) return out;
      final tmp = SchemaMeta.decode(p);
      return tmp.children;
    }
    final occs = ob.findAllFields(rawBytes, 3);
    for (var i = 0; i < occs.length; i++) {
      final (start, end, wt) = occs[i];
      if (wt != ob.WireType.map) continue;
      final r = ob.OmniBufReader(rawBytes, start, end);
      final len = r.readCheckedLength();
      final body = r.subReader(r.pos, r.pos + len);
      final (kWt, vWt, count) = body.readMapHeader();
      if (kWt != ob.WireType.uint || vWt != ob.WireType.subMsg) {
        throw ob.OmniBufTypeMismatchException(
            'children WireMap header mismatch');
      }
      for (var j = 0; j < count; j++) {
        final k = body.readUint32();
        final vLen = body.readCheckedLength();
        final vSub = body.subReader(body.pos, body.pos + vLen);
        final v = SchemaMeta();
        v.decodeBody(vSub, 2, ob.DecodeOptions.defaults);
        body.pos += vLen;
        out[k] = v;
      }
    }
    return out;
  }

  set children(Map<int, SchemaMeta> value) {
    if (value.isEmpty) {
      setPatch(3, null);
      return;
    }
    final w = ob.OmniBufWriter(64);
    w.writeTag(3, ob.WireType.map);
    final slot = w.reserveLen2();
    w.writeByte(ob.WireType.uint);
    w.writeByte(ob.WireType.subMsg);
    final keys = value.keys.toList();
    keys.sort(ob.compareUint64);
    w.writeVarint(keys.length);
    for (var i = 0; i < keys.length; i++) {
      final k = keys[i];
      final v = value[k]!;
      w.writeVarint(k & 0xFFFFFFFF);
      final vSlot = w.reserveLenAuto(v.estimateBodyBytes());
      v.encodeInto(w);
      w.patchLenAuto(vSlot);
    }
    w.patchLen2(slot);
    setPatch(3, w.toBytes());
  }
}
