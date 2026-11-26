// GENERATED CODE - DO NOT MODIFY BY HAND.
// Source: omnibuf/bench/peer.proto
// ignore_for_file: unused_import, constant_identifier_names, non_constant_identifier_names, prefer_final_locals, unnecessary_this, camel_case_types

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
    this.region = '';
    this.datacenter = '';
    this.city = '';
    this.rack = 0;
    this.latitude = 0.0;
    this.longitude = 0.0;
  }

  int estimateBodyBytes([int depth = 0]) {
    if (depth > ob.DecodeOptions.defaultMaxDepth) {
      throw const ob.OmniBufSerializeException(
          'message encoding depth exceeded limit of ${ob.DecodeOptions.defaultMaxDepth}');
    }
    var n = 32;
    n += this.region.length;
    n += this.datacenter.length;
    n += this.city.length;
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
      {ob.EncodeOptions options = ob.EncodeOptions.defaults, int depth = 0}) {
    if (depth > ob.DecodeOptions.defaultMaxDepth) {
      throw const ob.OmniBufSerializeException(
          'message encoding depth exceeded limit of ${ob.DecodeOptions.defaultMaxDepth}');
    }
    if (this.region.isNotEmpty) {
      w.writeTag(1, ob.WireType.string);
      w.writeString(this.region);
    }
    if (this.datacenter.isNotEmpty) {
      w.writeTag(2, ob.WireType.string);
      w.writeString(this.datacenter);
    }
    if (this.city.isNotEmpty) {
      w.writeTag(3, ob.WireType.string);
      w.writeString(this.city);
    }
    if (this.rack != 0) {
      w.writeTag(4, ob.WireType.uint);
      w.writeVarint(this.rack & 0xFFFFFFFF);
    }
    if (this.latitude != 0.0 || this.latitude.isNegative) {
      w.writeTag(5, ob.WireType.float32);
      w.writeFloat32(this.latitude);
    }
    if (this.longitude != 0.0 || this.longitude.isNegative) {
      w.writeTag(6, ob.WireType.float32);
      w.writeFloat32(this.longitude);
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
    options.validatedMaxDepth();
    if (data.length > options.maxMessageBytes) {
      throw ob.OmniBufAllocationLimitException(
          'packet size ${data.length} exceeds maxMessageBytes ${options.maxMessageBytes}');
    }
    if (!options.merge) {
      reset();
    }
    final budget = ob.DecodeBudget(options.maxCollectionElements,
        maxAllocBytes: options.maxAllocBytes);
    final r = ob.OmniBufReader(data);
    decodeBody(r, 0, options, budget);
  }

  void decodeBody(ob.OmniBufReader r, int depth, ob.DecodeOptions options,
      [ob.DecodeBudget? budget]) {
    final activeBudget = budget ??
        ob.DecodeBudget(options.maxCollectionElements,
            maxAllocBytes: options.maxAllocBytes);
    while (r.hasMore) {
      final tag = r.readTag();
      final fnum = tag >> 4;
      final wt = tag & 0x0F;
      if (fnum == 0) {
        ob.validateField0SubMsg(r, depth, options.maxDepth,
            maxElements: options.maxCollectionElements, budget: activeBudget);
        continue;
      }
      switch (fnum) {
        case 1:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.region = r.readString(budget: activeBudget);
        case 2:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.datacenter = r.readString(budget: activeBudget);
        case 3:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.city = r.readString(budget: activeBudget);
        case 4:
          if (wt != ob.WireType.uint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.rack = r.readUint32();
        case 5:
          if (wt != ob.WireType.float32) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.latitude = r.readFloat32();
        case 6:
          if (wt != ob.WireType.float32) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.longitude = r.readFloat32();
        default:
          ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
              maxElements: options.maxCollectionElements, budget: activeBudget);
      }
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Location) return false;
    return this.region == other.region &&
        this.datacenter == other.datacenter &&
        this.city == other.city &&
        this.rack == other.rack &&
        this.latitude == other.latitude &&
        this.longitude == other.longitude;
  }

  @override
  int get hashCode => Object.hashAll([
        this.region,
        this.datacenter,
        this.city,
        this.rack,
        this.latitude,
        this.longitude
      ]);

  @override
  String toString() =>
      'Location(region: ${this.region}, datacenter: ${this.datacenter}, city: ${this.city}, rack: ${this.rack}, latitude: ${this.latitude}, longitude: ${this.longitude})';
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
      if (wt != ob.WireType.string) {
        return '';
      }
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
      if (wt != ob.WireType.string) {
        return '';
      }
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
      if (wt != ob.WireType.string) {
        return '';
      }
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
      if (wt != ob.WireType.uint) {
        return 0;
      }
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
      if (wt != ob.WireType.float32) {
        return 0.0;
      }
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
      if (wt != ob.WireType.float32) {
        return 0.0;
      }
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
    this.peerAsn = 0;
    this.router = '';
    this.latencyUs = 0;
    this.established = false;
  }

  int estimateBodyBytes([int depth = 0]) {
    if (depth > ob.DecodeOptions.defaultMaxDepth) {
      throw const ob.OmniBufSerializeException(
          'message encoding depth exceeded limit of ${ob.DecodeOptions.defaultMaxDepth}');
    }
    var n = 32;
    n += this.router.length;
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
      {ob.EncodeOptions options = ob.EncodeOptions.defaults, int depth = 0}) {
    if (depth > ob.DecodeOptions.defaultMaxDepth) {
      throw const ob.OmniBufSerializeException(
          'message encoding depth exceeded limit of ${ob.DecodeOptions.defaultMaxDepth}');
    }
    if (this.peerAsn != 0) {
      w.writeTag(1, ob.WireType.uint);
      w.writeVarint(this.peerAsn & 0xFFFFFFFF);
    }
    if (this.router.isNotEmpty) {
      w.writeTag(2, ob.WireType.string);
      w.writeString(this.router);
    }
    if (this.latencyUs != 0) {
      w.writeTag(3, ob.WireType.uint);
      w.writeVarint(this.latencyUs & 0xFFFFFFFF);
    }
    if (this.established) {
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
    options.validatedMaxDepth();
    if (data.length > options.maxMessageBytes) {
      throw ob.OmniBufAllocationLimitException(
          'packet size ${data.length} exceeds maxMessageBytes ${options.maxMessageBytes}');
    }
    if (!options.merge) {
      reset();
    }
    final budget = ob.DecodeBudget(options.maxCollectionElements,
        maxAllocBytes: options.maxAllocBytes);
    final r = ob.OmniBufReader(data);
    decodeBody(r, 0, options, budget);
  }

  void decodeBody(ob.OmniBufReader r, int depth, ob.DecodeOptions options,
      [ob.DecodeBudget? budget]) {
    final activeBudget = budget ??
        ob.DecodeBudget(options.maxCollectionElements,
            maxAllocBytes: options.maxAllocBytes);
    while (r.hasMore) {
      final tag = r.readTag();
      final fnum = tag >> 4;
      final wt = tag & 0x0F;
      if (fnum == 0) {
        ob.validateField0SubMsg(r, depth, options.maxDepth,
            maxElements: options.maxCollectionElements, budget: activeBudget);
        continue;
      }
      switch (fnum) {
        case 1:
          if (wt != ob.WireType.uint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.peerAsn = r.readUint32();
        case 2:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.router = r.readString(budget: activeBudget);
        case 3:
          if (wt != ob.WireType.uint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.latencyUs = r.readUint32();
        case 4:
          if (wt != ob.WireType.boolFalse && wt != ob.WireType.boolTrue) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.established = wt == ob.WireType.boolTrue;
        default:
          ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
              maxElements: options.maxCollectionElements, budget: activeBudget);
      }
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Neighbor) return false;
    return this.peerAsn == other.peerAsn &&
        this.router == other.router &&
        this.latencyUs == other.latencyUs &&
        this.established == other.established;
  }

  @override
  int get hashCode => Object.hashAll(
      [this.peerAsn, this.router, this.latencyUs, this.established]);

  @override
  String toString() =>
      'Neighbor(peerAsn: ${this.peerAsn}, router: ${this.router}, latencyUs: ${this.latencyUs}, established: ${this.established})';
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
      if (wt != ob.WireType.uint) {
        return 0;
      }
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
      if (wt != ob.WireType.string) {
        return '';
      }
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
      if (wt != ob.WireType.uint) {
        return 0;
      }
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
    w.writeTag(4, value ? ob.WireType.boolTrue : ob.WireType.boolFalse);
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
  })  : this.tags = tags ?? <String>[],
        this.prefixes = prefixes ?? <int>[],
        this.neighbors = neighbors ?? <Neighbor>[];

  void reset() {
    this.asn = 0;
    this.routerId = '';
    this.active = false;
    this.uptimeSec = 0;
    this.rssiDbm = 0;
    this.cpuLoad = 0.0;
    this.tags.clear();
    this.prefixes.clear();
    this.location = null;
    this.neighbors.clear();
    this.sequence = 0;
  }

  int estimateBodyBytes([int depth = 0]) {
    if (depth > ob.DecodeOptions.defaultMaxDepth) {
      throw const ob.OmniBufSerializeException(
          'message encoding depth exceeded limit of ${ob.DecodeOptions.defaultMaxDepth}');
    }
    var n = 32;
    n += this.routerId.length;
    for (var i = 0; i < this.tags.length; i++) {
      n += this.tags[i].length + 4;
    }
    if (this.location != null) {
      n += this.location!.estimateBodyBytes(depth + 1);
    }
    for (var i = 0; i < this.neighbors.length; i++) {
      n += this.neighbors[i].estimateBodyBytes(depth + 2);
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
      children[9] = Location.buildSchemaMeta(maxDepth: maxDepth - depth - 2);
      children[10] = Neighbor.buildSchemaMeta(maxDepth: maxDepth - depth - 2);
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
      {ob.EncodeOptions options = ob.EncodeOptions.defaults, int depth = 0}) {
    if (depth > ob.DecodeOptions.defaultMaxDepth) {
      throw const ob.OmniBufSerializeException(
          'message encoding depth exceeded limit of ${ob.DecodeOptions.defaultMaxDepth}');
    }
    if (this.asn != 0) {
      w.writeTag(1, ob.WireType.uint);
      w.writeVarint(this.asn & 0xFFFFFFFF);
    }
    if (this.routerId.isNotEmpty) {
      w.writeTag(2, ob.WireType.string);
      w.writeString(this.routerId);
    }
    if (this.active) {
      w.writeTag(3, ob.WireType.boolTrue);
    }
    if (this.uptimeSec != 0) {
      w.writeTag(4, ob.WireType.uint);
      w.writeVarint(this.uptimeSec);
    }
    if (this.rssiDbm != 0) {
      w.writeTag(5, ob.WireType.sint);
      w.writeSint32(this.rssiDbm);
    }
    if (this.cpuLoad != 0.0 || this.cpuLoad.isNegative) {
      w.writeTag(6, ob.WireType.float64);
      w.writeFloat64(this.cpuLoad);
    }
    if (this.tags.isNotEmpty) {
      w.writeTag(7, ob.WireType.array);
      final slot = w.reserveLen2();
      w.writeByte(ob.WireType.string);
      w.writeVarint(this.tags.length);
      for (var i = 0; i < this.tags.length; i++) {
        w.writeString(this.tags[i]);
      }
      w.patchLen2(slot);
    }
    if (this.prefixes.isNotEmpty) {
      w.writeTag(8, ob.WireType.array);
      final slot = w.reserveLen2();
      w.writeByte(ob.WireType.uint);
      w.writeVarint(this.prefixes.length);
      for (var i = 0; i < this.prefixes.length; i++) {
        w.writeVarint(this.prefixes[i] & 0xFFFFFFFF);
      }
      w.patchLen2(slot);
    }
    if (this.location != null) {
      final sub = this.location!;
      w.writeTag(9, ob.WireType.subMsg);
      final slot = w.reserveLen2();
      sub.encodeInto(w, options: options, depth: depth + 1);
      w.patchLen2(slot);
    }
    if (this.neighbors.isNotEmpty) {
      w.writeTag(10, ob.WireType.array);
      final slot = w.reserveLen2();
      w.writeByte(ob.WireType.subMsg);
      w.writeVarint(this.neighbors.length);
      for (var i = 0; i < this.neighbors.length; i++) {
        final item = this.neighbors[i];
        final iSlot = w.reserveLen2();
        item.encodeInto(w, options: options, depth: depth + 2);
        w.patchLen2(iSlot);
      }
      w.patchLen2(slot);
    }
    if (this.sequence != 0) {
      w.writeTag(11, ob.WireType.uint);
      w.writeVarint(this.sequence);
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
    options.validatedMaxDepth();
    if (data.length > options.maxMessageBytes) {
      throw ob.OmniBufAllocationLimitException(
          'packet size ${data.length} exceeds maxMessageBytes ${options.maxMessageBytes}');
    }
    if (!options.merge) {
      reset();
    }
    final budget = ob.DecodeBudget(options.maxCollectionElements,
        maxAllocBytes: options.maxAllocBytes);
    final r = ob.OmniBufReader(data);
    decodeBody(r, 0, options, budget);
  }

  void decodeBody(ob.OmniBufReader r, int depth, ob.DecodeOptions options,
      [ob.DecodeBudget? budget]) {
    final activeBudget = budget ??
        ob.DecodeBudget(options.maxCollectionElements,
            maxAllocBytes: options.maxAllocBytes);
    while (r.hasMore) {
      final tag = r.readTag();
      final fnum = tag >> 4;
      final wt = tag & 0x0F;
      if (fnum == 0) {
        ob.validateField0SubMsg(r, depth, options.maxDepth,
            maxElements: options.maxCollectionElements, budget: activeBudget);
        continue;
      }
      switch (fnum) {
        case 1:
          if (wt != ob.WireType.uint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.asn = r.readUint32();
        case 2:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.routerId = r.readString(budget: activeBudget);
        case 3:
          if (wt != ob.WireType.boolFalse && wt != ob.WireType.boolTrue) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.active = wt == ob.WireType.boolTrue;
        case 4:
          if (wt != ob.WireType.uint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.uptimeSec = r.readVarint();
        case 5:
          if (wt != ob.WireType.sint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.rssiDbm = r.readSint32();
        case 6:
          if (wt != ob.WireType.float64) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.cpuLoad = r.readFloat64();
        case 7:
          if (wt != ob.WireType.array) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
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
          activeBudget.consume(count);
          if (elemWt != ob.WireType.string) {
            throw ob.OmniBufTypeMismatchException(
                'tags WireArray ElementType mismatch: $elemWt');
          }
          for (var i = 0; i < count; i++) {
            this.tags.add(body.readString(budget: activeBudget));
          }
          if (body.pos != bodyEnd) {
            throw const ob.OmniBufParseException('WireArray trailing bytes');
          }
          r.pos = bodyEnd;
        case 8:
          if (wt != ob.WireType.array) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
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
          activeBudget.consume(count);
          if (elemWt != ob.WireType.uint) {
            throw ob.OmniBufTypeMismatchException(
                'prefixes WireArray ElementType mismatch: $elemWt');
          }
          for (var i = 0; i < count; i++) {
            this.prefixes.add(body.readUint32());
          }
          if (body.pos != bodyEnd) {
            throw const ob.OmniBufParseException('WireArray trailing bytes');
          }
          r.pos = bodyEnd;
        case 9:
          if (wt != ob.WireType.subMsg) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          final nextDepth = depth + 1;
          if (nextDepth > options.maxDepth) {
            throw ob.OmniBufDepthLimitException(options.maxDepth);
          }
          final len = r.readCheckedLength();
          final subEnd = r.pos + len;
          final sub = r.subReader(r.pos, subEnd);
          final target = this.location ??= Location();
          target.decodeBody(sub, nextDepth, options, activeBudget);
          r.pos = subEnd;
        case 10:
          if (wt != ob.WireType.array) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
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
          activeBudget.consume(count);
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
            item.decodeBody(iSub, itemDepth, options, activeBudget);
            body.pos = iEnd;
            this.neighbors.add(item);
          }
          if (body.pos != bodyEnd) {
            throw const ob.OmniBufParseException('WireArray trailing bytes');
          }
          r.pos = bodyEnd;
        case 11:
          if (wt != ob.WireType.uint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.sequence = r.readVarint();
        default:
          ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
              maxElements: options.maxCollectionElements, budget: activeBudget);
      }
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PeerUpdate) return false;
    return this.asn == other.asn &&
        this.routerId == other.routerId &&
        this.active == other.active &&
        this.uptimeSec == other.uptimeSec &&
        this.rssiDbm == other.rssiDbm &&
        this.cpuLoad == other.cpuLoad &&
        ob.listEquals(this.tags, other.tags) &&
        ob.listEquals(this.prefixes, other.prefixes) &&
        this.location == other.location &&
        ob.listEquals(this.neighbors, other.neighbors) &&
        this.sequence == other.sequence;
  }

  @override
  int get hashCode => Object.hashAll([
        this.asn,
        this.routerId,
        this.active,
        this.uptimeSec,
        this.rssiDbm,
        this.cpuLoad,
        ob.listHash(this.tags),
        ob.listHash(this.prefixes),
        this.location,
        ob.listHash(this.neighbors),
        this.sequence
      ]);

  @override
  String toString() =>
      'PeerUpdate(asn: ${this.asn}, routerId: ${this.routerId}, active: ${this.active}, uptimeSec: ${this.uptimeSec}, rssiDbm: ${this.rssiDbm}, cpuLoad: ${this.cpuLoad}, tags: ${this.tags}, prefixes: ${this.prefixes}, location: ${this.location}, neighbors: ${this.neighbors}, sequence: ${this.sequence})';
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
      if (wt != ob.WireType.uint) {
        return 0;
      }
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
      if (wt != ob.WireType.string) {
        return '';
      }
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
    w.writeTag(3, value ? ob.WireType.boolTrue : ob.WireType.boolFalse);
    setPatch(3, w.toBytes());
  }

  int get uptimeSec {
    if (hasPatch(4)) {
      final p = getPatch(4);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.uint) {
        return 0;
      }
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
      if (wt != ob.WireType.sint) {
        return 0;
      }
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
      if (wt != ob.WireType.float64) {
        return 0.0;
      }
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
    final budget =
        ob.DecodeBudget(ob.DecodeOptions.defaultMaxCollectionElements);
    final occs = ob.findAllFields(rawBytes, 7);
    for (var i = 0; i < occs.length; i++) {
      final (start, end, wt) = occs[i];
      if (wt != ob.WireType.array) continue;
      final r = ob.OmniBufReader(rawBytes, start, end);
      final len = r.readCheckedLength();
      final bodyEnd = r.pos + len;
      final body = r.subReader(r.pos, bodyEnd);
      final (elemWt, count) = body.readArrayHeader();
      budget.consume(count);
      if (elemWt != ob.WireType.string) {
        throw ob.OmniBufTypeMismatchException(
            'tags WireArray ElementType mismatch');
      }
      for (var j = 0; j < count; j++) {
        out.add(body.readString());
      }
      if (body.pos != bodyEnd) {
        throw const ob.OmniBufParseException('WireArray trailing bytes');
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
    final budget =
        ob.DecodeBudget(ob.DecodeOptions.defaultMaxCollectionElements);
    final occs = ob.findAllFields(rawBytes, 8);
    for (var i = 0; i < occs.length; i++) {
      final (start, end, wt) = occs[i];
      if (wt != ob.WireType.array) continue;
      final r = ob.OmniBufReader(rawBytes, start, end);
      final len = r.readCheckedLength();
      final bodyEnd = r.pos + len;
      final body = r.subReader(r.pos, bodyEnd);
      final (elemWt, count) = body.readArrayHeader();
      budget.consume(count);
      if (elemWt != ob.WireType.uint) {
        throw ob.OmniBufTypeMismatchException(
            'prefixes WireArray ElementType mismatch');
      }
      for (var j = 0; j < count; j++) {
        out.add(body.readUint32());
      }
      if (body.pos != bodyEnd) {
        throw const ob.OmniBufParseException('WireArray trailing bytes');
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
    final est = value.estimateBodyBytes(1);
    final w = ob.OmniBufWriter(est + 8);
    w.writeTag(9, ob.WireType.subMsg);
    final slot = w.reserveLenAuto(est);
    value.encodeInto(w, depth: 1);
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
    final budget =
        ob.DecodeBudget(ob.DecodeOptions.defaultMaxCollectionElements);
    final occs = ob.findAllFields(rawBytes, 10);
    for (var i = 0; i < occs.length; i++) {
      final (start, end, wt) = occs[i];
      if (wt != ob.WireType.array) continue;
      final r = ob.OmniBufReader(rawBytes, start, end);
      final len = r.readCheckedLength();
      final bodyEnd = r.pos + len;
      final body = r.subReader(r.pos, bodyEnd);
      final (elemWt, count) = body.readArrayHeader();
      budget.consume(count);
      if (elemWt != ob.WireType.subMsg) {
        throw ob.OmniBufTypeMismatchException(
            'neighbors WireArray ElementType mismatch');
      }
      for (var j = 0; j < count; j++) {
        final iLen = body.readCheckedLength();
        final iEnd = body.pos + iLen;
        final iSub = body.subReader(body.pos, iEnd);
        final item = Neighbor();
        item.decodeBody(iSub, 2, ob.DecodeOptions.defaults, budget);
        body.pos = iEnd;
        out.add(item);
      }
      if (body.pos != bodyEnd) {
        throw const ob.OmniBufParseException('WireArray trailing bytes');
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
      final iSlot = w.reserveLen2();
      item.encodeInto(w, depth: 2);
      w.patchLen2(iSlot);
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
      if (wt != ob.WireType.uint) {
        return 0;
      }
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
