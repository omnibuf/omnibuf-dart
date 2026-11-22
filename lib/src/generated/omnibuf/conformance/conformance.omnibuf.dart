// GENERATED CODE - DO NOT MODIFY BY HAND.
// Source: omnibuf/conformance/conformance.proto
// ignore_for_file: unused_import, constant_identifier_names, non_constant_identifier_names, prefer_final_locals, unnecessary_this, camel_case_types

import 'dart:typed_data';

import 'package:omnibuf/omnibuf.dart' as ob;

abstract final class WireFormat {
  static const int WIRE_FORMAT_UNSPECIFIED = 0;
  static const int WIRE_FORMAT_OMNIBUF = 1;
  static const int WIRE_FORMAT_JSON = 2;
}

abstract final class TestTier {
  static const int TEST_TIER_UNSPECIFIED = 0;
  static const int TEST_TIER_PLUGIN = 1;
  static const int TEST_TIER_PROTOBUF_TYPES = 2;
  static const int TEST_TIER_ANNOTATED_STRUCT = 3;
  static const int TEST_TIER_BLIND = 4;
}

class ConformanceRequest {
  String testName;
  String messageType;
  int tier;
  int requestedOutputFormat;
  Uint8List omnibufPayload;
  String jsonPayload;
  bool selfDescribing;
  bool testOpaqueSplice;
  bool testOpaqueSpliceShrink;

  ConformanceRequest({
    this.testName = '',
    this.messageType = '',
    this.tier = 0,
    this.requestedOutputFormat = 0,
    Uint8List? omnibufPayload,
    this.jsonPayload = '',
    this.selfDescribing = false,
    this.testOpaqueSplice = false,
    this.testOpaqueSpliceShrink = false,
  }) : this.omnibufPayload = omnibufPayload ?? Uint8List(0);

  void reset() {
    this.testName = '';
    this.messageType = '';
    this.tier = 0;
    this.requestedOutputFormat = 0;
    this.omnibufPayload = Uint8List(0);
    this.jsonPayload = '';
    this.selfDescribing = false;
    this.testOpaqueSplice = false;
    this.testOpaqueSpliceShrink = false;
  }

  int estimateBodyBytes([int depth = 0]) {
    if (depth > ob.DecodeOptions.defaultMaxDepth) {
      throw const ob.OmniBufSerializeException(
          'message encoding depth exceeded limit of ${ob.DecodeOptions.defaultMaxDepth}');
    }
    var n = 32;
    n += this.testName.length;
    n += this.messageType.length;
    n += this.omnibufPayload.length;
    n += this.jsonPayload.length;
    return n;
  }

  static ob.SchemaMeta buildSchemaMeta({int maxDepth = 16}) {
    return _buildSchemaMeta(0, maxDepth);
  }

  static ob.SchemaMeta _buildSchemaMeta(int depth, int maxDepth) {
    final fields = <int, String>{
      1: 'test_name',
      2: 'message_type',
      3: 'tier',
      4: 'requested_output_format',
      5: 'omnibuf_payload',
      6: 'json_payload',
      7: 'self_describing',
      8: 'test_opaque_splice',
      9: 'test_opaque_splice_shrink',
    };
    final children = <int, ob.SchemaMeta>{};
    if (depth + 2 <= maxDepth) {}
    return ob.SchemaMeta(
        typeName: 'omnibuf.conformance.ConformanceRequest',
        fields: fields,
        children: children);
  }

  Uint8List encode({ob.EncodeOptions options = ob.EncodeOptions.defaults}) {
    final w = ob.OmniBufWriter(estimateBodyBytes());
    if (options.selfDescribing) {
      buildSchemaMeta().writeField0(w);
    }
    encodeInto(w, options: options);
    return w.toBytes();
  }

  void encodeInto(ob.OmniBufWriter w,
      {ob.EncodeOptions options = ob.EncodeOptions.defaults, int depth = 0}) {
    if (depth > ob.DecodeOptions.defaultMaxDepth) {
      throw const ob.OmniBufSerializeException(
          'message encoding depth exceeded limit of ${ob.DecodeOptions.defaultMaxDepth}');
    }
    if (this.testName.isNotEmpty) {
      w.writeTag(1, ob.WireType.string);
      w.writeString(this.testName);
    }
    if (this.messageType.isNotEmpty) {
      w.writeTag(2, ob.WireType.string);
      w.writeString(this.messageType);
    }
    if (this.tier != 0) {
      w.writeTag(3, ob.WireType.sint);
      w.writeSint32(this.tier);
    }
    if (this.requestedOutputFormat != 0) {
      w.writeTag(4, ob.WireType.sint);
      w.writeSint32(this.requestedOutputFormat);
    }
    if (this.omnibufPayload.isNotEmpty) {
      w.writeTag(5, ob.WireType.bytes);
      w.writeBytes(this.omnibufPayload);
    }
    if (this.jsonPayload.isNotEmpty) {
      w.writeTag(6, ob.WireType.string);
      w.writeString(this.jsonPayload);
    }
    if (this.selfDescribing) {
      w.writeTag(7, ob.WireType.boolTrue);
    }
    if (this.testOpaqueSplice) {
      w.writeTag(8, ob.WireType.boolTrue);
    }
    if (this.testOpaqueSpliceShrink) {
      w.writeTag(9, ob.WireType.boolTrue);
    }
  }

  static ConformanceRequest decode(Uint8List data,
      {ob.DecodeOptions options = ob.DecodeOptions.defaults}) {
    final msg = ConformanceRequest();
    msg.decodeInto(data, options: options);
    return msg;
  }

  void decodeInto(Uint8List data,
      {ob.DecodeOptions options = ob.DecodeOptions.defaults}) {
    if (data.length > options.maxMessageBytes) {
      throw ob.OmniBufAllocationLimitException(
          'packet size ${data.length} exceeds maxMessageBytes ${options.maxMessageBytes}');
    }
    if (!options.merge) {
      reset();
    }
    final budget = ob.DecodeBudget(options.maxCollectionElements);
    final r = ob.OmniBufReader(data);
    decodeBody(r, 0, options, budget);
  }

  void decodeBody(ob.OmniBufReader r, int depth, ob.DecodeOptions options,
      [ob.DecodeBudget? budget]) {
    final activeBudget =
        budget ?? ob.DecodeBudget(options.maxCollectionElements);
    while (r.hasMore) {
      final tag = r.readTag();
      final fnum = tag >> 4;
      final wt = tag & 0x0F;
      if (fnum == 0) {
        ob.validateField0SubMsg(r, depth, options.maxDepth,
            maxElements: options.maxCollectionElements, budget: activeBudget);
        continue;
      }
      switch (fnum) {
        case 1:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.testName = r.readString();
        case 2:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.messageType = r.readString();
        case 3:
          if (wt != ob.WireType.sint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.tier = r.readSint32();
        case 4:
          if (wt != ob.WireType.sint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.requestedOutputFormat = r.readSint32();
        case 5:
          if (wt != ob.WireType.bytes) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.omnibufPayload = r.readBytes();
        case 6:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.jsonPayload = r.readString();
        case 7:
          if (wt != ob.WireType.boolFalse && wt != ob.WireType.boolTrue) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.selfDescribing = wt == ob.WireType.boolTrue;
        case 8:
          if (wt != ob.WireType.boolFalse && wt != ob.WireType.boolTrue) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.testOpaqueSplice = wt == ob.WireType.boolTrue;
        case 9:
          if (wt != ob.WireType.boolFalse && wt != ob.WireType.boolTrue) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.testOpaqueSpliceShrink = wt == ob.WireType.boolTrue;
        default:
          ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
              maxElements: options.maxCollectionElements, budget: activeBudget);
      }
    }
  }
}

class OpaqueConformanceRequest extends ob.OpaqueMessage {
  OpaqueConformanceRequest(super.rawBytes);

