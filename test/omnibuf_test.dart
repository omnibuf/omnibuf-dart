import 'dart:typed_data';

import 'package:fixnum/fixnum.dart' show Int64;
import 'package:omnibuf/omnibuf.dart';
import 'package:omnibuf/src/codegen.dart';
import 'package:omnibuf/src/descriptor.dart';
import 'package:omnibuf/src/generated/omnibuf/bench/peer.omnibuf.dart'
    as gen_peer;
import 'package:omnibuf/src/generated/omnibuf/conformance/conformance.omnibuf.dart'
    as gen_conf;
import 'package:protobuf/protobuf.dart';
import 'package:test/test.dart';

class _PbTestMsg extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo(
    'PbTestMsg',
    package: const PackageName('omnibuf.test'),
    createEmptyInstance: create,
  )
    ..a<int>(1, 'id', PbFieldType.OU3)
    ..aOS(2, 'name')
    ..aOB(3, 'active')
    ..a<Int64>(4, 'big_u64', PbFieldType.OU6, defaultOrMaker: Int64.ZERO)
    ..a<int>(5, 'delta', PbFieldType.OS3)
    ..m<String, Int64>(
      6,
      'scores',
      keyFieldType: PbFieldType.OS,
      valueFieldType: PbFieldType.OU6,
    )
    ..hasRequiredFields = false;

  _PbTestMsg() : super();
  static _PbTestMsg create() => _PbTestMsg();
  @override
  _PbTestMsg createEmptyInstance() => create();
  @override
  _PbTestMsg clone() => _PbTestMsg()..mergeFromMessage(this);
  @override
  BuilderInfo get info_ => _i;
}

