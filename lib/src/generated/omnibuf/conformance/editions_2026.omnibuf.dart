// GENERATED CODE - DO NOT MODIFY BY HAND.
// Source: omnibuf/conformance/editions_2026.proto
// ignore_for_file: unused_import, constant_identifier_names, non_constant_identifier_names, prefer_final_locals, unnecessary_this, camel_case_types

import 'dart:typed_data';

import 'package:omnibuf/omnibuf.dart' as ob;

abstract final class Editions2026Status {
  static const int EDITIONS2026_STATUS_UNSPECIFIED = 0;
  static const int EDITIONS2026_STATUS_ACTIVE = 1;
  static const int EDITIONS2026_STATUS_PAUSED = 2;
}

class Editions2026Child {
  int _id;
  bool _has_id;
  bool get has_id => _has_id;
  int get id => _id;
  set id(int value) {
    _id = value;
    _has_id = true;
  }

  void clear_id() {
    _id = 0;
    _has_id = false;
  }

  String _note;
  bool _has_note;
  bool get has_note => _has_note;
  String get note => _note;
  set note(String value) {
    _note = value;
    _has_note = true;
  }

  void clear_note() {
    _note = '';
    _has_note = false;
  }

  Editions2026Child({
    int? id,
    String? note,
  })  : _id = id ?? 0,
        _has_id = id != null,
        _note = note ?? '',
        _has_note = note != null;

  void reset() {
    clear_id();
    clear_note();
  }

  int estimateBodyBytes([int depth = 0]) {
    if (depth > ob.DecodeOptions.defaultMaxDepth) {
      throw const ob.OmniBufSerializeException(
          'message encoding depth exceeded limit of ${ob.DecodeOptions.defaultMaxDepth}');
    }
    var n = 32;
    n += this.note.length;
    return n;
  }

  static ob.SchemaMeta buildSchemaMeta({int maxDepth = 16}) {
    return _buildSchemaMeta(0, maxDepth);
  }

  static ob.SchemaMeta _buildSchemaMeta(int depth, int maxDepth) {
    final fields = <int, String>{
      1: 'id',
      2: 'note',
    };
    final children = <int, ob.SchemaMeta>{};
    if (depth + 2 <= maxDepth) {}
    return ob.SchemaMeta(
        typeName: 'omnibuf.conformance.Editions2026Child',
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
    if (this._has_id) {
      w.writeTag(1, ob.WireType.sint);
      w.writeSint32(this._id);
    }
    if (this._has_note) {
      w.writeTag(2, ob.WireType.string);
      w.writeString(this._note);
    }
  }

  static Editions2026Child decode(Uint8List data,
      {ob.DecodeOptions options = ob.DecodeOptions.defaults}) {
    final msg = Editions2026Child();
    msg.decodeInto(data, options: options);
    return msg;
  }

  void decodeInto(Uint8List data,
      {ob.DecodeOptions options = ob.DecodeOptions.defaults}) {
    options.validatedMaxDepth();
    if (data.length > options.maxMessageBytes) {
      throw ob.OmniBufAllocationLimitException(
          'packet size ${data.length} exceeds maxMessageBytes ${options.maxMessageBytes}');
    }
    if (!options.merge) {
      reset();
    }
    final budget = ob.DecodeBudget(options.maxCollectionElements,
        maxAllocBytes: options.maxAllocBytes);
    final r = ob.OmniBufReader(data);
    decodeBody(r, 0, options, budget);
  }

  void decodeBody(ob.OmniBufReader r, int depth, ob.DecodeOptions options,
      [ob.DecodeBudget? budget]) {
    final activeBudget = budget ??
        ob.DecodeBudget(options.maxCollectionElements,
            maxAllocBytes: options.maxAllocBytes);
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
          if (wt != ob.WireType.sint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.id = r.readSint32();
        case 2:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.note = r.readString(budget: activeBudget);
        default:
          ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
              maxElements: options.maxCollectionElements, budget: activeBudget);
      }
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Editions2026Child) return false;
    return this._has_id == other._has_id &&
        (!this._has_id || this._id == other._id) &&
        this._has_note == other._has_note &&
        (!this._has_note || this._note == other._note);
  }

  @override
  int get hashCode =>
      Object.hashAll([this._has_id, this._id, this._has_note, this._note]);

  @override
  String toString() =>
      'Editions2026Child(id: ${this._has_id ? this._id : null}, note: ${this._has_note ? this._note : null})';
}

class OpaqueEditions2026Child extends ob.OpaqueMessage {
  OpaqueEditions2026Child(super.rawBytes);

  bool get has_id => hasPatch(1)
      ? (getPatch(1)?.isNotEmpty ?? false)
      : ob.findLastFieldWithWireType(rawBytes, 1, ob.WireType.sint) != null;
  void clear_id() => setPatch(1, null);
  int get id {
    if (hasPatch(1)) {
      final p = getPatch(1);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.sint) {
        return 0;
      }
      return r.readSint32();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 1, ob.WireType.sint);
    if (hit == null) return 0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readSint32();
  }

  set id(int value) {
    final w = ob.OmniBufWriter(32);
    w.writeTag(1, ob.WireType.sint);
    w.writeSint32(value);
    setPatch(1, w.toBytes());
  }

  bool get has_note => hasPatch(2)
      ? (getPatch(2)?.isNotEmpty ?? false)
      : ob.findLastFieldWithWireType(rawBytes, 2, ob.WireType.string) != null;
  void clear_note() => setPatch(2, null);
  String get note {
    if (hasPatch(2)) {
      final p = getPatch(2);
      if (p == null || p.isEmpty) return '';
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.string) {
        return '';
      }
      return r.readString();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 2, ob.WireType.string);
    if (hit == null) return '';
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readString();
  }

  set note(String value) {
    final w = ob.OmniBufWriter(32);
    w.writeTag(2, ob.WireType.string);
    w.writeString(value);
    setPatch(2, w.toBytes());
  }
}

