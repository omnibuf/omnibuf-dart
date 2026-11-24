import 'dart:convert';
import 'dart:typed_data';

import 'errors.dart';
import 'options.dart';

/// OmniBuf v1 DRAFT-1 4-bit wire type codes.
abstract final class WireType {
  static const int uint = 0;
  static const int sint = 1;
  static const int boolFalse = 2;
  static const int boolTrue = 3;
  static const int fixed32 = 4;
  static const int fixed64 = 5;
  static const int sfixed32 = 6;
  static const int sfixed64 = 7;
  static const int float32 = 8;
  static const int float64 = 9;
  static const int string = 10;
  static const int bytes = 11;
  static const int subMsg = 12;
  static const int array = 13;
  static const int map = 14;
  static const int extended = 15;

  /// Boolean element/key/value code inside WireArray and WireMap headers.
  static const int collectionBool = boolFalse;

  /// Maximum valid field number (`2^29 - 1`).
  static const int maxFieldNumber = 536870911;

  /// Maximum valid tag `(maxFieldNumber << 4) | 0x0F`.
  static const int maxTag = (maxFieldNumber << 4) | 0x0F;

  /// Encoded 1-byte tag for Field #0 (`SchemaMeta`, `WireSubMsg = 12`).
  static const int field0EncodedTag = 0x19;

  /// Returns `true` if [wt] is a valid WireArray element type or WireMap value type.
  static bool isValidCollectionType(int wt) =>
      wt >= 0 && wt <= 15 && wt != boolTrue;

  /// Returns `true` if [wt] is a valid WireMap key type.
  static bool isValidMapKeyType(int wt) {
    return wt == uint ||
        wt == sint ||
        wt == boolFalse ||
        wt == fixed32 ||
        wt == fixed64 ||
        wt == sfixed32 ||
        wt == sfixed64 ||
        wt == string;
  }

  /// Fixed byte width of [wt] inside a collection, or 0 if variable-width.
  static int fixedCollectionWidth(int wt) {
    switch (wt) {
      case boolFalse:
        return 1;
      case fixed32:
      case sfixed32:
      case float32:
        return 4;
      case fixed64:
      case sfixed64:
      case float64:
        return 8;
      default:
        return 0;
    }
  }
}

/// Sign bit constant for unsigned 64-bit integer comparisons in Dart's signed 64-bit `int`.
const int _int64SignBit = -9223372036854775808; // 0x8000000000000000

/// Compares two 64-bit values as unsigned `uint64`.
int compareUint64(int a, int b) {
  return (a ^ _int64SignBit).compareTo(b ^ _int64SignBit);
}

/// Converts a raw 64-bit `int` (unsigned bit pattern) to a non-negative [BigInt].
BigInt uint64ToBigInt(int v) {
  if (v >= 0) return BigInt.from(v);
  return BigInt.from(v).toUnsigned(64);
}

/// Converts a [BigInt] to a raw 64-bit `int` bit pattern.
int bigIntToUint64(BigInt v) {
  return v.toSigned(64).toInt();
}

/// Formats a raw 64-bit `int` as an unsigned decimal string.
String uint64ToDecimal(int v) {
  if (v >= 0) return v.toString();
  return BigInt.from(v).toUnsigned(64).toString();
}

/// Compares two strings in unsigned UTF-8 byte order (NOT UTF-16 code-unit order).
int compareUtf8(String a, String b) {
  final lenA = a.length;
  final lenB = b.length;
  final minLen = lenA < lenB ? lenA : lenB;
  for (var i = 0; i < minLen; i++) {
    final cuA = a.codeUnitAt(i);
    final cuB = b.codeUnitAt(i);
    if (cuA != cuB) {
      if (cuA < 0xD800 && cuB < 0xD800) {
        return cuA - cuB;
      }
      // At least one side is >= 0xD800 (surrogate or U+E000..U+FFFF):
      // compare actual UTF-8 bytes from this point.
      final bytesA = utf8.encode(a);
      final bytesB = utf8.encode(b);
      final minBytes =
          bytesA.length < bytesB.length ? bytesA.length : bytesB.length;
      for (var j = 0; j < minBytes; j++) {
        final d = bytesA[j] - bytesB[j];
        if (d != 0) return d;
      }
      return bytesA.length - bytesB.length;
    }
  }
  return lenA - lenB;
}

/// Encodes a signed 64-bit integer using ZigZag mapping.
int zigzagEncode(int n) => (n << 1) ^ (n >> 63);

/// Decodes a ZigZag-mapped unsigned 64-bit integer to signed 64-bit `int`.
int zigzagDecode(int u) => (u >>> 1) ^ -(u & 1);

/// Encodes a field tag `(fieldNumber << 4) | wireType`.
int makeTag(int fieldNumber, int wireType) => (fieldNumber << 4) | wireType;

/// Returns the minimal Prefix-Varint byte width for an unsigned 64-bit value.
int varintWidth(int v) {
  if (v >= 0) {
    if (v < 128) return 1;
    if (v < 16384) return 2;
    if (v < 536870912) return 4;
  }
  return 9;
}

