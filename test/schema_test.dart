import 'package:fixnum/fixnum.dart' show Int64;
import 'package:omnibuf/omnibuf.dart';
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

class _TypedCollectionObj {
  List<String> tags = <String>[];
  Map<String, int> scores = <String, int>{};
}

class _CyclicSchemaObj {
  _CyclicSchemaObj? next;
}

void main() {
  group('Tier 2 package:protobuf Codec', () {
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

    test('round-trips repeated and map enums and skips unknown enum integers',
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
  });

  group('Tier 3 OmniBufSchema & Cycle Guards', () {
    test('replace-mode decodeInto clears typed List and Map fields in place',
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

    test('sorts 32-bit unsigned and signed map keys in masked wire order', () {
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

    test(
        'rejects cyclic graphs across SchemaMeta, OmniBufSchema, protobuf, and generated messages',
        () {
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
  });
}
