# Changelog

## 0.1.2

- Added detached `package:omnibuf/grpc.dart` codec helpers (`ClientMethod` and `ServiceMethod` marshallers for `package:grpc`) with zero runtime gRPC dependency on core `package:omnibuf/omnibuf.dart`.
- Added detached `package:omnibuf/connect.dart` codec helpers (`OmniBufConnectCodec`) separate from gRPC.
- Added integration tests exercising `package:grpc` loopback `Server` and `ClientChannel` unary RPCs and Connect codec round-trips.

## 0.1.1

- Hardened cumulative decode element budgets across all 4 tiers, `decodeBlind`, and Field #0 validation.
- Fixed `ProtobufOmniBufCodec` enum map and repeated enum decoding (`TypeError` on unknown values).
- Added recursion/cycle guards on encoding and `SchemaMeta`, default validation in `OpaqueMessage.marshalInto`, trailing-bytes checks on generated `Opaque` getters, Field #0 empty-string tombstones, and nested-type/import/keyword escaping in `protoc-gen-omnibuf-dart`.

## 0.1.0

- Initial OmniBuf v0.1 Dart implementation covering all 16 wire types, 1/2/4/9-byte Prefix-Varints, 64-bit ZigZag, strict UTF-8 validation, unsigned UTF-8 deterministic map sorting, Field #0 `SchemaMeta`, and container depth/allocation budgets.
- Added Tier 1 `protoc-gen-omnibuf-dart` plugin with lazy `Opaque` zero-decode views and in-place wire splicing.
- Added Tier 2 `ProtobufOmniBufCodec` for `package:protobuf` `GeneratedMessage` types.
- Added Tier 3 `OmniBufSchema` declarative and annotated class codec.
- Added Tier 4 `decodeBlind` and `decodeBlindJson` schema-less decoders.
- Verified 992/992 cross-language conformance tests across all 4 tiers.