/// High-performance single-pass OmniBuf binary writer with reusable slab support.
class OmniBufWriter {
  Uint8List _buf;
  ByteData _bd;
  int _pos = 0;

  OmniBufWriter([int initialCapacity = 512])
      : _buf = Uint8List(initialCapacity < 32 ? 32 : initialCapacity),
        _bd = ByteData(0) {
    _bd = ByteData.sublistView(_buf);
  }

  /// Current written byte length.
  int get length => _pos;

  /// Resets the write cursor to 0 while keeping the backing buffer for reuse.
  void reset() {
    _pos = 0;
  }

  /// Returns a freshly copied [Uint8List] containing the written bytes.
  Uint8List toBytes() {
    final out = Uint8List(_pos);
    out.setRange(0, _pos, _buf);
    return out;
  }

  /// Returns a zero-copy view of the written bytes (valid until next mutation/reset).
  Uint8List viewBytes() => Uint8List.sublistView(_buf, 0, _pos);

  static const int _maxGrowShift = 1 << 62;

  void _grow(int needed) {
    if (needed < 0) {
      throw const OmniBufSerializeException('negative buffer growth requested');
    }
    final minCap = _pos + needed;
    if (minCap < _pos) {
      throw const OmniBufSerializeException('buffer capacity overflow');
    }
    var newCap = _buf.length;
    if (newCap <= 0) {
      newCap = minCap;
    } else {
      while (newCap < minCap) {
        if (newCap >= _maxGrowShift) {
          newCap = minCap;
          break;
        }
        newCap <<= 1;
      }
    }
    final next = Uint8List(newCap);
    next.setRange(0, _pos, _buf);
    _buf = next;
    _bd = ByteData.sublistView(_buf);
  }

  void _ensure(int needed) {
    if (_pos + needed > _buf.length) {
      _grow(needed);
    }
  }

  /// Writes a single raw byte.
  void writeByte(int b) {
    if (_pos >= _buf.length) _grow(1);
    _buf[_pos++] = b;
  }

  /// Writes raw bytes directly without a length prefix.
  void writeRawBytes(Uint8List bytes) {
    final len = bytes.length;
    if (len == 0) return;
    _ensure(len);
    _buf.setRange(_pos, _pos + len, bytes);
    _pos += len;
  }

  /// Writes a slice of raw bytes directly without a length prefix.
  void writeRawSlice(Uint8List bytes, int start, int end) {
    final len = end - start;
    if (len <= 0) return;
    _ensure(len);
    _buf.setRange(_pos, _pos + len, bytes, start);
    _pos += len;
  }

  /// Writes an unsigned 64-bit integer as a minimal Prefix-Varint (1/2/4/9 bytes).
  void writeVarint(int v) {
    if (v >= 0) {
      if (v < 128) {
        if (_pos >= _buf.length) _grow(1);
        _buf[_pos++] = (v << 1) | 1;
        return;
      }
      if (v < 16384) {
        if (_pos + 2 > _buf.length) _grow(2);
        final enc = (v << 2) | 2;
        _buf[_pos] = enc & 0xFF;
        _buf[_pos + 1] = (enc >> 8) & 0xFF;
        _pos += 2;
        return;
      }
      if (v < 536870912) {
        if (_pos + 4 > _buf.length) _grow(4);
        _bd.setUint32(_pos, (v << 3) | 4, Endian.little);
        _pos += 4;
        return;
      }
    }
    if (_pos + 9 > _buf.length) _grow(9);
    _buf[_pos] = 0;
    _bd.setUint64(_pos + 1, v, Endian.little);
    _pos += 9;
  }

  /// Writes a field tag `(fieldNumber << 4) | wireType`.
  void writeTag(int fieldNumber, int wireType) {
    writeVarint((fieldNumber << 4) | wireType);
  }

  /// Writes a ZigZag-encoded signed 64-bit integer (`WireSint`).
  void writeSint(int v) => writeVarint(zigzagEncode(v));

  /// Writes a 32-bit signed integer as ZigZag (`WireSint`).
  void writeSint32(int v) => writeVarint(zigzagEncode(v.toSigned(32)));

  /// Writes a 32-bit unsigned little-endian integer (`WireFixed32`).
  void writeFixed32(int v) {
    if (_pos + 4 > _buf.length) _grow(4);
    _bd.setUint32(_pos, v, Endian.little);
    _pos += 4;
  }

  /// Writes a 64-bit unsigned little-endian integer (`WireFixed64`).
  void writeFixed64(int v) {
    if (_pos + 8 > _buf.length) _grow(8);
    _bd.setUint64(_pos, v, Endian.little);
    _pos += 8;
  }

  /// Writes a 32-bit signed little-endian integer (`WireSfixed32`).
  void writeSfixed32(int v) {
    if (_pos + 4 > _buf.length) _grow(4);
    _bd.setInt32(_pos, v, Endian.little);
    _pos += 4;
  }

