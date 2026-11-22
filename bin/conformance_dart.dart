import 'dart:io';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart' show Int64;
import 'package:omnibuf/omnibuf.dart';
import 'package:omnibuf/src/generated/omnibuf/bench/peer.omnibuf.dart'
    as gen_peer;
import 'package:omnibuf/src/generated/omnibuf/conformance/conformance.omnibuf.dart'
    as gen_conf;
import 'package:protobuf/protobuf.dart';

const int _maxFrameBytes = 16 * 1024 * 1024;
const int _uint64Max = -1; // 0xFFFFFFFFFFFFFFFF
const int _int64Min = -9223372036854775808; // 0x8000000000000000

// ============================================================================
// Tier 2: Standard package:protobuf GeneratedMessage Types
// ============================================================================

class PbLocation extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo(
    'Location',
    package: const PackageName('omnibuf.bench'),
    createEmptyInstance: create,
  )
    ..aOS(1, 'region')
    ..aOS(2, 'datacenter')
    ..aOS(3, 'city')
    ..a<int>(4, 'rack', PbFieldType.OU3)
    ..a<double>(5, 'latitude', PbFieldType.OF)
    ..a<double>(6, 'longitude', PbFieldType.OF)
    ..hasRequiredFields = false;

  PbLocation() : super();
  static PbLocation create() => PbLocation();
  @override
  PbLocation createEmptyInstance() => create();
  @override
  PbLocation clone() => PbLocation()..mergeFromMessage(this);
  @override
  BuilderInfo get info_ => _i;
}

class PbNeighbor extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo(
    'Neighbor',
    package: const PackageName('omnibuf.bench'),
    createEmptyInstance: create,
  )
    ..a<int>(1, 'peer_asn', PbFieldType.OU3)
    ..aOS(2, 'router')
    ..a<int>(3, 'latency_us', PbFieldType.OU3)
    ..aOB(4, 'established')
    ..hasRequiredFields = false;

  PbNeighbor() : super();
  static PbNeighbor create() => PbNeighbor();
  @override
  PbNeighbor createEmptyInstance() => create();
  @override
  PbNeighbor clone() => PbNeighbor()..mergeFromMessage(this);
  @override
  BuilderInfo get info_ => _i;
}

class PbPeerUpdate extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo(
    'PeerUpdate',
    package: const PackageName('omnibuf.bench'),
    createEmptyInstance: create,
  )
    ..a<int>(1, 'asn', PbFieldType.OU3)
    ..aOS(2, 'router_id')
    ..aOB(3, 'active')
    ..a<Int64>(4, 'uptime_sec', PbFieldType.OU6, defaultOrMaker: Int64.ZERO)
    ..a<int>(5, 'rssi_dbm', PbFieldType.OS3)
    ..a<double>(6, 'cpu_load', PbFieldType.OD)
    ..pPS(7, 'tags')
    ..p<int>(8, 'prefixes', PbFieldType.KU3)
    ..aOM<PbLocation>(9, 'location', subBuilder: PbLocation.create)
    ..pc<PbNeighbor>(10, 'neighbors', PbFieldType.PM,
        subBuilder: PbNeighbor.create)
    ..a<Int64>(11, 'sequence', PbFieldType.OU6, defaultOrMaker: Int64.ZERO)
    ..hasRequiredFields = false;

  PbPeerUpdate() : super();
  static PbPeerUpdate create() => PbPeerUpdate();
  @override
  PbPeerUpdate createEmptyInstance() => create();
  @override
  PbPeerUpdate clone() => PbPeerUpdate()..mergeFromMessage(this);
  @override
  BuilderInfo get info_ => _i;
}

class PbAllTypesSubMsg extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo(
    'AllTypesSubMsg',
    package: const PackageName('omnibuf.conformance'),
    createEmptyInstance: create,
  )
    ..a<int>(1, 'id', PbFieldType.OU3)
    ..aOS(2, 'label')
    ..aOB(3, 'flag')
    ..a<Int64>(4, 'score', PbFieldType.OS6, defaultOrMaker: Int64.ZERO)
    ..hasRequiredFields = false;

  PbAllTypesSubMsg() : super();
  static PbAllTypesSubMsg create() => PbAllTypesSubMsg();
  @override
  PbAllTypesSubMsg createEmptyInstance() => create();
  @override
  PbAllTypesSubMsg clone() => PbAllTypesSubMsg()..mergeFromMessage(this);
  @override
  BuilderInfo get info_ => _i;
}

class PbTestAllTypes extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo(
    'TestAllTypes',
    package: const PackageName('omnibuf.conformance'),
    createEmptyInstance: create,
  )
    ..a<int>(1, 'f1_uint32', PbFieldType.OU3)
    ..a<Int64>(2, 'f2_uint64', PbFieldType.OU6, defaultOrMaker: Int64.ZERO)
    ..a<int>(3, 'f3_sint32', PbFieldType.OS3)
    ..a<Int64>(4, 'f4_sint64', PbFieldType.OS6, defaultOrMaker: Int64.ZERO)
    ..aOB(5, 'f5_bool')
    ..aOS(6, 'f6_string')
    ..a<List<int>>(7, 'f7_bytes', PbFieldType.OY)
    ..aOM<PbAllTypesSubMsg>(8, 'f8_sub_msg',
        subBuilder: PbAllTypesSubMsg.create)
    ..pPS(9, 'f9_string_arr')
    ..p<int>(10, 'f10_uint32_arr', PbFieldType.KU3)
    ..pc<PbAllTypesSubMsg>(11, 'f11_sub_msg_arr', PbFieldType.PM,
        subBuilder: PbAllTypesSubMsg.create)
    ..m<String, Int64>(
      12,
      'f12_map_str_uint',
      keyFieldType: PbFieldType.OS,
      valueFieldType: PbFieldType.OU6,
    )
    ..a<double>(13, 'f13_float32', PbFieldType.OF)
    ..a<double>(14, 'f14_float64', PbFieldType.OD)
    ..a<int>(15, 'f15_fixed32', PbFieldType.OF3)
    ..a<Int64>(16, 'f16_fixed64', PbFieldType.OF6, defaultOrMaker: Int64.ZERO)
    ..aOS(20, 'f20_overflow_str')
    ..hasRequiredFields = false;

  PbTestAllTypes() : super();
  static PbTestAllTypes create() => PbTestAllTypes();
  @override
  PbTestAllTypes createEmptyInstance() => create();
  @override
  PbTestAllTypes clone() => PbTestAllTypes()..mergeFromMessage(this);
  @override
  BuilderInfo get info_ => _i;
}

