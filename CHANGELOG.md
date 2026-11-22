# Changelog

## 0.1.0

- Initial OmniBuf v0.1 Dart implementation covering all 16 wire types, 1/2/4/9-byte Prefix-Varints, 64-bit ZigZag, strict UTF-8 validation, unsigned UTF-8 deterministic map sorting, Field #0 `SchemaMeta`, and container depth/allocation budgets.
- Added Tier 1 `protoc-gen-omnibuf-dart` plugin with lazy `Opaque` zero-decode views and in-place wire splicing.
- Added Tier 2 `ProtobufOmniBufCodec` for `package:protobuf` `GeneratedMessage` types.
- Added Tier 3 `OmniBufSchema` declarative and annotated class codec.
- Added Tier 4 `decodeBlind` and `decodeBlindJson` schema-less decoders.
- Verified 992/992 cross-language conformance tests across all 4 tiers.