  /// Writes a 64-bit signed little-endian integer (`WireSfixed64`).
  void writeSfixed64(int v) {
    if (_pos + 8 > _buf.length) _grow(8);
    _bd.setInt64(_pos, v, Endian.little);
    _pos += 8;
  }

  /// Writes a 32-bit IEEE-754 little-endian float (`WireFloat32`).
  void writeFloat32(double v) {
    if (_pos + 4 > _buf.length) _grow(4);
    _bd.setFloat32(_pos, v, Endian.little);
    _pos += 4;
  }

  /// Writes a 64-bit IEEE-754 little-endian float (`WireFloat64`).
  void writeFloat64(double v) {
    if (_pos + 8 > _buf.length) _grow(8);
    _bd.setFloat64(_pos, v, Endian.little);
    _pos += 8;
  }

  /// Writes a length-prefixed UTF-8 string (`WireString`) with an inline ASCII fast path.
  void writeString(String s) {
    final len = s.length;
    if (len == 0) {
      if (_pos >= _buf.length) _grow(1);
      _buf[_pos++] = 1; // varint(0)
      return;
    }
    // Optimistic ASCII fast path: if all code units < 128, UTF-8 byte length == len.
    final lenWidth = varintWidth(len);
    _ensure(lenWidth + len);
    final payloadStart = _pos + lenWidth;
    var isAscii = true;
    for (var i = 0; i < len; i++) {
      final cu = s.codeUnitAt(i);
      if (cu >= 128) {
        isAscii = false;
        break;
      }
      _buf[payloadStart + i] = cu;
    }
    if (isAscii) {
      writeVarint(len);
      _pos = payloadStart + len;
      return;
    }
    // Slow path for non-ASCII UTF-8.
    final encoded = utf8.encode(s);
    writeVarint(encoded.length);
    _ensure(encoded.length);
    _buf.setRange(_pos, _pos + encoded.length, encoded);
    _pos += encoded.length;
  }

  /// Writes a length-prefixed raw byte buffer (`WireBytes`).
  void writeBytes(Uint8List bytes) {
    final len = bytes.length;
    writeVarint(len);
    if (len > 0) {
      _ensure(len);
      _buf.setRange(_pos, _pos + len, bytes);
      _pos += len;
    }
  }

  /// Reserves a 2-byte Prefix-Varint length slot for single-pass container backpatching.
  int reserveLen2() {
    if (_pos + 2 > _buf.length) _grow(2);
    final slot = _pos;
    _pos += 2;
    return slot;
  }

  /// Reserves a 4-byte Prefix-Varint length slot for large containers (>= 16 KiB).
  int reserveLen4() {
    if (_pos + 4 > _buf.length) _grow(4);
    final slot = _pos;
    _pos += 4;
    return slot;
  }

  /// Patches a 2-byte reserved length slot, widening and shifting the body if needed.
  void patchLen2(int slot) {
    final bodyStart = slot + 2;
    final bodyLen = _pos - bodyStart;
    if (bodyLen < 16384) {
      final enc = (bodyLen << 2) | 2;
      _buf[slot] = enc & 0xFF;
      _buf[slot + 1] = (enc >> 8) & 0xFF;
      return;
    }
    if (bodyLen < 536870912) {
      _ensure(2);
      _buf.setRange(slot + 4, slot + 4 + bodyLen, _buf, bodyStart);
      _bd.setUint32(slot, (bodyLen << 3) | 4, Endian.little);
      _pos += 2;
      return;
    }
    _ensure(7);
    _buf.setRange(slot + 9, slot + 9 + bodyLen, _buf, bodyStart);
    _buf[slot] = 0;
    _bd.setUint64(slot + 1, bodyLen, Endian.little);
    _pos += 7;
  }

  /// Patches a 4-byte reserved length slot, widening to 9 bytes if body >= 512 MiB.
  void patchLen4(int slot) {
    final bodyStart = slot + 4;
    final bodyLen = _pos - bodyStart;
    if (bodyLen < 536870912) {
      _bd.setUint32(slot, (bodyLen << 3) | 4, Endian.little);
      return;
    }
    _ensure(5);
    _buf.setRange(slot + 9, slot + 9 + bodyLen, _buf, bodyStart);
    _buf[slot] = 0;
    _bd.setUint64(slot + 1, bodyLen, Endian.little);
    _pos += 5;
  }

  /// Reserves either 2 bytes or 4 bytes based on an estimated body size.
  /// Returns a tagged handle for [patchLenAuto].
  int reserveLenAuto(int estimatedBodyBytes) {
    if (estimatedBodyBytes >= 16384) {
      return -(reserveLen4() + 1);
    }
    return reserveLen2();
  }

  /// Patches a handle returned by [reserveLenAuto].
  void patchLenAuto(int handle) {
    if (handle < 0) {
      patchLen4(-handle - 1);
    } else {
      patchLen2(handle);
    }
  }
}

/// High-performance bounds-checked OmniBuf binary reader.
class OmniBufReader {
  final Uint8List buf;
  final ByteData bd;
  int pos;
  final int end;

  OmniBufReader(this.buf, [int start = 0, int? endOffset])
      : bd = ByteData.sublistView(buf),
        pos = start,
        end = endOffset ?? buf.length;

