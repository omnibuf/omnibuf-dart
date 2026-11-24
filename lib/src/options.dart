/// Options controlling OmniBuf wire decoding and validation budgets.
class DecodeOptions {
  /// Default maximum container nesting depth (OmniBuf v0.1 spec Section 10).
  static const int defaultMaxDepth = 32;

  /// Default maximum root message size in bytes (64 MiB).
  static const int defaultMaxMessageBytes = 64 * 1024 * 1024;

  /// Default maximum element count for a single WireArray or WireMap.
  static const int defaultMaxCollectionElements = 16 * 1024 * 1024;

  /// Default maximum cumulative allocated bytes during decode (64 MiB).
  static const int defaultMaxAllocBytes = 64 * 1024 * 1024;

  /// Maximum container depth (`WireSubMsg`, `WireArray`, `WireMap` each add +1).
  final int maxDepth;

  /// Maximum accepted root packet byte length.
  final int maxMessageBytes;

  /// Maximum element or entry count allowed in any single collection.
  final int maxCollectionElements;

  /// Maximum cumulative bytes allocated during a single decode pass.
  final int maxAllocBytes;

  /// When `true`, decoding merges into an existing message instead of resetting
  /// omitted fields.
  final bool merge;

  const DecodeOptions({
    this.maxDepth = defaultMaxDepth,
    this.maxMessageBytes = defaultMaxMessageBytes,
    this.maxCollectionElements = defaultMaxCollectionElements,
    this.maxAllocBytes = defaultMaxAllocBytes,
    this.merge = false,
  });

  /// Validates resource limit options and returns the validated `maxDepth` in `1..32`.
  int validatedMaxDepth() {
    if (maxDepth < 1 || maxDepth > defaultMaxDepth) {
      throw RangeError.range(maxDepth, 1, defaultMaxDepth, 'maxDepth');
    }
    if (maxMessageBytes < 0) {
      throw RangeError.value(
          maxMessageBytes, 'maxMessageBytes', 'must be >= 0');
    }
    if (maxCollectionElements < 0) {
      throw RangeError.value(
        maxCollectionElements,
        'maxCollectionElements',
        'must be >= 0',
      );
    }
    if (maxAllocBytes < 0) {
      throw RangeError.value(maxAllocBytes, 'maxAllocBytes', 'must be >= 0');
    }
    return maxDepth;
  }

  /// Default replace-mode decode options.
  static const DecodeOptions defaults = DecodeOptions();

  /// Default merge-mode decode options.
  static const DecodeOptions mergeDefaults = DecodeOptions(merge: true);
}

/// Options controlling OmniBuf wire encoding.
class EncodeOptions {
  /// When `true`, emits Field #0 (`SchemaMeta`) so blind readers resolve names.
  final bool selfDescribing;

  /// When `true` (default), sorts map keys deterministically in wire order
  /// (unsigned UTF-8 byte order for strings, numeric order for ints, false < true).
  final bool deterministicMaps;

  const EncodeOptions({
    this.selfDescribing = false,
    this.deterministicMaps = true,
  });

  /// Default compact encode options (no Field #0, deterministic maps).
  static const EncodeOptions defaults = EncodeOptions();

  /// Self-describing encode options (emits Field #0 metadata).
  static const EncodeOptions selfDescribingDefaults =
      EncodeOptions(selfDescribing: true);
}
