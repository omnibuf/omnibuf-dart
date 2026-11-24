import 'dart:typed_data';

import 'package:omnibuf/omnibuf.dart';
import 'package:omnibuf/src/generated/omnibuf/bench/peer.omnibuf.dart'
    as gen_peer;
import 'package:omnibuf/src/generated/omnibuf/conformance/conformance.omnibuf.dart'
    as gen_conf;
import 'package:protobuf/protobuf.dart';
import 'package:test/test.dart';

class _EmptyPbMsg extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo(
    'EmptyPbMsg',
    package: const PackageName('omnibuf.test'),
    createEmptyInstance: create,
  )..hasRequiredFields = false;

  _EmptyPbMsg() : super();
  static _EmptyPbMsg create() => _EmptyPbMsg();
  @override
  _EmptyPbMsg createEmptyInstance() => create();
  @override
  _EmptyPbMsg clone() => _EmptyPbMsg()..mergeFromMessage(this);
  @override
  BuilderInfo get info_ => _i;
}

class _DummyObj {}

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

  group('Packet Validation & Decode Limits', () {
    test(
        'enforces cumulative collection element budget across all tiers and validates Field #0 strings',
        () {
      // 4 chunks of 3 uint32 elements = 12 elements total (> budget 10).
      final w = OmniBufWriter();
      for (var c = 0; c < 4; c++) {
        w.writeTag(10, WireType.array);
        final slot = w.reserveLen2();
        w.writeByte(WireType.uint);
        w.writeVarint(3);
        w.writeVarint(1);
        w.writeVarint(2);
        w.writeVarint(3);
        w.patchLen2(slot);
      }
      final chunked = w.toBytes();
      const opts = DecodeOptions(maxCollectionElements: 10);

      expect(
        () => validatePacket(chunked, maxElements: 10),
        throwsA(isA<OmniBufAllocationLimitException>()),
      );
      expect(
        () => decodeBlind(chunked, options: opts),
        throwsA(isA<OmniBufAllocationLimitException>()),
      );
      expect(
        () => gen_conf.TestAllTypes.decode(chunked, options: opts),
        throwsA(isA<OmniBufAllocationLimitException>()),
      );

      final schema = OmniBufSchema<_DummyObj>(
        name: 'T',
        create: _DummyObj.new,
        fields: [
          OmniFieldDef(
            id: 10,
            name: 'arr',
            kind: OmniFieldKind.repeated,
            elementKind: OmniFieldKind.uint32,
            get: (m) => <int>[],
            set: (m, v) {},
          ),
        ],
      );
      expect(
        () => schema.decode(chunked, options: opts),
        throwsA(isA<OmniBufAllocationLimitException>()),
      );

      // Many scalar fields in decodeBlind also hit cumulative budget.
      final fw = OmniBufWriter();
      for (var i = 1; i <= 12; i++) {
        fw.writeTag(i, WireType.uint);
        fw.writeVarint(i);
      }
      expect(
        () => decodeBlind(fw.toBytes(), options: opts),
        throwsA(isA<OmniBufAllocationLimitException>()),
      );

      // Field #0 wrong-wire-type field with invalid UTF-8 is caught by validatePacket.
      final f0w = OmniBufWriter();
      f0w.writeByte(WireType.field0EncodedTag);
      final f0Slot = f0w.reserveLen2();
      // Field #2 in SchemaMeta is normally map, give it WireString with invalid UTF-8.
      f0w.writeTag(2, WireType.string);
      f0w.writeVarint(2);
      f0w.writeByte(0xFF);
      f0w.writeByte(0xFE);
      f0w.patchLen2(f0Slot);
      expect(
        () => validatePacket(f0w.toBytes(), validateStrings: true),
        throwsA(isA<OmniBufInvalidUtf8Exception>()),
      );
    });

    test('rejects unknown string fields with invalid UTF-8 across all tiers',
        () {
      final w = OmniBufWriter()
        ..writeTag(999, WireType.string)
        ..writeVarint(2)
        ..writeByte(0xFF)
        ..writeByte(0xFE);
      final badUnknown = w.toBytes();

      expect(
        () => gen_peer.PeerUpdate.decode(badUnknown),
        throwsA(isA<OmniBufInvalidUtf8Exception>()),
      );
      expect(
        () => ProtobufOmniBufCodec.decodeInto(badUnknown, _EmptyPbMsg()),
        throwsA(isA<OmniBufInvalidUtf8Exception>()),
      );
      final schema = OmniBufSchema<_DummyObj>(
        name: 'T',
        create: _DummyObj.new,
        fields: const [],
      );
      expect(
        () => schema.decode(badUnknown),
        throwsA(isA<OmniBufInvalidUtf8Exception>()),
      );
    });

    test('validates maxDepth bounds (1..32) and enforces maxAllocBytes', () {
      final valid = gen_peer.PeerUpdate(routerId: 'abcdefghij').encode();
      expect(
        () => decodeBlind(valid, options: const DecodeOptions(maxDepth: 0)),
        throwsA(isA<RangeError>()),
      );
      expect(
        () => decodeBlind(valid, options: const DecodeOptions(maxDepth: -5)),
        throwsA(isA<RangeError>()),
      );
      expect(
        () => decodeBlind(valid, options: const DecodeOptions(maxDepth: 33)),
        throwsA(isA<RangeError>()),
      );
      expect(
        () => validatePacket(valid, maxDepth: 0),
        throwsA(isA<RangeError>()),
      );
      expect(
        () => validatePacket(valid, maxDepth: 64),
        throwsA(isA<RangeError>()),
      );
      expect(
        () => decodeBlind(
          valid,
          options: const DecodeOptions(maxAllocBytes: 5),
        ),
        throwsA(isA<OmniBufAllocationLimitException>()),
      );
      expect(
        () => decodeBlind(
          valid,
          options: const DecodeOptions(maxAllocBytes: 100),
        ),
        returnsNormally,
      );
    });
  });
}