  String get testName {
    if (hasPatch(1)) {
      final p = getPatch(1);
      if (p == null || p.isEmpty) return '';
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.string) return '';
      return r.readString();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 1, ob.WireType.string);
    if (hit == null) return '';
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readString();
  }

  set testName(String value) {
    if (!(value.isNotEmpty)) {
      setPatch(1, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(1, ob.WireType.string);
    w.writeString(value);
    setPatch(1, w.toBytes());
  }

  String get messageType {
    if (hasPatch(2)) {
      final p = getPatch(2);
      if (p == null || p.isEmpty) return '';
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.string) return '';
      return r.readString();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 2, ob.WireType.string);
    if (hit == null) return '';
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readString();
  }

  set messageType(String value) {
    if (!(value.isNotEmpty)) {
      setPatch(2, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(2, ob.WireType.string);
    w.writeString(value);
    setPatch(2, w.toBytes());
  }

  int get tier {
    if (hasPatch(3)) {
      final p = getPatch(3);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.sint) return 0;
      return r.readSint32();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 3, ob.WireType.sint);
    if (hit == null) return 0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readSint32();
  }

  set tier(int value) {
    if (!(value != 0)) {
      setPatch(3, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(3, ob.WireType.sint);
    w.writeSint32(value);
    setPatch(3, w.toBytes());
  }

  int get requestedOutputFormat {
    if (hasPatch(4)) {
      final p = getPatch(4);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.sint) return 0;
      return r.readSint32();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 4, ob.WireType.sint);
    if (hit == null) return 0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readSint32();
  }

  set requestedOutputFormat(int value) {
    if (!(value != 0)) {
      setPatch(4, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(4, ob.WireType.sint);
    w.writeSint32(value);
    setPatch(4, w.toBytes());
  }

  Uint8List get omnibufPayload {
    if (hasPatch(5)) {
      final p = getPatch(5);
      if (p == null || p.isEmpty) return Uint8List(0);
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.bytes) return Uint8List(0);
      return r.readBytes();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 5, ob.WireType.bytes);
    if (hit == null) return Uint8List(0);
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readBytes();
  }

  set omnibufPayload(Uint8List value) {
    if (!(value.isNotEmpty)) {
      setPatch(5, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(5, ob.WireType.bytes);
    w.writeBytes(value);
    setPatch(5, w.toBytes());
  }

  String get jsonPayload {
    if (hasPatch(6)) {
      final p = getPatch(6);
      if (p == null || p.isEmpty) return '';
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.string) return '';
      return r.readString();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 6, ob.WireType.string);
    if (hit == null) return '';
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readString();
  }

  set jsonPayload(String value) {
    if (!(value.isNotEmpty)) {
      setPatch(6, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(6, ob.WireType.string);
    w.writeString(value);
    setPatch(6, w.toBytes());
  }

  bool get selfDescribing {
    if (hasPatch(7)) {
      final p = getPatch(7);
      if (p == null || p.isEmpty) return false;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      return wt == ob.WireType.boolTrue;
    }
    final wt = ob.findLastBoolField(rawBytes, 7);
    return wt == ob.WireType.boolTrue;
  }

  set selfDescribing(bool value) {
    if (!value) {
      setPatch(7, null);
      return;
    }
    final w = ob.OmniBufWriter(8);
    w.writeTag(7, ob.WireType.boolTrue);
    setPatch(7, w.toBytes());
  }

  bool get testOpaqueSplice {
    if (hasPatch(8)) {
      final p = getPatch(8);
      if (p == null || p.isEmpty) return false;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      return wt == ob.WireType.boolTrue;
    }
    final wt = ob.findLastBoolField(rawBytes, 8);
    return wt == ob.WireType.boolTrue;
  }

  set testOpaqueSplice(bool value) {
    if (!value) {
      setPatch(8, null);
      return;
    }
    final w = ob.OmniBufWriter(8);
    w.writeTag(8, ob.WireType.boolTrue);
    setPatch(8, w.toBytes());
  }

  bool get testOpaqueSpliceShrink {
    if (hasPatch(9)) {
      final p = getPatch(9);
      if (p == null || p.isEmpty) return false;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      return wt == ob.WireType.boolTrue;
    }
    final wt = ob.findLastBoolField(rawBytes, 9);
    return wt == ob.WireType.boolTrue;
  }

  set testOpaqueSpliceShrink(bool value) {
    if (!value) {
      setPatch(9, null);
      return;
    }
    final w = ob.OmniBufWriter(8);
    w.writeTag(9, ob.WireType.boolTrue);
    setPatch(9, w.toBytes());
  }
}

class ConformanceResponse {
  String parseError;
  String serializeError;
  String runtimeError;
  String skipped;
  Uint8List omnibufPayload;
  String jsonPayload;

  ConformanceResponse({
    this.parseError = '',
    this.serializeError = '',
    this.runtimeError = '',
    this.skipped = '',
    Uint8List? omnibufPayload,
    this.jsonPayload = '',
  }) : this.omnibufPayload = omnibufPayload ?? Uint8List(0);

  void reset() {
    this.parseError = '';
    this.serializeError = '';
    this.runtimeError = '';
    this.skipped = '';
    this.omnibufPayload = Uint8List(0);
    this.jsonPayload = '';
  }

  int estimateBodyBytes([int depth = 0]) {
    if (depth > ob.DecodeOptions.defaultMaxDepth) {
      throw const ob.OmniBufSerializeException(
          'message encoding depth exceeded limit of ${ob.DecodeOptions.defaultMaxDepth}');
    }
    var n = 32;
    n += this.parseError.length;
    n += this.serializeError.length;
    n += this.runtimeError.length;
    n += this.skipped.length;
    n += this.omnibufPayload.length;
    n += this.jsonPayload.length;
    return n;
  }

  static ob.SchemaMeta buildSchemaMeta({int maxDepth = 16}) {
    return _buildSchemaMeta(0, maxDepth);
  }

  static ob.SchemaMeta _buildSchemaMeta(int depth, int maxDepth) {
    final fields = <int, String>{
      1: 'parse_error',
      2: 'serialize_error',
      3: 'runtime_error',
      4: 'skipped',
      5: 'omnibuf_payload',
      6: 'json_payload',
    };
    final children = <int, ob.SchemaMeta>{};
    if (depth + 2 <= maxDepth) {}
    return ob.SchemaMeta(
        typeName: 'omnibuf.conformance.ConformanceResponse',
        fields: fields,
        children: children);
  }

  Uint8List encode({ob.EncodeOptions options = ob.EncodeOptions.defaults}) {
    final w = ob.OmniBufWriter(estimateBodyBytes());
    if (options.selfDescribing) {
      buildSchemaMeta().writeField0(w);
    }
    encodeInto(w, options: options);
    return w.toBytes();
  }

  void encodeInto(ob.OmniBufWriter w,
      {ob.EncodeOptions options = ob.EncodeOptions.defaults, int depth = 0}) {
    if (depth > ob.DecodeOptions.defaultMaxDepth) {
      throw const ob.OmniBufSerializeException(
          'message encoding depth exceeded limit of ${ob.DecodeOptions.defaultMaxDepth}');
    }
    if (this.parseError.isNotEmpty) {
      w.writeTag(1, ob.WireType.string);
      w.writeString(this.parseError);
    }
    if (this.serializeError.isNotEmpty) {
      w.writeTag(2, ob.WireType.string);
      w.writeString(this.serializeError);
    }
    if (this.runtimeError.isNotEmpty) {
      w.writeTag(3, ob.WireType.string);
      w.writeString(this.runtimeError);
    }
    if (this.skipped.isNotEmpty) {
      w.writeTag(4, ob.WireType.string);
      w.writeString(this.skipped);
    }
    if (this.omnibufPayload.isNotEmpty) {
      w.writeTag(5, ob.WireType.bytes);
      w.writeBytes(this.omnibufPayload);
    }
    if (this.jsonPayload.isNotEmpty) {
      w.writeTag(6, ob.WireType.string);
      w.writeString(this.jsonPayload);
    }
  }

  static ConformanceResponse decode(Uint8List data,
      {ob.DecodeOptions options = ob.DecodeOptions.defaults}) {
    final msg = ConformanceResponse();
    msg.decodeInto(data, options: options);
    return msg;
  }

  void decodeInto(Uint8List data,
      {ob.DecodeOptions options = ob.DecodeOptions.defaults}) {
    if (data.length > options.maxMessageBytes) {
      throw ob.OmniBufAllocationLimitException(
          'packet size ${data.length} exceeds maxMessageBytes ${options.maxMessageBytes}');
    }
    if (!options.merge) {
      reset();
    }
    final budget = ob.DecodeBudget(options.maxCollectionElements);
    final r = ob.OmniBufReader(data);
    decodeBody(r, 0, options, budget);
  }

  void decodeBody(ob.OmniBufReader r, int depth, ob.DecodeOptions options,
      [ob.DecodeBudget? budget]) {
    final activeBudget =
        budget ?? ob.DecodeBudget(options.maxCollectionElements);
    while (r.hasMore) {
      final tag = r.readTag();
      final fnum = tag >> 4;
      final wt = tag & 0x0F;
      if (fnum == 0) {
        ob.validateField0SubMsg(r, depth, options.maxDepth,
            maxElements: options.maxCollectionElements, budget: activeBudget);
        continue;
      }
      switch (fnum) {
        case 1:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.parseError = r.readString();
        case 2:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.serializeError = r.readString();
        case 3:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.runtimeError = r.readString();
        case 4:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.skipped = r.readString();
        case 5:
          if (wt != ob.WireType.bytes) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.omnibufPayload = r.readBytes();
        case 6:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.jsonPayload = r.readString();
        default:
          ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
              maxElements: options.maxCollectionElements, budget: activeBudget);
      }
    }
  }
}

class OpaqueConformanceResponse extends ob.OpaqueMessage {
  OpaqueConformanceResponse(super.rawBytes);

  String get parseError {
    if (hasPatch(1)) {
      final p = getPatch(1);
      if (p == null || p.isEmpty) return '';
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.string) return '';
      return r.readString();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 1, ob.WireType.string);
    if (hit == null) return '';
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readString();
  }

  set parseError(String value) {
    if (!(value.isNotEmpty)) {
      setPatch(1, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(1, ob.WireType.string);
    w.writeString(value);
    setPatch(1, w.toBytes());
  }

  String get serializeError {
    if (hasPatch(2)) {
      final p = getPatch(2);
      if (p == null || p.isEmpty) return '';
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.string) return '';
      return r.readString();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 2, ob.WireType.string);
    if (hit == null) return '';
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readString();
  }

  set serializeError(String value) {
    if (!(value.isNotEmpty)) {
      setPatch(2, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(2, ob.WireType.string);
    w.writeString(value);
    setPatch(2, w.toBytes());
  }

  String get runtimeError {
    if (hasPatch(3)) {
      final p = getPatch(3);
      if (p == null || p.isEmpty) return '';
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.string) return '';
      return r.readString();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 3, ob.WireType.string);
    if (hit == null) return '';
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readString();
  }

  set runtimeError(String value) {
    if (!(value.isNotEmpty)) {
      setPatch(3, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(3, ob.WireType.string);
    w.writeString(value);
    setPatch(3, w.toBytes());
  }

  String get skipped {
    if (hasPatch(4)) {
      final p = getPatch(4);
      if (p == null || p.isEmpty) return '';
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.string) return '';
      return r.readString();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 4, ob.WireType.string);
    if (hit == null) return '';
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readString();
  }

  set skipped(String value) {
    if (!(value.isNotEmpty)) {
      setPatch(4, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(4, ob.WireType.string);
    w.writeString(value);
    setPatch(4, w.toBytes());
  }

  Uint8List get omnibufPayload {
    if (hasPatch(5)) {
      final p = getPatch(5);
      if (p == null || p.isEmpty) return Uint8List(0);
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.bytes) return Uint8List(0);
      return r.readBytes();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 5, ob.WireType.bytes);
    if (hit == null) return Uint8List(0);
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readBytes();
  }

  set omnibufPayload(Uint8List value) {
    if (!(value.isNotEmpty)) {
      setPatch(5, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(5, ob.WireType.bytes);
    w.writeBytes(value);
    setPatch(5, w.toBytes());
  }

  String get jsonPayload {
    if (hasPatch(6)) {
      final p = getPatch(6);
      if (p == null || p.isEmpty) return '';
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.string) return '';
      return r.readString();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 6, ob.WireType.string);
    if (hit == null) return '';
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readString();
  }

  set jsonPayload(String value) {
    if (!(value.isNotEmpty)) {
      setPatch(6, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(6, ob.WireType.string);
    w.writeString(value);
    setPatch(6, w.toBytes());
  }
}

class AllTypesSubMsg {
  int id;
  String label;
  bool flag;
  int score;

  AllTypesSubMsg({
    this.id = 0,
    this.label = '',
    this.flag = false,
    this.score = 0,
  });

  void reset() {
    this.id = 0;
    this.label = '';
    this.flag = false;
    this.score = 0;
  }

  int estimateBodyBytes([int depth = 0]) {
    if (depth > ob.DecodeOptions.defaultMaxDepth) {
      throw const ob.OmniBufSerializeException(
          'message encoding depth exceeded limit of ${ob.DecodeOptions.defaultMaxDepth}');
    }
    var n = 32;
    n += this.label.length;
    return n;
  }

  static ob.SchemaMeta buildSchemaMeta({int maxDepth = 16}) {
    return _buildSchemaMeta(0, maxDepth);
  }

  static ob.SchemaMeta _buildSchemaMeta(int depth, int maxDepth) {
    final fields = <int, String>{
      1: 'id',
      2: 'label',
      3: 'flag',
      4: 'score',
    };
    final children = <int, ob.SchemaMeta>{};
    if (depth + 2 <= maxDepth) {}
    return ob.SchemaMeta(
        typeName: 'omnibuf.conformance.AllTypesSubMsg',
        fields: fields,
        children: children);
  }

  Uint8List encode({ob.EncodeOptions options = ob.EncodeOptions.defaults}) {
    final w = ob.OmniBufWriter(estimateBodyBytes());
    if (options.selfDescribing) {
      buildSchemaMeta().writeField0(w);
    }
    encodeInto(w, options: options);
    return w.toBytes();
  }

  void encodeInto(ob.OmniBufWriter w,
      {ob.EncodeOptions options = ob.EncodeOptions.defaults, int depth = 0}) {
    if (depth > ob.DecodeOptions.defaultMaxDepth) {
      throw const ob.OmniBufSerializeException(
          'message encoding depth exceeded limit of ${ob.DecodeOptions.defaultMaxDepth}');
    }
    if (this.id != 0) {
      w.writeTag(1, ob.WireType.uint);
      w.writeVarint(this.id & 0xFFFFFFFF);
    }
    if (this.label.isNotEmpty) {
      w.writeTag(2, ob.WireType.string);
      w.writeString(this.label);
    }
    if (this.flag) {
      w.writeTag(3, ob.WireType.boolTrue);
    }
    if (this.score != 0) {
      w.writeTag(4, ob.WireType.sint);
      w.writeSint(this.score);
    }
  }

  static AllTypesSubMsg decode(Uint8List data,
      {ob.DecodeOptions options = ob.DecodeOptions.defaults}) {
    final msg = AllTypesSubMsg();
    msg.decodeInto(data, options: options);
    return msg;
  }

  void decodeInto(Uint8List data,
      {ob.DecodeOptions options = ob.DecodeOptions.defaults}) {
    if (data.length > options.maxMessageBytes) {
      throw ob.OmniBufAllocationLimitException(
          'packet size ${data.length} exceeds maxMessageBytes ${options.maxMessageBytes}');
    }
    if (!options.merge) {
      reset();
    }
    final budget = ob.DecodeBudget(options.maxCollectionElements);
    final r = ob.OmniBufReader(data);
    decodeBody(r, 0, options, budget);
  }

  void decodeBody(ob.OmniBufReader r, int depth, ob.DecodeOptions options,
      [ob.DecodeBudget? budget]) {
    final activeBudget =
        budget ?? ob.DecodeBudget(options.maxCollectionElements);
    while (r.hasMore) {
      final tag = r.readTag();
      final fnum = tag >> 4;
      final wt = tag & 0x0F;
      if (fnum == 0) {
        ob.validateField0SubMsg(r, depth, options.maxDepth,
            maxElements: options.maxCollectionElements, budget: activeBudget);
        continue;
      }
      switch (fnum) {
        case 1:
          if (wt != ob.WireType.uint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.id = r.readUint32();
        case 2:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.label = r.readString();
        case 3:
          if (wt != ob.WireType.boolFalse && wt != ob.WireType.boolTrue) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.flag = wt == ob.WireType.boolTrue;
        case 4:
          if (wt != ob.WireType.sint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.score = r.readSint();
        default:
          ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
              maxElements: options.maxCollectionElements, budget: activeBudget);
      }
    }
  }
}

class OpaqueAllTypesSubMsg extends ob.OpaqueMessage {
  OpaqueAllTypesSubMsg(super.rawBytes);

  int get id {
    if (hasPatch(1)) {
      final p = getPatch(1);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.uint) return 0;
      return r.readUint32();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 1, ob.WireType.uint);
    if (hit == null) return 0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readUint32();
  }

  set id(int value) {
    if (!(value != 0)) {
      setPatch(1, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(1, ob.WireType.uint);
    w.writeVarint(value & 0xFFFFFFFF);
    setPatch(1, w.toBytes());
  }

  String get label {
    if (hasPatch(2)) {
      final p = getPatch(2);
      if (p == null || p.isEmpty) return '';
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.string) return '';
      return r.readString();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 2, ob.WireType.string);
    if (hit == null) return '';
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readString();
  }

  set label(String value) {
    if (!(value.isNotEmpty)) {
      setPatch(2, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(2, ob.WireType.string);
    w.writeString(value);
    setPatch(2, w.toBytes());
  }

  bool get flag {
    if (hasPatch(3)) {
      final p = getPatch(3);
      if (p == null || p.isEmpty) return false;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      return wt == ob.WireType.boolTrue;
    }
    final wt = ob.findLastBoolField(rawBytes, 3);
    return wt == ob.WireType.boolTrue;
  }

  set flag(bool value) {
    if (!value) {
      setPatch(3, null);
      return;
    }
    final w = ob.OmniBufWriter(8);
    w.writeTag(3, ob.WireType.boolTrue);
    setPatch(3, w.toBytes());
  }

  int get score {
    if (hasPatch(4)) {
      final p = getPatch(4);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.sint) return 0;
      return r.readSint();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 4, ob.WireType.sint);
    if (hit == null) return 0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readSint();
  }

  set score(int value) {
    if (!(value != 0)) {
      setPatch(4, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(4, ob.WireType.sint);
    w.writeSint(value);
    setPatch(4, w.toBytes());
  }
}

class TestAllTypes {
  int f1Uint32;
  int f2Uint64;
  int f3Sint32;
  int f4Sint64;
  bool f5Bool;
  String f6String;
  Uint8List f7Bytes;
  AllTypesSubMsg? f8SubMsg;
  List<String> f9StringArr;
  List<int> f10Uint32Arr;
  List<AllTypesSubMsg> f11SubMsgArr;
  Map<String, int> f12MapStrUint;
  double f13Float32;
  double f14Float64;
  int f15Fixed32;
  int f16Fixed64;
  String f20OverflowStr;

  TestAllTypes({
    this.f1Uint32 = 0,
    this.f2Uint64 = 0,
    this.f3Sint32 = 0,
    this.f4Sint64 = 0,
    this.f5Bool = false,
    this.f6String = '',
    Uint8List? f7Bytes,
    this.f8SubMsg,
    List<String>? f9StringArr,
    List<int>? f10Uint32Arr,
    List<AllTypesSubMsg>? f11SubMsgArr,
    Map<String, int>? f12MapStrUint,
    this.f13Float32 = 0.0,
    this.f14Float64 = 0.0,
    this.f15Fixed32 = 0,
    this.f16Fixed64 = 0,
    this.f20OverflowStr = '',
  })  : this.f7Bytes = f7Bytes ?? Uint8List(0),
        this.f9StringArr = f9StringArr ?? <String>[],
        this.f10Uint32Arr = f10Uint32Arr ?? <int>[],
        this.f11SubMsgArr = f11SubMsgArr ?? <AllTypesSubMsg>[],
        this.f12MapStrUint = f12MapStrUint ?? <String, int>{};

  void reset() {
    this.f1Uint32 = 0;
    this.f2Uint64 = 0;
    this.f3Sint32 = 0;
    this.f4Sint64 = 0;
    this.f5Bool = false;
    this.f6String = '';
    this.f7Bytes = Uint8List(0);
    this.f8SubMsg = null;
    this.f9StringArr.clear();
    this.f10Uint32Arr.clear();
    this.f11SubMsgArr.clear();
    this.f12MapStrUint.clear();
    this.f13Float32 = 0.0;
    this.f14Float64 = 0.0;
    this.f15Fixed32 = 0;
    this.f16Fixed64 = 0;
    this.f20OverflowStr = '';
  }

  int estimateBodyBytes([int depth = 0]) {
    if (depth > ob.DecodeOptions.defaultMaxDepth) {
      throw const ob.OmniBufSerializeException(
          'message encoding depth exceeded limit of ${ob.DecodeOptions.defaultMaxDepth}');
    }
    var n = 32;
    n += this.f6String.length;
    n += this.f7Bytes.length;
    if (this.f8SubMsg != null) n += this.f8SubMsg!.estimateBodyBytes(depth + 1);
    for (var i = 0; i < this.f9StringArr.length; i++) {
      n += this.f9StringArr[i].length + 4;
    }
    for (var i = 0; i < this.f11SubMsgArr.length; i++) {
      n += this.f11SubMsgArr[i].estimateBodyBytes(depth + 2);
    }
    n += this.f20OverflowStr.length;
    return n;
  }

  static ob.SchemaMeta buildSchemaMeta({int maxDepth = 16}) {
    return _buildSchemaMeta(0, maxDepth);
  }

  static ob.SchemaMeta _buildSchemaMeta(int depth, int maxDepth) {
    final fields = <int, String>{
      1: 'f1_uint32',
      2: 'f2_uint64',
      3: 'f3_sint32',
      4: 'f4_sint64',
      5: 'f5_bool',
      6: 'f6_string',
      7: 'f7_bytes',
      8: 'f8_sub_msg',
      9: 'f9_string_arr',
      10: 'f10_uint32_arr',
      11: 'f11_sub_msg_arr',
      12: 'f12_map_str_uint',
      13: 'f13_float32',
      14: 'f14_float64',
      15: 'f15_fixed32',
      16: 'f16_fixed64',
      20: 'f20_overflow_str',
    };
    final children = <int, ob.SchemaMeta>{};
    if (depth + 2 <= maxDepth) {
      children[8] =
          AllTypesSubMsg.buildSchemaMeta(maxDepth: maxDepth - depth - 2);
      children[11] =
          AllTypesSubMsg.buildSchemaMeta(maxDepth: maxDepth - depth - 2);
    }
    return ob.SchemaMeta(
        typeName: 'omnibuf.conformance.TestAllTypes',
        fields: fields,
        children: children);
  }

  Uint8List encode({ob.EncodeOptions options = ob.EncodeOptions.defaults}) {
    final w = ob.OmniBufWriter(estimateBodyBytes());
    if (options.selfDescribing) {
      buildSchemaMeta().writeField0(w);
    }
    encodeInto(w, options: options);
    return w.toBytes();
  }

  void encodeInto(ob.OmniBufWriter w,
      {ob.EncodeOptions options = ob.EncodeOptions.defaults, int depth = 0}) {
    if (depth > ob.DecodeOptions.defaultMaxDepth) {
      throw const ob.OmniBufSerializeException(
          'message encoding depth exceeded limit of ${ob.DecodeOptions.defaultMaxDepth}');
    }
    if (this.f1Uint32 != 0) {
      w.writeTag(1, ob.WireType.uint);
      w.writeVarint(this.f1Uint32 & 0xFFFFFFFF);
    }
    if (this.f2Uint64 != 0) {
      w.writeTag(2, ob.WireType.uint);
      w.writeVarint(this.f2Uint64);
    }
    if (this.f3Sint32 != 0) {
      w.writeTag(3, ob.WireType.sint);
      w.writeSint32(this.f3Sint32);
    }
    if (this.f4Sint64 != 0) {
      w.writeTag(4, ob.WireType.sint);
      w.writeSint(this.f4Sint64);
    }
    if (this.f5Bool) {
      w.writeTag(5, ob.WireType.boolTrue);
    }
    if (this.f6String.isNotEmpty) {
      w.writeTag(6, ob.WireType.string);
      w.writeString(this.f6String);
    }
    if (this.f7Bytes.isNotEmpty) {
      w.writeTag(7, ob.WireType.bytes);
      w.writeBytes(this.f7Bytes);
    }
    if (this.f8SubMsg != null) {
      final sub = this.f8SubMsg!;
      w.writeTag(8, ob.WireType.subMsg);
      final slot = w.reserveLenAuto(sub.estimateBodyBytes(depth + 1));
      sub.encodeInto(w, options: options, depth: depth + 1);
      w.patchLenAuto(slot);
    }
    if (this.f9StringArr.isNotEmpty) {
      w.writeTag(9, ob.WireType.array);
      final slot = w.reserveLen2();
      w.writeByte(ob.WireType.string);
      w.writeVarint(this.f9StringArr.length);
      for (var i = 0; i < this.f9StringArr.length; i++) {
        w.writeString(this.f9StringArr[i]);
      }
      w.patchLen2(slot);
    }
    if (this.f10Uint32Arr.isNotEmpty) {
      w.writeTag(10, ob.WireType.array);
      final slot = w.reserveLen2();
      w.writeByte(ob.WireType.uint);
      w.writeVarint(this.f10Uint32Arr.length);
      for (var i = 0; i < this.f10Uint32Arr.length; i++) {
        w.writeVarint(this.f10Uint32Arr[i] & 0xFFFFFFFF);
      }
      w.patchLen2(slot);
    }
    if (this.f11SubMsgArr.isNotEmpty) {
      w.writeTag(11, ob.WireType.array);
      var est = 8;
      for (var i = 0; i < this.f11SubMsgArr.length; i++) {
        est += this.f11SubMsgArr[i].estimateBodyBytes(depth + 2);
      }
      final slot = w.reserveLenAuto(est);
      w.writeByte(ob.WireType.subMsg);
      w.writeVarint(this.f11SubMsgArr.length);
      for (var i = 0; i < this.f11SubMsgArr.length; i++) {
        final item = this.f11SubMsgArr[i];
        final iSlot = w.reserveLenAuto(item.estimateBodyBytes(depth + 2));
        item.encodeInto(w, options: options, depth: depth + 2);
        w.patchLenAuto(iSlot);
      }
      w.patchLenAuto(slot);
    }
    if (this.f12MapStrUint.isNotEmpty) {
      w.writeTag(12, ob.WireType.map);
      final slot = w.reserveLen2();
      w.writeByte(ob.WireType.string);
      w.writeByte(ob.WireType.uint);
      final keys = this.f12MapStrUint.keys.toList();
      if (options.deterministicMaps) {
        keys.sort(ob.compareUtf8);
      }
      w.writeVarint(keys.length);
      for (var i = 0; i < keys.length; i++) {
        final k = keys[i];
        final v = this.f12MapStrUint[k]!;
        w.writeString(k);
        w.writeVarint(v);
      }
      w.patchLen2(slot);
    }
    if (this.f13Float32 != 0.0 || this.f13Float32.isNegative) {
      w.writeTag(13, ob.WireType.float32);
      w.writeFloat32(this.f13Float32);
    }
    if (this.f14Float64 != 0.0 || this.f14Float64.isNegative) {
      w.writeTag(14, ob.WireType.float64);
      w.writeFloat64(this.f14Float64);
    }
    if (this.f15Fixed32 != 0) {
      w.writeTag(15, ob.WireType.fixed32);
      w.writeFixed32(this.f15Fixed32 & 0xFFFFFFFF);
    }
    if (this.f16Fixed64 != 0) {
      w.writeTag(16, ob.WireType.fixed64);
      w.writeFixed64(this.f16Fixed64);
    }
    if (this.f20OverflowStr.isNotEmpty) {
      w.writeTag(20, ob.WireType.string);
      w.writeString(this.f20OverflowStr);
    }
  }

  static TestAllTypes decode(Uint8List data,
      {ob.DecodeOptions options = ob.DecodeOptions.defaults}) {
    final msg = TestAllTypes();
    msg.decodeInto(data, options: options);
    return msg;
  }

  void decodeInto(Uint8List data,
      {ob.DecodeOptions options = ob.DecodeOptions.defaults}) {
    if (data.length > options.maxMessageBytes) {
      throw ob.OmniBufAllocationLimitException(
          'packet size ${data.length} exceeds maxMessageBytes ${options.maxMessageBytes}');
    }
    if (!options.merge) {
      reset();
    }
    final budget = ob.DecodeBudget(options.maxCollectionElements);
    final r = ob.OmniBufReader(data);
    decodeBody(r, 0, options, budget);
  }

  void decodeBody(ob.OmniBufReader r, int depth, ob.DecodeOptions options,
      [ob.DecodeBudget? budget]) {
    final activeBudget =
        budget ?? ob.DecodeBudget(options.maxCollectionElements);
    while (r.hasMore) {
      final tag = r.readTag();
      final fnum = tag >> 4;
      final wt = tag & 0x0F;
      if (fnum == 0) {
        ob.validateField0SubMsg(r, depth, options.maxDepth,
            maxElements: options.maxCollectionElements, budget: activeBudget);
        continue;
      }
      switch (fnum) {
        case 1:
          if (wt != ob.WireType.uint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.f1Uint32 = r.readUint32();
        case 2:
          if (wt != ob.WireType.uint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.f2Uint64 = r.readVarint();
        case 3:
          if (wt != ob.WireType.sint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.f3Sint32 = r.readSint32();
        case 4:
          if (wt != ob.WireType.sint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.f4Sint64 = r.readSint();
        case 5:
          if (wt != ob.WireType.boolFalse && wt != ob.WireType.boolTrue) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.f5Bool = wt == ob.WireType.boolTrue;
        case 6:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.f6String = r.readString();
        case 7:
          if (wt != ob.WireType.bytes) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.f7Bytes = r.readBytes();
        case 8:
          if (wt != ob.WireType.subMsg) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          final nextDepth = depth + 1;
          if (nextDepth > options.maxDepth) {
            throw ob.OmniBufDepthLimitException(options.maxDepth);
          }
          final len = r.readCheckedLength();
          final subEnd = r.pos + len;
          final sub = r.subReader(r.pos, subEnd);
          final target = this.f8SubMsg ??= AllTypesSubMsg();
          target.decodeBody(sub, nextDepth, options, activeBudget);
          r.pos = subEnd;
        case 9:
          if (wt != ob.WireType.array) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          final nextDepth = depth + 1;
          if (nextDepth > options.maxDepth) {
            throw ob.OmniBufDepthLimitException(options.maxDepth);
          }
          final len = r.readCheckedLength();
          final bodyEnd = r.pos + len;
          final body = r.subReader(r.pos, bodyEnd);
          final (elemWt, count) =
              body.readArrayHeader(maxElements: options.maxCollectionElements);
          activeBudget.consume(count);
          if (elemWt != ob.WireType.string) {
            throw ob.OmniBufTypeMismatchException(
                'f9_string_arr WireArray ElementType mismatch: $elemWt');
          }
          for (var i = 0; i < count; i++) {
            this.f9StringArr.add(body.readString());
          }
          if (body.pos != bodyEnd) {
            throw const ob.OmniBufParseException('WireArray trailing bytes');
          }
          r.pos = bodyEnd;
        case 10:
          if (wt != ob.WireType.array) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          final nextDepth = depth + 1;
          if (nextDepth > options.maxDepth) {
            throw ob.OmniBufDepthLimitException(options.maxDepth);
          }
          final len = r.readCheckedLength();
          final bodyEnd = r.pos + len;
          final body = r.subReader(r.pos, bodyEnd);
          final (elemWt, count) =
              body.readArrayHeader(maxElements: options.maxCollectionElements);
          activeBudget.consume(count);
          if (elemWt != ob.WireType.uint) {
            throw ob.OmniBufTypeMismatchException(
                'f10_uint32_arr WireArray ElementType mismatch: $elemWt');
          }
          for (var i = 0; i < count; i++) {
            this.f10Uint32Arr.add(body.readUint32());
          }
          if (body.pos != bodyEnd) {
            throw const ob.OmniBufParseException('WireArray trailing bytes');
          }
          r.pos = bodyEnd;
        case 11:
          if (wt != ob.WireType.array) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          final nextDepth = depth + 1;
          if (nextDepth > options.maxDepth) {
            throw ob.OmniBufDepthLimitException(options.maxDepth);
          }
          final len = r.readCheckedLength();
          final bodyEnd = r.pos + len;
          final body = r.subReader(r.pos, bodyEnd);
          final (elemWt, count) =
              body.readArrayHeader(maxElements: options.maxCollectionElements);
          activeBudget.consume(count);
          if (elemWt != ob.WireType.subMsg) {
            throw ob.OmniBufTypeMismatchException(
                'f11_sub_msg_arr WireArray ElementType mismatch: $elemWt');
          }
          for (var i = 0; i < count; i++) {
            final itemDepth = nextDepth + 1;
            if (itemDepth > options.maxDepth) {
              throw ob.OmniBufDepthLimitException(options.maxDepth);
            }
            final iLen = body.readCheckedLength();
            final iEnd = body.pos + iLen;
            final iSub = body.subReader(body.pos, iEnd);
            final item = AllTypesSubMsg();
            item.decodeBody(iSub, itemDepth, options, activeBudget);
            body.pos = iEnd;
            this.f11SubMsgArr.add(item);
          }
          if (body.pos != bodyEnd) {
            throw const ob.OmniBufParseException('WireArray trailing bytes');
          }
          r.pos = bodyEnd;
        case 12:
          if (wt != ob.WireType.map) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          final nextDepth = depth + 1;
          if (nextDepth > options.maxDepth) {
            throw ob.OmniBufDepthLimitException(options.maxDepth);
          }
          final len = r.readCheckedLength();
          final bodyEnd = r.pos + len;
          final body = r.subReader(r.pos, bodyEnd);
          final (kWt, vWt, count) =
              body.readMapHeader(maxElements: options.maxCollectionElements);
          activeBudget.consume(count);
          if (kWt != ob.WireType.string || vWt != ob.WireType.uint) {
            throw ob.OmniBufTypeMismatchException(
                'f12_map_str_uint WireMap header mismatch: <$kWt, $vWt>');
          }
          for (var i = 0; i < count; i++) {
            final k = body.readString();
            this.f12MapStrUint[k] = body.readVarint();
          }
          if (body.pos != bodyEnd) {
            throw const ob.OmniBufParseException('WireMap trailing bytes');
          }
          r.pos = bodyEnd;
        case 13:
          if (wt != ob.WireType.float32) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.f13Float32 = r.readFloat32();
        case 14:
          if (wt != ob.WireType.float64) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.f14Float64 = r.readFloat64();
        case 15:
          if (wt != ob.WireType.fixed32) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.f15Fixed32 = r.readFixed32();
        case 16:
          if (wt != ob.WireType.fixed64) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.f16Fixed64 = r.readFixed64();
        case 20:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.f20OverflowStr = r.readString();
        default:
          ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
              maxElements: options.maxCollectionElements, budget: activeBudget);
      }
    }
  }
}

class OpaqueTestAllTypes extends ob.OpaqueMessage {
  OpaqueTestAllTypes(super.rawBytes);

  int get f1Uint32 {
    if (hasPatch(1)) {
      final p = getPatch(1);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.uint) return 0;
      return r.readUint32();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 1, ob.WireType.uint);
    if (hit == null) return 0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readUint32();
  }

  set f1Uint32(int value) {
    if (!(value != 0)) {
      setPatch(1, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(1, ob.WireType.uint);
    w.writeVarint(value & 0xFFFFFFFF);
    setPatch(1, w.toBytes());
  }

  int get f2Uint64 {
    if (hasPatch(2)) {
      final p = getPatch(2);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.uint) return 0;
      return r.readVarint();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 2, ob.WireType.uint);
    if (hit == null) return 0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readVarint();
  }

  set f2Uint64(int value) {
    if (!(value != 0)) {
      setPatch(2, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(2, ob.WireType.uint);
    w.writeVarint(value);
    setPatch(2, w.toBytes());
  }

  int get f3Sint32 {
    if (hasPatch(3)) {
      final p = getPatch(3);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.sint) return 0;
      return r.readSint32();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 3, ob.WireType.sint);
    if (hit == null) return 0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readSint32();
  }

  set f3Sint32(int value) {
    if (!(value != 0)) {
      setPatch(3, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(3, ob.WireType.sint);
    w.writeSint32(value);
    setPatch(3, w.toBytes());
  }

  int get f4Sint64 {
    if (hasPatch(4)) {
      final p = getPatch(4);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.sint) return 0;
      return r.readSint();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 4, ob.WireType.sint);
    if (hit == null) return 0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readSint();
  }

  set f4Sint64(int value) {
    if (!(value != 0)) {
      setPatch(4, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(4, ob.WireType.sint);
    w.writeSint(value);
    setPatch(4, w.toBytes());
  }

  bool get f5Bool {
    if (hasPatch(5)) {
      final p = getPatch(5);
      if (p == null || p.isEmpty) return false;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      return wt == ob.WireType.boolTrue;
    }
    final wt = ob.findLastBoolField(rawBytes, 5);
    return wt == ob.WireType.boolTrue;
  }

  set f5Bool(bool value) {
    if (!value) {
      setPatch(5, null);
      return;
    }
    final w = ob.OmniBufWriter(8);
    w.writeTag(5, ob.WireType.boolTrue);
    setPatch(5, w.toBytes());
  }

  String get f6String {
    if (hasPatch(6)) {
      final p = getPatch(6);
      if (p == null || p.isEmpty) return '';
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.string) return '';
      return r.readString();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 6, ob.WireType.string);
    if (hit == null) return '';
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readString();
  }

  set f6String(String value) {
    if (!(value.isNotEmpty)) {
      setPatch(6, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(6, ob.WireType.string);
    w.writeString(value);
    setPatch(6, w.toBytes());
  }

  Uint8List get f7Bytes {
    if (hasPatch(7)) {
      final p = getPatch(7);
      if (p == null || p.isEmpty) return Uint8List(0);
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.bytes) return Uint8List(0);
      return r.readBytes();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 7, ob.WireType.bytes);
    if (hit == null) return Uint8List(0);
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readBytes();
  }

  set f7Bytes(Uint8List value) {
    if (!(value.isNotEmpty)) {
      setPatch(7, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(7, ob.WireType.bytes);
    w.writeBytes(value);
    setPatch(7, w.toBytes());
  }

  OpaqueAllTypesSubMsg? get f8SubMsgOpaque {
    if (hasPatch(8)) {
      final p = getPatch(8);
      if (p == null || p.isEmpty) return null;
      final r = ob.OmniBufReader(p);
      r.readTag();
      final len = r.readCheckedLength();
      return OpaqueAllTypesSubMsg(Uint8List.sublistView(p, r.pos, r.pos + len));
    }
    final occs = ob.findAllFields(rawBytes, 8);
    if (occs.isEmpty) return null;
    if (occs.length == 1) {
      final (start, end, wt) = occs[0];
      if (wt != ob.WireType.subMsg) return null;
      final r = ob.OmniBufReader(rawBytes, start, end);
      final len = r.readCheckedLength();
      return OpaqueAllTypesSubMsg(
          Uint8List.sublistView(rawBytes, r.pos, r.pos + len));
    }
    final w = ob.OmniBufWriter(64);
    var found = false;
    for (var i = 0; i < occs.length; i++) {
      final (start, end, wt) = occs[i];
      if (wt != ob.WireType.subMsg) continue;
      found = true;
      final r = ob.OmniBufReader(rawBytes, start, end);
      final len = r.readCheckedLength();
      w.writeRawSlice(rawBytes, r.pos, r.pos + len);
    }
    return found ? OpaqueAllTypesSubMsg(w.toBytes()) : null;
  }

  AllTypesSubMsg? get f8SubMsg {
    final op = f8SubMsgOpaque;
    if (op == null) return null;
    return AllTypesSubMsg.decode(op.rawBytes);
  }

  set f8SubMsg(AllTypesSubMsg? value) {
    if (value == null) {
      setPatch(8, null);
      return;
    }
    final est = value.estimateBodyBytes(1);
    final w = ob.OmniBufWriter(est + 8);
    w.writeTag(8, ob.WireType.subMsg);
    final slot = w.reserveLenAuto(est);
    value.encodeInto(w, depth: 1);
    w.patchLenAuto(slot);
    setPatch(8, w.toBytes());
  }

  void setF8SubMsgOpaque(OpaqueAllTypesSubMsg value) {
    final body = value.marshalAppend();
    final w = ob.OmniBufWriter(body.length + 8);
    w.writeTag(8, ob.WireType.subMsg);
    w.writeVarint(body.length);
    w.writeRawBytes(body);
    setPatch(8, w.toBytes());
  }

  List<String> get f9StringArr {
    final out = <String>[];
    if (hasPatch(9)) {
      final p = getPatch(9);
      if (p == null || p.isEmpty) return out;
      return TestAllTypes.decode(p).f9StringArr;
    }
    final budget =
        ob.DecodeBudget(ob.DecodeOptions.defaultMaxCollectionElements);
    final occs = ob.findAllFields(rawBytes, 9);
    for (var i = 0; i < occs.length; i++) {
      final (start, end, wt) = occs[i];
      if (wt != ob.WireType.array) continue;
      final r = ob.OmniBufReader(rawBytes, start, end);
      final len = r.readCheckedLength();
      final bodyEnd = r.pos + len;
      final body = r.subReader(r.pos, bodyEnd);
      final (elemWt, count) = body.readArrayHeader();
      budget.consume(count);
      if (elemWt != ob.WireType.string) {
        throw ob.OmniBufTypeMismatchException(
            'f9_string_arr WireArray ElementType mismatch');
      }
      for (var j = 0; j < count; j++) {
        out.add(body.readString());
      }
      if (body.pos != bodyEnd) {
        throw const ob.OmniBufParseException('WireArray trailing bytes');
      }
    }
    return out;
  }

  set f9StringArr(List<String> value) {
    if (value.isEmpty) {
      setPatch(9, null);
      return;
    }
    final w = ob.OmniBufWriter(64);
    w.writeTag(9, ob.WireType.array);
    final slot = w.reserveLen2();
    w.writeByte(ob.WireType.string);
    w.writeVarint(value.length);
    for (var i = 0; i < value.length; i++) {
      w.writeString(value[i]);
    }
    w.patchLen2(slot);
    setPatch(9, w.toBytes());
  }

  List<int> get f10Uint32Arr {
    final out = <int>[];
    if (hasPatch(10)) {
      final p = getPatch(10);
      if (p == null || p.isEmpty) return out;
      return TestAllTypes.decode(p).f10Uint32Arr;
    }
    final budget =
        ob.DecodeBudget(ob.DecodeOptions.defaultMaxCollectionElements);
    final occs = ob.findAllFields(rawBytes, 10);
    for (var i = 0; i < occs.length; i++) {
      final (start, end, wt) = occs[i];
      if (wt != ob.WireType.array) continue;
      final r = ob.OmniBufReader(rawBytes, start, end);
      final len = r.readCheckedLength();
      final bodyEnd = r.pos + len;
      final body = r.subReader(r.pos, bodyEnd);
      final (elemWt, count) = body.readArrayHeader();
      budget.consume(count);
      if (elemWt != ob.WireType.uint) {
        throw ob.OmniBufTypeMismatchException(
            'f10_uint32_arr WireArray ElementType mismatch');
      }
      for (var j = 0; j < count; j++) {
        out.add(body.readUint32());
      }
      if (body.pos != bodyEnd) {
        throw const ob.OmniBufParseException('WireArray trailing bytes');
      }
    }
    return out;
  }

  set f10Uint32Arr(List<int> value) {
    if (value.isEmpty) {
      setPatch(10, null);
      return;
    }
    final w = ob.OmniBufWriter(64);
    w.writeTag(10, ob.WireType.array);
    final slot = w.reserveLen2();
    w.writeByte(ob.WireType.uint);
    w.writeVarint(value.length);
    for (var i = 0; i < value.length; i++) {
      w.writeVarint(value[i] & 0xFFFFFFFF);
    }
    w.patchLen2(slot);
    setPatch(10, w.toBytes());
  }

  List<AllTypesSubMsg> get f11SubMsgArr {
    final out = <AllTypesSubMsg>[];
    if (hasPatch(11)) {
      final p = getPatch(11);
      if (p == null || p.isEmpty) return out;
      return TestAllTypes.decode(p).f11SubMsgArr;
    }
    final budget =
        ob.DecodeBudget(ob.DecodeOptions.defaultMaxCollectionElements);
    final occs = ob.findAllFields(rawBytes, 11);
    for (var i = 0; i < occs.length; i++) {
      final (start, end, wt) = occs[i];
      if (wt != ob.WireType.array) continue;
      final r = ob.OmniBufReader(rawBytes, start, end);
      final len = r.readCheckedLength();
      final bodyEnd = r.pos + len;
      final body = r.subReader(r.pos, bodyEnd);
      final (elemWt, count) = body.readArrayHeader();
      budget.consume(count);
      if (elemWt != ob.WireType.subMsg) {
        throw ob.OmniBufTypeMismatchException(
            'f11_sub_msg_arr WireArray ElementType mismatch');
      }
      for (var j = 0; j < count; j++) {
        final iLen = body.readCheckedLength();
        final iEnd = body.pos + iLen;
        final iSub = body.subReader(body.pos, iEnd);
        final item = AllTypesSubMsg();
        item.decodeBody(iSub, 2, ob.DecodeOptions.defaults, budget);
        body.pos = iEnd;
        out.add(item);
      }
      if (body.pos != bodyEnd) {
        throw const ob.OmniBufParseException('WireArray trailing bytes');
      }
    }
    return out;
  }

  set f11SubMsgArr(List<AllTypesSubMsg> value) {
    if (value.isEmpty) {
      setPatch(11, null);
      return;
    }
    final w = ob.OmniBufWriter(64);
    w.writeTag(11, ob.WireType.array);
    final slot = w.reserveLen2();
    w.writeByte(ob.WireType.subMsg);
    w.writeVarint(value.length);
    for (var i = 0; i < value.length; i++) {
      final item = value[i];
      final iSlot = w.reserveLenAuto(item.estimateBodyBytes(2));
      item.encodeInto(w, depth: 2);
      w.patchLenAuto(iSlot);
    }
    w.patchLen2(slot);
    setPatch(11, w.toBytes());
  }

  Map<String, int> get f12MapStrUint {
    final out = <String, int>{};
    if (hasPatch(12)) {
      final p = getPatch(12);
      if (p == null || p.isEmpty) return out;
      final tmp = TestAllTypes.decode(p);
      return tmp.f12MapStrUint;
    }
    final budget =
        ob.DecodeBudget(ob.DecodeOptions.defaultMaxCollectionElements);
    final occs = ob.findAllFields(rawBytes, 12);
    for (var i = 0; i < occs.length; i++) {
      final (start, end, wt) = occs[i];
      if (wt != ob.WireType.map) continue;
      final r = ob.OmniBufReader(rawBytes, start, end);
      final len = r.readCheckedLength();
      final bodyEnd = r.pos + len;
      final body = r.subReader(r.pos, bodyEnd);
      final (kWt, vWt, count) = body.readMapHeader();
      budget.consume(count);
      if (kWt != ob.WireType.string || vWt != ob.WireType.uint) {
        throw ob.OmniBufTypeMismatchException(
            'f12_map_str_uint WireMap header mismatch');
      }
      for (var j = 0; j < count; j++) {
        final k = body.readString();
        out[k] = body.readVarint();
      }
      if (body.pos != bodyEnd) {
        throw const ob.OmniBufParseException('WireMap trailing bytes');
      }
    }
    return out;
  }

  set f12MapStrUint(Map<String, int> value) {
    if (value.isEmpty) {
      setPatch(12, null);
      return;
    }
    final w = ob.OmniBufWriter(64);
    w.writeTag(12, ob.WireType.map);
    final slot = w.reserveLen2();
    w.writeByte(ob.WireType.string);
    w.writeByte(ob.WireType.uint);
    final keys = value.keys.toList();
    keys.sort(ob.compareUtf8);
    w.writeVarint(keys.length);
    for (var i = 0; i < keys.length; i++) {
      final k = keys[i];
      final v = value[k]!;
      w.writeString(k);
      w.writeVarint(v);
    }
    w.patchLen2(slot);
    setPatch(12, w.toBytes());
  }

  double get f13Float32 {
    if (hasPatch(13)) {
      final p = getPatch(13);
      if (p == null || p.isEmpty) return 0.0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.float32) return 0.0;
      return r.readFloat32();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 13, ob.WireType.float32);
    if (hit == null) return 0.0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readFloat32();
  }

  set f13Float32(double value) {
    if (!(value != 0.0 || value.isNegative)) {
      setPatch(13, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(13, ob.WireType.float32);
    w.writeFloat32(value);
    setPatch(13, w.toBytes());
  }

  double get f14Float64 {
    if (hasPatch(14)) {
      final p = getPatch(14);
      if (p == null || p.isEmpty) return 0.0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.float64) return 0.0;
      return r.readFloat64();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 14, ob.WireType.float64);
    if (hit == null) return 0.0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readFloat64();
  }

  set f14Float64(double value) {
    if (!(value != 0.0 || value.isNegative)) {
      setPatch(14, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(14, ob.WireType.float64);
    w.writeFloat64(value);
    setPatch(14, w.toBytes());
  }

  int get f15Fixed32 {
    if (hasPatch(15)) {
      final p = getPatch(15);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.fixed32) return 0;
      return r.readFixed32();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 15, ob.WireType.fixed32);
    if (hit == null) return 0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readFixed32();
  }

  set f15Fixed32(int value) {
    if (!(value != 0)) {
      setPatch(15, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(15, ob.WireType.fixed32);
    w.writeFixed32(value & 0xFFFFFFFF);
    setPatch(15, w.toBytes());
  }

  int get f16Fixed64 {
    if (hasPatch(16)) {
      final p = getPatch(16);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.fixed64) return 0;
      return r.readFixed64();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 16, ob.WireType.fixed64);
    if (hit == null) return 0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readFixed64();
  }

  set f16Fixed64(int value) {
    if (!(value != 0)) {
      setPatch(16, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(16, ob.WireType.fixed64);
    w.writeFixed64(value);
    setPatch(16, w.toBytes());
  }

  String get f20OverflowStr {
    if (hasPatch(20)) {
      final p = getPatch(20);
      if (p == null || p.isEmpty) return '';
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.string) return '';
      return r.readString();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 20, ob.WireType.string);
    if (hit == null) return '';
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readString();
  }

  set f20OverflowStr(String value) {
    if (!(value.isNotEmpty)) {
      setPatch(20, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(20, ob.WireType.string);
    w.writeString(value);
    setPatch(20, w.toBytes());
  }
}