void main() {
  group('Prefix-Varint & ZigZag', () {
    test('round-trips 1/2/4/9-byte boundary values', () {
      final values = <int>[
        0,
        1,
        127,
        128,
        300,
        16383,
        16384,
        536870911,
        536870912,
        9007199254740993,
        9223372036854775807, // int64 max
        -1, // uint64 max (0xFFFFFFFFFFFFFFFF)
      ];
      final expectedWidths = [1, 1, 1, 2, 2, 2, 4, 4, 9, 9, 9, 9];
      for (var i = 0; i < values.length; i++) {
        final w = OmniBufWriter();
        w.writeVarint(values[i]);
        final bytes = w.toBytes();
        expect(bytes.length, expectedWidths[i], reason: 'value ${values[i]}');
        final r = OmniBufReader(bytes);
        expect(r.readVarint(), values[i]);
        expect(r.hasMore, isFalse);
      }
    });

    test('accepts non-minimal encodings', () {
      // 42 as 1-byte (0x55), 2-byte (0xAA 0x00), 4-byte, 9-byte
      expect(OmniBufReader(Uint8List.fromList([0x55])).readVarint(), 42);
      expect(OmniBufReader(Uint8List.fromList([0xAA, 0x00])).readVarint(), 42);
      expect(
        OmniBufReader(Uint8List.fromList([0x54, 0x01, 0x00, 0x00]))
            .readVarint(),
        42,
      );
      expect(
        OmniBufReader(
          Uint8List.fromList([0x00, 42, 0, 0, 0, 0, 0, 0, 0]),
        ).readVarint(),
        42,
      );
    });

    test('rejects reserved prefix-varint first bytes', () {
      for (final b in [0x08, 0x10, 0x20, 0x40, 0x80, 0xF8]) {
        expect(
          () => OmniBufReader(Uint8List.fromList([b, 0, 0, 0, 0, 0, 0, 0, 0]))
              .readVarint(),
          throwsA(isA<OmniBufParseException>()),
        );
      }
    });

    test('ZigZag 64-bit extremes and 32-bit narrowing', () {
      for (final n in [
        0,
        -1,
        1,
        -64,
        64,
        -2147483648,
        2147483647,
        -9223372036854775808,
        9223372036854775807,
      ]) {
        expect(zigzagDecode(zigzagEncode(n)), n);
      }
      final w = OmniBufWriter()..writeSint(0x100000001);
      expect(OmniBufReader(w.toBytes()).readSint32(), 1);
    });
  });

  group('UTF-8 & Deterministic Map Sorting', () {
    test('strict UTF-8 rejects invalid sequences', () {
      final w = OmniBufWriter()
        ..writeTag(1, WireType.string)
        ..writeVarint(2)
        ..writeByte(0xFF)
        ..writeByte(0xFE);
      expect(
        () => decodeBlind(w.toBytes()),
        throwsA(isA<OmniBufInvalidUtf8Exception>()),
      );
    });

    test('sorts astral emoji after U+FF01 in unsigned UTF-8 byte order', () {
      final keys = [
        '🚀_astral_1f680',
        '！_fullwidth_ff01',
        '\uE000_pua',
        '𐐷_deseret_10437',
      ];
      keys.sort(compareUtf8);
      expect(keys, [
        '\uE000_pua',
        '！_fullwidth_ff01',
        '𐐷_deseret_10437',
        '🚀_astral_1f680',
      ]);
    });

    test('rejects Count=0 WireArray and WireMap with trailing bytes', () {
      // Tag #1 WireArray, ByteLen=3, elemType=uint(0), count=0(0x01), trailing 0x99
      final badArr = Uint8List.fromList([0x3B, 0x07, 0x00, 0x01, 0x99]);
      expect(
        () => decodeBlind(badArr),
        throwsA(isA<OmniBufParseException>()),
      );
      // Tag #1 WireMap, ByteLen=4, key=uint(0), val=uint(0), count=0(0x01), trailing 0x99
      final badMap = Uint8List.fromList([0x3D, 0x09, 0x00, 0x00, 0x01, 0x99]);
      expect(
        () => decodeBlind(badMap),
        throwsA(isA<OmniBufParseException>()),
      );
    });
  });

  group('Tier 1 Generated, Opaque & Wire Splicing', () {
    test('round-trips PeerUpdate, verifies Opaque getters and splices cleanly',
        () {
      final peer = gen_peer.PeerUpdate(
        asn: 64512,
        routerId: 'edge-rtr-fra01',
        active: true,
        uptimeSec: -1, // uint64 max
        rssiDbm: -62,
        cpuLoad: 0.42875,
        tags: ['tier1', 'ebgp'],
        prefixes: [167772160, 3232235520],
        location: gen_peer.Location(
          region: 'eu-central-1',
          datacenter: 'FRA-FR5',
          city: 'Frankfurt',
          rack: 42,
          latitude: 50.1109,
          longitude: 8.6821,
        ),
        neighbors: [
          gen_peer.Neighbor(
            peerAsn: 3356,
            router: 'ae0.fra1.level3.net',
            latencyUs: 850,
            established: true,
          ),
        ],
        sequence: 9876543210,
      );

      final wire = peer.encode();
      final decoded = gen_peer.PeerUpdate.decode(wire);
      expect(decoded.asn, 64512);
      expect(decoded.uptimeSec, -1);
      expect(decoded.location?.city, 'Frankfurt');
      expect(decoded.neighbors.single.router, 'ae0.fra1.level3.net');

      final op = gen_peer.OpaquePeerUpdate(wire);
      expect(op.locationOpaque?.city, 'Frankfurt');
      op.sequence = op.sequence + 1;
      final spliced = op.marshalAppend();
      final after = gen_peer.PeerUpdate.decode(spliced);
      expect(after.sequence, 9876543211);
      expect(after.location?.city, 'Frankfurt');
    });

    test('replace vs merge mode', () {
      final a = gen_conf.AllTypesSubMsg(id: 1, label: 'first', flag: true);
      final b = gen_conf.AllTypesSubMsg(score: -42);

      final target = gen_conf.AllTypesSubMsg.decode(a.encode());
      target.decodeInto(b.encode(), options: DecodeOptions.mergeDefaults);
      expect(target.id, 1);
      expect(target.label, 'first');
      expect(target.flag, isTrue);
      expect(target.score, -42);

      target.decodeInto(b.encode(), options: DecodeOptions.defaults);
      expect(target.id, 0);
      expect(target.label, '');
      expect(target.flag, isFalse);
      expect(target.score, -42);
    });
  });

  group('Tier 2 package:protobuf & Tier 4 Blind + Field #0', () {
    test('encodes self-describing protobuf message and decodes blindly', () {
      final msg = _PbTestMsg()
        ..setField(1, 77)
        ..setField(2, 'alpha')
        ..setField(3, true)
        ..setField(4, Int64(-1))
        ..setField(5, -9);
      (msg.getField(6) as Map<String, Int64>)['b'] = Int64(2);
      (msg.getField(6) as Map<String, Int64>)['a'] = Int64(1);

      final wire = ProtobufOmniBufCodec.encode(
        msg,
        options: EncodeOptions.selfDescribingDefaults,
      );
      final blind = decodeBlind(wire);
      expect(blind['id'], 77);
      expect(blind['name'], 'alpha');
      expect(blind['active'], isTrue);
      expect(blind['big_u64'], const BlindUint64(-1));
      expect(blind['delta'], -9);
      expect(blind['scores'], {'a': 1, 'b': 2});

      final roundTripped = _PbTestMsg();
      ProtobufOmniBufCodec.decodeInto(wire, roundTripped);
      expect(roundTripped.getField(1), 77);
      expect(roundTripped.getField(2), 'alpha');
      expect(roundTripped.getField(4), Int64(-1));
    });
  });

  group('Tier 1 Codegen Smoke Test', () {
    test('generates Dart source for CodeGeneratorRequest', () {
      final fd = ProtoFileDescriptor()
        ..name = 'sample.proto'
        ..packageName = 'demo';
      final md = ProtoMessageDescriptor()..name = 'Ping';
      md.fields.add(
        ProtoFieldDescriptor()
          ..name = 'id'
          ..number = 1
          ..label = 1
          ..type = 13,
      );
      fd.messages.add(md);

      final req = CodeGeneratorRequest()
        ..fileToGenerate.add('sample.proto')
        ..protoFiles.add(fd);
      final resp = generateOmniBufDart(req);
      expect(resp.error, isEmpty);
      expect(resp.files.single.name, 'sample.omnibuf.dart');
      expect(resp.files.single.content, contains('class Ping'));
      expect(resp.files.single.content, contains('class OpaquePing'));
    });
  });
}
