import 'package:omnibuf/omnibuf.dart';
import 'package:test/test.dart';

void main() {
  group('Tier 4 Blind Decode & Container Shape Unification', () {
    test('unifies empty nested array shapes and rejects conflicting elements',
        () {
      // Field 1: two WireArray-of-WireArray occurrences:
      // 1st is empty outer array -> shape A(13)
      // 2nd is [[1, 2]] -> shape A(13:A(0))
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

    test('unifies empty nested map shapes and rejects conflicting value shapes',
        () {
      // Field 1: empty map<string, array> followed by {'a': [7]}
      final w = OmniBufWriter();
      w.writeTag(1, WireType.map);
      final s1 = w.reserveLen2();
      w.writeByte(WireType.string);
      w.writeByte(WireType.array);
      w.writeVarint(0);
      w.patchLen2(s1);

      w.writeTag(1, WireType.map);
      final s2 = w.reserveLen2();
      w.writeByte(WireType.string);
      w.writeByte(WireType.array);
      w.writeVarint(1);
      w.writeString('a');
      final arrSlot = w.reserveLen2();
      w.writeByte(WireType.uint);
      w.writeVarint(1);
      w.writeVarint(7);
      w.patchLen2(arrSlot);
      w.patchLen2(s2);

      final decoded = decodeBlind(w.toBytes());
      expect(decoded['field_1'], {
        'a': [7],
      });

      // Appending a map<string, array<sint>> conflicts with M(10,13:A(0)).
      w.writeTag(1, WireType.map);
      final s3 = w.reserveLen2();
      w.writeByte(WireType.string);
      w.writeByte(WireType.array);
      w.writeVarint(1);
      w.writeString('b');
      final badArrSlot = w.reserveLen2();
      w.writeByte(WireType.sint);
      w.writeVarint(1);
      w.writeSint(-3);
      w.patchLen2(badArrSlot);
      w.patchLen2(s3);
      expect(
        () => decodeBlind(w.toBytes()),
        throwsA(isA<OmniBufParseException>()),
      );
    });

    test('rejects WireExtended and formats non-finite floats in JSON output',
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

      // Non-finite floats in decodeBlind vs decodeBlindJson (conformance strings)
      for (final entry in [
        (double.nan, '{"field_1":"NaN"}'),
        (double.infinity, '{"field_1":"Infinity"}'),
        (double.negativeInfinity, '{"field_1":"-Infinity"}'),
      ]) {
        final fw = OmniBufWriter()
          ..writeTag(1, WireType.float64)
          ..writeFloat64(entry.$1);
        final wire = fw.toBytes();
        expect(decodeBlind(wire)['field_1'], isA<double>());
        expect(decodeBlindJson(wire), equals(entry.$2));
      }
    });
  });

  group('Field #0 SchemaMeta Resolution', () {
    test('empty-string tombstones across multiple blocks clear inherited names',
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
  });
}