// ============================================================================
// Tier 3: Declarative / Annotated Dart Classes (OmniBufSchema)
// ============================================================================

@OmniBufMessage('Location')
class AnnotatedLocation {
  @OmniBufField(1, name: 'region', kind: OmniFieldKind.string)
  String region = '';
  @OmniBufField(2, name: 'datacenter', kind: OmniFieldKind.string)
  String datacenter = '';
  @OmniBufField(3, name: 'city', kind: OmniFieldKind.string)
  String city = '';
  @OmniBufField(4, name: 'rack', kind: OmniFieldKind.uint32)
  int rack = 0;
  @OmniBufField(5, name: 'latitude', kind: OmniFieldKind.float32)
  double latitude = 0.0;
  @OmniBufField(6, name: 'longitude', kind: OmniFieldKind.float32)
  double longitude = 0.0;
}

final OmniBufSchema<AnnotatedLocation> locationSchema = OmniBufSchema(
  name: 'Location',
  create: AnnotatedLocation.new,
  fields: [
    OmniFieldDef(
      id: 1,
      name: 'region',
      kind: OmniFieldKind.string,
      get: (m) => m.region,
      set: (m, v) => m.region = v as String,
    ),
    OmniFieldDef(
      id: 2,
      name: 'datacenter',
      kind: OmniFieldKind.string,
      get: (m) => m.datacenter,
      set: (m, v) => m.datacenter = v as String,
    ),
    OmniFieldDef(
      id: 3,
      name: 'city',
      kind: OmniFieldKind.string,
      get: (m) => m.city,
      set: (m, v) => m.city = v as String,
    ),
    OmniFieldDef(
      id: 4,
      name: 'rack',
      kind: OmniFieldKind.uint32,
      get: (m) => m.rack,
      set: (m, v) => m.rack = v as int,
    ),
    OmniFieldDef(
      id: 5,
      name: 'latitude',
      kind: OmniFieldKind.float32,
      get: (m) => m.latitude,
      set: (m, v) => m.latitude = v as double,
    ),
    OmniFieldDef(
      id: 6,
      name: 'longitude',
      kind: OmniFieldKind.float32,
      get: (m) => m.longitude,
      set: (m, v) => m.longitude = v as double,
    ),
  ],
);

@OmniBufMessage('Neighbor')
class AnnotatedNeighbor {
  int peerAsn = 0;
  String router = '';
  int latencyUs = 0;
  bool established = false;
}

final OmniBufSchema<AnnotatedNeighbor> neighborSchema = OmniBufSchema(
  name: 'Neighbor',
  create: AnnotatedNeighbor.new,
  fields: [
    OmniFieldDef(
      id: 1,
      name: 'peer_asn',
      kind: OmniFieldKind.uint32,
      get: (m) => m.peerAsn,
      set: (m, v) => m.peerAsn = v as int,
    ),
    OmniFieldDef(
      id: 2,
      name: 'router',
      kind: OmniFieldKind.string,
      get: (m) => m.router,
      set: (m, v) => m.router = v as String,
    ),
    OmniFieldDef(
      id: 3,
      name: 'latency_us',
      kind: OmniFieldKind.uint32,
      get: (m) => m.latencyUs,
      set: (m, v) => m.latencyUs = v as int,
    ),
    OmniFieldDef(
      id: 4,
      name: 'established',
      kind: OmniFieldKind.boolType,
      get: (m) => m.established,
      set: (m, v) => m.established = v as bool,
    ),
  ],
);

@OmniBufMessage('PeerUpdate')
class AnnotatedPeerUpdate {
  int asn = 0;
  String routerId = '';
  bool active = false;
  int uptimeSec = 0;
  int rssiDbm = 0;
  double cpuLoad = 0.0;
  List<String> tags = <String>[];
  List<int> prefixes = <int>[];
  AnnotatedLocation? location;
  List<AnnotatedNeighbor> neighbors = <AnnotatedNeighbor>[];
  int sequence = 0;
}

final OmniBufSchema<AnnotatedPeerUpdate> peerUpdateSchema = OmniBufSchema(
  name: 'PeerUpdate',
  create: AnnotatedPeerUpdate.new,
  reset: (m) {
    m.asn = 0;
    m.routerId = '';
    m.active = false;
    m.uptimeSec = 0;
    m.rssiDbm = 0;
    m.cpuLoad = 0.0;
    m.tags = <String>[];
    m.prefixes = <int>[];
    m.location = null;
    m.neighbors = <AnnotatedNeighbor>[];
    m.sequence = 0;
  },
  fields: [
    OmniFieldDef(
      id: 1,
      name: 'asn',
      kind: OmniFieldKind.uint32,
      get: (m) => m.asn,
      set: (m, v) => m.asn = v as int,
    ),
    OmniFieldDef(
      id: 2,
      name: 'router_id',
      kind: OmniFieldKind.string,
      get: (m) => m.routerId,
      set: (m, v) => m.routerId = v as String,
    ),
    OmniFieldDef(
      id: 3,
      name: 'active',
      kind: OmniFieldKind.boolType,
      get: (m) => m.active,
      set: (m, v) => m.active = v as bool,
    ),
    OmniFieldDef(
      id: 4,
      name: 'uptime_sec',
      kind: OmniFieldKind.uint64,
      get: (m) => m.uptimeSec,
      set: (m, v) => m.uptimeSec = v as int,
    ),
    OmniFieldDef(
      id: 5,
      name: 'rssi_dbm',
      kind: OmniFieldKind.sint32,
      get: (m) => m.rssiDbm,
      set: (m, v) => m.rssiDbm = v as int,
    ),
    OmniFieldDef(
      id: 6,
      name: 'cpu_load',
      kind: OmniFieldKind.float64,
      get: (m) => m.cpuLoad,
      set: (m, v) => m.cpuLoad = v as double,
    ),
    OmniFieldDef(
      id: 7,
      name: 'tags',
      kind: OmniFieldKind.repeated,
      elementKind: OmniFieldKind.string,
      get: (m) => m.tags,
      set: (m, v) => m.tags = (v as List).cast<String>(),
    ),
    OmniFieldDef(
      id: 8,
      name: 'prefixes',
      kind: OmniFieldKind.repeated,
      elementKind: OmniFieldKind.uint32,
      get: (m) => m.prefixes,
      set: (m, v) => m.prefixes = (v as List).cast<int>(),
    ),
    OmniFieldDef(
      id: 9,
      name: 'location',
      kind: OmniFieldKind.message,
      subSchema: () => locationSchema,
      get: (m) => m.location,
      set: (m, v) => m.location = v as AnnotatedLocation?,
    ),
    OmniFieldDef(
      id: 10,
      name: 'neighbors',
      kind: OmniFieldKind.repeated,
      elementKind: OmniFieldKind.message,
      subSchema: () => neighborSchema,
      get: (m) => m.neighbors,
      set: (m, v) => m.neighbors = (v as List).cast<AnnotatedNeighbor>(),
    ),
    OmniFieldDef(
      id: 11,
      name: 'sequence',
      kind: OmniFieldKind.uint64,
      get: (m) => m.sequence,
      set: (m, v) => m.sequence = v as int,
    ),
  ],
);