class TestEditions2026 {
  int _which_choice = 0;
  int get which_choice => _which_choice;
  void clear_choice() {
    switch (_which_choice) {
      case 14:
        _choiceInt = 0;
      case 15:
        _choiceText = '';
      case 16:
        _choiceFlag = false;
      case 17:
        _choiceChild = null;
    }
    _which_choice = 0;
  }

  int _explicitInt;
  bool _has_explicitInt;
  bool get has_explicitInt => _has_explicitInt;
  int get explicitInt => _explicitInt;
  set explicitInt(int value) {
    _explicitInt = value;
    _has_explicitInt = true;
  }

  void clear_explicitInt() {
    _explicitInt = 0;
    _has_explicitInt = false;
  }

  bool _explicitBool;
  bool _has_explicitBool;
  bool get has_explicitBool => _has_explicitBool;
  bool get explicitBool => _explicitBool;
  set explicitBool(bool value) {
    _explicitBool = value;
    _has_explicitBool = true;
  }

  void clear_explicitBool() {
    _explicitBool = false;
    _has_explicitBool = false;
  }

  String _explicitString;
  bool _has_explicitString;
  bool get has_explicitString => _has_explicitString;
  String get explicitString => _explicitString;
  set explicitString(String value) {
    _explicitString = value;
    _has_explicitString = true;
  }

  void clear_explicitString() {
    _explicitString = '';
    _has_explicitString = false;
  }

  Uint8List _explicitBytes;
  bool _has_explicitBytes;
  bool get has_explicitBytes => _has_explicitBytes;
  Uint8List get explicitBytes => _explicitBytes;
  set explicitBytes(Uint8List value) {
    _explicitBytes = value;
    _has_explicitBytes = true;
  }

  void clear_explicitBytes() {
    _explicitBytes = Uint8List(0);
    _has_explicitBytes = false;
  }

  double _explicitDouble;
  bool _has_explicitDouble;
  bool get has_explicitDouble => _has_explicitDouble;
  double get explicitDouble => _explicitDouble;
  set explicitDouble(double value) {
    _explicitDouble = value;
    _has_explicitDouble = true;
  }

  void clear_explicitDouble() {
    _explicitDouble = 0.0;
    _has_explicitDouble = false;
  }

  int _status;
  bool _has_status;
  bool get has_status => _has_status;
  int get status => _status;
  set status(int value) {
    _status = value;
    _has_status = true;
  }

  void clear_status() {
    _status = 0;
    _has_status = false;
  }

  int implicitCount;
  bool implicitFlag;
  Editions2026Child? child;
  Editions2026Child? delimitedChild;
  List<int> packedVals;
  List<int> expandedVals;
  Map<String, int> scores;
  int _choiceInt;
  bool get has_choiceInt => _which_choice == 14;
  int get choiceInt => _choiceInt;
  set choiceInt(int value) {
    if (_which_choice != 14) {
      clear_choice();
      _which_choice = 14;
    }
    _choiceInt = value;
  }

  void clear_choiceInt() {
    if (_which_choice == 14) {
      _choiceInt = 0;
      _which_choice = 0;
    }
  }

  String _choiceText;
  bool get has_choiceText => _which_choice == 15;
  String get choiceText => _choiceText;
  set choiceText(String value) {
    if (_which_choice != 15) {
      clear_choice();
      _which_choice = 15;
    }
    _choiceText = value;
  }

  void clear_choiceText() {
    if (_which_choice == 15) {
      _choiceText = '';
      _which_choice = 0;
    }
  }

  bool _choiceFlag;
  bool get has_choiceFlag => _which_choice == 16;
  bool get choiceFlag => _choiceFlag;
  set choiceFlag(bool value) {
    if (_which_choice != 16) {
      clear_choice();
      _which_choice = 16;
    }
    _choiceFlag = value;
  }

  void clear_choiceFlag() {
    if (_which_choice == 16) {
      _choiceFlag = false;
      _which_choice = 0;
    }
  }

  Editions2026Child? _choiceChild;
  bool get has_choiceChild => _which_choice == 17;
  Editions2026Child? get choiceChild => _choiceChild;
  set choiceChild(Editions2026Child? value) {
    if (value == null) {
      clear_choiceChild();
      return;
    }
    if (_which_choice != 17) {
      clear_choice();
      _which_choice = 17;
    }
    _choiceChild = value;
  }

  void clear_choiceChild() {
    if (_which_choice == 17) {
      _choiceChild = null;
      _which_choice = 0;
    }
  }

  TestEditions2026({
    int? explicitInt,
    bool? explicitBool,
    String? explicitString,
    Uint8List? explicitBytes,
    double? explicitDouble,
    int? status,
    this.implicitCount = 0,
    this.implicitFlag = false,
    this.child,
    this.delimitedChild,
    List<int>? packedVals,
    List<int>? expandedVals,
    Map<String, int>? scores,
    int? choiceInt,
    String? choiceText,
    bool? choiceFlag,
    Editions2026Child? choiceChild,
  })  : _explicitInt = explicitInt ?? 0,
        _has_explicitInt = explicitInt != null,
        _explicitBool = explicitBool ?? false,
        _has_explicitBool = explicitBool != null,
        _explicitString = explicitString ?? '',
        _has_explicitString = explicitString != null,
        _explicitBytes = explicitBytes ?? Uint8List(0),
        _has_explicitBytes = explicitBytes != null,
        _explicitDouble = explicitDouble ?? 0.0,
        _has_explicitDouble = explicitDouble != null,
        _status = status ?? 0,
        _has_status = status != null,
        this.packedVals = packedVals ?? <int>[],
        this.expandedVals = expandedVals ?? <int>[],
        this.scores = scores ?? <String, int>{},
        _choiceInt = 0,
        _choiceText = '',
        _choiceFlag = false {
    if (choiceInt != null) {
      this.choiceInt = choiceInt;
    }
    if (choiceText != null) {
      this.choiceText = choiceText;
    }
    if (choiceFlag != null) {
      this.choiceFlag = choiceFlag;
    }
    if (choiceChild != null) {
      this.choiceChild = choiceChild;
    }
  }

