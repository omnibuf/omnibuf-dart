/// gRPC codec entrypoint for `package:grpc` (`ClientMethod` and `ServiceMethod`).
library;

import 'dart:typed_data';

import 'src/options.dart';
import 'src/schema.dart';

export 'src/options.dart' show DecodeOptions, EncodeOptions;

/// Standard gRPC codec name for compact OmniBuf payloads.
const String omnibufGrpcCodecName = 'omnibuf';

/// gRPC codec name for self-describing OmniBuf payloads carrying Field #0 metadata.
const String omnibufGrpcSelfDescribingCodecName = 'x-omnibuf';

/// gRPC HTTP/2 content-type header value for compact OmniBuf payloads.
const String omnibufGrpcContentType = 'application/grpc+omnibuf';

/// gRPC HTTP/2 content-type header value for self-describing OmniBuf payloads.
const String omnibufGrpcSelfDescribingContentType =
    'application/grpc+x-omnibuf';

/// Function signature for encoding a message of type [T] into OmniBuf bytes.
typedef OmniBufGrpcEncode<T> = Uint8List Function(
  T message, {
  EncodeOptions options,
});

/// Function signature for decoding OmniBuf bytes into a message of type [T].
typedef OmniBufGrpcDecode<T> = T Function(
  Uint8List data, {
  DecodeOptions options,
});

/// gRPC codec for `package:grpc` `ClientMethod` and `ServiceMethod`.
///
/// Supports both `protoc-gen-omnibuf-dart` generated message classes and
/// declarative [OmniBufSchema] codecs.
class OmniBufGrpcCodec<T> {
  final OmniBufGrpcEncode<T> _encode;
  final OmniBufGrpcDecode<T> _decode;

  /// Encoding options applied by [serialize].
  final EncodeOptions encodeOptions;

  /// Decoding limits applied by [deserialize].
  final DecodeOptions decodeOptions;

  /// Creates a gRPC codec from explicit [encode] and [decode] functions.
  const OmniBufGrpcCodec({
    required OmniBufGrpcEncode<T> encode,
    required OmniBufGrpcDecode<T> decode,
    this.encodeOptions = EncodeOptions.defaults,
    this.decodeOptions = DecodeOptions.defaults,
  })  : _encode = encode,
        _decode = decode;

  /// Creates a gRPC codec backed by a declarative [OmniBufSchema].
  OmniBufGrpcCodec.fromSchema(
    OmniBufSchema<T> schema, {
    EncodeOptions encodeOptions = EncodeOptions.defaults,
    DecodeOptions decodeOptions = DecodeOptions.defaults,
  }) : this(
          encode: schema.encode,
          decode: schema.decode,
          encodeOptions: encodeOptions,
          decodeOptions: decodeOptions,
        );

  /// gRPC codec identifier (`omnibuf` or `x-omnibuf`).
  String get name => encodeOptions.selfDescribing
      ? omnibufGrpcSelfDescribingCodecName
      : omnibufGrpcCodecName;

  /// gRPC content-type header matching [encodeOptions].
  String get contentType => encodeOptions.selfDescribing
      ? omnibufGrpcSelfDescribingContentType
      : omnibufGrpcContentType;

  /// Serializes [message] into OmniBuf wire bytes for `package:grpc`.
  List<int> serialize(T message) => _encode(message, options: encodeOptions);

  /// Deserializes OmniBuf wire [data] from `package:grpc` into a new [T].
  T deserialize(List<int> data) {
    final bytes = data is Uint8List ? data : Uint8List.fromList(data);
    return _decode(bytes, options: decodeOptions);
  }
}