@OmniBufMessage('AllTypesSubMsg')
class AnnotatedAllTypesSubMsg {
  int id = 0;
  String label = '';
  bool flag = false;
  int score = 0;
}

final OmniBufSchema<AnnotatedAllTypesSubMsg> allTypesSubMsgSchema =
    OmniBufSchema(
  name: 'AllTypesSubMsg',
  create: AnnotatedAllTypesSubMsg.new,
  fields: [
    OmniFieldDef(
      id: 1,
      name: 'id',
      kind: OmniFieldKind.uint32,
      get: (m) => m.id,
      set: (m, v) => m.id = v as int,
    ),
    OmniFieldDef(
      id: 2,
      name: 'label',
      kind: OmniFieldKind.string,
      get: (m) => m.label,
      set: (m, v) => m.label = v as String,
    ),
    OmniFieldDef(
      id: 3,
      name: 'flag',
      kind: OmniFieldKind.boolType,
      get: (m) => m.flag,
      set: (m, v) => m.flag = v as bool,
    ),
    OmniFieldDef(
      id: 4,
      name: 'score',
      kind: OmniFieldKind.sint64,
      get: (m) => m.score,
      set: (m, v) => m.score = v as int,
    ),
  ],
);

@OmniBufMessage('TestAllTypes')
class AnnotatedTestAllTypes {
  int f1Uint32 = 0;
  int f2Uint64 = 0;
  int f3Sint32 = 0;
  int f4Sint64 = 0;
  bool f5Bool = false;
  String f6String = '';
  Uint8List f7Bytes = Uint8List(0);
  AnnotatedAllTypesSubMsg? f8SubMsg;
  List<String> f9StringArr = <String>[];
  List<int> f10Uint32Arr = <int>[];
  List<AnnotatedAllTypesSubMsg> f11SubMsgArr = <AnnotatedAllTypesSubMsg>[];
  Map<String, int> f12MapStrUint = <String, int>{};
  double f13Float32 = 0.0;
  double f14Float64 = 0.0;
  int f15Fixed32 = 0;
  int f16Fixed64 = 0;
  String f20OverflowStr = '';
}

final OmniBufSchema<AnnotatedTestAllTypes> testAllTypesSchema = OmniBufSchema(
  name: 'TestAllTypes',
  create: AnnotatedTestAllTypes.new,
  reset: (m) {
    m.f1Uint32 = 0;
    m.f2Uint64 = 0;
    m.f3Sint32 = 0;
    m.f4Sint64 = 0;
    m.f5Bool = false;
    m.f6String = '';
    m.f7Bytes = Uint8List(0);
    m.f8SubMsg = null;
    m.f9StringArr = <String>[];
    m.f10Uint32Arr = <int>[];
    m.f11SubMsgArr = <AnnotatedAllTypesSubMsg>[];
    m.f12MapStrUint = <String, int>{};
    m.f13Float32 = 0.0;
    m.f14Float64 = 0.0;
    m.f15Fixed32 = 0;
    m.f16Fixed64 = 0;
    m.f20OverflowStr = '';
  },
  fields: [
    OmniFieldDef(
      id: 1,
      name: 'f1_uint32',
      kind: OmniFieldKind.uint32,
      get: (m) => m.f1Uint32,
      set: (m, v) => m.f1Uint32 = v as int,
    ),
    OmniFieldDef(
      id: 2,
      name: 'f2_uint64',
      kind: OmniFieldKind.uint64,
      get: (m) => m.f2Uint64,
      set: (m, v) => m.f2Uint64 = v as int,
    ),
    OmniFieldDef(
      id: 3,
      name: 'f3_sint32',
      kind: OmniFieldKind.sint32,
      get: (m) => m.f3Sint32,
      set: (m, v) => m.f3Sint32 = v as int,
    ),
    OmniFieldDef(
      id: 4,
      name: 'f4_sint64',
      kind: OmniFieldKind.sint64,
      get: (m) => m.f4Sint64,
      set: (m, v) => m.f4Sint64 = v as int,
    ),
    OmniFieldDef(
      id: 5,
      name: 'f5_bool',
      kind: OmniFieldKind.boolType,
      get: (m) => m.f5Bool,
      set: (m, v) => m.f5Bool = v as bool,
    ),
    OmniFieldDef(
      id: 6,
      name: 'f6_string',
      kind: OmniFieldKind.string,
      get: (m) => m.f6String,
      set: (m, v) => m.f6String = v as String,
    ),
    OmniFieldDef(
      id: 7,
      name: 'f7_bytes',
      kind: OmniFieldKind.bytes,
      get: (m) => m.f7Bytes,
      set: (m, v) => m.f7Bytes = v as Uint8List,
    ),
    OmniFieldDef(
      id: 8,
      name: 'f8_sub_msg',
      kind: OmniFieldKind.message,
      subSchema: () => allTypesSubMsgSchema,
      get: (m) => m.f8SubMsg,
      set: (m, v) => m.f8SubMsg = v as AnnotatedAllTypesSubMsg?,
    ),
    OmniFieldDef(
      id: 9,
      name: 'f9_string_arr',
      kind: OmniFieldKind.repeated,
      elementKind: OmniFieldKind.string,
      get: (m) => m.f9StringArr,
      set: (m, v) => m.f9StringArr = (v as List).cast<String>(),
    ),
    OmniFieldDef(
      id: 10,
      name: 'f10_uint32_arr',
      kind: OmniFieldKind.repeated,
      elementKind: OmniFieldKind.uint32,
      get: (m) => m.f10Uint32Arr,
      set: (m, v) => m.f10Uint32Arr = (v as List).cast<int>(),
    ),
    OmniFieldDef(
      id: 11,
      name: 'f11_sub_msg_arr',
      kind: OmniFieldKind.repeated,
      elementKind: OmniFieldKind.message,
      subSchema: () => allTypesSubMsgSchema,
      get: (m) => m.f11SubMsgArr,
      set: (m, v) =>
          m.f11SubMsgArr = (v as List).cast<AnnotatedAllTypesSubMsg>(),
    ),
    OmniFieldDef(
      id: 12,
      name: 'f12_map_str_uint',
      kind: OmniFieldKind.map,
      keyKind: OmniFieldKind.string,
      valueKind: OmniFieldKind.uint64,
      get: (m) => m.f12MapStrUint,
      set: (m, v) => m.f12MapStrUint = (v as Map).cast<String, int>(),
    ),
    OmniFieldDef(
      id: 13,
      name: 'f13_float32',
      kind: OmniFieldKind.float32,
      get: (m) => m.f13Float32,
      set: (m, v) => m.f13Float32 = v as double,
    ),
    OmniFieldDef(
      id: 14,
      name: 'f14_float64',
      kind: OmniFieldKind.float64,
      get: (m) => m.f14Float64,
      set: (m, v) => m.f14Float64 = v as double,
    ),
    OmniFieldDef(
      id: 15,
      name: 'f15_fixed32',
      kind: OmniFieldKind.fixed32,
      get: (m) => m.f15Fixed32,
      set: (m, v) => m.f15Fixed32 = v as int,
    ),
    OmniFieldDef(
      id: 16,
      name: 'f16_fixed64',
      kind: OmniFieldKind.fixed64,
      get: (m) => m.f16Fixed64,
      set: (m, v) => m.f16Fixed64 = v as int,
    ),
    OmniFieldDef(
      id: 20,
      name: 'f20_overflow_str',
      kind: OmniFieldKind.string,
      get: (m) => m.f20OverflowStr,
      set: (m, v) => m.f20OverflowStr = v as String,
    ),
  ],
);