  void reset() {
    clear_choice();
    clear_explicitInt();
    clear_explicitBool();
    clear_explicitString();
    clear_explicitBytes();
    clear_explicitDouble();
    clear_status();
    this.implicitCount = 0;
    this.implicitFlag = false;
    this.child = null;
    this.delimitedChild = null;
    this.packedVals.clear();
    this.expandedVals.clear();
    this.scores.clear();
  }

  int estimateBodyBytes([int depth = 0]) {
    if (depth > ob.DecodeOptions.defaultMaxDepth) {
      throw const ob.OmniBufSerializeException(
          'message encoding depth exceeded limit of ${ob.DecodeOptions.defaultMaxDepth}');
    }
    var n = 32;
    n += this.explicitString.length;
    n += this.explicitBytes.length;
    if (this.child != null) {
      n += this.child!.estimateBodyBytes(depth + 1);
    }
    if (this.delimitedChild != null) {
      n += this.delimitedChild!.estimateBodyBytes(depth + 1);
    }
    if (this._which_choice == 15) {
      n += this._choiceText.length;
    }
    if (this._which_choice == 17 && this._choiceChild != null) {
      n += this._choiceChild!.estimateBodyBytes(depth + 1);
    }
    return n;
  }

  static ob.SchemaMeta buildSchemaMeta({int maxDepth = 16}) {
    return _buildSchemaMeta(0, maxDepth);
  }

