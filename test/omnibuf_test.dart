import 'dart:typed_data';

import 'package:fixnum/fixnum.dart' show Int64;
import 'package:omnibuf/omnibuf.dart';
import 'package:omnibuf/src/codegen.dart';
import 'package:omnibuf/src/descriptor.dart';
import 'package:omnibuf/src/generated/omnibuf/bench/peer.omnibuf.dart'
    as gen_peer;
import 'package:omnibuf/src/generated/omnibuf/conformance/conformance.omnibuf.dart'
    as gen_conf;
import 'package:omnibuf/src/generated/omnibuf/v1/meta.omnibuf.dart' as gen_meta;
import 'package:protobuf/protobuf.dart';
import 'package:test/test.dart';

class _TestColor extends ProtobufEnum {
  static const _TestColor red = _TestColor._(1, 'RED');
  static const _TestColor green = _TestColor._(2, 'GREEN');
  static const List<_TestColor> values = [_TestColor.red, _TestColor.green];
  static final Map<int, _TestColor> _byValue = ProtobufEnum.initByValue(values);
  static _TestColor? valueOf(int value) => _byValue[value];
  const _TestColor._(super.v, super.n);
}

class _PbEnumMsg extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo(
    'PbEnumMsg',
    package: const PackageName('omnibuf.test'),
    createEmptyInstance: create,
  )
    ..pc<_TestColor>(
      1,
      'colors',
      PbFieldType.PE,
      valueOf: _TestColor.valueOf,
      enumValues: _TestColor.values,
    )
    ..m<String, _TestColor>(
      2,
      'color_map',
      keyFieldType: PbFieldType.OS,
      valueFieldType: PbFieldType.OE,
      valueOf: _TestColor.valueOf,
      enumValues: _TestColor.values,
    )
    ..hasRequiredFields = false;

  _PbEnumMsg() : super();
  static _PbEnumMsg create() => _PbEnumMsg();
  @override
  _PbEnumMsg createEmptyInstance() => create();
  @override
  _PbEnumMsg clone() => _PbEnumMsg()..mergeFromMessage(this);
  @override
  BuilderInfo get info_ => _i;
}

class _PbRecursiveMsg extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo(
    'PbRecursiveMsg',
    package: const PackageName('omnibuf.test'),
    createEmptyInstance: create,
  )
    ..aOM<_PbRecursiveMsg>(1, 'next', subBuilder: _PbRecursiveMsg.create)
    ..hasRequiredFields = false;

  _PbRecursiveMsg() : super();
  static _PbRecursiveMsg create() => _PbRecursiveMsg();
  @override
  _PbRecursiveMsg createEmptyInstance() => create();
  @override
  _PbRecursiveMsg clone() => _PbRecursiveMsg()..mergeFromMessage(this);
  @override
  BuilderInfo get info_ => _i;
}

class _TypedCollectionObj {
  List<String> tags = <String>[];
  Map<String, int> scores = <String, int>{};
}