  OmniBufReader._sub(this.buf, this.bd, this.pos, this.end);

  /// Remaining unread bytes in this reader's slice.
  int get remaining => end - pos;

  /// Whether there are unread bytes remaining.
  bool get hasMore => pos < end;

  /// Creates a bounded sub-reader for `[start, subEnd)` sharing the underlying [ByteData].
  OmniBufReader subReader(int start, int subEnd) {
    return OmniBufReader._sub(buf, bd, start, subEnd);
  }

  /// Reads a single raw byte.
  int readByte() {
    if (pos >= end) {
      throw const OmniBufParseException('unexpected EOF reading byte');
    }
    return buf[pos++];
  }

  /// Reads a Prefix-Varint (1/2/4/9 bytes). Accepts non-minimal encodings;
  /// rejects reserved first-byte patterns (`(b0 & 0x07) == 0 && b0 != 0`).
  int readVarint() {
    if (pos >= end) {
      throw const OmniBufParseException('unexpected EOF reading prefix-varint');
    }
    final b0 = buf[pos];
    if ((b0 & 1) != 0) {
      pos += 1;
      return b0 >> 1;
    }
    if ((b0 & 2) != 0) {
      if (pos + 2 > end) {
        throw const OmniBufParseException('truncated 2-byte prefix-varint');
      }
      final v = (b0 | (buf[pos + 1] << 8)) >> 2;
      pos += 2;
      return v;
    }
    if ((b0 & 4) != 0) {
      if (pos + 4 > end) {
        throw const OmniBufParseException('truncated 4-byte prefix-varint');
      }
      final v = bd.getUint32(pos, Endian.little) >> 3;
      pos += 4;
      return v;
    }
    if (b0 == 0) {
      if (pos + 9 > end) {
        throw const OmniBufParseException('truncated 9-byte prefix-varint');
      }
      final v = bd.getUint64(pos + 1, Endian.little);
      pos += 9;
      return v;
    }
    throw OmniBufParseException(
      'reserved prefix-varint first byte 0x${b0.toRadixString(16)}',
    );
  }

  /// Reads and validates a field tag. Rejects out-of-range field numbers and
  /// Field #0 tags with wire type != `WireSubMsg (12)`.
  int readTag() {
    final tag = readVarint();
    if (tag < 0 || tag > WireType.maxTag) {
      throw const OmniBufParseException('field tag out of valid range');
    }
    if ((tag >> 4) == 0 && (tag & 0x0F) != WireType.subMsg) {
      throw OmniBufParseException(
        'Field #0 must use WireSubMsg (12), got ${tag & 0x0F}',
      );
    }
    return tag;
  }

  /// Reads a ZigZag-encoded signed 64-bit integer (`WireSint`).
  int readSint() => zigzagDecode(readVarint());

  /// Reads a ZigZag-encoded signed 32-bit integer (64-bit ZigZag then low 32-bit signed).
  int readSint32() => zigzagDecode(readVarint()).toSigned(32);

  /// Reads a `uint32` from `WireUint` (retains low 32 bits).
  int readUint32() => readVarint() & 0xFFFFFFFF;

  /// Reads a 4-byte little-endian `uint32` (`WireFixed32`).
  int readFixed32() {
    if (pos + 4 > end) {
      throw const OmniBufParseException('truncated WireFixed32');
    }
    final v = bd.getUint32(pos, Endian.little);
    pos += 4;
    return v;
  }

  /// Reads an 8-byte little-endian `uint64` (`WireFixed64`).
  int readFixed64() {
    if (pos + 8 > end) {
      throw const OmniBufParseException('truncated WireFixed64');
    }
    final v = bd.getUint64(pos, Endian.little);
    pos += 8;
    return v;
  }

  /// Reads a 4-byte little-endian `int32` (`WireSfixed32`).
  int readSfixed32() {
    if (pos + 4 > end) {
      throw const OmniBufParseException('truncated WireSfixed32');
    }
    final v = bd.getInt32(pos, Endian.little);
    pos += 4;
    return v;
  }

  /// Reads an 8-byte little-endian `int64` (`WireSfixed64`).
  int readSfixed64() {
    if (pos + 8 > end) {
      throw const OmniBufParseException('truncated WireSfixed64');
    }
    final v = bd.getInt64(pos, Endian.little);
    pos += 8;
    return v;
  }

  /// Reads a 4-byte little-endian IEEE-754 binary32 (`WireFloat32`).
  double readFloat32() {
    if (pos + 4 > end) {
      throw const OmniBufParseException('truncated WireFloat32');
    }
    final v = bd.getFloat32(pos, Endian.little);
    pos += 4;
    return v;
  }

  /// Reads an 8-byte little-endian IEEE-754 binary64 (`WireFloat64`).
  double readFloat64() {
    if (pos + 8 > end) {
      throw const OmniBufParseException('truncated WireFloat64');
    }
    final v = bd.getFloat64(pos, Endian.little);
    pos += 8;
    return v;
  }

