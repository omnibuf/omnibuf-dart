// GENERATED CODE - DO NOT MODIFY BY HAND.
// Source: omnibuf/bench/peer.proto
// ignore_for_file: unused_import, constant_identifier_names, non_constant_identifier_names, prefer_final_locals

import 'dart:typed_data';

import 'package:omnibuf/omnibuf.dart' as ob;

class Location {
  String region;
  String datacenter;
  String city;
  int rack;
  double latitude;
  double longitude;

  Location({
    this.region = '',
    this.datacenter = '',
    this.city = '',
    this.rack = 0,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  void reset() {
    region = '';
    datacenter = '';
    city = '';
    rack = 0;
    latitude = 0.0;
    longitude = 0.0;
  }

  int estimateBodyBytes() {
    var n = 32;
    n += region.length;
    n += datacenter.length;
    n += city.length;
    return n;
  }

  static ob.SchemaMeta buildSchemaMeta({int maxDepth = 16}) {
    return _buildSchemaMeta(0, maxDepth);
  }

  static ob.SchemaMeta _buildSchemaMeta(int depth, int maxDepth) {
    final fields = <int, String>{
      1: 'region',
      2: 'datacenter',
      3: 'city',
      4: 'rack',
      5: 'latitude',
      6: 'longitude',
    };
    final children = <int, ob.SchemaMeta>{};
    if (depth + 2 <= maxDepth) {}
    return ob.SchemaMeta(
        typeName: 'omnibuf.bench.Location', fields: fields, children: children);
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
    if (region.isNotEmpty) {
      w.writeTag(1, ob.WireType.string);
      w.writeString(region);
    }
    if (datacenter.isNotEmpty) {
      w.writeTag(2, ob.WireType.string);
      w.writeString(datacenter);
    }
    if (city.isNotEmpty) {
      w.writeTag(3, ob.WireType.string);
      w.writeString(city);
    }
    if (rack != 0) {
      w.writeTag(4, ob.WireType.uint);
      w.writeVarint(rack & 0xFFFFFFFF);
    }
    if (latitude != 0.0 || latitude.isNegative) {
      w.writeTag(5, ob.WireType.float32);
      w.writeFloat32(latitude);
    }
    if (longitude != 0.0 || longitude.isNegative) {
      w.writeTag(6, ob.WireType.float32);
      w.writeFloat32(longitude);
    }
  }

  static Location decode(Uint8List data,
      {ob.DecodeOptions options = ob.DecodeOptions.defaults}) {
    final msg = Location();
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
          region = r.readString();
        case 2:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements);
            break;
          }
          datacenter = r.readString();
        case 3:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements);
            break;
          }
          city = r.readString();
        case 4:
          if (wt != ob.WireType.uint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements);
            break;
          }
          rack = r.readUint32();
        case 5:
          if (wt != ob.WireType.float32) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements);
            break;
          }
          latitude = r.readFloat32();
        case 6:
          if (wt != ob.WireType.float32) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements);
            break;
          }
          longitude = r.readFloat32();
        default:
          ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
              maxElements: options.maxCollectionElements);
      }
    }
  }
}

class OpaqueLocation extends ob.OpaqueMessage {
  OpaqueLocation(super.rawBytes);

