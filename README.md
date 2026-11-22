# OmniBuf for Dart

Dart 3 implementation of the [OmniBuf v0.1](https://omnibuf.com/spec) binary wire format.

## Features

- **Core v0.1 Wire Codec**: All 16 wire types (`WireUint` through `WireExtended`), 1/2/4/9-byte Prefix-Varints with non-minimal decoding and reserved-prefix rejection, 64-bit ZigZag + 32-bit narrowing, strict UTF-8 validation, `O(1)` field skipping, and unsigned UTF-8 byte-order deterministic map sorting.
- **Field #0 Self-Describing Metadata**: Optional `SchemaMeta` embedding, recursive child propagation, empty-string name clearing, and multi-block merge support.
- **Tier 1 (`protoc-gen-omnibuf-dart`)**: Generates idiomatic Dart 3 message classes, single-pass `Uint8List`/`ByteData` encoders with 4-byte container pre-sizing, and lazy `Opaque` views for zero-decode field access and in-place wire splicing.
- **Tier 2 (`package:protobuf`)**: `ProtobufOmniBufCodec` serializes and deserializes standard `GeneratedMessage` instances directly via `BuilderInfo`.
- **Tier 3 (`OmniBufSchema`)**: Declarative and `@OmniBufMessage` / `@OmniBufField` class schema codec with replace and merge decoding modes.
- **Tier 4 (`decodeBlind` / `decodeBlindJson`)**: Schema-less packet inspection resolving Field #0 names or `field_<N>` fallback keys.

## Installation

Add `omnibuf` to your `pubspec.yaml`:

```yaml
dependencies:
  omnibuf: ^0.1.0
```

## Quick Start

```dart
import 'package:omnibuf/omnibuf.dart';
import 'package:omnibuf/src/generated/omnibuf/bench/peer.omnibuf.dart';

void main() {
  final msg = PeerUpdate(
    asn: 64512,
    routerId: 'edge-rtr-fra01',
    active: true,
    location: Location(city: 'Frankfurt', rack: 42),
    sequence: 100,
  );

  // Single-pass binary encode
  final bytes = msg.encode();

  // Zero-decode nested field read via Opaque view
  final view = OpaquePeerUpdate(bytes);
  print(view.locationOpaque?.city); // Frankfurt

  // In-place wire splice (untouched fields copy verbatim)
  view.sequence = view.sequence + 1;
  final patched = view.marshalAppend();

  // Schema-less inspection
  print(decodeBlindJson(patched));
}
```

## Benchmarks

Dart benchmark results, methodology, and cross-language comparisons live at [omnibuf.com/benchmarks?lang=dart](https://omnibuf.com/benchmarks?lang=dart) (all languages at [omnibuf.com/benchmarks](https://omnibuf.com/benchmarks)). Run `just bench` locally to execute the AOT suite and regenerate [`testdata/benchmarks.json`](testdata/benchmarks.json).

## Development & Verification

```bash
just install      # dart pub get
just proto        # buf lint + regenerate Tier 1 Dart code
just build        # AOT-compile plugin, conformance adapter, and benchmarks
just test         # dart test
just conformance  # Run cross-language conformance-runner (992/992 across all 4 tiers)
just bench        # Run AOT PeerUpdate benchmarks -> testdata/benchmarks.json
just ci           # fmt-check + lint + build + test + conformance
```

## License

Apache-2.0. See [LICENSE](LICENSE).