  /// Reads a validated byte length Prefix-Varint that fits within [remaining].
  int readCheckedLength() {
    final len = readVarint();
    if (len < 0 || len > end - pos) {
      throw OmniBufParseException(
        'length prefix exceeds remaining container bounds',
      );
    }
    return len;
  }

  /// Reads a length-prefixed strict UTF-8 string (`WireString`).
  String readString({DecodeBudget? budget}) {
    final len = readCheckedLength();
    if (len == 0) return '';
    budget?.consumeBytes(len);
    final start = pos;
    pos += len;
    return decodeStrictUtf8(buf, start, start + len);
  }

  /// Reads a length-prefixed raw byte copy (`WireBytes`).
  Uint8List readBytes({DecodeBudget? budget}) {
    final len = readCheckedLength();
    if (len == 0) return Uint8List(0);
    budget?.consumeBytes(len);
    final out = Uint8List(len);
    out.setRange(0, len, buf, pos);
    pos += len;
    return out;
  }

  /// Reads a boolean byte inside a `WireArray` or `WireMap` (`0x00` or `0x01`).
  bool readCollectionBool() {
    final b = readByte();
    if (b == 0) return false;
    if (b == 1) return true;
    throw OmniBufParseException('invalid collection boolean byte $b');
  }

  /// Parses a `WireArray` header inside an already-bounded array body reader.
  /// Returns `(elementType, count)` and validates `Count = 0`, fixed widths,
  /// and variable-width allocation bounds.
  (int, int) readArrayHeader({int maxElements = 16 * 1024 * 1024}) {
    final elemType = readByte();
    if (!WireType.isValidCollectionType(elemType)) {
      throw OmniBufParseException('invalid WireArray ElementType $elemType');
    }
    final count = readVarint();
    final rem = end - pos;
    if (count < 0 || count > maxElements) {
      throw OmniBufAllocationLimitException(
        'WireArray element count exceeds limit',
      );
    }
    if (count == 0) {
      if (rem != 0) {
        throw OmniBufParseException(
          'empty WireArray (Count=0) has $rem trailing bytes',
        );
      }
      return (elemType, 0);
    }
    final fixedW = WireType.fixedCollectionWidth(elemType);
    if (fixedW > 0) {
      if (rem % fixedW != 0 || count != rem ~/ fixedW) {
        throw OmniBufParseException(
          'fixed-width WireArray count $count does not match $rem remaining bytes (width $fixedW)',
        );
      }
    } else {
      if (count > rem) {
        throw OmniBufParseException(
          'variable-width WireArray count $count exceeds $rem remaining bytes',
        );
      }
    }
    return (elemType, count);
  }

  /// Parses a `WireMap` header inside an already-bounded map body reader.
  /// Returns `(keyType, valueType, count)` and validates key/value types,
  /// `Count = 0`, and entry count bounds.
  (int, int, int) readMapHeader({int maxElements = 16 * 1024 * 1024}) {
    final keyType = readByte();
    final valType = readByte();
    if (!WireType.isValidMapKeyType(keyType)) {
      throw OmniBufParseException('invalid WireMap KeyType $keyType');
    }
    if (!WireType.isValidCollectionType(valType)) {
      throw OmniBufParseException('invalid WireMap ValueType $valType');
    }
    final count = readVarint();
    final rem = end - pos;
    if (count < 0 || count > maxElements) {
      throw OmniBufAllocationLimitException(
        'WireMap entry count exceeds limit',
      );
    }
    if (count == 0) {
      if (rem != 0) {
        throw OmniBufParseException(
          'empty WireMap (Count=0) has $rem trailing bytes',
        );
      }
      return (keyType, valType, 0);
    }
    if (count > rem ~/ 2) {
      throw OmniBufParseException(
        'WireMap count $count exceeds physical maximum ${rem ~/ 2} entries',
      );
    }
    return (keyType, valType, count);
  }
}

/// Decodes a UTF-8 slice with an inline ASCII fast path and strict UTF-8 validation.
String decodeStrictUtf8(Uint8List buf, int start, int end) {
  var isAscii = true;
  for (var i = start; i < end; i++) {
    if (buf[i] >= 128) {
      isAscii = false;
      break;
    }
  }
  if (isAscii) {
    return String.fromCharCodes(buf, start, end);
  }
  try {
    return utf8.decode(
      Uint8List.sublistView(buf, start, end),
      allowMalformed: false,
    );
  } on FormatException catch (e) {
    throw OmniBufInvalidUtf8Exception('invalid UTF-8 string: ${e.message}');
  }
}

/// Mutable cumulative element/allocation budget threaded through a single
/// decode or validation pass so chunked collections or repeated structures
/// cannot bypass `DecodeOptions.maxCollectionElements` or `DecodeOptions.maxAllocBytes`.
class DecodeBudget {
  final int maxElements;
  final int maxAllocBytes;
  int elements = 0;
  int allocBytes = 0;

  DecodeBudget(
    this.maxElements, {
    this.maxAllocBytes = DecodeOptions.defaultMaxAllocBytes,
  });