class _CyclicSchemaObj {
  _CyclicSchemaObj? next;
}

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

    test('emits relative imports, nested types/enums, keyword escaping & this.',
        () {
      final sharedFd = ProtoFileDescriptor()
        ..name = 'common/shared.proto'
        ..packageName = 'common';
      sharedFd.messages.add(ProtoMessageDescriptor()..name = 'SharedMeta');

      final mainFd = ProtoFileDescriptor()
        ..name = 'pkg/main.proto'
        ..packageName = 'pkg'
        ..dependencies.add('common/shared.proto');

      final innerMd = ProtoMessageDescriptor()..name = 'Inner';
      innerMd.fields.add(
        ProtoFieldDescriptor()
          ..name = 'value'
          ..number = 1
          ..label = 1
          ..type = 13,
      );
      final nestedEnum = ProtoEnumDescriptor()
        ..name = 'Status'
        ..values.add(('OK', 0))
        ..values.add(('default', 1));

      final mapEntry = ProtoMessageDescriptor()
        ..name = 'U32MapEntry'
        ..isMapEntry = true;
      mapEntry.fields.addAll([
        ProtoFieldDescriptor()
          ..name = 'key'
          ..number = 1
          ..label = 1
          ..type = 13, // uint32
        ProtoFieldDescriptor()
          ..name = 'value'
          ..number = 2
          ..label = 1
          ..type = 9, // string
      ]);

      final s32MapEntry = ProtoMessageDescriptor()
        ..name = 'S32MapEntry'
        ..isMapEntry = true;
      s32MapEntry.fields.addAll([
        ProtoFieldDescriptor()
          ..name = 'key'
          ..number = 1
          ..label = 1
          ..type = 17, // sint32
        ProtoFieldDescriptor()
          ..name = 'value'
          ..number = 2
          ..label = 1
          ..type = 9, // string
      ]);

      final outerMd = ProtoMessageDescriptor()..name = 'Outer';
      outerMd.nestedTypes.addAll([innerMd, mapEntry, s32MapEntry]);
      outerMd.enumTypes.add(nestedEnum);
      outerMd.fields.addAll([
        ProtoFieldDescriptor()
          ..name = 'class'
          ..number = 1
          ..label = 1
          ..type = 9,
        ProtoFieldDescriptor()
          ..name = 'reset'
          ..number = 2
          ..label = 1
          ..type = 13,
        ProtoFieldDescriptor()
          ..name = '_leading'
          ..number = 3
          ..label = 1
          ..type = 13,
        ProtoFieldDescriptor()
          ..name = '___'
          ..number = 4
          ..label = 1
          ..type = 13,
        ProtoFieldDescriptor()
          ..name = 'w'
          ..number = 5
          ..label = 1
          ..type = 13,
        ProtoFieldDescriptor()
          ..name = 'inner'
          ..number = 6
          ..label = 1
          ..type = 11
          ..typeName = '.pkg.Outer.Inner',
        ProtoFieldDescriptor()
          ..name = 'shared'
          ..number = 7
          ..label = 1
          ..type = 11
          ..typeName = '.common.SharedMeta',
        ProtoFieldDescriptor()
          ..name = 'u32_map'
          ..number = 8
          ..label = 3
          ..type = 11
          ..typeName = '.pkg.Outer.U32MapEntry',
        ProtoFieldDescriptor()
          ..name = 's32_map'
          ..number = 9
          ..label = 3
          ..type = 11
          ..typeName = '.pkg.Outer.S32MapEntry',
      ]);
      mainFd.messages.add(outerMd);

      final req = CodeGeneratorRequest()
        ..fileToGenerate.add('pkg/main.proto')
        ..protoFiles.addAll([sharedFd, mainFd]);
      final resp = generateOmniBufDart(req);
      expect(resp.error, isEmpty);
      final code = resp.files.single.content;
      expect(
          code, contains("import '../common/shared.omnibuf.dart' as dep_0;"));
      expect(code, contains('abstract final class Outer_Status'));
      expect(code, contains('static const int default_ = 1;'));
      expect(code, contains('class Outer_Inner'));
      expect(code, contains('class OpaqueOuter_Inner'));
      expect(code, contains('String class_;'));
      expect(code, contains('int reset_;'));
      expect(code, contains('int leading;'));
      expect(code, contains('int field4;'));
      expect(code, contains('this.w'));
      expect(code, contains('Outer_Inner? inner;'));
      expect(code, contains('dep_0.SharedMeta? shared;'));
      expect(code, contains('(a & 0xFFFFFFFF).compareTo(b & 0xFFFFFFFF)'));
      expect(code, contains('a.toSigned(32).compareTo(b.toSigned(32))'));
    });
  });

  group('Audit Regression Tests', () {
    test('ProtobufOmniBufCodec handles map & repeated enums and skips unknown',
        () {
      final msg = _PbEnumMsg();
      (msg.getField(1) as List<_TestColor>)
          .addAll([_TestColor.red, _TestColor.green]);
      (msg.getField(2) as Map<String, _TestColor>)['r'] = _TestColor.red;
      (msg.getField(2) as Map<String, _TestColor>)['g'] = _TestColor.green;

      final wire = ProtobufOmniBufCodec.encode(msg);
      final decoded = _PbEnumMsg();
      ProtobufOmniBufCodec.decodeInto(wire, decoded);
      expect(decoded.getField(1), [_TestColor.red, _TestColor.green]);
      expect(decoded.getField(2), {'r': _TestColor.red, 'g': _TestColor.green});

      // Encode packet with unknown enum integer 999 in both repeated & map.
      final w = OmniBufWriter();
      // Field 1: repeated sint32 [1, 999, 2]
      w.writeTag(1, WireType.array);
      final aSlot = w.reserveLen2();
      w.writeByte(WireType.sint);
      w.writeVarint(3);
      w.writeSint32(1);
      w.writeSint32(999);
      w.writeSint32(2);
      w.patchLen2(aSlot);
      // Field 2: map<string, sint32> {'ok': 1, 'bad': 999}
      w.writeTag(2, WireType.map);
      final mSlot = w.reserveLen2();
      w.writeByte(WireType.string);
      w.writeByte(WireType.sint);
      w.writeVarint(2);
      w.writeString('ok');
      w.writeSint32(1);
      w.writeString('bad');
      w.writeSint32(999);
      w.patchLen2(mSlot);

      final decodedUnknown = _PbEnumMsg();
      ProtobufOmniBufCodec.decodeInto(w.toBytes(), decodedUnknown);
      expect(decodedUnknown.getField(1), [_TestColor.red, _TestColor.green]);
      expect(decodedUnknown.getField(2), {'ok': _TestColor.red});
    });

    test('cumulative DoS budget blocks chunked collections across all tiers',
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

      final schema = OmniBufSchema<_TypedCollectionObj>(
        name: 'T',
        create: _TypedCollectionObj.new,
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

    test('OpaqueMessage.marshalInto validates rawBytes by default', () {
      final w = OmniBufWriter()
        ..writeTag(2, WireType.string)
        ..writeVarint(2)
        ..writeByte(0xFF)
        ..writeByte(0xFE);
      final badBytes = w.toBytes();
      final op = gen_peer.OpaquePeerUpdate(badBytes);

      expect(
        () => op.marshalInto(OmniBufWriter()),
        throwsA(isA<OmniBufInvalidUtf8Exception>()),
      );
      final uncheckedWriter = OmniBufWriter();
      op.marshalInto(uncheckedWriter, validate: false);
      expect(uncheckedWriter.toBytes(), badBytes);
    });

    test('generated Opaque getters reject WireArray and WireMap trailing bytes',
        () {
      // Field 10: f10_uint32_arr with 1 element + 1 trailing byte
      final aw = OmniBufWriter();
      aw.writeTag(10, WireType.array);
      final aSlot = aw.reserveLen2();
      aw.writeByte(WireType.uint);
      aw.writeVarint(1);
      aw.writeVarint(42);
      aw.writeByte(0x99); // trailing byte
      aw.patchLen2(aSlot);
      expect(
        () => gen_conf.OpaqueTestAllTypes(aw.toBytes()).f10Uint32Arr,
        throwsA(isA<OmniBufParseException>()),
      );

      // Field 12: f12_map_str_uint with 1 entry + 1 trailing byte
      final mw = OmniBufWriter();
      mw.writeTag(12, WireType.map);
      final mSlot = mw.reserveLen2();
      mw.writeByte(WireType.string);
      mw.writeByte(WireType.uint);
      mw.writeVarint(1);
      mw.writeString('k');
      mw.writeVarint(7);
      mw.writeByte(0x99); // trailing byte
      mw.patchLen2(mSlot);
      expect(
        () => gen_conf.OpaqueTestAllTypes(mw.toBytes()).f12MapStrUint,
        throwsA(isA<OmniBufParseException>()),
      );
    });

    test('cycle and recursion guards throw OmniBufSerializeException', () {
      // Cyclic SchemaMeta
      final meta = SchemaMeta(typeName: 'Loop');
      meta.children[1] = meta;
      expect(() => meta.clone(), throwsA(isA<OmniBufSerializeException>()));
      expect(
        () => SchemaMeta().mergeFrom(meta),
        throwsA(isA<OmniBufSerializeException>()),
      );
      expect(
        () => meta.writeField0(OmniBufWriter()),
        throwsA(isA<OmniBufSerializeException>()),
      );

      // Cyclic OmniBufSchema object
      late final OmniBufSchema<_CyclicSchemaObj> cyclicSchema;
      cyclicSchema = OmniBufSchema<_CyclicSchemaObj>(
        name: 'Cyclic',
        create: _CyclicSchemaObj.new,
        fields: [
          OmniFieldDef(
            id: 1,
            name: 'next',
            kind: OmniFieldKind.message,
            subSchema: () => cyclicSchema,
            get: (m) => m.next,
            set: (m, v) => m.next = v as _CyclicSchemaObj?,
          ),
        ],
      );
      final cObj = _CyclicSchemaObj();
      cObj.next = cObj;
      expect(
        () => cyclicSchema.encode(cObj),
        throwsA(isA<OmniBufSerializeException>()),
      );

      // Cyclic GeneratedMessage
      final pbObj = _PbRecursiveMsg();
      pbObj.setField(1, pbObj);
      expect(
        () => ProtobufOmniBufCodec.encode(pbObj),
        throwsA(isA<OmniBufSerializeException>()),
      );

      // Cyclic Tier 1 generated message
      final genMeta = gen_meta.SchemaMeta(typeName: 'Loop');
      genMeta.children[1] = genMeta;
      expect(
        () => genMeta.estimateBodyBytes(),
        throwsA(isA<OmniBufSerializeException>()),
      );
      expect(
        () => genMeta.encode(),
        throwsA(isA<OmniBufSerializeException>()),
      );
    });

    test('OmniBufSchema._resetMessage preserves typed List and Map instances',
        () {
      final schema = OmniBufSchema<_TypedCollectionObj>(
        name: 'Typed',
        create: _TypedCollectionObj.new,
        fields: [
          OmniFieldDef(
            id: 1,
            name: 'tags',
            kind: OmniFieldKind.repeated,
            elementKind: OmniFieldKind.string,
            get: (m) => m.tags,
            set: (m, v) => m.tags = v as List<String>,
          ),
          OmniFieldDef(
            id: 2,
            name: 'scores',
            kind: OmniFieldKind.map,
            keyKind: OmniFieldKind.string,
            valueKind: OmniFieldKind.uint32,
            get: (m) => m.scores,
            set: (m, v) => m.scores = v as Map<String, int>,
          ),
        ],
      );

      final first = _TypedCollectionObj()
        ..tags = ['a', 'b']
        ..scores = {'x': 10};
      final second = _TypedCollectionObj()..tags = ['c'];

      final dst = schema.decode(schema.encode(first));
      expect(dst.tags, ['a', 'b']);
      expect(dst.scores, {'x': 10});

      // Replace-mode decodeInto must clear typed collections without TypeError.
      schema.decodeInto(schema.encode(second), dst);
      expect(dst.tags, ['c']);
      expect(dst.scores, isEmpty);
    });

    test('decodeBlind unifies empty nested container signatures', () {
      // Field 1: two WireArray-of-WireArray occurrences:
      // 1st is empty outer array -> signature A(13)
      // 2nd is [[1, 2]] -> signature A(13:A(0))
      final w = OmniBufWriter();
      w.writeTag(1, WireType.array);
      final s1 = w.reserveLen2();
      w.writeByte(WireType.array);
      w.writeVarint(0);
      w.patchLen2(s1);

      w.writeTag(1, WireType.array);
      final s2 = w.reserveLen2();
      w.writeByte(WireType.array);
      w.writeVarint(1);
      final innerSlot = w.reserveLen2();
      w.writeByte(WireType.uint);
      w.writeVarint(2);
      w.writeVarint(1);
      w.writeVarint(2);
      w.patchLen2(innerSlot);
      w.patchLen2(s2);

      final decoded = decodeBlind(w.toBytes());
      expect(decoded['field_1'], [
        [1, 2],
      ]);

      // True conflict: A(13:A(0)) followed by A(13:A(1)) must still throw.
      w.writeTag(1, WireType.array);
      final s3 = w.reserveLen2();
      w.writeByte(WireType.array);
      w.writeVarint(1);
      final badInner = w.reserveLen2();
      w.writeByte(WireType.sint);
      w.writeVarint(1);
      w.writeSint(-1);
      w.patchLen2(badInner);
      w.patchLen2(s3);
      expect(
        () => decodeBlind(w.toBytes()),
        throwsA(isA<OmniBufParseException>()),
      );
    });

    test('Field #0 empty-string tombstone across multiple blocks clears parent',
        () {
      final w = OmniBufWriter();
      // Parent Field #0: children[1].fields = {1: 'inherited_name'}
      SchemaMeta(
        children: {
          1: SchemaMeta(fields: {1: 'inherited_name'}),
        },
      ).writeField0(w);

      // Field #1 submessage with TWO Field #0 blocks:
      // Block 1 sets {1: 'temp_name'}, Block 2 sets {1: ''} tombstone.
      w.writeTag(1, WireType.subMsg);
      final subSlot = w.reserveLen2();
      SchemaMeta(fields: {1: 'temp_name'}).writeField0(w);
      SchemaMeta(fields: {1: ''}).writeField0(w);
      w.writeTag(1, WireType.uint);
      w.writeVarint(42);
      w.patchLen2(subSlot);

      final decoded = decodeBlind(w.toBytes());
      final child = decoded['field_1'] as Map<String, Object?>;
      expect(child.containsKey('inherited_name'), isFalse);
      expect(child['field_1'], 42);
    });

    test('OmniBufSchema sorts 32-bit map keys in masked wire order', () {
      final u32Map = <int, String>{-1: 'max', 1: 'one'};
      final u32Schema = OmniBufSchema<Map<int, String>>(
        name: 'U32',
        create: () => <int, String>{},
        fields: [
          OmniFieldDef(
            id: 1,
            name: 'm',
            kind: OmniFieldKind.map,
            keyKind: OmniFieldKind.uint32,
            valueKind: OmniFieldKind.string,
            get: (m) => m,
            set: (m, v) {},
          ),
        ],
      );
      final u32Bytes = u32Schema.encode(u32Map);
      final r1 = OmniBufReader(u32Bytes);
      r1.readTag();
      r1.readCheckedLength();
      r1.readMapHeader();
      expect(r1.readUint32(), 1);
      expect(r1.readString(), 'one');
      expect(r1.readUint32(), 0xFFFFFFFF);
      expect(r1.readString(), 'max');

      final s32Map = <int, String>{0xFFFFFFFF: 'neg_one', 1: 'one'};
      final s32Schema = OmniBufSchema<Map<int, String>>(
        name: 'S32',
        create: () => <int, String>{},
        fields: [
          OmniFieldDef(
            id: 1,
            name: 'm',
            kind: OmniFieldKind.map,
            keyKind: OmniFieldKind.sint32,
            valueKind: OmniFieldKind.string,
            get: (m) => m,
            set: (m, v) {},
          ),
        ],
      );
      final s32Bytes = s32Schema.encode(s32Map);
      final r2 = OmniBufReader(s32Bytes);
      r2.readTag();
      r2.readCheckedLength();
      r2.readMapHeader();
      expect(r2.readSint32(), -1);
      expect(r2.readString(), 'neg_one');
      expect(r2.readSint32(), 1);
      expect(r2.readString(), 'one');
    });

    test('descriptor _PbReader rejects varint overflow and out-of-bounds lens',
        () {
      // 11-byte varint with continuation bits set
      final overflowVarint = Uint8List.fromList(List.filled(11, 0x80));
      expect(
        () => CodeGeneratorRequest.decode(overflowVarint),
        throwsA(isA<FormatException>()),
      );

      // Field 1 (string, wt=2) claiming length 100 with only 2 bytes remaining
      final badLen = Uint8List.fromList([0x0A, 100, 0x41, 0x42]);
      expect(
        () => CodeGeneratorRequest.decode(badLen),
        throwsA(isA<FormatException>()),
      );

      // Unknown field (fnum=9, wt=1 fixed64) with only 2 bytes remaining
      final badFixed64 = Uint8List.fromList([(9 << 3) | 1, 0x01, 0x02]);
      expect(
        () => CodeGeneratorRequest.decode(badFixed64),
        throwsA(isA<FormatException>()),
      );
    });

    test('unknown field with invalid UTF-8 is rejected across all tiers', () {
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
        () => ProtobufOmniBufCodec.decodeInto(badUnknown, _PbTestMsg()),
        throwsA(isA<OmniBufInvalidUtf8Exception>()),
      );
      final schema = OmniBufSchema<_TypedCollectionObj>(
        name: 'T',
        create: _TypedCollectionObj.new,
        fields: const [],
      );
      expect(
        () => schema.decode(badUnknown),
        throwsA(isA<OmniBufInvalidUtf8Exception>()),
      );
    });

    test('DecodeOptions validates maxDepth 1..32 and enforces maxAllocBytes',
        () {
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

    test(
        'OpaqueMessage.marshalAppend supports fast default and validated tryMarshal',
        () {
      final w = OmniBufWriter()
        ..writeTag(2, WireType.string)
        ..writeVarint(2)
        ..writeByte(0xFF)
        ..writeByte(0xFE);
      final badBytes = w.toBytes();
      final op = gen_peer.OpaquePeerUpdate(badBytes);

      // Default marshalAppend skips deep UTF-8 scan for speed
      expect(op.marshalAppend(), badBytes);
      // Explicit validate: true and tryMarshal reject invalid UTF-8
      expect(
        () => op.marshalAppend(null, true),
        throwsA(isA<OmniBufInvalidUtf8Exception>()),
      );
      expect(
        () => op.tryMarshal(),
        throwsA(isA<OmniBufInvalidUtf8Exception>()),
      );
    });

    test(
        'decodeBlind rejects WireExtended and decodeBlindJson rejects non-finite floats',
        () {
      // Top-level WireExtended (fnum=1, wt=15, len=2, extType=1, payload=0xAA)
      final extW = OmniBufWriter()
        ..writeTag(1, WireType.extended)
        ..writeVarint(2)
        ..writeByte(1)
        ..writeByte(0xAA);
      expect(
        () => decodeBlind(extW.toBytes()),
        throwsA(isA<OmniBufParseException>()),
      );

      // Non-finite floats in decodeBlind vs decodeBlindJson
      for (final badFloat in [
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        final fw = OmniBufWriter()
          ..writeTag(1, WireType.float64)
          ..writeFloat64(badFloat);
        final wire = fw.toBytes();
        expect(decodeBlind(wire)['field_1'], isA<double>());
        expect(
          () => decodeBlindJson(wire),
          throwsA(isA<OmniBufSerializeException>()),
        );
      }
    });

    test('rejects nested Field #0 inside SchemaMeta', () {
      // Outer Field #0 containing an inner Field #0
      final innerMeta = OmniBufWriter();
      SchemaMeta(typeName: 'Inner').writeField0(innerMeta);
      final outer = OmniBufWriter()
        ..writeByte(WireType.field0EncodedTag)
        ..writeBytes(innerMeta.toBytes());
      final pkt = outer.toBytes();

      expect(
        () => decodeBlind(pkt),
        throwsA(isA<OmniBufParseException>()),
      );
      expect(
        () => validatePacket(pkt),
        throwsA(isA<OmniBufParseException>()),
      );
      expect(
        () => SchemaMeta.readFromPacket(pkt),
        throwsA(isA<OmniBufParseException>()),
      );
    });

    test(
        'codegen emits operator ==, hashCode, toString and avoids nested estimateBodyBytes',
        () {
      final fd = ProtoFileDescriptor()
        ..name = 'eq.proto'
        ..packageName = 'demo';
      final child = ProtoMessageDescriptor()..name = 'Child';
      child.fields.add(
        ProtoFieldDescriptor()
          ..name = 'x'
          ..number = 1
          ..label = 1
          ..type = 13,
      );
      final parent = ProtoMessageDescriptor()..name = 'Parent';
      parent.fields.addAll([
        ProtoFieldDescriptor()
          ..name = 'raw'
          ..number = 1
          ..label = 1
          ..type = 12,
        ProtoFieldDescriptor()
          ..name = 'child'
          ..number = 2
          ..label = 1
          ..type = 11
          ..typeName = '.demo.Child',
      ]);
      fd.messages.addAll([child, parent]);

      final req = CodeGeneratorRequest()
        ..fileToGenerate.add('eq.proto')
        ..protoFiles.add(fd);
      final code = generateOmniBufDart(req).files.single.content;
      expect(code, contains('bool operator ==(Object other)'));
      expect(code, contains('int get hashCode =>'));
      expect(code, contains('String toString() =>'));
      expect(code, contains('ob.bytesEquals(this.raw, other.raw)'));
      expect(code, isNot(contains('reserveLenAuto(sub.estimateBodyBytes')));
    });
  });
}
