import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart' show Int64;
import 'package:omnibuf/omnibuf.dart';
import 'package:omnibuf/src/generated/omnibuf/bench/peer.omnibuf.dart' as gen;
import 'package:protobuf/protobuf.dart';

// ============================================================================
// package:protobuf GeneratedMessage definitions for PeerUpdate
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

  String get city => $_getSZ(2);
  set datacenter(String v) => $_setString(1, v);
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

  PbLocation get location => $_getN(8);
  Int64 get sequence => $_getI64(10);
  set sequence(Int64 v) => $_setInt64(10, v);
}

// ============================================================================
// Tier 3 OmniBufSchema definitions for PeerUpdate
// ============================================================================

final OmniBufSchema<gen.Location> _locationSchema = OmniBufSchema(
  name: 'Location',
  create: gen.Location.new,
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

final OmniBufSchema<gen.Neighbor> _neighborSchema = OmniBufSchema(
  name: 'Neighbor',
  create: gen.Neighbor.new,
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

final OmniBufSchema<gen.PeerUpdate> _peerSchema = OmniBufSchema(
  name: 'PeerUpdate',
  create: gen.PeerUpdate.new,
  reset: (m) => m.reset(),
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
      subSchema: () => _locationSchema,
      get: (m) => m.location,
      set: (m, v) => m.location = v as gen.Location?,
    ),
    OmniFieldDef(
      id: 10,
      name: 'neighbors',
      kind: OmniFieldKind.repeated,
      elementKind: OmniFieldKind.message,
      subSchema: () => _neighborSchema,
      get: (m) => m.neighbors,
      set: (m, v) => m.neighbors = (v as List).cast<gen.Neighbor>(),
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

// ============================================================================
// Canonical PeerUpdate Workloads (matching Go/Rust/ES)
// ============================================================================

gen.PeerUpdate _createSamplePeerUpdate() {
  return gen.PeerUpdate(
    asn: 64512,
    routerId: 'edge-rtr-fra01.core.backbone.net',
    active: true,
    uptimeSec: 1849203,
    rssiDbm: -62,
    cpuLoad: 0.42875,
    tags: ['tier1', 'ebgp', 'eu-central', 'ixp-de-cix'],
    prefixes: [
      167772160,
      172032000,
      3232235520,
      2886729728,
      134744072,
      134743040,
    ],
    location: gen.Location(
      region: 'eu-central-1',
      datacenter: 'FRA-Equinix-FR5',
      city: 'Frankfurt',
      rack: 42,
      latitude: 50.1109,
      longitude: 8.6821,
    ),
    neighbors: [
      gen.Neighbor(
        peerAsn: 3356,
        router: 'ae0.fra1.level3.net',
        latencyUs: 850,
        established: true,
      ),
      gen.Neighbor(
        peerAsn: 1299,
        router: 'ffm-b5-link.telia.net',
        latencyUs: 920,
        established: true,
      ),
      gen.Neighbor(
        peerAsn: 174,
        router: 'be2040.ccr41.fra03.atlas.cogentco.com',
        latencyUs: 1120,
        established: true,
      ),
      gen.Neighbor(
        peerAsn: 2914,
        router: 'ae-12.r24.frnkge08.de.bb.gin.ntt.net',
        latencyUs: 980,
        established: false,
      ),
    ],
    sequence: 9876543210,
  );
}

gen.PeerUpdate _createLargeNestedPeerUpdate() {
  final p = _createSamplePeerUpdate();
  p.location!.datacenter = 'd' * 20480;
  p.neighbors[0].router = 'n' * 18432;
  return p;
}

gen.PeerUpdate _createManyNeighborsPeerUpdate() {
  final p = _createSamplePeerUpdate();
  final base = p.neighbors;
  final expanded = <gen.Neighbor>[];
  for (var r = 0; r < 8; r++) {
    for (final nb in base) {
      expanded.add(
        gen.Neighbor(
          peerAsn: nb.peerAsn,
          router: nb.router,
          latencyUs: nb.latencyUs,
          established: nb.established,
        ),
      );
    }
  }
  p.neighbors = expanded;
  return p;
}

PbPeerUpdate _toPb(gen.PeerUpdate p) {
  final pb = PbPeerUpdate()
    ..setField(1, p.asn)
    ..setField(2, p.routerId)
    ..setField(3, p.active)
    ..setField(4, Int64(p.uptimeSec))
    ..setField(5, p.rssiDbm)
    ..setField(6, p.cpuLoad);
  (pb.getField(7) as List<String>).addAll(p.tags);
  (pb.getField(8) as List<int>).addAll(p.prefixes);
  if (p.location != null) {
    final loc = PbLocation()
      ..setField(1, p.location!.region)
      ..setField(2, p.location!.datacenter)
      ..setField(3, p.location!.city)
      ..setField(4, p.location!.rack)
      ..setField(5, p.location!.latitude)
      ..setField(6, p.location!.longitude);
    pb.setField(9, loc);
  }
  final nbs = pb.getField(10) as List<PbNeighbor>;
  for (final n in p.neighbors) {
    nbs.add(
      PbNeighbor()
        ..setField(1, n.peerAsn)
        ..setField(2, n.router)
        ..setField(3, n.latencyUs)
        ..setField(4, n.established),
    );
  }
  pb.setField(11, Int64(p.sequence));
  return pb;
}

Map<String, Object?> _toJsonMap(gen.PeerUpdate p) {
  return {
    'asn': p.asn,
    'router_id': p.routerId,
    'active': p.active,
    'uptime_sec': p.uptimeSec,
    'rssi_dbm': p.rssiDbm,
    'cpu_load': p.cpuLoad,
    'tags': p.tags,
    'prefixes': p.prefixes,
    'location': p.location == null
        ? null
        : {
            'region': p.location!.region,
            'datacenter': p.location!.datacenter,
            'city': p.location!.city,
            'rack': p.location!.rack,
            'latitude': p.location!.latitude,
            'longitude': p.location!.longitude,
          },
    'neighbors': [
      for (final n in p.neighbors)
        {
          'peer_asn': n.peerAsn,
          'router': n.router,
          'latency_us': n.latencyUs,
          'established': n.established,
        },
    ],
    'sequence': p.sequence,
  };
}

// ============================================================================
// Benchmark Harness
// ============================================================================

int _sink = 0;

Map<String, Object?> _bench(
  String name,
  int Function() fn, {
  int? wireBytes,
  bool highlight = false,
  bool baseline = false,
  int minMs = 250,
}) {
  // Warmup
  final warmSw = Stopwatch()..start();
  var warmIters = 0;
  while (warmSw.elapsedMilliseconds < 40 || warmIters < 200) {
    _sink ^= fn();
    warmIters++;
  }

  // Calibrate batch size
  final sw = Stopwatch()..start();
  var iters = 0;
  while (sw.elapsedMilliseconds < minMs) {
    for (var i = 0; i < 64; i++) {
      _sink ^= fn();
    }
    iters += 64;
  }
  sw.stop();

  final totalNs = sw.elapsedMicroseconds * 1000;
  final nsPerOp = (totalNs / iters).round();
  final opsPerSec = nsPerOp > 0 ? (1000000000 / nsPerOp).round() : 1000000000;

  final entry = <String, Object?>{
    'name': name,
    'nsPerOp': nsPerOp,
    'opsPerSec': opsPerSec,
  };
  if (wireBytes != null) entry['wireBytes'] = wireBytes;
  if (highlight) entry['highlight'] = true;
  if (baseline) entry['baseline'] = true;

  final sizeStr = wireBytes != null ? ' ($wireBytes B)' : '';
  print(
    '  ${name.padRight(28)} ${nsPerOp.toString().padLeft(7)} ns/op  '
    '${opsPerSec.toString().padLeft(10)} ops/s$sizeStr',
  );
  return entry;
}

String _detectCpu() {
  try {
    if (Platform.isMacOS) {
      final res = Process.runSync('sysctl', ['-n', 'machdep.cpu.brand_string']);
      if (res.exitCode == 0) return (res.stdout as String).trim();
    }
  } catch (_) {}
  return Platform.operatingSystem;
}

void main() {
  final sample = _createSamplePeerUpdate();
  final large = _createLargeNestedPeerUpdate();
  final manyNb = _createManyNeighborsPeerUpdate();

  final pbSample = _toPb(sample);
  final pbLarge = _toPb(large);
  final pbManyNb = _toPb(manyNb);

  final jsonSampleMap = _toJsonMap(sample);
  final jsonLargeMap = _toJsonMap(large);
  final jsonManyNbMap = _toJsonMap(manyNb);

  final obWire = sample.encode();
  final pbWire = pbSample.writeToBuffer();
  final jsonWire = Uint8List.fromList(utf8.encode(jsonEncode(jsonSampleMap)));

  final obLargeWire = large.encode();
  final pbLargeWire = pbLarge.writeToBuffer();
  final jsonLargeWire =
      Uint8List.fromList(utf8.encode(jsonEncode(jsonLargeMap)));

  final obManyWire = manyNb.encode();
  final pbManyWire = pbManyNb.writeToBuffer();
  final jsonManyWire =
      Uint8List.fromList(utf8.encode(jsonEncode(jsonManyNbMap)));

  final reuseWriter = OmniBufWriter(1024);
  final largeWriter = OmniBufWriter(65536);
  final growWriter = OmniBufWriter(65536);
  final grownDatacenter = 'd' * 20480;

  final categories = <Map<String, Object?>>[];

  // 1. Full Message Encode Speed
  print('\n1. Full Message Encode Speed');
  categories.add({
    'id': 'encode',
    'title': 'Full Message Encode Speed',
    'unit': 'ns',
    'results': [
      _bench(
        'OmniBuf (Generated)',
        () {
          reuseWriter.reset();
          sample.encodeInto(reuseWriter);
          return reuseWriter.length;
        },
        wireBytes: obWire.length,
        highlight: true,
        baseline: true,
      ),
      _bench(
        'OmniBuf (Schema)',
        () {
          reuseWriter.reset();
          _peerSchema.encodeInto(reuseWriter, sample);
          return reuseWriter.length;
        },
        wireBytes: obWire.length,
        highlight: true,
      ),
      _bench(
        'package:protobuf',
        () => pbSample.writeToBuffer().length,
        wireBytes: pbWire.length,
      ),
      _bench(
        'dart:convert (JSON)',
        () => utf8.encode(jsonEncode(jsonSampleMap)).length,
        wireBytes: jsonWire.length,
      ),
    ],
  });

  // 2. Full Message Decode Speed
  print('\n2. Full Message Decode Speed');
  categories.add({
    'id': 'decode',
    'title': 'Full Message Decode Speed',
    'unit': 'ns',
    'results': [
      _bench(
        'OmniBuf (Generated)',
        () => gen.PeerUpdate.decode(obWire).asn,
        highlight: true,
        baseline: true,
      ),
      _bench(
        'OmniBuf (Schema)',
        () => _peerSchema.decode(obWire).asn,
        highlight: true,
      ),
      _bench(
        'package:protobuf',
        () => (PbPeerUpdate()..mergeFromBuffer(pbWire)).getField(1) as int,
      ),
      _bench(
        'dart:convert (JSON)',
        () => (jsonDecode(utf8.decode(jsonWire)) as Map<String, dynamic>)['asn']
            as int,
      ),
    ],
  });

  // 3. Read a Single Nested Field (location.city)
  print('\n3. Read a Single Nested Field');
  categories.add({
    'id': 'lookup_city',
    'title': 'Read a Single Nested Field',
    'unit': 'ns',
    'results': [
      _bench(
        'OmniBuf (Opaque)',
        () => gen.OpaquePeerUpdate(obWire).locationOpaque!.city.length,
        highlight: true,
        baseline: true,
      ),
      _bench(
        'package:protobuf',
        () => (PbPeerUpdate()..mergeFromBuffer(pbWire)).location.city.length,
      ),
      _bench(
        'dart:convert (JSON)',
        () {
          final m = jsonDecode(utf8.decode(jsonWire)) as Map<String, dynamic>;
          final loc = m['location'] as Map<String, dynamic>;
          return (loc['city'] as String).length;
        },
      ),
    ],
  });

  // 4. Selective Single-Field Mutation (sequence++)
  print('\n4. Selective Single-Field Mutation');
  categories.add({
    'id': 'mutate_sequence',
    'title': 'Selective Single-Field Mutation',
    'unit': 'ns',
    'results': [
      _bench(
        'OmniBuf (Opaque Splice)',
        () {
          final op = gen.OpaquePeerUpdate(obWire);
          op.sequence = op.sequence + 1;
          reuseWriter.reset();
          op.marshalInto(reuseWriter);
          return reuseWriter.length;
        },
        highlight: true,
        baseline: true,
      ),
      _bench(
        'package:protobuf',
        () {
          final msg = PbPeerUpdate()..mergeFromBuffer(pbWire);
          msg.sequence = msg.sequence + 1;
          return msg.writeToBuffer().length;
        },
      ),
      _bench(
        'dart:convert (JSON)',
        () {
          final m = jsonDecode(utf8.decode(jsonWire)) as Map<String, dynamic>;
          m['sequence'] = (m['sequence'] as int) + 1;
          return utf8.encode(jsonEncode(m)).length;
        },
      ),
    ],
  });

  // 5. Large Embedded Message Encode
  print('\n5. Large Embedded Message Encode');
  categories.add({
    'id': 'encode_nested_shift',
    'title': 'Large Embedded Message Encode',
    'unit': 'ns',
    'results': [
      _bench(
        'OmniBuf (Generated)',
        () {
          largeWriter.reset();
          large.encodeInto(largeWriter);
          return largeWriter.length;
        },
        wireBytes: obLargeWire.length,
        highlight: true,
        baseline: true,
      ),
      _bench(
        'package:protobuf',
        () => pbLarge.writeToBuffer().length,
        wireBytes: pbLargeWire.length,
      ),
      _bench(
        'dart:convert (JSON)',
        () => utf8.encode(jsonEncode(jsonLargeMap)).length,
        wireBytes: jsonLargeWire.length,
      ),
    ],
  });

  // 6. Embedded Message Growth (32 neighbors untouched, grow location.datacenter -> 20KB)
  print('\n6. Embedded Message Growth');
  categories.add({
    'id': 'mutate_embedded_grow',
    'title': 'Embedded Message Growth',
    'unit': 'ns',
    'results': [
      _bench(
        'OmniBuf (Opaque Splice)',
        () {
          final op = gen.OpaquePeerUpdate(obManyWire);
          final locOp = op.locationOpaque!;
          locOp.datacenter = grownDatacenter;
          op.setLocationOpaque(locOp);
          growWriter.reset();
          op.marshalInto(growWriter);
          return growWriter.length;
        },
        highlight: true,
        baseline: true,
      ),
      _bench(
        'package:protobuf',
        () {
          final msg = PbPeerUpdate()..mergeFromBuffer(pbManyWire);
          msg.location.datacenter = grownDatacenter;
          return msg.writeToBuffer().length;
        },
      ),
      _bench(
        'dart:convert (JSON)',
        () {
          final m =
              jsonDecode(utf8.decode(jsonManyWire)) as Map<String, dynamic>;
          final loc = m['location'] as Map<String, dynamic>;
          loc['datacenter'] = grownDatacenter;
          return utf8.encode(jsonEncode(m)).length;
        },
      ),
    ],
  });

  final dartVersion = Platform.version.split(' ').first;
  final report = <String, Object?>{
    'language': 'dart',
    'runtime': 'dart $dartVersion (AOT)',
    'platform': Platform.operatingSystem,
    'arch': Platform.version.contains('arm64') ? 'arm64' : 'x64',
    'cpu': _detectCpu(),
    'workload': 'PeerUpdate',
    'categories': categories,
  };

  final outDir = Directory('testdata');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);
  final outFile = File('testdata/benchmarks.json');
  const encoder = JsonEncoder.withIndent('  ');
  outFile.writeAsStringSync('${encoder.convert(report)}\n');
  print('\nWrote testdata/benchmarks.json (sink=$_sink)');
}