  void consume(int count) {
    if (count < 0 || count > maxElements - elements) {
      throw OmniBufAllocationLimitException(
        'cumulative element count exceeds limit $maxElements',
      );
    }
    elements += count;
  }

  void consumeBytes(int bytes) {
    if (bytes < 0 || bytes > maxAllocBytes - allocBytes) {
      throw OmniBufAllocationLimitException(
        'cumulative allocated bytes exceeds limit $maxAllocBytes',
      );
    }
    allocBytes += bytes;
  }
}

/// Skips a single field value in `O(1)` for scalars/strings/bytes/extensions,
/// and recursively validates containers (`WireSubMsg`, `WireArray`, `WireMap`)
/// against depth limits, Field #0 rules, and container boundaries.
void skipAndValidateValue(
  OmniBufReader r,
  int wireType,
  int depth,
  int maxDepth, {
  bool inCollection = false,
  bool validateStrings = true,
  int maxElements = 16 * 1024 * 1024,
  DecodeBudget? budget,
}) {
  final effectiveBudget = budget ?? DecodeBudget(maxElements);
  switch (wireType) {
    case WireType.uint:
    case WireType.sint:
      r.readVarint();
      return;
    case WireType.boolFalse:
      if (inCollection) {
        r.readCollectionBool();
      }
      return;
    case WireType.boolTrue:
      if (inCollection) {
        throw const OmniBufParseException(
          'WireBoolTrue (3) is invalid inside collections',
        );
      }
      return;
    case WireType.fixed32:
    case WireType.sfixed32:
    case WireType.float32:
      if (r.pos + 4 > r.end) {
        throw const OmniBufParseException('truncated 4-byte fixed value');
      }
      r.pos += 4;
      return;
    case WireType.fixed64:
    case WireType.sfixed64:
    case WireType.float64:
      if (r.pos + 8 > r.end) {
        throw const OmniBufParseException('truncated 8-byte fixed value');
      }
      r.pos += 8;
      return;
    case WireType.string:
      final len = r.readCheckedLength();
      if (validateStrings && len > 0) {
        decodeStrictUtf8(r.buf, r.pos, r.pos + len);
      }
      r.pos += len;
      return;
    case WireType.bytes:
      final len = r.readCheckedLength();
      r.pos += len;
      return;
    case WireType.subMsg:
      final nextDepth = depth + 1;
      if (nextDepth > maxDepth) {
        throw OmniBufDepthLimitException(maxDepth);
      }
      final len = r.readCheckedLength();
      final subEnd = r.pos + len;
      final sub = r.subReader(r.pos, subEnd);
      while (sub.hasMore) {
        final tag = sub.readTag();
        final fnum = tag >> 4;
        final wt = tag & 0x0F;
        if (fnum == 0) {
          validateField0SubMsg(
            sub,
            nextDepth,
            maxDepth,
            maxElements: effectiveBudget.maxElements,
            validateStrings: validateStrings,
            budget: effectiveBudget,
          );
        } else {
          skipAndValidateValue(
            sub,
            wt,
            nextDepth,
            maxDepth,
            validateStrings: validateStrings,
            maxElements: effectiveBudget.maxElements,
            budget: effectiveBudget,
          );
        }
      }
      r.pos = subEnd;
      return;
    case WireType.array:
      final nextDepth = depth + 1;
      if (nextDepth > maxDepth) {
        throw OmniBufDepthLimitException(maxDepth);
      }
      final len = r.readCheckedLength();
      final bodyEnd = r.pos + len;
      final body = r.subReader(r.pos, bodyEnd);
      final (elemType, count) =
          body.readArrayHeader(maxElements: effectiveBudget.maxElements);
      effectiveBudget.consume(count);
      if (elemType == WireType.boolFalse) {
        for (var i = 0; i < count; i++) {
          body.readCollectionBool();
        }
      } else {
        final fixedW = WireType.fixedCollectionWidth(elemType);
        if (fixedW > 0) {
          body.pos = bodyEnd;
        } else {
          for (var i = 0; i < count; i++) {
            skipAndValidateValue(
              body,
              elemType,
              nextDepth,
              maxDepth,
              inCollection: true,
              validateStrings: validateStrings,
              maxElements: effectiveBudget.maxElements,
              budget: effectiveBudget,
            );
          }
        }
      }
      if (body.pos != bodyEnd) {
        throw const OmniBufParseException('WireArray trailing bytes');
      }
      r.pos = bodyEnd;
      return;
    case WireType.map:
      final nextDepth = depth + 1;
      if (nextDepth > maxDepth) {
        throw OmniBufDepthLimitException(maxDepth);
      }
      final len = r.readCheckedLength();
      final bodyEnd = r.pos + len;
      final body = r.subReader(r.pos, bodyEnd);
      final (keyType, valType, count) =
          body.readMapHeader(maxElements: effectiveBudget.maxElements);
      effectiveBudget.consume(count);
      for (var i = 0; i < count; i++) {
        skipAndValidateValue(
          body,
          keyType,
          nextDepth,
          maxDepth,
          inCollection: true,
          validateStrings: validateStrings,
          maxElements: effectiveBudget.maxElements,
          budget: effectiveBudget,
        );
        skipAndValidateValue(
          body,
          valType,
          nextDepth,
          maxDepth,
          inCollection: true,
          validateStrings: validateStrings,
          maxElements: effectiveBudget.maxElements,
          budget: effectiveBudget,
        );
      }
      if (body.pos != bodyEnd) {
        throw const OmniBufParseException('WireMap trailing bytes');
      }
      r.pos = bodyEnd;
      return;
    case WireType.extended:
      final len = r.readCheckedLength();
      if (len < 1) {
        throw const OmniBufParseException(
          'WireExtended requires ByteLen >= 1 for ExtType byte',
        );
      }
      r.pos += len;
      return;
    default:
      throw OmniBufParseException('unknown wire type $wireType');
  }
}