  String get region {
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

  set region(String value) {
    if (!(value.isNotEmpty)) {
      setPatch(1, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(1, ob.WireType.string);
    w.writeString(value);
    setPatch(1, w.toBytes());
  }

  String get datacenter {
    if (hasPatch(2)) {
      final p = getPatch(2);
      if (p == null || p.isEmpty) return '';
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.string) return '';
      return r.readString();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 2, ob.WireType.string);
    if (hit == null) return '';
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readString();
  }

  set datacenter(String value) {
    if (!(value.isNotEmpty)) {
      setPatch(2, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(2, ob.WireType.string);
    w.writeString(value);
    setPatch(2, w.toBytes());
  }

  String get city {
    if (hasPatch(3)) {
      final p = getPatch(3);
      if (p == null || p.isEmpty) return '';
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.string) return '';
      return r.readString();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 3, ob.WireType.string);
    if (hit == null) return '';
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readString();
  }

  set city(String value) {
    if (!(value.isNotEmpty)) {
      setPatch(3, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(3, ob.WireType.string);
    w.writeString(value);
    setPatch(3, w.toBytes());
  }

  int get rack {
    if (hasPatch(4)) {
      final p = getPatch(4);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.uint) return 0;
      return r.readUint32();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 4, ob.WireType.uint);
    if (hit == null) return 0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readUint32();
  }

  set rack(int value) {
    if (!(value != 0)) {
      setPatch(4, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(4, ob.WireType.uint);
    w.writeVarint(value & 0xFFFFFFFF);
    setPatch(4, w.toBytes());
  }

  double get latitude {
    if (hasPatch(5)) {
      final p = getPatch(5);
      if (p == null || p.isEmpty) return 0.0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.float32) return 0.0;
      return r.readFloat32();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 5, ob.WireType.float32);
    if (hit == null) return 0.0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readFloat32();
  }

  set latitude(double value) {
    if (!(value != 0.0 || value.isNegative)) {
      setPatch(5, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(5, ob.WireType.float32);
    w.writeFloat32(value);
    setPatch(5, w.toBytes());
  }

  double get longitude {
    if (hasPatch(6)) {
      final p = getPatch(6);
      if (p == null || p.isEmpty) return 0.0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.float32) return 0.0;
      return r.readFloat32();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 6, ob.WireType.float32);
    if (hit == null) return 0.0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readFloat32();
  }

  set longitude(double value) {
    if (!(value != 0.0 || value.isNegative)) {
      setPatch(6, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(6, ob.WireType.float32);
    w.writeFloat32(value);
    setPatch(6, w.toBytes());
  }
}

class Neighbor {
  int peerAsn;
  String router;
  int latencyUs;
  bool established;

  Neighbor({
    this.peerAsn = 0,
    this.router = '',
    this.latencyUs = 0,
    this.established = false,
  });

  void reset() {
    peerAsn = 0;
    router = '';
    latencyUs = 0;
    established = false;
  }

  int estimateBodyBytes() {
    var n = 32;
    n += router.length;
    return n;
  }

  static ob.SchemaMeta buildSchemaMeta({int maxDepth = 16}) {
    return _buildSchemaMeta(0, maxDepth);
  }

  static ob.SchemaMeta _buildSchemaMeta(int depth, int maxDepth) {
    final fields = <int, String>{
      1: 'peer_asn',
      2: 'router',
      3: 'latency_us',
      4: 'established',
    };
    final children = <int, ob.SchemaMeta>{};
    if (depth + 2 <= maxDepth) {}
    return ob.SchemaMeta(
        typeName: 'omnibuf.bench.Neighbor', fields: fields, children: children);
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
    if (peerAsn != 0) {
      w.writeTag(1, ob.WireType.uint);
      w.writeVarint(peerAsn & 0xFFFFFFFF);
    }
    if (router.isNotEmpty) {
      w.writeTag(2, ob.WireType.string);
      w.writeString(router);
    }
    if (latencyUs != 0) {
      w.writeTag(3, ob.WireType.uint);
      w.writeVarint(latencyUs & 0xFFFFFFFF);
    }
    if (established) {
      w.writeTag(4, ob.WireType.boolTrue);
    }
  }

  static Neighbor decode(Uint8List data,
      {ob.DecodeOptions options = ob.DecodeOptions.defaults}) {
    final msg = Neighbor();
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
          if (wt != ob.WireType.uint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements);
            break;
          }
          peerAsn = r.readUint32();
        case 2:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements);
            break;
          }
          router = r.readString();
        case 3:
          if (wt != ob.WireType.uint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements);
            break;
          }
          latencyUs = r.readUint32();
        case 4:
          if (wt != ob.WireType.boolFalse && wt != ob.WireType.boolTrue) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements);
            break;
          }
          established = wt == ob.WireType.boolTrue;
        default:
          ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
              maxElements: options.maxCollectionElements);
      }
    }
  }
}

class OpaqueNeighbor extends ob.OpaqueMessage {
  OpaqueNeighbor(super.rawBytes);

