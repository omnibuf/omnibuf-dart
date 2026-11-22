/// OmniBuf v0.1 binary wire format for Dart.
///
/// Provides:
/// - Core Prefix-Varint wire primitives, [OmniBufWriter], [OmniBufReader], and
///   all 16 explicit [WireType] codes.
/// - Field #0 [SchemaMeta] self-describing metadata support.
/// - Tier 1 generated code runtime and lazy [OpaqueMessage] zero-decode views
///   with in-place [spliceFields] wire splicing.
/// - Tier 2 [ProtobufOmniBufCodec] for standard `package:protobuf` messages.
/// - Tier 3 [OmniBufSchema] declarative/annotated class codec.
/// - Tier 4 [decodeBlind] and [decodeBlindJson] schema-less inspection.
library;

export 'src/blind.dart';
export 'src/errors.dart';
export 'src/opaque.dart';
export 'src/options.dart';
export 'src/protobuf_codec.dart';
export 'src/schema.dart';
export 'src/schema_meta.dart';
export 'src/wire.dart';