/// Validates a Field #0 (`SchemaMeta`) submessage payload at the current reader position.
/// Enforces depth (+1 for `SchemaMeta` submessage, +1 for `fields`/`children` map,
/// +1 for each child `SchemaMeta`), strict UTF-8 on `type_name` and `fields` values,
/// and exact map headers (`0x00`/`0x0A` for `fields`, `0x00`/`0x0C` for `children`).
void validateField0SubMsg(
  OmniBufReader r,
  int depth,
  int maxDepth, {
  int maxElements = 16 * 1024 * 1024,
  bool validateStrings = true,
  DecodeBudget? budget,
}) {
  final effectiveBudget = budget ?? DecodeBudget(maxElements);
  final nextDepth = depth + 1;
  if (nextDepth > maxDepth) {
    throw OmniBufDepthLimitException(maxDepth);
  }
  final len = r.readCheckedLength();
  final subEnd = r.pos + len;
  final sub = r.subReader(r.pos, subEnd);
  while (sub.hasMore) {
    final tag = sub.readTag();
    final fnum = tag >> 4;
    final wt = tag & 0x0F;
    if (fnum == 0) {
      throw const OmniBufParseException(
        'nested Field #0 (SchemaMeta) is not allowed inside SchemaMeta',
      );
    }
    switch (fnum) {
      case 1: // type_name: string
        if (wt == WireType.string) {
          sub.readString();
        } else {
          skipAndValidateValue(
            sub,
            wt,
            nextDepth,
            maxDepth,
            validateStrings: validateStrings,
            maxElements: effectiveBudget.maxElements,
            budget: effectiveBudget,
          );
        }
      case 2: // fields: map<uint32, string>
        if (wt == WireType.map) {
          final mapDepth = nextDepth + 1;
          if (mapDepth > maxDepth) {
            throw OmniBufDepthLimitException(maxDepth);
          }
          final mLen = sub.readCheckedLength();
          final mEnd = sub.pos + mLen;
          final mBody = sub.subReader(sub.pos, mEnd);
          final (kt, vt, count) =
              mBody.readMapHeader(maxElements: effectiveBudget.maxElements);
          effectiveBudget.consume(count);
          if (kt != WireType.uint || vt != WireType.string) {
            throw OmniBufTypeMismatchException(
              'SchemaMeta.fields expects map<uint, string>, got <$kt, $vt>',
            );
          }
          for (var i = 0; i < count; i++) {
            final k = mBody.readVarint();
            if (k < 1 || k > WireType.maxFieldNumber) {
              throw OmniBufParseException(
                'SchemaMeta.fields key $k out of valid field number range',
              );
            }
            mBody.readString();
          }
          if (mBody.pos != mEnd) {
            throw const OmniBufParseException(
              'SchemaMeta.fields trailing bytes',
            );
          }
          sub.pos = mEnd;
        } else {
          skipAndValidateValue(
            sub,
            wt,
            nextDepth,
            maxDepth,
            validateStrings: validateStrings,
            maxElements: effectiveBudget.maxElements,
            budget: effectiveBudget,
          );
        }
      case 3: // children: map<uint32, SchemaMeta>
        if (wt == WireType.map) {
          final mapDepth = nextDepth + 1;
          if (mapDepth > maxDepth) {
            throw OmniBufDepthLimitException(maxDepth);
          }
          final mLen = sub.readCheckedLength();
          final mEnd = sub.pos + mLen;
          final mBody = sub.subReader(sub.pos, mEnd);
          final (kt, vt, count) =
              mBody.readMapHeader(maxElements: effectiveBudget.maxElements);
          effectiveBudget.consume(count);
          if (kt != WireType.uint || vt != WireType.subMsg) {
            throw OmniBufTypeMismatchException(
              'SchemaMeta.children expects map<uint, submsg>, got <$kt, $vt>',
            );
          }
          for (var i = 0; i < count; i++) {
            final k = mBody.readVarint();
            if (k < 1 || k > WireType.maxFieldNumber) {
              throw OmniBufParseException(
                'SchemaMeta.children key $k out of valid field number range',
              );
            }
            validateField0SubMsg(
              mBody,
              mapDepth,
              maxDepth,
              maxElements: effectiveBudget.maxElements,
              validateStrings: validateStrings,
              budget: effectiveBudget,
            );
          }
          if (mBody.pos != mEnd) {
            throw const OmniBufParseException(
              'SchemaMeta.children trailing bytes',
            );
          }
          sub.pos = mEnd;
        } else {
          skipAndValidateValue(
            sub,
            wt,
            nextDepth,
            maxDepth,
            validateStrings: validateStrings,
            maxElements: effectiveBudget.maxElements,
            budget: effectiveBudget,
          );
        }
      default:
        skipAndValidateValue(
          sub,
          wt,
          nextDepth,
          maxDepth,
          validateStrings: validateStrings,
          maxElements: effectiveBudget.maxElements,
          budget: effectiveBudget,
        );
    }
  }
  r.pos = subEnd;
}

