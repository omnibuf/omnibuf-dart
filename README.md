# omnibuf-dart

[![OmniBuf Spec: v1 DRAFT-1](https://img.shields.io/badge/OmniBuf%20Spec-v1%20DRAFT--1-FF4F18)](https://omnibuf.com/spec)

Dart 3 implementation of the [OmniBuf v1 DRAFT-1 wire specification](https://omnibuf.com/spec). Documentation and benchmarks live at [omnibuf.com/dart](https://omnibuf.com/dart).

## Install

Add `omnibuf` to `pubspec.yaml`:

```yaml
dependencies:
  omnibuf: ^0.1.0
```

## Quick Usage

```dart
import 'package:omnibuf/omnibuf.dart';
import 'package:omnibuf/src/generated/omnibuf/bench/peer.omnibuf.dart';

void main() {
  final msg = PeerUpdate(
    asn: 64512,
    routerId: 'edge-rtr-fra01',
    active: true,
    sequence: 100,
  );

  final bytes = msg.encode();
  final view = OpaquePeerUpdate(bytes);
  view.sequence = view.sequence + 1;
  final patched = view.marshalAppend();
}
```

## gRPC

Import the detached `package:omnibuf/grpc.dart` entrypoint for `package:grpc` without adding a runtime gRPC dependency to core `omnibuf`.

```dart
import 'package:grpc/grpc.dart';
import 'package:omnibuf/grpc.dart';
import 'package:omnibuf/src/generated/omnibuf/bench/peer.omnibuf.dart';

final codec = OmniBufGrpcCodec<PeerUpdate>(
  encode: (msg, {options = EncodeOptions.defaults}) =>
      msg.encode(options: options),
  decode: PeerUpdate.decode,
);

final method = ClientMethod<PeerUpdate, PeerUpdate>(
  '/omnibuf.bench.PeerService/Update',
  codec.serialize,
  codec.deserialize,
);
```

## Connect RPC

Import the separate `package:omnibuf/connect.dart` entrypoint for `connect-dart` codecs.

```dart
import 'package:omnibuf/connect.dart';

final schemaCodec = OmniBufConnectCodec.fromSchema(mySchema);
final bytes = schemaCodec.encode(value);
final decoded = schemaCodec.decode(bytes);
```

Set `encodeOptions: EncodeOptions.selfDescribingDefaults` on either codec to emit `Field #0` metadata under codec name `x-omnibuf`.

## Implementation Details

- **64-bit Dart VM wire codec**: Operates directly on `Uint8List` and `ByteData` with single-pass container pre-sizing and `O(1)` field skipping.
- **`package:protobuf` interop**: `ProtobufOmniBufCodec` encodes and decodes `GeneratedMessage` instances via `BuilderInfo`.
- **Codegen**: `protoc-gen-omnibuf-dart` emits Dart 3 message classes and lazy `OpaqueMessage` views with `spliceFields` in-place mutation.
- **Declarative schemas**: `OmniBufSchema` and `@OmniBufMessage` / `@OmniBufField` annotations support replace and merge decoding modes.
- **Blind decode**: `decodeBlind` and `decodeBlindJson` resolve `Field #0` metadata or `field_<N>` fallback keys.

## Development

```bash
just install && just build && just test && just conformance
```

## License

Apache-2.0. See [LICENSE](./LICENSE).