@OmniBufMessage('TreeNode')
class AnnotatedTreeNode {
  int id = 0;
  String name = '';
  int weight = 0;
  AnnotatedTreeNode? primary;
  List<AnnotatedTreeNode>? children;
  List<AnnotatedTreeNode>? branches;
  Map<String, int>? labels;
}

final OmniBufSchema<AnnotatedTreeNode> treeNodeSchema = OmniBufSchema(
  name: 'TreeNode',
  create: AnnotatedTreeNode.new,
  reset: (m) {
    m.id = 0;
    m.name = '';
    m.weight = 0;
    m.primary = null;
    m.children = null;
    m.branches = null;
    m.labels = null;
  },
  fields: [
    OmniFieldDef(
      id: 1,
      name: 'id',
      kind: OmniFieldKind.uint32,
      get: (m) => m.id,
      set: (m, v) => m.id = v as int,
    ),
    OmniFieldDef(
      id: 2,
      name: 'name',
      kind: OmniFieldKind.string,
      get: (m) => m.name,
      set: (m, v) => m.name = v as String,
    ),
    OmniFieldDef(
      id: 3,
      name: 'weight',
      kind: OmniFieldKind.sint64,
      get: (m) => m.weight,
      set: (m, v) => m.weight = v as int,
    ),
    OmniFieldDef(
      id: 4,
      name: 'primary',
      kind: OmniFieldKind.message,
      subSchema: () => treeNodeSchema,
      get: (m) => m.primary,
      set: (m, v) => m.primary = v as AnnotatedTreeNode?,
    ),
    OmniFieldDef(
      id: 5,
      name: 'children',
      kind: OmniFieldKind.repeated,
      elementKind: OmniFieldKind.message,
      subSchema: () => treeNodeSchema,
      preserveEmpty: true,
      get: (m) => m.children,
      set: (m, v) => m.children = (v as List).cast<AnnotatedTreeNode>(),
    ),
    OmniFieldDef(
      id: 6,
      name: 'branches',
      kind: OmniFieldKind.repeated,
      elementKind: OmniFieldKind.message,
      subSchema: () => treeNodeSchema,
      preserveEmpty: true,
      get: (m) => m.branches,
      set: (m, v) => m.branches = (v as List).cast<AnnotatedTreeNode>(),
    ),
    OmniFieldDef(
      id: 7,
      name: 'labels',
      kind: OmniFieldKind.map,
      keyKind: OmniFieldKind.string,
      valueKind: OmniFieldKind.uint64,
      preserveEmpty: true,
      get: (m) => m.labels,
      set: (m, v) => m.labels = (v as Map).cast<String, int>(),
    ),
  ],
);

@OmniBufMessage('NestedNIC')
class AnnotatedNestedNic {
  int ifIndex = 0;
  String mac = '';
  List<int> ips = <int>[];
}

final OmniBufSchema<AnnotatedNestedNic> nestedNicSchema = OmniBufSchema(
  name: 'NestedNIC',
  create: AnnotatedNestedNic.new,
  fields: [
    OmniFieldDef(
      id: 1,
      name: 'if_index',
      kind: OmniFieldKind.uint32,
      get: (m) => m.ifIndex,
      set: (m, v) => m.ifIndex = v as int,
    ),
    OmniFieldDef(
      id: 2,
      name: 'mac',
      kind: OmniFieldKind.string,
      get: (m) => m.mac,
      set: (m, v) => m.mac = v as String,
    ),
    OmniFieldDef(
      id: 3,
      name: 'ips',
      kind: OmniFieldKind.repeated,
      elementKind: OmniFieldKind.uint32,
      get: (m) => m.ips,
      set: (m, v) => m.ips = (v as List).cast<int>(),
    ),
  ],
);

@OmniBufMessage('NestedServer')
class AnnotatedNestedServer {
  int serverId = 0;
  String hostname = '';
  List<AnnotatedNestedNic> nics = <AnnotatedNestedNic>[];
}

final OmniBufSchema<AnnotatedNestedServer> nestedServerSchema = OmniBufSchema(
  name: 'NestedServer',
  create: AnnotatedNestedServer.new,
  fields: [
    OmniFieldDef(
      id: 1,
      name: 'server_id',
      kind: OmniFieldKind.uint32,
      get: (m) => m.serverId,
      set: (m, v) => m.serverId = v as int,
    ),
    OmniFieldDef(
      id: 2,
      name: 'hostname',
      kind: OmniFieldKind.string,
      get: (m) => m.hostname,
      set: (m, v) => m.hostname = v as String,
    ),
    OmniFieldDef(
      id: 3,
      name: 'nics',
      kind: OmniFieldKind.repeated,
      elementKind: OmniFieldKind.message,
      subSchema: () => nestedNicSchema,
      get: (m) => m.nics,
      set: (m, v) => m.nics = (v as List).cast<AnnotatedNestedNic>(),
    ),
  ],
);