  static ob.SchemaMeta _buildSchemaMeta(int depth, int maxDepth) {
    final fields = <int, String>{
      1: 'explicit_int',
      2: 'explicit_bool',
      3: 'explicit_string',
      4: 'explicit_bytes',
      5: 'explicit_double',
      6: 'status',
      7: 'implicit_count',
      8: 'implicit_flag',
      9: 'child',
      10: 'delimited_child',
      11: 'packed_vals',
      12: 'expanded_vals',
      13: 'scores',
      14: 'choice_int',
      15: 'choice_text',
      16: 'choice_flag',
      17: 'choice_child',
    };
    final children = <int, ob.SchemaMeta>{};
    if (depth + 2 <= maxDepth) {
      children[9] =
          Editions2026Child.buildSchemaMeta(maxDepth: maxDepth - depth - 2);
      children[10] =
          Editions2026Child.buildSchemaMeta(maxDepth: maxDepth - depth - 2);
      children[17] =
          Editions2026Child.buildSchemaMeta(maxDepth: maxDepth - depth - 2);
    }
    return ob.SchemaMeta(
        typeName: 'omnibuf.conformance.TestEditions2026',
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
    if (this._has_explicitInt) {
      w.writeTag(1, ob.WireType.sint);
      w.writeSint32(this._explicitInt);
    }
    if (this._has_explicitBool) {
      w.writeTag(
          2, this._explicitBool ? ob.WireType.boolTrue : ob.WireType.boolFalse);
    }
    if (this._has_explicitString) {
      w.writeTag(3, ob.WireType.string);
      w.writeString(this._explicitString);
    }
    if (this._has_explicitBytes) {
      w.writeTag(4, ob.WireType.bytes);
      w.writeBytes(this._explicitBytes);
    }
    if (this._has_explicitDouble) {
      w.writeTag(5, ob.WireType.float64);
      w.writeFloat64(this._explicitDouble);
    }
    if (this._has_status) {
      w.writeTag(6, ob.WireType.sint);
      w.writeSint32(this._status);
    }
    if (this.implicitCount != 0) {
      w.writeTag(7, ob.WireType.sint);
      w.writeSint32(this.implicitCount);
    }
    if (this.implicitFlag) {
      w.writeTag(8, ob.WireType.boolTrue);
    }
    if (this.child != null) {
      final sub = this.child!;
      w.writeTag(9, ob.WireType.subMsg);
      final slot = w.reserveLen2();
      sub.encodeInto(w, options: options, depth: depth + 1);
      w.patchLen2(slot);
    }
    if (this.delimitedChild != null) {
      final sub = this.delimitedChild!;
      w.writeTag(10, ob.WireType.subMsg);
      final slot = w.reserveLen2();
      sub.encodeInto(w, options: options, depth: depth + 1);
      w.patchLen2(slot);
    }
    if (this.packedVals.isNotEmpty) {
      w.writeTag(11, ob.WireType.array);
      final slot = w.reserveLen2();
      w.writeByte(ob.WireType.sint);
      w.writeVarint(this.packedVals.length);
      for (var i = 0; i < this.packedVals.length; i++) {
        w.writeSint32(this.packedVals[i]);
      }
      w.patchLen2(slot);
    }
    if (this.expandedVals.isNotEmpty) {
      w.writeTag(12, ob.WireType.array);
      final slot = w.reserveLen2();
      w.writeByte(ob.WireType.sint);
      w.writeVarint(this.expandedVals.length);
      for (var i = 0; i < this.expandedVals.length; i++) {
        w.writeSint32(this.expandedVals[i]);
      }
      w.patchLen2(slot);
    }
    if (this.scores.isNotEmpty) {
      w.writeTag(13, ob.WireType.map);
      final slot = w.reserveLen2();
      w.writeByte(ob.WireType.string);
      w.writeByte(ob.WireType.sint);
      final keys = this.scores.keys.toList();
      if (options.deterministicMaps) {
        keys.sort(ob.compareUtf8);
      }
      w.writeVarint(keys.length);
      for (var i = 0; i < keys.length; i++) {
        final k = keys[i];
        final v = this.scores[k]!;
        w.writeString(k);
        w.writeSint32(v);
      }
      w.patchLen2(slot);
    }
    if (this._which_choice == 14) {
      w.writeTag(14, ob.WireType.sint);
      w.writeSint32(this._choiceInt);
    }
    if (this._which_choice == 15) {
      w.writeTag(15, ob.WireType.string);
      w.writeString(this._choiceText);
    }
    if (this._which_choice == 16) {
      w.writeTag(
          16, this._choiceFlag ? ob.WireType.boolTrue : ob.WireType.boolFalse);
    }
    if (this._which_choice == 17 && this._choiceChild != null) {
      final sub = this._choiceChild!;
      w.writeTag(17, ob.WireType.subMsg);
      final slot = w.reserveLen2();
      sub.encodeInto(w, options: options, depth: depth + 1);
      w.patchLen2(slot);
    }
  }

  static TestEditions2026 decode(Uint8List data,
      {ob.DecodeOptions options = ob.DecodeOptions.defaults}) {
    final msg = TestEditions2026();
    msg.decodeInto(data, options: options);
    return msg;
  }

  void decodeInto(Uint8List data,
      {ob.DecodeOptions options = ob.DecodeOptions.defaults}) {
    options.validatedMaxDepth();
    if (data.length > options.maxMessageBytes) {
      throw ob.OmniBufAllocationLimitException(
          'packet size ${data.length} exceeds maxMessageBytes ${options.maxMessageBytes}');
    }
    if (!options.merge) {
      reset();
    }
    final budget = ob.DecodeBudget(options.maxCollectionElements,
        maxAllocBytes: options.maxAllocBytes);
    final r = ob.OmniBufReader(data);
    decodeBody(r, 0, options, budget);
  }

  void decodeBody(ob.OmniBufReader r, int depth, ob.DecodeOptions options,
      [ob.DecodeBudget? budget]) {
    final activeBudget = budget ??
        ob.DecodeBudget(options.maxCollectionElements,
            maxAllocBytes: options.maxAllocBytes);
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
          if (wt != ob.WireType.sint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.explicitInt = r.readSint32();
        case 2:
          if (wt != ob.WireType.boolFalse && wt != ob.WireType.boolTrue) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.explicitBool = wt == ob.WireType.boolTrue;
        case 3:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.explicitString = r.readString(budget: activeBudget);
        case 4:
          if (wt != ob.WireType.bytes) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.explicitBytes = r.readBytes(budget: activeBudget);
        case 5:
          if (wt != ob.WireType.float64) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.explicitDouble = r.readFloat64();
        case 6:
          if (wt != ob.WireType.sint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.status = r.readSint32();
        case 7:
          if (wt != ob.WireType.sint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.implicitCount = r.readSint32();
        case 8:
          if (wt != ob.WireType.boolFalse && wt != ob.WireType.boolTrue) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.implicitFlag = wt == ob.WireType.boolTrue;
        case 9:
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
          final target = this.child ??= Editions2026Child();
          target.decodeBody(sub, nextDepth, options, activeBudget);
          r.pos = subEnd;
        case 10:
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
          final target = this.delimitedChild ??= Editions2026Child();
          target.decodeBody(sub, nextDepth, options, activeBudget);
          r.pos = subEnd;
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
          if (elemWt != ob.WireType.sint) {
            throw ob.OmniBufTypeMismatchException(
                'packed_vals WireArray ElementType mismatch: $elemWt');
          }
          for (var i = 0; i < count; i++) {
            this.packedVals.add(body.readSint32());
          }
          if (body.pos != bodyEnd) {
            throw const ob.OmniBufParseException('WireArray trailing bytes');
          }
          r.pos = bodyEnd;
        case 12:
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
          if (elemWt != ob.WireType.sint) {
            throw ob.OmniBufTypeMismatchException(
                'expanded_vals WireArray ElementType mismatch: $elemWt');
          }
          for (var i = 0; i < count; i++) {
            this.expandedVals.add(body.readSint32());
          }
          if (body.pos != bodyEnd) {
            throw const ob.OmniBufParseException('WireArray trailing bytes');
          }
          r.pos = bodyEnd;
        case 13:
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
          if (kWt != ob.WireType.string || vWt != ob.WireType.sint) {
            throw ob.OmniBufTypeMismatchException(
                'scores WireMap header mismatch: <$kWt, $vWt>');
          }
          for (var i = 0; i < count; i++) {
            final k = body.readString(budget: activeBudget);
            this.scores[k] = body.readSint32();
          }
          if (body.pos != bodyEnd) {
            throw const ob.OmniBufParseException('WireMap trailing bytes');
          }
          r.pos = bodyEnd;
        case 14:
          if (wt != ob.WireType.sint) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.choiceInt = r.readSint32();
        case 15:
          if (wt != ob.WireType.string) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.choiceText = r.readString(budget: activeBudget);
        case 16:
          if (wt != ob.WireType.boolFalse && wt != ob.WireType.boolTrue) {
            ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
                maxElements: options.maxCollectionElements,
                budget: activeBudget);
            break;
          }
          this.choiceFlag = wt == ob.WireType.boolTrue;
        case 17:
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
          final Editions2026Child target;
          if (this._which_choice == 17 && this._choiceChild != null) {
            target = this._choiceChild!;
          } else {
            target = Editions2026Child();
            this.choiceChild = target;
          }
          target.decodeBody(sub, nextDepth, options, activeBudget);
          r.pos = subEnd;
        default:
          ob.skipAndValidateValue(r, wt, depth, options.maxDepth,
              maxElements: options.maxCollectionElements, budget: activeBudget);
      }
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TestEditions2026) return false;
    return this._which_choice == other._which_choice &&
        this._has_explicitInt == other._has_explicitInt &&
        (!this._has_explicitInt || this._explicitInt == other._explicitInt) &&
        this._has_explicitBool == other._has_explicitBool &&
        (!this._has_explicitBool ||
            this._explicitBool == other._explicitBool) &&
        this._has_explicitString == other._has_explicitString &&
        (!this._has_explicitString ||
            this._explicitString == other._explicitString) &&
        this._has_explicitBytes == other._has_explicitBytes &&
        (!this._has_explicitBytes ||
            ob.bytesEquals(this._explicitBytes, other._explicitBytes)) &&
        this._has_explicitDouble == other._has_explicitDouble &&
        (!this._has_explicitDouble ||
            this._explicitDouble == other._explicitDouble) &&
        this._has_status == other._has_status &&
        (!this._has_status || this._status == other._status) &&
        this.implicitCount == other.implicitCount &&
        this.implicitFlag == other.implicitFlag &&
        this.child == other.child &&
        this.delimitedChild == other.delimitedChild &&
        ob.listEquals(this.packedVals, other.packedVals) &&
        ob.listEquals(this.expandedVals, other.expandedVals) &&
        ob.mapEquals(this.scores, other.scores) &&
        this._choiceInt == other._choiceInt &&
        this._choiceText == other._choiceText &&
        this._choiceFlag == other._choiceFlag &&
        this._choiceChild == other._choiceChild;
  }

  @override
  int get hashCode => Object.hashAll([
        this._which_choice,
        this._has_explicitInt,
        this._explicitInt,
        this._has_explicitBool,
        this._explicitBool,
        this._has_explicitString,
        this._explicitString,
        this._has_explicitBytes,
        ob.bytesHash(this._explicitBytes),
        this._has_explicitDouble,
        this._explicitDouble,
        this._has_status,
        this._status,
        this.implicitCount,
        this.implicitFlag,
        this.child,
        this.delimitedChild,
        ob.listHash(this.packedVals),
        ob.listHash(this.expandedVals),
        ob.mapHash(this.scores),
        this._choiceInt,
        this._choiceText,
        this._choiceFlag,
        this._choiceChild
      ]);

  @override
  String toString() =>
      'TestEditions2026(explicitInt: ${this._has_explicitInt ? this._explicitInt : null}, explicitBool: ${this._has_explicitBool ? this._explicitBool : null}, explicitString: ${this._has_explicitString ? this._explicitString : null}, explicitBytes: ${this._has_explicitBytes ? this._explicitBytes : null}, explicitDouble: ${this._has_explicitDouble ? this._explicitDouble : null}, status: ${this._has_status ? this._status : null}, implicitCount: ${this.implicitCount}, implicitFlag: ${this.implicitFlag}, child: ${this.child}, delimitedChild: ${this.delimitedChild}, packedVals: ${this.packedVals}, expandedVals: ${this.expandedVals}, scores: ${this.scores}, choiceInt: ${this._which_choice == 14 ? this._choiceInt : null}, choiceText: ${this._which_choice == 15 ? this._choiceText : null}, choiceFlag: ${this._which_choice == 16 ? this._choiceFlag : null}, choiceChild: ${this._which_choice == 17 ? this._choiceChild : null})';
}

class OpaqueTestEditions2026 extends ob.OpaqueMessage {
  OpaqueTestEditions2026(super.rawBytes);

