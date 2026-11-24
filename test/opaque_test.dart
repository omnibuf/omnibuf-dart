import 'package:omnibuf/omnibuf.dart';
import 'package:omnibuf/src/generated/omnibuf/bench/peer.omnibuf.dart'
    as gen_peer;
import 'package:omnibuf/src/generated/omnibuf/conformance/conformance.omnibuf.dart'
    as gen_conf;
import 'package:test/test.dart';

void main() {
  group('Tier 1 Generated Messages, Opaque Views & Wire Splicing', () {
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

    test('marshalInto validates rawBytes by default and allows opt-out', () {
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

    test(
        'marshalAppend skips deep validation by default while tryMarshal validates',
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

    test('generated Opaque array and map getters reject trailing bytes', () {
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
  });
}