@OmniBufMessage('NestedRack')
class AnnotatedNestedRack {
  int rackId = 0;
  String zone = '';
  List<AnnotatedNestedServer> servers = <AnnotatedNestedServer>[];
}

final OmniBufSchema<AnnotatedNestedRack> nestedRackSchema = OmniBufSchema(
  name: 'NestedRack',
  create: AnnotatedNestedRack.new,
  fields: [
    OmniFieldDef(
      id: 1,
      name: 'rack_id',
      kind: OmniFieldKind.uint32,
      get: (m) => m.rackId,
      set: (m, v) => m.rackId = v as int,
    ),
    OmniFieldDef(
      id: 2,
      name: 'zone',
      kind: OmniFieldKind.string,
      get: (m) => m.zone,
      set: (m, v) => m.zone = v as String,
    ),
    OmniFieldDef(
      id: 3,
      name: 'servers',
      kind: OmniFieldKind.repeated,
      elementKind: OmniFieldKind.message,
      subSchema: () => nestedServerSchema,
      get: (m) => m.servers,
      set: (m, v) => m.servers = (v as List).cast<AnnotatedNestedServer>(),
    ),
  ],
);

@OmniBufMessage('NestedCluster')
class AnnotatedNestedCluster {
  String clusterName = '';
  List<AnnotatedNestedRack> racks = <AnnotatedNestedRack>[];
  int epoch = 0;
}

final OmniBufSchema<AnnotatedNestedCluster> nestedClusterSchema = OmniBufSchema(
  name: 'NestedCluster',
  create: AnnotatedNestedCluster.new,
  reset: (m) {
    m.clusterName = '';
    m.racks = <AnnotatedNestedRack>[];
    m.epoch = 0;
  },
  fields: [
    OmniFieldDef(
      id: 1,
      name: 'cluster_name',
      kind: OmniFieldKind.string,
      get: (m) => m.clusterName,
      set: (m, v) => m.clusterName = v as String,
    ),
    OmniFieldDef(
      id: 2,
      name: 'racks',
      kind: OmniFieldKind.repeated,
      elementKind: OmniFieldKind.message,
      subSchema: () => nestedRackSchema,
      get: (m) => m.racks,
      set: (m, v) => m.racks = (v as List).cast<AnnotatedNestedRack>(),
    ),
    OmniFieldDef(
      id: 3,
      name: 'epoch',
      kind: OmniFieldKind.uint64,
      get: (m) => m.epoch,
      set: (m, v) => m.epoch = v as int,
    ),
  ],
);

// ============================================================================
// Main Synchronous Framing Loop over stdin / stdout
// ============================================================================

void main() {
  final lenBuf = Uint8List(4);
  final lenBd = ByteData.sublistView(lenBuf);

  while (true) {
    final first = stdin.readByteSync();
    if (first < 0) break; // Clean EOF
    lenBuf[0] = first;
    for (var i = 1; i < 4; i++) {
      final b = stdin.readByteSync();
      if (b < 0) {
        stderr.writeln('conformance_dart: unexpected EOF reading frame length');
        exit(1);
      }
      lenBuf[i] = b;
    }
    final size = lenBd.getUint32(0, Endian.little);
    if (size > _maxFrameBytes) {
      stderr.writeln(
        'conformance_dart: frame size $size exceeds $_maxFrameBytes',
      );
      exit(1);
    }
    final payload = Uint8List(size);
    var offset = 0;
    while (offset < size) {
      final b = stdin.readByteSync();
      if (b < 0) {
        stderr.writeln('conformance_dart: unexpected EOF reading frame body');
        exit(1);
      }
      payload[offset++] = b;
    }

    gen_conf.ConformanceResponse resp;
    try {
      final req = _decodeConformanceRequest(payload);
      resp = _handleRequest(req);
    } catch (e) {
      resp = gen_conf.ConformanceResponse(runtimeError: e.toString());
    }

    final outBytes = resp.encode();
    lenBd.setUint32(0, outBytes.length, Endian.little);
    stdout.add(lenBuf);
    if (outBytes.isNotEmpty) {
      stdout.add(outBytes);
    }
  }
}

gen_conf.ConformanceRequest _decodeConformanceRequest(Uint8List data) {
  final req = gen_conf.ConformanceRequest();
  final r = OmniBufReader(data);
  while (r.hasMore) {
    final tag = r.readTag();
    final fnum = tag >> 4;
    final wt = tag & 0x0F;
    switch (fnum) {
      case 1:
        if (wt == WireType.string) req.testName = r.readString();
      case 2:
        if (wt == WireType.string) req.messageType = r.readString();
      case 3:
        if (wt == WireType.uint) {
          req.tier = r.readUint32();
        } else if (wt == WireType.sint) {
          req.tier = r.readSint32();
        } else {
          fastSkipValue(r, wt);
        }
      case 4:
        if (wt == WireType.uint) {
          req.requestedOutputFormat = r.readUint32();
        } else if (wt == WireType.sint) {
          req.requestedOutputFormat = r.readSint32();
        } else {
          fastSkipValue(r, wt);
        }
      case 5:
        if (wt == WireType.bytes) req.omnibufPayload = r.readBytes();
      case 6:
        if (wt == WireType.string) req.jsonPayload = r.readString();
      case 7:
        if (wt == WireType.boolFalse || wt == WireType.boolTrue) {
          req.selfDescribing = wt == WireType.boolTrue;
        }
      case 8:
        if (wt == WireType.boolFalse || wt == WireType.boolTrue) {
          req.testOpaqueSplice = wt == WireType.boolTrue;
        }
      case 9:
        if (wt == WireType.boolFalse || wt == WireType.boolTrue) {
          req.testOpaqueSpliceShrink = wt == WireType.boolTrue;
        }
      default:
        fastSkipValue(r, wt);
    }
  }
  return req;
}

gen_conf.ConformanceResponse _handleRequest(gen_conf.ConformanceRequest req) {
  switch (req.tier) {
    case gen_conf.TestTier.TEST_TIER_BLIND:
      return _handleBlind(req);
    case gen_conf.TestTier.TEST_TIER_ANNOTATED_STRUCT:
      return _handleAnnotatedStruct(req);
    case gen_conf.TestTier.TEST_TIER_PROTOBUF_TYPES:
      return _handleProtobufTypes(req);
    case gen_conf.TestTier.TEST_TIER_PLUGIN:
      return _handlePlugin(req);
    default:
      return gen_conf.ConformanceResponse(
        runtimeError: 'unknown tier ${req.tier}',
      );
  }
}