  static const Map<int, int> _oneof_choice = <int, int>{
    14: ob.WireType.sint,
    15: ob.WireType.string,
    16: ob.WireType.boolFalse,
    17: ob.WireType.subMsg,
  };

  int get which_choice {
    var anyPatch = false;
    for (final fnum in _oneof_choice.keys) {
      if (hasPatch(fnum)) {
        anyPatch = true;
        final p = getPatch(fnum);
        if (p != null && p.isNotEmpty) return fnum;
      }
    }
    if (anyPatch) return 0;
    return ob.findLastOneofField(rawBytes, _oneof_choice);
  }

  void clear_choice() {
    setPatch(14, null);
    setPatch(15, null);
    setPatch(16, null);
    setPatch(17, null);
  }

  bool get has_explicitInt => hasPatch(1)
      ? (getPatch(1)?.isNotEmpty ?? false)
      : ob.findLastFieldWithWireType(rawBytes, 1, ob.WireType.sint) != null;
  void clear_explicitInt() => setPatch(1, null);
  int get explicitInt {
    if (hasPatch(1)) {
      final p = getPatch(1);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.sint) {
        return 0;
      }
      return r.readSint32();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 1, ob.WireType.sint);
    if (hit == null) return 0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readSint32();
  }

  set explicitInt(int value) {
    final w = ob.OmniBufWriter(32);
    w.writeTag(1, ob.WireType.sint);
    w.writeSint32(value);
    setPatch(1, w.toBytes());
  }

  bool get has_explicitBool => hasPatch(2)
      ? (getPatch(2)?.isNotEmpty ?? false)
      : ob.findLastBoolField(rawBytes, 2) != null;
  void clear_explicitBool() => setPatch(2, null);
  bool get explicitBool {
    if (hasPatch(2)) {
      final p = getPatch(2);
      if (p == null || p.isEmpty) return false;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      return wt == ob.WireType.boolTrue;
    }
    final wt = ob.findLastBoolField(rawBytes, 2);
    return wt == ob.WireType.boolTrue;
  }

  set explicitBool(bool value) {
    final w = ob.OmniBufWriter(8);
    w.writeTag(2, value ? ob.WireType.boolTrue : ob.WireType.boolFalse);
    setPatch(2, w.toBytes());
  }