/// Validates an entire OmniBuf packet including container bounds, recursion depth,
/// Field #0 metadata, and optionally strict UTF-8 on every `WireString`.
void validatePacket(
  Uint8List data, {
  int maxDepth = DecodeOptions.defaultMaxDepth,
  bool validateStrings = true,
  int maxElements = DecodeOptions.defaultMaxCollectionElements,
  int maxAllocBytes = DecodeOptions.defaultMaxAllocBytes,
}) {
  if (maxDepth < 1 || maxDepth > DecodeOptions.defaultMaxDepth) {
    throw RangeError.range(
        maxDepth, 1, DecodeOptions.defaultMaxDepth, 'maxDepth');
  }
  final budget = DecodeBudget(maxElements, maxAllocBytes: maxAllocBytes);
  final r = OmniBufReader(data);
  while (r.hasMore) {
    final tag = r.readTag();
    final fnum = tag >> 4;
    final wt = tag & 0x0F;
    if (fnum == 0) {
      validateField0SubMsg(
        r,
        0,
        maxDepth,
        maxElements: maxElements,
        validateStrings: validateStrings,
        budget: budget,
      );
    } else {
      skipAndValidateValue(
        r,
        wt,
        0,
        maxDepth,
        validateStrings: validateStrings,
        maxElements: maxElements,
        budget: budget,
      );
    }
  }
}

/// Fast `O(1)`-per-field value skip without recursing into containers.
/// Used by lazy `Opaque` scanners and splicers for unread fields.
int fastSkipValue(OmniBufReader r, int wireType) {
  switch (wireType) {
    case WireType.uint:
    case WireType.sint:
      r.readVarint();
      return r.pos;
    case WireType.boolFalse:
    case WireType.boolTrue:
      return r.pos;
    case WireType.fixed32:
    case WireType.sfixed32:
    case WireType.float32:
      if (r.pos + 4 > r.end) {
        throw const OmniBufParseException('truncated 4-byte fixed value');
      }
      r.pos += 4;
      return r.pos;
    case WireType.fixed64:
    case WireType.sfixed64:
    case WireType.float64:
      if (r.pos + 8 > r.end) {
        throw const OmniBufParseException('truncated 8-byte fixed value');
      }
      r.pos += 8;
      return r.pos;
    case WireType.string:
    case WireType.bytes:
    case WireType.subMsg:
    case WireType.array:
    case WireType.map:
      final len = r.readCheckedLength();
      r.pos += len;
      return r.pos;
    case WireType.extended:
      final len = r.readCheckedLength();
      if (len < 1) {
        throw const OmniBufParseException(
          'WireExtended requires ByteLen >= 1',
        );
      }
      r.pos += len;
      return r.pos;
    default:
      throw OmniBufParseException('unknown wire type $wireType');
  }
}

/// Byte-wise equality for [Uint8List] values used by generated message classes.
bool bytesEquals(Uint8List a, Uint8List b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Byte-wise hash code for [Uint8List] values used by generated message classes.
int bytesHash(Uint8List b) => Object.hashAll(b);

/// Deep element-wise equality for generated `List` fields (handles `Uint8List` elements).
bool listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    final ai = a[i];
    final bi = b[i];
    if (ai is Uint8List && bi is Uint8List) {
      if (!bytesEquals(ai, bi)) return false;
    } else if (ai != bi) {
      return false;
    }
  }
  return true;
}

/// Deep element-wise hash code for generated `List` fields.
int listHash(List<Object?> list) => Object.hashAll(
      list.map((e) => e is Uint8List ? bytesHash(e) : e),
    );

/// Deep entry-wise equality for generated `Map` fields (handles `Uint8List` values).
bool mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (!b.containsKey(entry.key)) return false;
    final av = entry.value;
    final bv = b[entry.key];
    if (av is Uint8List && bv is Uint8List) {
      if (!bytesEquals(av, bv)) return false;
    } else if (av != bv) {
      return false;
    }
  }
  return true;
}

/// Deep entry-wise order-independent hash code for generated `Map` fields.
int mapHash(Map<Object?, Object?> map) {
  var h = 0;
  for (final entry in map.entries) {
    final v = entry.value;
    final vh = v is Uint8List ? bytesHash(v) : v.hashCode;
    h ^= Object.hash(entry.key, vh);
  }
  return h;
}