// ============================================================================
// Tier 4: Blind Decode
// ============================================================================

gen_conf.ConformanceResponse _handleBlind(gen_conf.ConformanceRequest req) {
  try {
    final json = decodeBlindJson(req.omnibufPayload);
    if (req.requestedOutputFormat == gen_conf.WireFormat.WIRE_FORMAT_JSON) {
      return gen_conf.ConformanceResponse(jsonPayload: json);
    }
    return gen_conf.ConformanceResponse(omnibufPayload: req.omnibufPayload);
  } on OmniBufParseException catch (e) {
    return gen_conf.ConformanceResponse(parseError: e.message);
  } catch (e) {
    return gen_conf.ConformanceResponse(runtimeError: e.toString());
  }
}

// ============================================================================
// Tier 3: Annotated Struct (OmniBufSchema)
// ============================================================================

gen_conf.ConformanceResponse _handleAnnotatedStruct(
  gen_conf.ConformanceRequest req,
) {
  final encOpts = EncodeOptions(selfDescribing: req.selfDescribing);
  try {
    switch (req.messageType) {
      case 'omnibuf.bench.PeerUpdate':
        final dirty = AnnotatedPeerUpdate()
          ..asn = 999999
          ..routerId = 'stale-router'
          ..active = true
          ..uptimeSec = 123456
          ..rssiDbm = -99
          ..cpuLoad = 0.99
          ..tags = ['stale']
          ..prefixes = [1, 2, 3]
          ..location = (AnnotatedLocation()..city = 'StaleCity')
          ..neighbors = [AnnotatedNeighbor()..router = 'stale-nb']
          ..sequence = 888;
        peerUpdateSchema.decodeInto(req.omnibufPayload, dirty);
        return gen_conf.ConformanceResponse(
          omnibufPayload: peerUpdateSchema.encode(dirty, options: encOpts),
        );
      case 'omnibuf.conformance.TreeNode':
        final dirty = AnnotatedTreeNode()
          ..id = 999
          ..name = 'stale'
          ..weight = -42
          ..primary = (AnnotatedTreeNode()..name = 'stale-child')
          ..children = [AnnotatedTreeNode()..name = 'stale-c']
          ..branches = [AnnotatedTreeNode()..name = 'stale-b']
          ..labels = {'stale': 1};
        treeNodeSchema.decodeInto(req.omnibufPayload, dirty);
        return gen_conf.ConformanceResponse(
          omnibufPayload: treeNodeSchema.encode(dirty, options: encOpts),
        );
      case 'omnibuf.conformance.NestedCluster':
        final dirty = AnnotatedNestedCluster()
          ..clusterName = 'stale-cluster'
          ..racks = [AnnotatedNestedRack()..zone = 'stale-z']
          ..epoch = 777;
        nestedClusterSchema.decodeInto(req.omnibufPayload, dirty);
        return gen_conf.ConformanceResponse(
          omnibufPayload: nestedClusterSchema.encode(dirty, options: encOpts),
        );
      default:
        final dirty = AnnotatedTestAllTypes()
          ..f1Uint32 = 123
          ..f2Uint64 = 456
          ..f3Sint32 = -7
          ..f4Sint64 = -8
          ..f5Bool = true
          ..f6String = 'stale'
          ..f7Bytes = Uint8List.fromList([1, 2, 3])
          ..f8SubMsg = (AnnotatedAllTypesSubMsg()..label = 'stale-sub')
          ..f9StringArr = ['stale']
          ..f10Uint32Arr = [9]
          ..f11SubMsgArr = [AnnotatedAllTypesSubMsg()..id = 9]
          ..f12MapStrUint = {'stale': 9}
          ..f13Float32 = 1.5
          ..f14Float64 = 2.5
          ..f15Fixed32 = 11
          ..f16Fixed64 = 22
          ..f20OverflowStr = 'stale-20';
        testAllTypesSchema.decodeInto(req.omnibufPayload, dirty);
        return gen_conf.ConformanceResponse(
          omnibufPayload: testAllTypesSchema.encode(dirty, options: encOpts),
        );
    }
  } on OmniBufParseException catch (e) {
    return gen_conf.ConformanceResponse(parseError: e.message);
  } on OmniBufSerializeException catch (e) {
    return gen_conf.ConformanceResponse(serializeError: e.message);
  } catch (e) {
    return gen_conf.ConformanceResponse(runtimeError: e.toString());
  }
}

// ============================================================================
// Tier 2: package:protobuf GeneratedMessage
// ============================================================================

gen_conf.ConformanceResponse _handleProtobufTypes(
  gen_conf.ConformanceRequest req,
) {
  final encOpts = EncodeOptions(selfDescribing: req.selfDescribing);
  try {
    switch (req.messageType) {
      case 'omnibuf.bench.PeerUpdate':
        final dirty = PbPeerUpdate()
          ..setField(1, 999999)
          ..setField(2, 'stale-router')
          ..setField(3, true)
          ..setField(9, PbLocation()..setField(3, 'StaleCity'));
        ProtobufOmniBufCodec.decodeInto(req.omnibufPayload, dirty);
        return gen_conf.ConformanceResponse(
          omnibufPayload: ProtobufOmniBufCodec.encode(dirty, options: encOpts),
        );
      default:
        final dirty = PbTestAllTypes()
          ..setField(1, 123)
          ..setField(5, true)
          ..setField(6, 'stale')
          ..setField(8, PbAllTypesSubMsg()..setField(2, 'stale-sub'));
        ProtobufOmniBufCodec.decodeInto(req.omnibufPayload, dirty);
        return gen_conf.ConformanceResponse(
          omnibufPayload: ProtobufOmniBufCodec.encode(dirty, options: encOpts),
        );
    }
  } on OmniBufParseException catch (e) {
    return gen_conf.ConformanceResponse(parseError: e.message);
  } on OmniBufSerializeException catch (e) {
    return gen_conf.ConformanceResponse(serializeError: e.message);
  } catch (e) {
    return gen_conf.ConformanceResponse(runtimeError: e.toString());
  }
}

// ============================================================================
// Tier 1: Generated Plugin Code + Lazy Opaque<T> + Wire Splicing
// ============================================================================