  bool get has_explicitString => hasPatch(3)
      ? (getPatch(3)?.isNotEmpty ?? false)
      : ob.findLastFieldWithWireType(rawBytes, 3, ob.WireType.string) != null;
  void clear_explicitString() => setPatch(3, null);
  String get explicitString {
    if (hasPatch(3)) {
      final p = getPatch(3);
      if (p == null || p.isEmpty) return '';
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.string) {
        return '';
      }
      return r.readString();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 3, ob.WireType.string);
    if (hit == null) return '';
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readString();
  }

  set explicitString(String value) {
    final w = ob.OmniBufWriter(32);
    w.writeTag(3, ob.WireType.string);
    w.writeString(value);
    setPatch(3, w.toBytes());
  }

  bool get has_explicitBytes => hasPatch(4)
      ? (getPatch(4)?.isNotEmpty ?? false)
      : ob.findLastFieldWithWireType(rawBytes, 4, ob.WireType.bytes) != null;
  void clear_explicitBytes() => setPatch(4, null);
  Uint8List get explicitBytes {
    if (hasPatch(4)) {
      final p = getPatch(4);
      if (p == null || p.isEmpty) return Uint8List(0);
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.bytes) {
        return Uint8List(0);
      }
      return r.readBytes();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 4, ob.WireType.bytes);
    if (hit == null) return Uint8List(0);
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readBytes();
  }

  set explicitBytes(Uint8List value) {
    final w = ob.OmniBufWriter(32);
    w.writeTag(4, ob.WireType.bytes);
    w.writeBytes(value);
    setPatch(4, w.toBytes());
  }

  bool get has_explicitDouble => hasPatch(5)
      ? (getPatch(5)?.isNotEmpty ?? false)
      : ob.findLastFieldWithWireType(rawBytes, 5, ob.WireType.float64) != null;
  void clear_explicitDouble() => setPatch(5, null);
  double get explicitDouble {
    if (hasPatch(5)) {
      final p = getPatch(5);
      if (p == null || p.isEmpty) return 0.0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.float64) {
        return 0.0;
      }
      return r.readFloat64();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 5, ob.WireType.float64);
    if (hit == null) return 0.0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readFloat64();
  }

  set explicitDouble(double value) {
    final w = ob.OmniBufWriter(32);
    w.writeTag(5, ob.WireType.float64);
    w.writeFloat64(value);
    setPatch(5, w.toBytes());
  }

  bool get has_status => hasPatch(6)
      ? (getPatch(6)?.isNotEmpty ?? false)
      : ob.findLastFieldWithWireType(rawBytes, 6, ob.WireType.sint) != null;
  void clear_status() => setPatch(6, null);
  int get status {
    if (hasPatch(6)) {
      final p = getPatch(6);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.sint) {
        return 0;
      }
      return r.readSint32();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 6, ob.WireType.sint);
    if (hit == null) return 0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readSint32();
  }

  set status(int value) {
    final w = ob.OmniBufWriter(32);
    w.writeTag(6, ob.WireType.sint);
    w.writeSint32(value);
    setPatch(6, w.toBytes());
  }

  int get implicitCount {
    if (hasPatch(7)) {
      final p = getPatch(7);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.sint) {
        return 0;
      }
      return r.readSint32();
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 7, ob.WireType.sint);
    if (hit == null) return 0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readSint32();
  }

  set implicitCount(int value) {
    if (!(value != 0)) {
      setPatch(7, null);
      return;
    }
    final w = ob.OmniBufWriter(32);
    w.writeTag(7, ob.WireType.sint);
    w.writeSint32(value);
    setPatch(7, w.toBytes());
  }

  bool get implicitFlag {
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

  set implicitFlag(bool value) {
    if (!value) {
      setPatch(8, null);
      return;
    }
    final w = ob.OmniBufWriter(8);
    w.writeTag(8, value ? ob.WireType.boolTrue : ob.WireType.boolFalse);
    setPatch(8, w.toBytes());
  }

  OpaqueEditions2026Child? get childOpaque {
    if (hasPatch(9)) {
      final p = getPatch(9);
      if (p == null || p.isEmpty) return null;
      final r = ob.OmniBufReader(p);
      r.readTag();
      final len = r.readCheckedLength();
      return OpaqueEditions2026Child(
          Uint8List.sublistView(p, r.pos, r.pos + len));
    }
    final occs = ob.findAllFields(rawBytes, 9);
    if (occs.isEmpty) return null;
    if (occs.length == 1) {
      final (start, end, wt) = occs[0];
      if (wt != ob.WireType.subMsg) return null;
      final r = ob.OmniBufReader(rawBytes, start, end);
      final len = r.readCheckedLength();
      return OpaqueEditions2026Child(
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
    return found ? OpaqueEditions2026Child(w.toBytes()) : null;
  }

  Editions2026Child? get child {
    final op = childOpaque;
    if (op == null) return null;
    return Editions2026Child.decode(op.rawBytes);
  }

  set child(Editions2026Child? value) {
    if (value == null) {
      setPatch(9, null);
      return;
    }
    final est = value.estimateBodyBytes(1);
    final w = ob.OmniBufWriter(est + 8);
    w.writeTag(9, ob.WireType.subMsg);
    final slot = w.reserveLenAuto(est);
    value.encodeInto(w, depth: 1);
    w.patchLenAuto(slot);
    setPatch(9, w.toBytes());
  }

  void setChildOpaque(OpaqueEditions2026Child value) {
    final body = value.marshalAppend();
    final w = ob.OmniBufWriter(body.length + 8);
    w.writeTag(9, ob.WireType.subMsg);
    w.writeVarint(body.length);
    w.writeRawBytes(body);
    setPatch(9, w.toBytes());
  }

  OpaqueEditions2026Child? get delimitedChildOpaque {
    if (hasPatch(10)) {
      final p = getPatch(10);
      if (p == null || p.isEmpty) return null;
      final r = ob.OmniBufReader(p);
      r.readTag();
      final len = r.readCheckedLength();
      return OpaqueEditions2026Child(
          Uint8List.sublistView(p, r.pos, r.pos + len));
    }
    final occs = ob.findAllFields(rawBytes, 10);
    if (occs.isEmpty) return null;
    if (occs.length == 1) {
      final (start, end, wt) = occs[0];
      if (wt != ob.WireType.subMsg) return null;
      final r = ob.OmniBufReader(rawBytes, start, end);
      final len = r.readCheckedLength();
      return OpaqueEditions2026Child(
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
    return found ? OpaqueEditions2026Child(w.toBytes()) : null;
  }

  Editions2026Child? get delimitedChild {
    final op = delimitedChildOpaque;
    if (op == null) return null;
    return Editions2026Child.decode(op.rawBytes);
  }

  set delimitedChild(Editions2026Child? value) {
    if (value == null) {
      setPatch(10, null);
      return;
    }
    final est = value.estimateBodyBytes(1);
    final w = ob.OmniBufWriter(est + 8);
    w.writeTag(10, ob.WireType.subMsg);
    final slot = w.reserveLenAuto(est);
    value.encodeInto(w, depth: 1);
    w.patchLenAuto(slot);
    setPatch(10, w.toBytes());
  }

  void setDelimitedChildOpaque(OpaqueEditions2026Child value) {
    final body = value.marshalAppend();
    final w = ob.OmniBufWriter(body.length + 8);
    w.writeTag(10, ob.WireType.subMsg);
    w.writeVarint(body.length);
    w.writeRawBytes(body);
    setPatch(10, w.toBytes());
  }

  List<int> get packedVals {
    final out = <int>[];
    if (hasPatch(11)) {
      final p = getPatch(11);
      if (p == null || p.isEmpty) return out;
      return TestEditions2026.decode(p).packedVals;
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
      if (elemWt != ob.WireType.sint) {
        throw ob.OmniBufTypeMismatchException(
            'packed_vals WireArray ElementType mismatch');
      }
      for (var j = 0; j < count; j++) {
        out.add(body.readSint32());
      }
      if (body.pos != bodyEnd) {
        throw const ob.OmniBufParseException('WireArray trailing bytes');
      }
    }
    return out;
  }

  set packedVals(List<int> value) {
    if (value.isEmpty) {
      setPatch(11, null);
      return;
    }
    final w = ob.OmniBufWriter(64);
    w.writeTag(11, ob.WireType.array);
    final slot = w.reserveLen2();
    w.writeByte(ob.WireType.sint);
    w.writeVarint(value.length);
    for (var i = 0; i < value.length; i++) {
      w.writeSint32(value[i]);
    }
    w.patchLen2(slot);
    setPatch(11, w.toBytes());
  }

  List<int> get expandedVals {
    final out = <int>[];
    if (hasPatch(12)) {
      final p = getPatch(12);
      if (p == null || p.isEmpty) return out;
      return TestEditions2026.decode(p).expandedVals;
    }
    final budget =
        ob.DecodeBudget(ob.DecodeOptions.defaultMaxCollectionElements);
    final occs = ob.findAllFields(rawBytes, 12);
    for (var i = 0; i < occs.length; i++) {
      final (start, end, wt) = occs[i];
      if (wt != ob.WireType.array) continue;
      final r = ob.OmniBufReader(rawBytes, start, end);
      final len = r.readCheckedLength();
      final bodyEnd = r.pos + len;
      final body = r.subReader(r.pos, bodyEnd);
      final (elemWt, count) = body.readArrayHeader();
      budget.consume(count);
      if (elemWt != ob.WireType.sint) {
        throw ob.OmniBufTypeMismatchException(
            'expanded_vals WireArray ElementType mismatch');
      }
      for (var j = 0; j < count; j++) {
        out.add(body.readSint32());
      }
      if (body.pos != bodyEnd) {
        throw const ob.OmniBufParseException('WireArray trailing bytes');
      }
    }
    return out;
  }

  set expandedVals(List<int> value) {
    if (value.isEmpty) {
      setPatch(12, null);
      return;
    }
    final w = ob.OmniBufWriter(64);
    w.writeTag(12, ob.WireType.array);
    final slot = w.reserveLen2();
    w.writeByte(ob.WireType.sint);
    w.writeVarint(value.length);
    for (var i = 0; i < value.length; i++) {
      w.writeSint32(value[i]);
    }
    w.patchLen2(slot);
    setPatch(12, w.toBytes());
  }

  Map<String, int> get scores {
    final out = <String, int>{};
    if (hasPatch(13)) {
      final p = getPatch(13);
      if (p == null || p.isEmpty) return out;
      final tmp = TestEditions2026.decode(p);
      return tmp.scores;
    }
    final budget =
        ob.DecodeBudget(ob.DecodeOptions.defaultMaxCollectionElements);
    final occs = ob.findAllFields(rawBytes, 13);
    for (var i = 0; i < occs.length; i++) {
      final (start, end, wt) = occs[i];
      if (wt != ob.WireType.map) continue;
      final r = ob.OmniBufReader(rawBytes, start, end);
      final len = r.readCheckedLength();
      final bodyEnd = r.pos + len;
      final body = r.subReader(r.pos, bodyEnd);
      final (kWt, vWt, count) = body.readMapHeader();
      budget.consume(count);
      if (kWt != ob.WireType.string || vWt != ob.WireType.sint) {
        throw ob.OmniBufTypeMismatchException('scores WireMap header mismatch');
      }
      for (var j = 0; j < count; j++) {
        final k = body.readString();
        out[k] = body.readSint32();
      }
      if (body.pos != bodyEnd) {
        throw const ob.OmniBufParseException('WireMap trailing bytes');
      }
    }
    return out;
  }

  set scores(Map<String, int> value) {
    if (value.isEmpty) {
      setPatch(13, null);
      return;
    }
    final w = ob.OmniBufWriter(64);
    w.writeTag(13, ob.WireType.map);
    final slot = w.reserveLen2();
    w.writeByte(ob.WireType.string);
    w.writeByte(ob.WireType.sint);
    final keys = value.keys.toList();
    keys.sort(ob.compareUtf8);
    w.writeVarint(keys.length);
    for (var i = 0; i < keys.length; i++) {
      final k = keys[i];
      final v = value[k]!;
      w.writeString(k);
      w.writeSint32(v);
    }
    w.patchLen2(slot);
    setPatch(13, w.toBytes());
  }

  bool get has_choiceInt => which_choice == 14;
  void clear_choiceInt() {
    if (which_choice == 14) {
      clear_choice();
    }
  }

  int get choiceInt {
    if (hasPatch(14)) {
      final p = getPatch(14);
      if (p == null || p.isEmpty) return 0;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.sint) {
        return 0;
      }
      return r.readSint32();
    }
    if (which_choice != 14) {
      return 0;
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 14, ob.WireType.sint);
    if (hit == null) return 0;
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readSint32();
  }

  set choiceInt(int value) {
    clear_choice();
    final w = ob.OmniBufWriter(32);
    w.writeTag(14, ob.WireType.sint);
    w.writeSint32(value);
    setPatch(14, w.toBytes());
  }

  bool get has_choiceText => which_choice == 15;
  void clear_choiceText() {
    if (which_choice == 15) {
      clear_choice();
    }
  }

  String get choiceText {
    if (hasPatch(15)) {
      final p = getPatch(15);
      if (p == null || p.isEmpty) return '';
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      if (wt != ob.WireType.string) {
        return '';
      }
      return r.readString();
    }
    if (which_choice != 15) {
      return '';
    }
    final hit = ob.findLastFieldWithWireType(rawBytes, 15, ob.WireType.string);
    if (hit == null) return '';
    final (start, end, _) = hit;
    final r = ob.OmniBufReader(rawBytes, start, end);
    return r.readString();
  }

  set choiceText(String value) {
    clear_choice();
    final w = ob.OmniBufWriter(32);
    w.writeTag(15, ob.WireType.string);
    w.writeString(value);
    setPatch(15, w.toBytes());
  }

  bool get has_choiceFlag => which_choice == 16;
  void clear_choiceFlag() {
    if (which_choice == 16) {
      clear_choice();
    }
  }

  bool get choiceFlag {
    if (hasPatch(16)) {
      final p = getPatch(16);
      if (p == null || p.isEmpty) return false;
      final r = ob.OmniBufReader(p);
      final tag = r.readTag();
      final wt = tag & 0x0F;
      return wt == ob.WireType.boolTrue;
    }
    if (which_choice != 16) {
      return false;
    }
    final wt = ob.findLastBoolField(rawBytes, 16);
    return wt == ob.WireType.boolTrue;
  }

  set choiceFlag(bool value) {
    clear_choice();
    final w = ob.OmniBufWriter(8);
    w.writeTag(16, value ? ob.WireType.boolTrue : ob.WireType.boolFalse);
    setPatch(16, w.toBytes());
  }

  bool get has_choiceChild => which_choice == 17;
  void clear_choiceChild() {
    if (which_choice == 17) {
      clear_choice();
    }
  }

  OpaqueEditions2026Child? get choiceChildOpaque {
    if (hasPatch(17)) {
      final p = getPatch(17);
      if (p == null || p.isEmpty) return null;
      final r = ob.OmniBufReader(p);
      r.readTag();
      final len = r.readCheckedLength();
      return OpaqueEditions2026Child(
          Uint8List.sublistView(p, r.pos, r.pos + len));
    }
    if (which_choice != 17) {
      return null;
    }
    final occs = ob.findActiveOneofSubMsgFields(rawBytes, 17, _oneof_choice);
    if (occs.isEmpty) return null;
    if (occs.length == 1) {
      final (start, end) = occs[0];
      final r = ob.OmniBufReader(rawBytes, start, end);
      final len = r.readCheckedLength();
      return OpaqueEditions2026Child(
          Uint8List.sublistView(rawBytes, r.pos, r.pos + len));
    }
    final w = ob.OmniBufWriter(64);
    for (var i = 0; i < occs.length; i++) {
      final (start, end) = occs[i];
      final r = ob.OmniBufReader(rawBytes, start, end);
      final len = r.readCheckedLength();
      w.writeRawSlice(rawBytes, r.pos, r.pos + len);
    }
    return OpaqueEditions2026Child(w.toBytes());
  }

  Editions2026Child? get choiceChild {
    final op = choiceChildOpaque;
    if (op == null) return null;
    return Editions2026Child.decode(op.rawBytes);
  }

  set choiceChild(Editions2026Child? value) {
    if (value == null) {
      clear_choiceChild();
      return;
    }
    clear_choice();
    final est = value.estimateBodyBytes(1);
    final w = ob.OmniBufWriter(est + 8);
    w.writeTag(17, ob.WireType.subMsg);
    final slot = w.reserveLenAuto(est);
    value.encodeInto(w, depth: 1);
    w.patchLenAuto(slot);
    setPatch(17, w.toBytes());
  }

  void setChoiceChildOpaque(OpaqueEditions2026Child value) {
    clear_choice();
    final body = value.marshalAppend();
    final w = ob.OmniBufWriter(body.length + 8);
    w.writeTag(17, ob.WireType.subMsg);
    w.writeVarint(body.length);
    w.writeRawBytes(body);
    setPatch(17, w.toBytes());
  }
}