  int get peerAsn {
    if (hasPatch(1)) {
      final p = getPatch(1);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.uint) return 0;
      return r.readUint32();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 1, ob.WireType.uint);
    if (hit == null) return 0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readUint32();
  }

  set peerAsn(int value) {
    if (!(value != 0)) {
      setPatch(1, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(1, ob.WireType.uint);
    w.writeVarint(value & 0xFFFFFFFF);
    setPatch(1, w.toBytes());
  }

  String get router {
    if (hasPatch(2)) {
      final p = getPatch(2);
      if (p == null || p.isEmpty) return '';
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.string) return '';
      return r.readString();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 2, ob.WireType.string);
    if (hit == null) return '';
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readString();
  }

  set router(String value) {
    if (!(value.isNotEmpty)) {
      setPatch(2, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(2, ob.WireType.string);
    w.writeString(value);
    setPatch(2, w.toBytes());
  }

  int get latencyUs {
    if (hasPatch(3)) {
      final p = getPatch(3);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.uint) return 0;
      return r.readUint32();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 3, ob.WireType.uint);
    if (hit == null) return 0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readUint32();
  }

  set latencyUs(int value) {
    if (!(value != 0)) {
      setPatch(3, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(3, ob.WireType.uint);
    w.writeVarint(value & 0xFFFFFFFF);
    setPatch(3, w.toBytes());
  }

  bool get established {
    if (hasPatch(4)) {
      final p = getPatch(4);
      if (p == null || p.isEmpty) return false;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      return wt == ob.WireType.boolTrue;
    }
    final wt = ob.findLastBoolField(rawBytes, 4);
    return wt == ob.WireType.boolTrue;
  }

  set established(bool value) {
    if (!value) {
      setPatch(4, null);
      return;
    }
    final w = ob.OmniBufWriter(8);
    w.writeTag(4, ob.WireType.boolTrue);
    setPatch(4, w.toBytes());
  }
}

class PeerUpdate {
  int asn;
  String routerId;
  bool active;
  int uptimeSec;
  int rssiDbm;
  double cpuLoad;
  List<String> tags;
  List<int> prefixes;
  Location? location;
  List<Neighbor> neighbors;
  int sequence;

  PeerUpdate({
    this.asn = 0,
    this.routerId = '',
    this.active = false,
    this.uptimeSec = 0,
    this.rssiDbm = 0,
    this.cpuLoad = 0.0,
    List<String>? tags,
    List<int>? prefixes,
    this.location,
    List<Neighbor>? neighbors,
    this.sequence = 0,
  })  : tags = tags ?? <String>[],
        prefixes = prefixes ?? <int>[],
        neighbors = neighbors ?? <Neighbor>[];

  void reset() {
    asn = 0;
    routerId = '';
    active = false;
    uptimeSec = 0;
    rssiDbm = 0;
    cpuLoad = 0.0;
    tags.clear();
    prefixes.clear();
    location = null;
    neighbors.clear();
    sequence = 0;
  }

  int estimateBodyBytes() {
    var n = 32;
    n += routerId.length;
    for (var i = 0; i < tags.length; i++) {
      n += tags[i].length + 4;
    }
    if (location != null) n += location!.estimateBodyBytes();
    for (var i = 0; i < neighbors.length; i++) {
      n += neighbors[i].estimateBodyBytes();
    }
    return n;
  }

  static ob.SchemaMeta buildSchemaMeta({int maxDepth = 16}) {
    return _buildSchemaMeta(0, maxDepth);
  }

  static ob.SchemaMeta _buildSchemaMeta(int depth, int maxDepth) {
    final fields = <int, String>{
      1: 'asn',
      2: 'router_id',
      3: 'active',
      4: 'uptime_sec',
      5: 'rssi_dbm',
      6: 'cpu_load',
      7: 'tags',
      8: 'prefixes',
      9: 'location',
      10: 'neighbors',
      11: 'sequence',
    };
    final children = <int, ob.SchemaMeta>{};
    if (depth + 2 <= maxDepth) {
      children[9] = Location._buildSchemaMeta(depth + 2, maxDepth);
      children[10] = Neighbor._buildSchemaMeta(depth + 2, maxDepth);
    }
    return ob.SchemaMeta(
        typeName: 'omnibuf.bench.PeerUpdate',
        fields: fields,
        children: children);
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
    if (asn != 0) {
      w.writeTag(1, ob.WireType.uint);
      w.writeVarint(asn & 0xFFFFFFFF);
    }
    if (routerId.isNotEmpty) {
      w.writeTag(2, ob.WireType.string);
      w.writeString(routerId);
    }
    if (active) {
      w.writeTag(3, ob.WireType.boolTrue);
    }
    if (uptimeSec != 0) {
      w.writeTag(4, ob.WireType.uint);
      w.writeVarint(uptimeSec);
    }
    if (rssiDbm != 0) {
      w.writeTag(5, ob.WireType.sint);
      w.writeSint32(rssiDbm);
    }
    if (cpuLoad != 0.0 || cpuLoad.isNegative) {
      w.writeTag(6, ob.WireType.float64);
      w.writeFloat64(cpuLoad);
    }
    if (tags.isNotEmpty) {
      w.writeTag(7, ob.WireType.array);
      final slot = w.reserveLen2();
      w.writeByte(ob.WireType.string);
      w.writeVarint(tags.length);
      for (var i = 0; i < tags.length; i++) {
        w.writeString(tags[i]);
      }
      w.patchLen2(slot);
    }
    if (prefixes.isNotEmpty) {
      w.writeTag(8, ob.WireType.array);
      final slot = w.reserveLen2();
      w.writeByte(ob.WireType.uint);
      w.writeVarint(prefixes.length);
      for (var i = 0; i < prefixes.length; i++) {
        w.writeVarint(prefixes[i] & 0xFFFFFFFF);
      }
      w.patchLen2(slot);
    }
    if (location != null) {
      final sub = location!;
      w.writeTag(9, ob.WireType.subMsg);
      final slot = w.reserveLenAuto(sub.estimateBodyBytes());
      sub.encodeInto(w, options: options);
      w.patchLenAuto(slot);
    }
    if (neighbors.isNotEmpty) {
      w.writeTag(10, ob.WireType.array);
      var est = 8;
      for (var i = 0; i < neighbors.length; i++) {
        est += neighbors[i].estimateBodyBytes();
      }
      final slot = w.reserveLenAuto(est);
      w.writeByte(ob.WireType.subMsg);
      w.writeVarint(neighbors.length);
      for (var i = 0; i < neighbors.length; i++) {
        final item = neighbors[i];
        final iSlot = w.reserveLenAuto(item.estimateBodyBytes());
        item.encodeInto(w, options: options);
        w.patchLenAuto(iSlot);
      }
      w.patchLenAuto(slot);
    }
    if (sequence != 0) {
      w.writeTag(11, ob.WireType.uint);
      w.writeVarint(sequence);
    }
  }

  static PeerUpdate decode(Uint8List data,
      {ob.DecodeOptions options = ob.DecodeOptions.defaults}) {
    final msg = PeerUpdate();
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
          if (wt != ob.WireType.uint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements);
            break;
          }
          asn = r.readUint32();
        case 2:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements);
            break;
          }
          routerId = r.readString();
        case 3:
          if (wt != ob.WireType.boolFalse && wt != ob.WireType.boolTrue) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements);
            break;
          }
          active = wt == ob.WireType.boolTrue;
        case 4:
          if (wt != ob.WireType.uint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements);
            break;
          }
          uptimeSec = r.readVarint();
        case 5:
          if (wt != ob.WireType.sint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements);
            break;
          }
          rssiDbm = r.readSint32();
        case 6:
          if (wt != ob.WireType.float64) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements);
            break;
          }
          cpuLoad = r.readFloat64();
        case 7:
          if (wt != ob.WireType.array) {
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
          final (elemWt, count) =
              body.readArrayHeader(maxElements: options.maxCollectionElements);
          if (elemWt != ob.WireType.string) {
            throw ob.OmniBufTypeMismatchException(
                'tags WireArray ElementType mismatch: $elemWt');
          }
          for (var i = 0; i < count; i++) {
            tags.add(body.readString());
          }
          if (body.pos != bodyEnd) {
            throw const ob.OmniBufParseException('WireArray trailing bytes');
          }
          r.pos = bodyEnd;
        case 8:
          if (wt != ob.WireType.array) {
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
          final (elemWt, count) =
              body.readArrayHeader(maxElements: options.maxCollectionElements);
          if (elemWt != ob.WireType.uint) {
            throw ob.OmniBufTypeMismatchException(
                'prefixes WireArray ElementType mismatch: $elemWt');
          }
          for (var i = 0; i < count; i++) {
            prefixes.add(body.readUint32());
          }
          if (body.pos != bodyEnd) {
            throw const ob.OmniBufParseException('WireArray trailing bytes');
          }
          r.pos = bodyEnd;
        case 9:
          if (wt != ob.WireType.subMsg) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements);
            break;
          }
          final nextDepth = depth + 1;
          if (nextDepth > options.maxDepth) {
            throw ob.OmniBufDepthLimitException(options.maxDepth);
          }
          final len = r.readCheckedLength();
          final subEnd = r.pos + len;
          final sub = r.subReader(r.pos, subEnd);
          final target = location ??= Location();
          target.decodeBody(sub, nextDepth, options);
          r.pos = subEnd;
        case 10:
          if (wt != ob.WireType.array) {
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
          final (elemWt, count) =
              body.readArrayHeader(maxElements: options.maxCollectionElements);
          if (elemWt != ob.WireType.subMsg) {
            throw ob.OmniBufTypeMismatchException(
                'neighbors WireArray ElementType mismatch: $elemWt');
          }
          for (var i = 0; i < count; i++) {
            final itemDepth = nextDepth + 1;
            if (itemDepth > options.maxDepth) {
              throw ob.OmniBufDepthLimitException(options.maxDepth);
            }
            final iLen = body.readCheckedLength();
            final iEnd = body.pos + iLen;
            final iSub = body.subReader(body.pos, iEnd);
            final item = Neighbor();
            item.decodeBody(iSub, itemDepth, options);
            body.pos = iEnd;
            neighbors.add(item);
          }
          if (body.pos != bodyEnd) {
            throw const ob.OmniBufParseException('WireArray trailing bytes');
          }
          r.pos = bodyEnd;
        case 11:
          if (wt != ob.WireType.uint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements);
            break;
          }
          sequence = r.readVarint();
        default:
          ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
              maxElements: options.maxCollectionElements);
      }
    }
  }
}