gen_conf.ConformanceResponse _handlePlugin(gen_conf.ConformanceRequest req) {
  final encOpts = EncodeOptions(selfDescribing: req.selfDescribing);
  final raw = req.omnibufPayload;
  final rawSnapshot = Uint8List.fromList(raw);

  try {
    if (req.messageType == 'omnibuf.bench.PeerUpdate') {
      final dirty = gen_peer.PeerUpdate(
        asn: 999999,
        routerId: 'stale-router',
        active: true,
        uptimeSec: 123456,
        rssiDbm: -99,
        cpuLoad: 0.99,
        tags: ['stale'],
        prefixes: [1, 2, 3],
        location: gen_peer.Location(city: 'StaleCity'),
        neighbors: [gen_peer.Neighbor(router: 'stale-nb')],
        sequence: 888,
      );
      dirty.decodeInto(raw);

      // Verify Opaque getters match eager decode.
      final op = gen_peer.OpaquePeerUpdate(raw);
      _verifyPeerUpdateOpaque(dirty, op);

      // Verify spliceFields preserves prefix and never mutates source buffer.
      final prefix = Uint8List.fromList([0xDE, 0xAD, 0xBE, 0xEF]);
      final splicedCheck = op.marshalAppend(prefix);
      if (splicedCheck.length < 4 ||
          splicedCheck[0] != 0xDE ||
          splicedCheck[1] != 0xAD ||
          splicedCheck[2] != 0xBE ||
          splicedCheck[3] != 0xEF) {
        return gen_conf.ConformanceResponse(
          runtimeError: 'spliceFields failed to preserve prefix slice',
        );
      }

      if (req.testOpaqueSplice) {
        op.asn = 1000000;
        op.routerId = 'edge-rtr-fra01-' * 20;
        op.active = !op.active;
        op.uptimeSec = _uint64Max;
        op.rssiDbm = -1000000;
        op.cpuLoad = 99.875;
        op.tags = ['tag-grow-a', 'tag-grow-b', 'long-tag-' * 20];
        op.prefixes = [100000, 200000, 300000, 400000, 500000, 600000];
        op.location = gen_peer.Location(
          region: 'eu-central-grown',
          datacenter: 'fra-dc-' * 25,
          city: 'Berlin',
          rack: 999999,
          latitude: 52.52,
          longitude: 13.405,
        );
        op.sequence = op.sequence + 1;
        final out = op.marshalAppend();
        _assertUnmutated(raw, rawSnapshot);
        return gen_conf.ConformanceResponse(omnibufPayload: out);
      }

      if (req.testOpaqueSpliceShrink) {
        op.asn = 1;
        op.routerId = 'r';
        op.active = false;
        op.uptimeSec = 5;
        op.rssiDbm = -1;
        op.cpuLoad = 0.5;
        op.tags = ['t'];
        op.prefixes = [1];
        op.location = gen_peer.Location(
          region: 'r',
          datacenter: 'd',
          city: 'c',
          rack: 1,
          latitude: 1.0,
          longitude: 2.0,
        );
        op.sequence = 2;
        final out = op.marshalAppend();
        _assertUnmutated(raw, rawSnapshot);
        return gen_conf.ConformanceResponse(omnibufPayload: out);
      }

      _assertUnmutated(raw, rawSnapshot);
      return gen_conf.ConformanceResponse(
        omnibufPayload: dirty.encode(options: encOpts),
      );
    } else {
      final dirty = gen_conf.TestAllTypes(
        f1Uint32: 123,
        f2Uint64: 456,
        f3Sint32: -7,
        f4Sint64: -8,
        f5Bool: true,
        f6String: 'stale',
        f7Bytes: Uint8List.fromList([1, 2, 3]),
        f8SubMsg: gen_conf.AllTypesSubMsg(label: 'stale-sub'),
        f9StringArr: ['stale'],
        f10Uint32Arr: [9],
        f11SubMsgArr: [gen_conf.AllTypesSubMsg(id: 9)],
        f12MapStrUint: {'stale': 9},
        f13Float32: 1.5,
        f14Float64: 2.5,
        f15Fixed32: 11,
        f16Fixed64: 22,
        f20OverflowStr: 'stale-20',
      );
      dirty.decodeInto(raw);

      final op = gen_conf.OpaqueTestAllTypes(raw);
      _verifyTestAllTypesOpaque(dirty, op);

      if (req.testOpaqueSplice) {
        final growBytes = Uint8List(260);
        for (var i = 0; i < 130; i++) {
          growBytes[i * 2] = 0xAB;
          growBytes[i * 2 + 1] = 0xCD;
        }
        op.f1Uint32 = 1000000;
        op.f2Uint64 = _uint64Max;
        op.f3Sint32 = -1000000;
        op.f4Sint64 = _int64Min;
        op.f5Bool = !op.f5Bool;
        op.f6String = 'grown-str-' * 30;
        op.f7Bytes = growBytes;
        op.f8SubMsg = gen_conf.AllTypesSubMsg(
          id: 888888,
          label: 'sub-grown-' * 20,
          flag: true,
          score: -999999999,
        );
        op.f9StringArr = ['arr-grow-1', 'arr-grow-2', 'arr-grow-3-' * 15];
        op.f10Uint32Arr = [100000, 200000, 300000, 400000, 500000];
        op.f11SubMsgArr = [
          gen_conf.AllTypesSubMsg(
            id: 100001,
            label: 'elem0-' * 25,
            flag: true,
            score: -500000,
          ),
          gen_conf.AllTypesSubMsg(
            id: 100002,
            label: 'elem1-grown',
            flag: false,
            score: 500000,
          ),
        ];
        op.f12MapStrUint = {
          'k1': 1000000,
          'k2': _uint64Max,
          'k3_long_key': 424242,
        };
        op.f13Float32 = -1234.5;
        op.f14Float64 = 3.141592653589793;
        op.f15Fixed32 = 0xDEADBEEF;
        op.f16Fixed64 = (0xCAFEBABE << 32) | 0xDEADBEEF;
        op.f20OverflowStr = 'overflow20-' * 20;
        final out = op.marshalAppend();
        _assertUnmutated(raw, rawSnapshot);
        return gen_conf.ConformanceResponse(omnibufPayload: out);
      }

      if (req.testOpaqueSpliceShrink) {
        op.f1Uint32 = 1;
        op.f2Uint64 = 2;
        op.f3Sint32 = -1;
        op.f4Sint64 = -2;
        op.f5Bool = false;
        op.f6String = 's';
        op.f7Bytes = Uint8List.fromList([0x01]);
        op.f8SubMsg = gen_conf.AllTypesSubMsg(
          id: 1,
          label: 'x',
          flag: false,
          score: -1,
        );
        op.f9StringArr = ['a'];
        op.f10Uint32Arr = [7];
        op.f11SubMsgArr = [
          gen_conf.AllTypesSubMsg(id: 1, label: 'e', flag: true, score: 1),
        ];
        op.f12MapStrUint = {'k': 1};
        op.f13Float32 = 0.5;
        op.f14Float64 = -0.25;
        op.f15Fixed32 = 7;
        op.f16Fixed64 = 9;
        op.f20OverflowStr = 'z';
        final out = op.marshalAppend();
        _assertUnmutated(raw, rawSnapshot);
        return gen_conf.ConformanceResponse(omnibufPayload: out);
      }

      _assertUnmutated(raw, rawSnapshot);
      return gen_conf.ConformanceResponse(
        omnibufPayload: dirty.encode(options: encOpts),
      );
    }
  } on OmniBufParseException catch (e) {
    return gen_conf.ConformanceResponse(parseError: e.message);
  } on OmniBufSerializeException catch (e) {
    return gen_conf.ConformanceResponse(serializeError: e.message);
  } catch (e) {
    return gen_conf.ConformanceResponse(runtimeError: e.toString());
  }
}

