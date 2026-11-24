import 'dart:typed_data';

import 'package:omnibuf/connect.dart';
import 'package:omnibuf/omnibuf.dart';
import 'package:omnibuf/src/generated/omnibuf/bench/peer.omnibuf.dart';
import 'package:test/test.dart';

@OmniBufMessage('ConnectPing')
class _ConnectPing {
  @OmniBufField(1, name: 'node', kind: OmniFieldKind.string)
  String node;

  @OmniBufField(2, name: 'seq', kind: OmniFieldKind.uint64)
  int seq;

  @OmniBufField(3, name: 'ok', kind: OmniFieldKind.boolType)
  bool ok;

  _ConnectPing({this.node = '', this.seq = 0, this.ok = false});
}

final OmniBufSchema<_ConnectPing> _connectPingSchema =
    OmniBufSchema<_ConnectPing>(
  name: 'ConnectPing',
  create: _ConnectPing.new,
  fields: [
    OmniFieldDef<_ConnectPing>(
      id: 1,
      name: 'node',
      kind: OmniFieldKind.string,
      get: (m) => m.node,
      set: (m, v) => m.node = v as String,
    ),
    OmniFieldDef<_ConnectPing>(
      id: 2,
      name: 'seq',
      kind: OmniFieldKind.uint64,
      get: (m) => m.seq,
      set: (m, v) => m.seq = v as int,
    ),
    OmniFieldDef<_ConnectPing>(
      id: 3,
      name: 'ok',
      kind: OmniFieldKind.boolType,
      get: (m) => m.ok,
      set: (m, v) => m.ok = v as bool,
    ),
  ],
);

void main() {
  group('OmniBufConnectCodec', () {
    test('exposes expected Connect codec names and content types', () {
      expect(omnibufConnectCodecName, 'omnibuf');
      expect(omnibufConnectSelfDescribingCodecName, 'x-omnibuf');

      final compact = OmniBufConnectCodec.fromSchema(_connectPingSchema);
      final selfDescribing = OmniBufConnectCodec.fromSchema(
        _connectPingSchema,
        encodeOptions: EncodeOptions.selfDescribingDefaults,
      );

      expect(compact.name, 'omnibuf');
      expect(compact.unaryContentType, 'application/omnibuf');
      expect(compact.streamingContentType, 'application/connect+omnibuf');

      expect(selfDescribing.name, 'x-omnibuf');
      expect(selfDescribing.unaryContentType, 'application/x-omnibuf');
      expect(
        selfDescribing.streamingContentType,
        'application/connect+x-omnibuf',
      );
    });

    test('round-trips generated OmniBuf message classes', () {
      final codec = OmniBufConnectCodec<Location>(
        encode: (msg, {options = EncodeOptions.defaults}) =>
            msg.encode(options: options),
        decode: Location.decode,
      );

      final original = Location(
        region: 'us-east',
        datacenter: 'iad2',
        city: 'Ashburn',
        rack: 17,
      );

      final Uint8List wire = codec.encode(original);
      final decoded = codec.decode(wire);

      expect(decoded.region, 'us-east');
      expect(decoded.datacenter, 'iad2');
      expect(decoded.city, 'Ashburn');
      expect(decoded.rack, 17);
    });

    test('round-trips OmniBufSchema in compact and self-describing modes', () {
      final compact = OmniBufConnectCodec.fromSchema(_connectPingSchema);
      final selfDescribing = OmniBufConnectCodec.fromSchema(
        _connectPingSchema,
        encodeOptions: EncodeOptions.selfDescribingDefaults,
      );

      final original = _ConnectPing(node: 'edge-sjc-04', seq: 512, ok: true);
      final compactBytes = compact.encode(original);
      final selfDescribingBytes = selfDescribing.encode(original);

      expect(selfDescribingBytes.length, greaterThan(compactBytes.length));

      final decoded = selfDescribing.decode(selfDescribingBytes);
      expect(decoded.node, 'edge-sjc-04');
      expect(decoded.seq, 512);
      expect(decoded.ok, isTrue);

      final blind = decodeBlind(selfDescribingBytes);
      expect(blind['node'], 'edge-sjc-04');
      expect(blind['seq'], 512);
      expect(blind['ok'], isTrue);
    });

    test('enforces DecodeOptions limits on decode', () {
      final limited = OmniBufConnectCodec.fromSchema(
        _connectPingSchema,
        decodeOptions: const DecodeOptions(maxMessageBytes: 4),
      );
      final wire = limited.encode(
        _ConnectPing(node: 'oversized-node-name', seq: 1, ok: true),
      );

      expect(
        () => limited.decode(wire),
        throwsA(isA<OmniBufAllocationLimitException>()),
      );
    });
  });
}