class OpaquePeerUpdate extends ob.OpaqueMessage {
  OpaquePeerUpdate(super.rawBytes);

  int get asn {
    if (hasPatch(1)) {
      final p = getPatch(1);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.uint) return 0;
      return r.readUint32();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 1, ob.WireType.uint);
    if (hit == null) return 0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readUint32();
  }

  set asn(int value) {
    if (!(value != 0)) {
      setPatch(1, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(1, ob.WireType.uint);
    w.writeVarint(value & 0xFFFFFFFF);
    setPatch(1, w.toBytes());
  }

  String get routerId {
    if (hasPatch(2)) {
      final p = getPatch(2);
      if (p == null || p.isEmpty) return '';
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.string) return '';
      return r.readString();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 2, ob.WireType.string);
    if (hit == null) return '';
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readString();
  }

  set routerId(String value) {
    if (!(value.isNotEmpty)) {
      setPatch(2, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(2, ob.WireType.string);
    w.writeString(value);
    setPatch(2, w.toBytes());
  }

  bool get active {
    if (hasPatch(3)) {
      final p = getPatch(3);
      if (p == null || p.isEmpty) return false;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      return wt == ob.WireType.boolTrue;
    }
    final wt = ob.findLastBoolField(rawBytes, 3);
    return wt == ob.WireType.boolTrue;
  }

  set active(bool value) {
    if (!value) {
      setPatch(3, null);
      return;
    }
    final w = ob.OmniBufWriter(8);
    w.writeTag(3, ob.WireType.boolTrue);
    setPatch(3, w.toBytes());
  }

  int get uptimeSec {
    if (hasPatch(4)) {
      final p = getPatch(4);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.uint) return 0;
      return r.readVarint();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 4, ob.WireType.uint);
    if (hit == null) return 0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readVarint();
  }

  set uptimeSec(int value) {
    if (!(value != 0)) {
      setPatch(4, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(4, ob.WireType.uint);
    w.writeVarint(value);
    setPatch(4, w.toBytes());
  }

  int get rssiDbm {
    if (hasPatch(5)) {
      final p = getPatch(5);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.sint) return 0;
      return r.readSint32();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 5, ob.WireType.sint);
    if (hit == null) return 0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readSint32();
  }

  set rssiDbm(int value) {
    if (!(value != 0)) {
      setPatch(5, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(5, ob.WireType.sint);
    w.writeSint32(value);
    setPatch(5, w.toBytes());
  }

  double get cpuLoad {
    if (hasPatch(6)) {
      final p = getPatch(6);
      if (p == null || p.isEmpty) return 0.0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.float64) return 0.0;
      return r.readFloat64();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 6, ob.WireType.float64);
    if (hit == null) return 0.0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readFloat64();
  }

  set cpuLoad(double value) {
    if (!(value != 0.0 || value.isNegative)) {
      setPatch(6, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(6, ob.WireType.float64);
    w.writeFloat64(value);
    setPatch(6, w.toBytes());
  }

  List<String> get tags {
    final out = <String>[];
    if (hasPatch(7)) {
      final p = getPatch(7);
      if (p == null || p.isEmpty) return out;
      return PeerUpdate.decode(p).tags;
    }
    final occs = ob.findAllFields(rawBytes, 7);
    for (var i = 0; i < occs.length; i++) {
      final (start, end, wt) = occs[i];
      if (wt != ob.WireType.array) continue;
      final r = ob.OmniBufReader(rawBytes, start, end);
      final len = r.readCheckedLength();
      final body = r.subReader(r.pos, r.pos + len);
      final (elemWt, count) = body.readArrayHeader();
      if (elemWt != ob.WireType.string) {
        throw ob.OmniBufTypeMismatchException(
            'tags WireArray ElementType mismatch');
      }
      for (var j = 0; j < count; j++) {
        out.add(body.readString());
      }
    }
    return out;
  }

  set tags(List<String> value) {
    if (value.isEmpty) {
      setPatch(7, null);
      return;
    }
    final w = ob.OmniBufWriter(64);
    w.writeTag(7, ob.WireType.array);
    final slot = w.reserveLen2();
    w.writeByte(ob.WireType.string);
    w.writeVarint(value.length);
    for (var i = 0; i < value.length; i++) {
      w.writeString(value[i]);
    }
    w.patchLen2(slot);
    setPatch(7, w.toBytes());
  }

  List<int> get prefixes {
    final out = <int>[];
    if (hasPatch(8)) {
      final p = getPatch(8);
      if (p == null || p.isEmpty) return out;
      return PeerUpdate.decode(p).prefixes;
    }
    final occs = ob.findAllFields(rawBytes, 8);
    for (var i = 0; i < occs.length; i++) {
      final (start, end, wt) = occs[i];
      if (wt != ob.WireType.array) continue;
      final r = ob.OmniBufReader(rawBytes, start, end);
      final len = r.readCheckedLength();
      final body = r.subReader(r.pos, r.pos + len);
      final (elemWt, count) = body.readArrayHeader();
      if (elemWt != ob.WireType.uint) {
        throw ob.OmniBufTypeMismatchException(
            'prefixes WireArray ElementType mismatch');
      }
      for (var j = 0; j < count; j++) {
        out.add(body.readUint32());
      }
    }
    return out;
  }

  set prefixes(List<int> value) {
    if (value.isEmpty) {
      setPatch(8, null);
      return;
    }
    final w = ob.OmniBufWriter(64);
    w.writeTag(8, ob.WireType.array);
    final slot = w.reserveLen2();
    w.writeByte(ob.WireType.uint);
    w.writeVarint(value.length);
    for (var i = 0; i < value.length; i++) {
      w.writeVarint(value[i] & 0xFFFFFFFF);
    }
    w.patchLen2(slot);
    setPatch(8, w.toBytes());
  }

  OpaqueLocation? get locationOpaque {
    if (hasPatch(9)) {
      final p = getPatch(9);
      if (p == null || p.isEmpty) return null;
      final r = ob.OmniBufReader(p);
      r.readTag();
      final len = r.readCheckedLength();
      return OpaqueLocation(Uint8List.sublistView(p, r.pos, r.pos + len));
    }
    final occs = ob.findAllFields(rawBytes, 9);
    if (occs.isEmpty) return null;
    if (occs.length == 1) {
      final (start, end, wt) = occs[0];
      if (wt != ob.WireType.subMsg) return null;
      final r = ob.OmniBufReader(rawBytes, start, end);
      final len = r.readCheckedLength();
      return OpaqueLocation(
          Uint8List.sublistView(rawBytes, r.pos, r.pos + len));
    }
    final w = ob.OmniBufWriter(64);
    var found = false;
    for (var i = 0; i < occs.length; i++) {
      final (start, end, wt) = occs[i];
      if (wt != ob.WireType.subMsg) continue;
      found = true;
      final r = ob.OmniBufReader(rawBytes, start, end);
      final len = r.readCheckedLength();
      w.writeRawSlice(rawBytes, r.pos, r.pos + len);
    }
    return found ? OpaqueLocation(w.toBytes()) : null;
  }

  Location? get location {
    final op = locationOpaque;
    if (op == null) return null;
    return Location.decode(op.rawBytes);
  }

  set location(Location? value) {
    if (value == null) {
      setPatch(9, null);
      return;
    }
    final est = value.estimateBodyBytes();
    final w = ob.OmniBufWriter(est + 8);
    w.writeTag(9, ob.WireType.subMsg);
    final slot = w.reserveLenAuto(est);
    value.encodeInto(w);
    w.patchLenAuto(slot);
    setPatch(9, w.toBytes());
  }

  void setLocationOpaque(OpaqueLocation value) {
    final body = value.marshalAppend();
    final w = ob.OmniBufWriter(body.length + 8);
    w.writeTag(9, ob.WireType.subMsg);
    w.writeVarint(body.length);
    w.writeRawBytes(body);
    setPatch(9, w.toBytes());
  }

  List<Neighbor> get neighbors {
    final out = <Neighbor>[];
    if (hasPatch(10)) {
      final p = getPatch(10);
      if (p == null || p.isEmpty) return out;
      return PeerUpdate.decode(p).neighbors;
    }
    final occs = ob.findAllFields(rawBytes, 10);
    for (var i = 0; i < occs.length; i++) {
      final (start, end, wt) = occs[i];
      if (wt != ob.WireType.array) continue;
      final r = ob.OmniBufReader(rawBytes, start, end);
      final len = r.readCheckedLength();
      final body = r.subReader(r.pos, r.pos + len);
      final (elemWt, count) = body.readArrayHeader();
      if (elemWt != ob.WireType.subMsg) {
        throw ob.OmniBufTypeMismatchException(
            'neighbors WireArray ElementType mismatch');
      }
      for (var j = 0; j < count; j++) {
        final iLen = body.readCheckedLength();
        final iSub = body.subReader(body.pos, body.pos + iLen);
        final item = Neighbor();
        item.decodeBody(iSub, 2, ob.DecodeOptions.defaults);
        body.pos += iLen;
        out.add(item);
      }
    }
    return out;
  }

  set neighbors(List<Neighbor> value) {
    if (value.isEmpty) {
      setPatch(10, null);
      return;
    }
    final w = ob.OmniBufWriter(64);
    w.writeTag(10, ob.WireType.array);
    final slot = w.reserveLen2();
    w.writeByte(ob.WireType.subMsg);
    w.writeVarint(value.length);
    for (var i = 0; i < value.length; i++) {
      final item = value[i];
      final iSlot = w.reserveLenAuto(item.estimateBodyBytes());
      item.encodeInto(w);
      w.patchLenAuto(iSlot);
    }
    w.patchLen2(slot);
    setPatch(10, w.toBytes());
  }

  int get sequence {
    if (hasPatch(11)) {
      final p = getPatch(11);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.uint) return 0;
      return r.readVarint();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 11, ob.WireType.uint);
    if (hit == null) return 0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readVarint();
  }

  set sequence(int value) {
    if (!(value != 0)) {
      setPatch(11, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(11, ob.WireType.uint);
    w.writeVarint(value);
    setPatch(11, w.toBytes());
  }
}