void _assertUnmutated(Uint8List buf, Uint8List snap) {
  if (buf.length != snap.length) {
    throw StateError('source buffer length mutated');
  }
  for (var i = 0; i < buf.length; i++) {
    if (buf[i] != snap[i]) {
      throw StateError('source buffer mutated at byte $i');
    }
  }
}

bool _doubleBitsEqual(double a, double b) {
  if (a.isNaN && b.isNaN) return true;
  if (a == 0.0 && b == 0.0) return a.isNegative == b.isNegative;
  return a == b;
}

void _verifyPeerUpdateOpaque(
  gen_peer.PeerUpdate eager,
  gen_peer.OpaquePeerUpdate op,
) {
  if (op.asn != eager.asn ||
      op.routerId != eager.routerId ||
      op.active != eager.active ||
      op.uptimeSec != eager.uptimeSec ||
      op.rssiDbm != eager.rssiDbm ||
      !_doubleBitsEqual(op.cpuLoad, eager.cpuLoad) ||
      op.sequence != eager.sequence) {
    throw StateError('OpaquePeerUpdate scalar mismatch');
  }
  final opTags = op.tags;
  if (opTags.length != eager.tags.length) {
    throw StateError('OpaquePeerUpdate tags length mismatch');
  }
  for (var i = 0; i < opTags.length; i++) {
    if (opTags[i] != eager.tags[i]) {
      throw StateError('OpaquePeerUpdate tags[$i] mismatch');
    }
  }
  final opPrefixes = op.prefixes;
  if (opPrefixes.length != eager.prefixes.length) {
    throw StateError('OpaquePeerUpdate prefixes length mismatch');
  }
  for (var i = 0; i < opPrefixes.length; i++) {
    if (opPrefixes[i] != eager.prefixes[i]) {
      throw StateError('OpaquePeerUpdate prefixes[$i] mismatch');
    }
  }
  final opLoc = op.location;
  if ((opLoc == null) != (eager.location == null)) {
    throw StateError('OpaquePeerUpdate location presence mismatch');
  }
  if (opLoc != null && eager.location != null) {
    if (opLoc.region != eager.location!.region ||
        opLoc.datacenter != eager.location!.datacenter ||
        opLoc.city != eager.location!.city ||
        opLoc.rack != eager.location!.rack ||
        !_doubleBitsEqual(opLoc.latitude, eager.location!.latitude) ||
        !_doubleBitsEqual(opLoc.longitude, eager.location!.longitude)) {
      throw StateError('OpaquePeerUpdate location mismatch');
    }
  }
  final opNbs = op.neighbors;
  if (opNbs.length != eager.neighbors.length) {
    throw StateError('OpaquePeerUpdate neighbors length mismatch');
  }
  for (var i = 0; i < opNbs.length; i++) {
    if (opNbs[i].peerAsn != eager.neighbors[i].peerAsn ||
        opNbs[i].router != eager.neighbors[i].router ||
        opNbs[i].latencyUs != eager.neighbors[i].latencyUs ||
        opNbs[i].established != eager.neighbors[i].established) {
      throw StateError('OpaquePeerUpdate neighbors[$i] mismatch');
    }
  }
}

void _verifyTestAllTypesOpaque(
  gen_conf.TestAllTypes eager,
  gen_conf.OpaqueTestAllTypes op,
) {
  if (op.f1Uint32 != eager.f1Uint32 ||
      op.f2Uint64 != eager.f2Uint64 ||
      op.f3Sint32 != eager.f3Sint32 ||
      op.f4Sint64 != eager.f4Sint64 ||
      op.f5Bool != eager.f5Bool ||
      op.f6String != eager.f6String ||
      !_doubleBitsEqual(op.f13Float32, eager.f13Float32) ||
      !_doubleBitsEqual(op.f14Float64, eager.f14Float64) ||
      op.f15Fixed32 != eager.f15Fixed32 ||
      op.f16Fixed64 != eager.f16Fixed64 ||
      op.f20OverflowStr != eager.f20OverflowStr) {
    throw StateError('OpaqueTestAllTypes scalar mismatch');
  }
  final opBytes = op.f7Bytes;
  if (opBytes.length != eager.f7Bytes.length) {
    throw StateError('OpaqueTestAllTypes f7Bytes length mismatch');
  }
  for (var i = 0; i < opBytes.length; i++) {
    if (opBytes[i] != eager.f7Bytes[i]) {
      throw StateError('OpaqueTestAllTypes f7Bytes[$i] mismatch');
    }
  }
  final opSub = op.f8SubMsg;
  if ((opSub == null) != (eager.f8SubMsg == null)) {
    throw StateError('OpaqueTestAllTypes f8SubMsg presence mismatch');
  }
  if (opSub != null && eager.f8SubMsg != null) {
    if (opSub.id != eager.f8SubMsg!.id ||
        opSub.label != eager.f8SubMsg!.label ||
        opSub.flag != eager.f8SubMsg!.flag ||
        opSub.score != eager.f8SubMsg!.score) {
      throw StateError('OpaqueTestAllTypes f8SubMsg mismatch');
    }
  }
  final opMap = op.f12MapStrUint;
  if (opMap.length != eager.f12MapStrUint.length) {
    throw StateError('OpaqueTestAllTypes f12MapStrUint length mismatch');
  }
  for (final e in eager.f12MapStrUint.entries) {
    if (opMap[e.key] != e.value) {
      throw StateError('OpaqueTestAllTypes f12MapStrUint[${e.key}] mismatch');
    }
  }
}
