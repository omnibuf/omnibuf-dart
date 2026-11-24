/// Exception hierarchy for OmniBuf encoding, decoding, and validation.
sealed class OmniBufException implements Exception {
  /// Human-readable error description.
  final String message;

  const OmniBufException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when wire bytes violate the OmniBuf v1 DRAFT-1 specification.
class OmniBufParseException extends OmniBufException {
  const OmniBufParseException(super.message);
}

/// Thrown when a message or value cannot be serialized to OmniBuf wire format.
class OmniBufSerializeException extends OmniBufException {
  const OmniBufSerializeException(super.message);
}

/// Thrown when container recursion exceeds [DecodeOptions.maxDepth].
class OmniBufDepthLimitException extends OmniBufParseException {
  final int maxDepth;

  const OmniBufDepthLimitException(this.maxDepth)
      : super('container nesting depth exceeded limit of $maxDepth');
}

/// Thrown when a payload or collection exceeds configured size or count budgets.
class OmniBufAllocationLimitException extends OmniBufParseException {
  const OmniBufAllocationLimitException(super.message);
}

/// Thrown when a `WireString` contains invalid UTF-8 byte sequences.
class OmniBufInvalidUtf8Exception extends OmniBufParseException {
  const OmniBufInvalidUtf8Exception([super.message = 'invalid UTF-8 string']);
}

/// Thrown when a known collection field has an unexpected wire element/key/value type.
class OmniBufTypeMismatchException extends OmniBufParseException {
  const OmniBufTypeMismatchException(super.message);
}
