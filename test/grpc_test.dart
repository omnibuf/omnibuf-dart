import 'dart:io';
import 'dart:typed_data';

import 'package:grpc/grpc.dart';
import 'package:omnibuf/grpc.dart';
import 'package:omnibuf/omnibuf.dart';
import 'package:omnibuf/src/generated/omnibuf/bench/peer.omnibuf.dart';
import 'package:test/test.dart';

@OmniBufMessage('PingMessage')
class _PingMessage {
  @OmniBufField(1, name: 'node', kind: OmniFieldKind.string)
  String node;

  @OmniBufField(2, name: 'seq', kind: OmniFieldKind.uint64)
  int seq;

  @OmniBufField(3, name: 'ok', kind: OmniFieldKind.boolType)
  bool ok;

  _PingMessage({this.node = '', this.seq = 0, this.ok = false});
}

final OmniBufSchema<_PingMessage> _pingSchema = OmniBufSchema<_PingMessage>(
  name: 'PingMessage',
  create: _PingMessage.new,
  fields: [
    OmniFieldDef<_PingMessage>(
      id: 1,
      name: 'node',
      kind: OmniFieldKind.string,
      get: (m) => m.node,
      set: (m, v) => m.node = v as String,
    ),
    OmniFieldDef<_PingMessage>(
      id: 2,
      name: 'seq',
      kind: OmniFieldKind.uint64,
      get: (m) => m.seq,
      set: (m, v) => m.seq = v as int,
    ),
    OmniFieldDef<_PingMessage>(
      id: 3,
      name: 'ok',
      kind: OmniFieldKind.boolType,
      get: (m) => m.ok,
      set: (m, v) => m.ok = v as bool,
    ),
  ],
);

class _OmniBufPingService extends Service {
  final OmniBufGrpcCodec<Location> locationCodec;
  final OmniBufGrpcCodec<_PingMessage> pingCodec;

  @override
  String get $name => 'omnibuf.test.PingService';

  _OmniBufPingService({
    required this.locationCodec,
    required this.pingCodec,
  }) {
    $addMethod(
      ServiceMethod<Location, Location>(
        'EchoLocation',
        _echoLocation,
        false,
        false,
        locationCodec.deserialize,
        locationCodec.serialize,
      ),
    );
    $addMethod(
      ServiceMethod<_PingMessage, _PingMessage>(
        'Ping',
        _ping,
        false,
        false,
        pingCodec.deserialize,
        pingCodec.serialize,
      ),
    );
  }

  Future<Location> _echoLocation(
    ServiceCall call,
    Future<Location> request,
  ) async {
    final req = await request;
    return Location(
      region: req.region,
      datacenter: req.datacenter,
      city: req.city,
      rack: req.rack + 1,
    );
  }

  Future<_PingMessage> _ping(
    ServiceCall call,
    Future<_PingMessage> request,
  ) async {
    final req = await request;
    return _PingMessage(
      node: '${req.node}:ack',
      seq: req.seq + 1,
      ok: req.ok,
    );
  }
}

void main() {
  group('OmniBufGrpcCodec', () {
    test('exposes expected gRPC codec names and content types', () {
      expect(omnibufGrpcCodecName, 'omnibuf');
      expect(omnibufGrpcSelfDescribingCodecName, 'x-omnibuf');
      expect(omnibufGrpcContentType, 'application/grpc+omnibuf');
      expect(
        omnibufGrpcSelfDescribingContentType,
        'application/grpc+x-omnibuf',
      );

      final compact = OmniBufGrpcCodec.fromSchema(_pingSchema);
      final selfDescribing = OmniBufGrpcCodec.fromSchema(
        _pingSchema,
        encodeOptions: EncodeOptions.selfDescribingDefaults,
      );

      expect(compact.name, 'omnibuf');
      expect(compact.contentType, 'application/grpc+omnibuf');
      expect(selfDescribing.name, 'x-omnibuf');
      expect(selfDescribing.contentType, 'application/grpc+x-omnibuf');
    });

    test(
        'executes real package:grpc loopback unary RPCs (compact & self-describing)',
        () async {
      final locationCodec = OmniBufGrpcCodec<Location>(
        encode: (msg, {options = EncodeOptions.defaults}) =>
            msg.encode(options: options),
        decode: Location.decode,
      );
      final selfDescribingPingCodec = OmniBufGrpcCodec.fromSchema(
        _pingSchema,
        encodeOptions: EncodeOptions.selfDescribingDefaults,
      );

      final server = Server.create(
        services: [
          _OmniBufPingService(
            locationCodec: locationCodec,
            pingCodec: selfDescribingPingCodec,
          ),
        ],
      );
      await server.serve(address: InternetAddress.loopbackIPv4, port: 0);

      final channel = ClientChannel(
        InternetAddress.loopbackIPv4.address,
        port: server.port!,
        options: const ChannelOptions(
          credentials: ChannelCredentials.insecure(),
        ),
      );

      try {
        final echoMethod = ClientMethod<Location, Location>(
          '/omnibuf.test.PingService/EchoLocation',
          locationCodec.serialize,
          locationCodec.deserialize,
        );
        final echoCall = channel.createCall(
          echoMethod,
          Stream.value(
            Location(
              region: 'eu-central',
              datacenter: 'fra1',
              city: 'Frankfurt',
              rack: 42,
            ),
          ),
          CallOptions(),
        );
        final echoResp = await ResponseFuture<Location>(echoCall);
        expect(echoResp.region, 'eu-central');
        expect(echoResp.datacenter, 'fra1');
        expect(echoResp.city, 'Frankfurt');
        expect(echoResp.rack, 43);

        final pingMethod = ClientMethod<_PingMessage, _PingMessage>(
          '/omnibuf.test.PingService/Ping',
          selfDescribingPingCodec.serialize,
          selfDescribingPingCodec.deserialize,
        );
        final pingCall = channel.createCall(
          pingMethod,
          Stream.value(_PingMessage(node: 'edge-fra-01', seq: 9000, ok: true)),
          CallOptions(),
        );
        final pingResp = await ResponseFuture<_PingMessage>(pingCall);
        expect(pingResp.node, 'edge-fra-01:ack');
        expect(pingResp.seq, 9001);
        expect(pingResp.ok, isTrue);

        // Verify self-describing payload emitted Field #0 metadata.
        final selfDescWire = Uint8List.fromList(
          selfDescribingPingCodec.serialize(pingResp),
        );
        final blind = decodeBlind(selfDescWire);
        expect(blind['node'], 'edge-fra-01:ack');
        expect(blind['seq'], 9001);
      } finally {
        await channel.shutdown();
        await server.shutdown();
      }
    });

    test('enforces DecodeOptions limits on deserialize', () {
      final limited = OmniBufGrpcCodec.fromSchema(
        _pingSchema,
        decodeOptions: const DecodeOptions(maxMessageBytes: 4),
      );
      final wire = limited.serialize(
        _PingMessage(node: 'oversized-node-name', seq: 1, ok: true),
      );

      expect(
        () => limited.deserialize(wire),
        throwsA(isA<OmniBufAllocationLimitException>()),
      );
    });
  });
}
