/// Detached Connect RPC codec entrypoint for `connect-dart` without adding a
/// runtime dependency on `package:connectrpc` to core `package:omnibuf/omnibuf.dart`.
library;

import 'dart:typed_data';

import 'src/options.dart';
import 'src/schema.dart';

export 'src/options.dart' show DecodeOptions, EncodeOptions;

/// Standard Connect codec name for compact OmniBuf payloads.
const String omnibufConnectCodecName = 'omnibuf';

/// Connect codec name for self-describing OmniBuf payloads carrying Field #0 metadata.
const String omnibufConnectSelfDescribingCodecName = 'x-omnibuf';

/// Function signature for encoding a message of type [T] into OmniBuf bytes.
typedef OmniBufConnectEncode<T> = Uint8List Function(
  T message, {
  EncodeOptions options,
});

/// Function signature for decoding OmniBuf bytes into a message of type [T].
typedef OmniBufConnectDecode<T> = T Function(
  Uint8List data, {
  DecodeOptions options,
});

/// Detached Connect RPC codec matching `connect-dart`'s `Codec` shape
/// (`name`, `encode`, `decode`).
///
/// Supports both `protoc-gen-omnibuf-dart` generated message classes and
/// declarative [OmniBufSchema] codecs.
class OmniBufConnectCodec<T> {
  final OmniBufConnectEncode<T> _encode;
  final OmniBufConnectDecode<T> _decode;

  /// Encoding options applied by [encode].
  final EncodeOptions encodeOptions;

  /// Decoding limits applied by [decode].
  final DecodeOptions decodeOptions;

  /// Creates a Connect codec from explicit [encode] and [decode] functions.
  const OmniBufConnectCodec({
    required OmniBufConnectEncode<T> encode,
    required OmniBufConnectDecode<T> decode,
    this.encodeOptions = EncodeOptions.defaults,
    this.decodeOptions = DecodeOptions.defaults,
  })  : _encode = encode,
        _decode = decode;

  /// Creates a Connect codec backed by a declarative [OmniBufSchema].
  OmniBufConnectCodec.fromSchema(
    OmniBufSchema<T> schema, {
    EncodeOptions encodeOptions = EncodeOptions.defaults,
    DecodeOptions decodeOptions = DecodeOptions.defaults,
  }) : this(
          encode: schema.encode,
          decode: schema.decode,
          encodeOptions: encodeOptions,
          decodeOptions: decodeOptions,
        );

  /// Connect codec identifier (`omnibuf` or `x-omnibuf`).
  String get name => encodeOptions.selfDescribing
      ? omnibufConnectSelfDescribingCodecName
      : omnibufConnectCodecName;

  /// Connect unary HTTP content-type header (`application/omnibuf` or `application/x-omnibuf`).
  String get unaryContentType => 'application/$name';

  /// Connect streaming HTTP content-type header (`application/connect+omnibuf` or `application/connect+x-omnibuf`).
  String get streamingContentType => 'application/connect+$name';

  /// Encodes [message] into OmniBuf wire bytes.
  Uint8List encode(T message) => _encode(message, options: encodeOptions);

  /// Decodes OmniBuf wire [data] into a new [T].
  T decode(Uint8List data) => _decode(data, options: decodeOptions);
}
