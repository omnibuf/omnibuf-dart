import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart' show Int64;
import 'package:omnibuf/omnibuf.dart';
import 'package:omnibuf/src/codegen.dart';
import 'package:omnibuf/src/descriptor.dart';
import 'package:protobuf/protobuf.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Tier 2 ProtobufOmniBufCodec Editions audit fixtures
// ---------------------------------------------------------------------------

class _AuditStatus extends ProtobufEnum {
  static const _AuditStatus unspecified = _AuditStatus._(0, 'UNSPECIFIED');
  static const _AuditStatus ok = _AuditStatus._(1, 'OK');
  static const List<_AuditStatus> values = <_AuditStatus>[
    _AuditStatus.unspecified,
    _AuditStatus.ok,
  ];
  static final Map<int, _AuditStatus> _byValue =
      ProtobufEnum.initByValue(values);
  static _AuditStatus? valueOf(int value) => _byValue[value];
  const _AuditStatus._(super.v, super.n);
}

class _AuditChild extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo(
    'AuditChild',
    package: const PackageName('omnibuf.editions.audit'),
    createEmptyInstance: create,
  )
    ..aOS(1, 'label')
    ..a<int>(2, 'num', PbFieldType.O3)
    ..hasRequiredFields = false;

  _AuditChild() : super();
  static _AuditChild create() => _AuditChild();
  @override
  _AuditChild createEmptyInstance() => create();
  @override
  _AuditChild clone() => _AuditChild()..mergeFromMessage(this);
  @override
  BuilderInfo get info_ => _i;
}

class _AuditEditionsMsg extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo(
    'AuditEditionsMsg',
    package: const PackageName('omnibuf.editions.audit'),
    createEmptyInstance: create,
  )
    ..oo(0, <int>[10, 11, 12])
    ..a<int>(1, 'i32', PbFieldType.O3)
    ..a<double>(2, 'f64', PbFieldType.OD)
    ..aOB(3, 'flag')
    ..aOS(4, 'text')
    ..a<List<int>>(5, 'raw', PbFieldType.OY)
    ..e<_AuditStatus>(
      6,
      'status',
      PbFieldType.OE,
      defaultOrMaker: _AuditStatus.unspecified,
      valueOf: _AuditStatus.valueOf,
      enumValues: _AuditStatus.values,
    )
    ..a<_AuditChild>(
      7,
      'delimited_child',
      PbFieldType.OG,
      subBuilder: _AuditChild.create,
    )
    ..pc<_AuditChild>(
      8,
      'delimited_list',
      PbFieldType.PG,
      subBuilder: _AuditChild.create,
    )
    ..p<int>(9, 'expanded_nums', PbFieldType.P3)
    ..a<int>(10, 'choice_int', PbFieldType.O3)
    ..aOS(11, 'choice_str')
    ..aOM<_AuditChild>(12, 'choice_child', subBuilder: _AuditChild.create)
    ..p<int>(13, 'packed_nums', PbFieldType.K3)
    ..a<Int64>(14, 'i64', PbFieldType.O6, defaultOrMaker: Int64.ZERO)
    ..hasRequiredFields = false;

  _AuditEditionsMsg() : super();
  static _AuditEditionsMsg create() => _AuditEditionsMsg();
  @override
  _AuditEditionsMsg createEmptyInstance() => create();
  @override
  _AuditEditionsMsg clone() => _AuditEditionsMsg()..mergeFromMessage(this);
  @override
  BuilderInfo get info_ => _i;
}

// ---------------------------------------------------------------------------
// Helpers for invoking real protoc + plugin + dart analyze/run
// ---------------------------------------------------------------------------

String _repoRoot() => Directory.current.path;

String _createPluginWrapper(Directory tempDir) {
  final dartExe = Platform.resolvedExecutable;
  final pluginScript = '${_repoRoot()}/bin/protoc-gen-omnibuf-dart.dart';
  final wrapper = File('${tempDir.path}/protoc-gen-omnibuf-dart');
  wrapper.writeAsStringSync(
    '#!/bin/sh\nexec "$dartExe" "$pluginScript"\n',
  );
  Process.runSync('chmod', <String>['+x', wrapper.path]);
  return wrapper.path;
}

void _writeTempPackageConfig(Directory tempDir) {
  final srcFile = File('${_repoRoot()}/.dart_tool/package_config.json');
  final decoded =
      jsonDecode(srcFile.readAsStringSync()) as Map<String, Object?>;
  final packages =
      (decoded['packages']! as List<Object?>).cast<Map<String, Object?>>();
  final repoUri = Uri.directory(_repoRoot()).toString();
  for (final pkg in packages) {
    if (pkg['name'] == 'omnibuf') {
      pkg['rootUri'] = repoUri;
    }
  }
  final dstDir = Directory('${tempDir.path}/.dart_tool')
    ..createSync(recursive: true);
  File('${dstDir.path}/package_config.json')
      .writeAsStringSync(jsonEncode(decoded));
  File('${tempDir.path}/pubspec.yaml').writeAsStringSync('''
name: editions_e2e_harness
environment:
  sdk: '>=3.4.0 <4.0.0'
dependencies:
  omnibuf:
    path: '${_repoRoot()}'
''');
  File('${tempDir.path}/analysis_options.yaml').writeAsStringSync(
    File('${_repoRoot()}/analysis_options.yaml').readAsStringSync(),
  );
}

ProcessResult _runProtocPlugin({
  required Directory protoDir,
  required Directory outDir,
  required String pluginPath,
  required List<String> protoFiles,
}) {
  return Process.runSync(
    'protoc',
    <String>[
      '-I${protoDir.path}',
      '--plugin=protoc-gen-omnibuf-dart=$pluginPath',
      '--omnibuf-dart_out=${outDir.path}',
      ...protoFiles,
    ],
  );
}

Map<int, int> _decodeResponseHeaderFields(Uint8List encoded) {
  final out = <int, int>{};
  var pos = 0;
  int readVarint() {
    var result = 0;
    var shift = 0;
    while (pos < encoded.length) {
      final b = encoded[pos++];
      result |= (b & 0x7F) << shift;
      if ((b & 0x80) == 0) return result;
      shift += 7;
    }
    throw StateError('truncated varint');
  }

  while (pos < encoded.length) {
    final tag = readVarint();
    final fnum = tag >> 3;
    final wt = tag & 7;
    if (wt == 0) {
      out[fnum] = readVarint();
    } else if (wt == 2) {
      final len = readVarint();
      pos += len;
    } else {
      throw StateError('unexpected wire type $wt');
    }
  }
  return out;
}

void main() {
  group('Editions Descriptor & Response Negotiation', () {
    test('CodeGeneratorResponse advertises Editions 2023..2026', () {
      final resp = CodeGeneratorResponse();
      expect(resp.supportedFeatures, 3);
      expect(resp.minimumEdition, ProtoEdition.edition2023);
      expect(resp.maximumEdition, ProtoEdition.edition2026);

      final fields = _decodeResponseHeaderFields(resp.encode());
      expect(fields[2], 3); // PROTO3_OPTIONAL | SUPPORTS_EDITIONS
      expect(fields[3], 1000); // EDITION_2023
      expect(fields[4], 1002); // EDITION_2026
    });

    test('rejects unsupported editions cleanly without throwing', () {
      for (final badEdition in <int>[0, 998, 999, 1003, 9999]) {
        final fd = ProtoFileDescriptor()
          ..name = 'bad_$badEdition.proto'
          ..syntax = 'editions'
          ..edition = badEdition;
        final req = CodeGeneratorRequest()
          ..fileToGenerate.add(fd.name)
          ..protoFiles.add(fd);

        final resp = generateOmniBufDart(req);
        expect(resp.error, contains('unsupported protobuf edition'));
        expect(resp.error, contains('$badEdition'));
        expect(resp.files, isEmpty);
      }
    });

    test(
        'resolveEditions is idempotent and preserves syntax, edition, and type',
        () {
      final fd = ProtoFileDescriptor()
        ..name = 'idem.proto'
        ..packageName = 'demo'
        ..syntax = 'editions'
        ..edition = ProtoEdition.edition2026;
      final child = ProtoMessageDescriptor()..name = 'Child';
      final parent = ProtoMessageDescriptor()..name = 'Parent';
      parent.fields.addAll(<ProtoFieldDescriptor>[
        ProtoFieldDescriptor()
          ..name = 'count'
          ..number = 1
          ..label = 1
          ..type = 5,
        ProtoFieldDescriptor()
          ..name = 'delimited_child'
          ..number = 2
          ..label = 1
          ..type = 10 // TYPE_GROUP for Editions DELIMITED
          ..typeName = '.demo.Child',
      ]);
      fd.messages.addAll(<ProtoMessageDescriptor>[child, parent]);

      resolveEditions(fd);
      resolveEditions(fd); // Second call must not fail or lose edition info.

      expect(fd.syntax, 'editions');
      expect(fd.edition, ProtoEdition.edition2026);
      expect(parent.fields[0].explicitPresence, isTrue);
      expect(parent.fields[1].type, 10);
      expect(parent.fields[1].isDelimitedMessage, isTrue);
      expect(parent.fields[1].explicitPresence, isFalse);
    });

    test(
        'inherits features across file -> message -> nested message -> oneof -> field and file -> message -> enum',
        () {
      // File sets IMPLICIT; Outer overrides EXPLICIT; Inner inherits EXPLICIT;
      // field overrides IMPLICIT.
      final fd = ProtoFileDescriptor()
        ..name = 'inherit.proto'
        ..packageName = 'demo'
        ..syntax = 'editions'
        ..edition = ProtoEdition.edition2024
        ..features = <int, int>{
          ProtoFeature.fieldPresence: ProtoFeature.fieldPresenceImplicit,
        };

      final inner = ProtoMessageDescriptor()..name = 'Inner';
      inner.fields.addAll(<ProtoFieldDescriptor>[
        ProtoFieldDescriptor()
          ..name = 'inherited_explicit'
          ..number = 1
          ..label = 1
          ..type = 5,
        ProtoFieldDescriptor()
          ..name = 'overridden_implicit'
          ..number = 2
          ..label = 1
          ..type = 5
          ..features = <int, int>{
            ProtoFeature.fieldPresence: ProtoFeature.fieldPresenceImplicit,
          },
      ]);

      final outer = ProtoMessageDescriptor()
        ..name = 'Outer'
        ..features = <int, int>{
          ProtoFeature.fieldPresence: ProtoFeature.fieldPresenceExplicit,
        };
      outer.nestedTypes.add(inner);
      outer.fields.add(
        ProtoFieldDescriptor()
          ..name = 'outer_explicit'
          ..number = 1
          ..label = 1
          ..type = 5,
      );
      fd.messages.add(outer);

      resolveEditions(fd);
      expect(outer.fields[0].explicitPresence, isTrue);
      expect(inner.fields[0].explicitPresence, isTrue);
      expect(inner.fields[1].explicitPresence, isFalse);

      // Oneof feature inheritance: OneofOptions sets utf8_validation = NONE -> rejected.
      final oneofBad = ProtoFileDescriptor()
        ..name = 'oneof_inherit.proto'
        ..packageName = 'demo'
        ..syntax = 'editions'
        ..edition = ProtoEdition.edition2023;
      final om = ProtoMessageDescriptor()..name = 'OneofMsg';
      om.oneofs.add(
        ProtoOneofDescriptor()
          ..name = 'choice'
          ..features = <int, int>{
            ProtoFeature.utf8Validation: ProtoFeature.utf8ValidationNone,
          },
      );
      om.fields.add(
        ProtoFieldDescriptor()
          ..name = 'raw_str'
          ..number = 1
          ..label = 1
          ..type = 9
          ..oneofIndex = 0,
      );
      oneofBad.messages.add(om);
      final resp1 = generateOmniBufDart(
        CodeGeneratorRequest()
          ..fileToGenerate.add(oneofBad.name)
          ..protoFiles.add(oneofBad),
      );
      expect(resp1.error, contains('UTF-8 NONE'));

      // Message -> Enum inheritance: message sets enum_type = CLOSED -> nested enum rejected.
      final enumBad = ProtoFileDescriptor()
        ..name = 'msg_enum_inherit.proto'
        ..packageName = 'demo'
        ..syntax = 'editions'
        ..edition = ProtoEdition.edition2023;
      final em = ProtoMessageDescriptor()
        ..name = 'Holder'
        ..features = <int, int>{
          ProtoFeature.enumType: ProtoFeature.enumTypeClosed,
        };
      em.enumTypes.add(
        ProtoEnumDescriptor()
          ..name = 'NestedClosed'
          ..values.add(('ZERO', 0)),
      );
      enumBad.messages.add(em);
      final resp2 = generateOmniBufDart(
        CodeGeneratorRequest()
          ..fileToGenerate.add(enumBad.name)
          ..protoFiles.add(enumBad),
      );
      expect(resp2.error, contains('CLOSED enums'));
    });
  });

  group('Real E2E protoc 36.2 + Plugin + Analyze + Execute (2023/2024/2026)',
      () {
    late Directory tempDir;
    late Directory protoDir;
    late Directory genDir;
    late String pluginPath;

    setUpAll(() {
      tempDir = Directory.systemTemp.createTempSync('omnibuf_dart_editions_');
      protoDir = Directory('${tempDir.path}/proto')..createSync();
      genDir = Directory('${tempDir.path}/lib/gen')
        ..createSync(recursive: true);
      pluginPath = _createPluginWrapper(tempDir);
      _writeTempPackageConfig(tempDir);
    });

    tearDownAll(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('generates, analyzes, and executes Editions 2023, 2024, and 2026 code',
        () {
      File('${protoDir.path}/editions_2023.proto').writeAsStringSync(r'''
edition = "2023";
package test.e2023;

import "google/protobuf/descriptor.proto";

extend google.protobuf.MessageOptions {
  string custom_note = 50001;
}

enum Status {
  STATUS_UNSPECIFIED = 0;
  STATUS_ACTIVE = 1;
  STATUS_PAUSED = 2;
}

message Child {
  option features.json_format = LEGACY_BEST_EFFORT;
  string label = 1;
  int32 weight = 2;
}

message AllEditions2023 {
  option (custom_note) = "allowed option extension";

  int32 i32 = 1 [default = 0];
  int64 i64 = 2;
  uint32 u32 = 3;
  double f64 = 4 [default = 0.0];
  bool flag = 5 [default = false];
  string text = 6 [default = ""];
  bytes raw = 7 [default = ""];
  Status status = 8 [default = STATUS_UNSPECIFIED];

  int32 implicit_num = 9 [features.field_presence = IMPLICIT];

  repeated int32 packed_nums = 10 [features.repeated_field_encoding = PACKED];
  repeated int32 expanded_nums = 11 [features.repeated_field_encoding = EXPANDED];
  repeated Child children = 12;

  map<string, int32> scores = 13;
  map<string, Child> child_map = 14;

  Child length_child = 15 [features.message_encoding = LENGTH_PREFIXED];
  Child delimited_child = 16 [features.message_encoding = DELIMITED];
  repeated Child delimited_children = 17 [features.message_encoding = DELIMITED];

  oneof choice {
    int32 choice_int = 18;
    bool choice_bool = 19;
    string choice_str = 20;
    bytes choice_bytes = 21;
    Child choice_child = 22;
    Child choice_delimited = 23 [features.message_encoding = DELIMITED];
  }
}
''');

      File('${protoDir.path}/editions_2024.proto').writeAsStringSync(r'''
edition = "2024";
package test.e2024;

option features.field_presence = IMPLICIT;
option features.enforce_naming_style = STYLE2024;
option features.default_symbol_visibility = EXPORT_TOP_LEVEL;

message ImplicitContainer {
  int32 implicit_a = 1;
  int32 explicit_b = 2 [features.field_presence = EXPLICIT];
  oneof u {
    int32 u_zero = 3;
    string u_empty = 4;
  }
}

message NestedContainer {
  option features.json_format = LEGACY_BEST_EFFORT;

  message Inner {
    int32 inherited_implicit = 1;
    int32 overridden_explicit = 2 [features.field_presence = EXPLICIT];
  }

  int32 explicit_c = 1 [features.field_presence = EXPLICIT];
  int32 implicit_d = 2;
  Inner inner = 3;
}
''');

      File('${protoDir.path}/editions_2026.proto').writeAsStringSync(r'''
edition = "2026";
package test.e2026;

option features.default_symbol_visibility = STRICT;
option features.enforce_naming_style = STYLE2026;

export enum Kind {
  KIND_UNSPECIFIED = 0;
  KIND_ALPHA = 1;
}

export message Item {
  option features.enforce_proto_limits = PROTO_LIMITS2026;
  string name = 1;
  int32 count = 2;
}

export message Envelope {
  option features.enforce_proto_limits = PROTO_LIMITS2026;
  int32 code = 1;
  Kind kind = 2;
  Item delimited_item = 3 [features.message_encoding = DELIMITED];
  repeated Item delimited_items = 4 [features.message_encoding = DELIMITED];
  oneof body {
    option features.enforce_proto_limits = PROTO_LIMITS2026;
    int32 num = 5;
    bool ok = 6;
    Item item = 7;
  }
}
''');

      final protocRes = _runProtocPlugin(
        protoDir: protoDir,
        outDir: genDir,
        pluginPath: pluginPath,
        protoFiles: <String>[
          'editions_2023.proto',
          'editions_2024.proto',
          'editions_2026.proto',
        ],
      );
      expect(
        protocRes.exitCode,
        0,
        reason:
            'protoc failed:\nstdout: ${protocRes.stdout}\nstderr: ${protocRes.stderr}',
      );

      expect(File('${genDir.path}/editions_2023.omnibuf.dart').existsSync(),
          isTrue);
      expect(File('${genDir.path}/editions_2024.omnibuf.dart').existsSync(),
          isTrue);
      expect(File('${genDir.path}/editions_2026.omnibuf.dart').existsSync(),
          isTrue);

      // Write an executable Dart harness exercising all generated classes.
      final harness = File('${tempDir.path}/verify_editions.dart');
      harness.writeAsStringSync(r'''
import 'dart:typed_data';

import 'package:omnibuf/omnibuf.dart' as ob;

import 'lib/gen/editions_2023.omnibuf.dart' as e23;
import 'lib/gen/editions_2024.omnibuf.dart' as e24;
import 'lib/gen/editions_2026.omnibuf.dart' as e26;

void check(bool cond, String msg) {
  if (!cond) throw StateError('FAIL: $msg');
}

void main() {
  // 1. Editions 2023: absent vs explicit zero/false/empty/enum(0)
  final absent = e23.AllEditions2023();
  check(absent.encode().isEmpty, 'absent message must encode to empty bytes');
  check(!absent.has_i32 && !absent.has_f64 && !absent.has_flag, 'absent flags');
  check(!absent.has_text && !absent.has_raw && !absent.has_status, 'absent fields');
  check(absent.which_choice == 0, 'absent oneof must be 0');

  final zeroPresent = e23.AllEditions2023(
    i32: 0,
    i64: 0,
    u32: 0,
    f64: 0.0,
    flag: false,
    text: '',
    raw: Uint8List(0),
    status: e23.Status.STATUS_UNSPECIFIED,
    implicitNum: 0,
  );
  check(zeroPresent.has_i32 && zeroPresent.i32 == 0, 'explicit zero i32');
  check(zeroPresent.has_f64 && zeroPresent.f64 == 0.0, 'explicit zero f64');
  check(zeroPresent.has_flag && !zeroPresent.flag, 'explicit false flag');
  check(zeroPresent.has_text && zeroPresent.text.isEmpty, 'explicit empty text');
  check(zeroPresent.has_raw && zeroPresent.raw.isEmpty, 'explicit empty raw');
  check(zeroPresent.has_status && zeroPresent.status == 0, 'explicit enum 0');
  check(absent != zeroPresent, 'absent must not equal present-zero');

  // Verify individual field equality distinguishes absent vs present-zero.
  check(e23.AllEditions2023() != e23.AllEditions2023(i32: 0), 'eq i32');
  check(e23.AllEditions2023() != e23.AllEditions2023(f64: 0.0), 'eq f64');
  check(e23.AllEditions2023() != e23.AllEditions2023(flag: false), 'eq flag');
  check(e23.AllEditions2023() != e23.AllEditions2023(text: ''), 'eq text');
  check(
    e23.AllEditions2023() != e23.AllEditions2023(raw: Uint8List(0)),
    'eq raw',
  );
  check(e23.AllEditions2023() != e23.AllEditions2023(status: 0), 'eq status');

  final zeroWire = zeroPresent.encode();
  check(zeroWire.isNotEmpty, 'present-zero wire bytes must be non-empty');
  // Verify flag=false encoded using WireType.boolFalse (field 5).
  check(
    ob.findLastBoolField(zeroWire, 5) == ob.WireType.boolFalse,
    'flag=false must encode with WireType.boolFalse',
  );
  // Implicit field 9 with value 0 must be omitted on wire.
  check(
    ob.findLastField(zeroWire, 9) == null,
    'implicit field with value 0 must be omitted on wire',
  );

  final decodedZero = e23.AllEditions2023.decode(zeroWire);
  check(decodedZero == zeroPresent, 'round-trip present-zero equality');
  check(decodedZero.hashCode == zeroPresent.hashCode, 'round-trip hashCode');
  check(decodedZero.has_i32 && decodedZero.has_flag && !decodedZero.flag, 'decoded has_flag');
  check(decodedZero.has_text && decodedZero.has_raw && decodedZero.has_status, 'decoded has_*');

  decodedZero.clear_i32();
  check(!decodedZero.has_i32 && decodedZero != zeroPresent, 'clear_i32');
  decodedZero.reset();
  check(decodedZero == absent, 'reset restores absent equality');

  // 2. Open enum unknown value, repeated PACKED/EXPANDED, maps, DELIMITED
  final full = e23.AllEditions2023(
    i32: -42,
    status: 999, // unknown open enum value preserved
    implicitNum: 7,
    packedNums: <int>[1, -2, 3],
    expandedNums: <int>[10, 20],
    children: <e23.Child>[e23.Child(label: 'c1', weight: 1)],
    scores: <String, int>{'a': 1, 'b': -2},
    childMap: <String, e23.Child>{'k': e23.Child(label: 'mk', weight: 5)},
    lengthChild: e23.Child(label: 'len', weight: 11),
    delimitedChild: e23.Child(label: 'del', weight: 22),
    delimitedChildren: <e23.Child>[
      e23.Child(label: 'd0', weight: 0),
      e23.Child(label: 'd1', weight: 1),
    ],
  );
  final fullWire = full.encode();
  final fullDecoded = e23.AllEditions2023.decode(fullWire);
  check(fullDecoded == full, 'full 2023 round-trip equality');
  check(fullDecoded.status == 999, 'open enum unknown integer preserved');
  check(fullDecoded.packedNums.length == 3, 'packedNums');
  check(fullDecoded.expandedNums.length == 2, 'expandedNums');
  check(fullDecoded.delimitedChild?.label == 'del', 'delimited child');
  check(fullDecoded.delimitedChildren.length == 2, 'delimited children');
  check(fullDecoded.delimitedChildren[0].has_weight, 'delimited child explicit 0');
  check(fullDecoded.childMap['k']?.weight == 5, 'childMap');

  // Verify Opaque reads absent, present-zero, unknown enum, DELIMITED, maps
  final opAbsent = e23.OpaqueAllEditions2023(Uint8List(0));
  check(!opAbsent.has_i32 && !opAbsent.has_flag && !opAbsent.has_text, 'opAbsent');
  final opZero = e23.OpaqueAllEditions2023(zeroWire);
  check(opZero.has_i32 && opZero.i32 == 0, 'opZero i32');
  check(opZero.has_f64 && opZero.f64 == 0.0, 'opZero f64');
  check(opZero.has_flag && !opZero.flag, 'opZero flag');
  check(opZero.has_text && opZero.text.isEmpty, 'opZero text');
  check(opZero.has_raw && opZero.raw.isEmpty, 'opZero raw');
  check(opZero.has_status && opZero.status == 0, 'opZero status');

  // Opaque has_* must ignore mismatched wire types on the wire!
  final badWtWriter = ob.OmniBufWriter();
  badWtWriter.writeTag(1, ob.WireType.string); // field 1 expects sint, not string
  badWtWriter.writeString('wrong');
  badWtWriter.writeTag(5, ob.WireType.uint); // field 5 expects bool, not uint
  badWtWriter.writeVarint(1);
  final opBadWt = e23.OpaqueAllEditions2023(badWtWriter.toBytes());
  check(!opBadWt.has_i32 && opBadWt.i32 == 0, 'mismatched wt has_i32 false');
  check(!opBadWt.has_flag && !opBadWt.flag, 'mismatched wt has_flag false');

  // Opaque mutations: set explicit zero/false/empty and clear_*
  opAbsent.i32 = 0;
  opAbsent.flag = false;
  opAbsent.text = '';
  opAbsent.raw = Uint8List(0);
  check(opAbsent.has_i32 && opAbsent.has_flag && opAbsent.has_text && opAbsent.has_raw, 'op set zero');
  final splicedZero = opAbsent.marshalAppend();
  final decSplicedZero = e23.AllEditions2023.decode(splicedZero);
  check(decSplicedZero.has_i32 && decSplicedZero.i32 == 0, 'spliced i32 0');
  check(decSplicedZero.has_flag && !decSplicedZero.flag, 'spliced flag false');
  check(decSplicedZero.has_text && decSplicedZero.text.isEmpty, 'spliced text empty');
  check(decSplicedZero.has_raw && decSplicedZero.raw.isEmpty, 'spliced raw empty');

  opZero.clear_flag();
  opZero.clear_i32();
  check(!opZero.has_flag && !opZero.has_i32, 'op clear_*');
  final clearedDec = e23.AllEditions2023.decode(opZero.marshalAppend());
  check(!clearedDec.has_flag && !clearedDec.has_i32 && clearedDec.has_text, 'spliced clear_*');

  final opFull = e23.OpaqueAllEditions2023(fullWire);
  check(opFull.status == 999, 'op open enum 999');
  check(opFull.delimitedChildOpaque?.label == 'del', 'op delimitedChildOpaque');
  check(opFull.delimitedChildren.length == 2, 'op delimitedChildren');

  // 3. Oneof: Eager & Opaque (including zero/false/empty, message, DELIMITED)
  final oneofMsg = e23.AllEditions2023();
  oneofMsg.choiceInt = 0;
  check(oneofMsg.which_choice == 18 && oneofMsg.has_choiceInt && oneofMsg.choiceInt == 0, 'oneof zero');
  check(oneofMsg != e23.AllEditions2023(), 'oneof unset != active zero');
  final oneofZeroRoundTrip = e23.AllEditions2023.decode(oneofMsg.encode());
  check(oneofZeroRoundTrip == oneofMsg && oneofZeroRoundTrip.which_choice == 18, 'oneof zero roundtrip');

  oneofMsg.choiceBool = false;
  check(oneofMsg.which_choice == 19 && !oneofMsg.has_choiceInt && oneofMsg.has_choiceBool && !oneofMsg.choiceBool, 'switch to false');
  check(e23.AllEditions2023.decode(oneofMsg.encode()) == oneofMsg, 'oneof false roundtrip');

  oneofMsg.choiceStr = '';
  check(oneofMsg.which_choice == 20 && !oneofMsg.has_choiceBool && oneofMsg.has_choiceStr, 'switch to empty str');
  check(e23.AllEditions2023.decode(oneofMsg.encode()) == oneofMsg, 'oneof empty str roundtrip');

  oneofMsg.choiceBytes = Uint8List(0);
  check(oneofMsg.which_choice == 21 && !oneofMsg.has_choiceStr && oneofMsg.has_choiceBytes, 'switch to empty bytes');
  check(e23.AllEditions2023.decode(oneofMsg.encode()) == oneofMsg, 'oneof empty bytes roundtrip');

  oneofMsg.choiceChild = e23.Child(label: 'in-oneof');
  check(oneofMsg.which_choice == 22 && !oneofMsg.has_choiceBytes && oneofMsg.has_choiceChild, 'switch to child');
  check(e23.AllEditions2023.decode(oneofMsg.encode()) == oneofMsg, 'oneof child roundtrip');

  oneofMsg.choiceDelimited = e23.Child(label: 'del-oneof', weight: 3);
  check(oneofMsg.which_choice == 23 && !oneofMsg.has_choiceChild && oneofMsg.choiceChild == null && oneofMsg.has_choiceDelimited, 'switch to delimited child');
  check(e23.AllEditions2023.decode(oneofMsg.encode()) == oneofMsg, 'oneof delimited roundtrip');

  // Clearing inactive branch is a no-op; clearing active branch resets to 0.
  oneofMsg.clear_choiceInt();
  check(oneofMsg.which_choice == 23 && oneofMsg.has_choiceDelimited, 'clear inactive no-op');
  oneofMsg.clear_choiceDelimited();
  check(oneofMsg.which_choice == 0 && !oneofMsg.has_choiceDelimited && oneofMsg.choiceDelimited == null, 'clear active');

  // Multi-sibling wire bytes: last sibling wins, submsg does NOT merge across intervening sibling.
  final multiW = ob.OmniBufWriter();
  // choiceChild (22) with label='stale', weight=99
  final staleChild = e23.Child(label: 'stale', weight: 99).encode();
  multiW.writeTag(22, ob.WireType.subMsg);
  multiW.writeVarint(staleChild.length);
  multiW.writeRawBytes(staleChild);
  // choiceInt (18) = 77
  multiW.writeTag(18, ob.WireType.sint);
  multiW.writeSint32(77);
  // choiceChild (22) with only label='fresh' (weight absent!)
  final freshChild = e23.Child(label: 'fresh').encode();
  multiW.writeTag(22, ob.WireType.subMsg);
  multiW.writeVarint(freshChild.length);
  multiW.writeRawBytes(freshChild);
  final multiWire = multiW.toBytes();

  final multiEager = e23.AllEditions2023.decode(multiWire);
  check(multiEager.which_choice == 22, 'multi eager last wins');
  check(!multiEager.has_choiceInt && multiEager.choiceInt == 0, 'multi eager cleared int');
  check(multiEager.choiceChild?.label == 'fresh' && !(multiEager.choiceChild?.has_weight ?? true), 'multi eager fresh child');

  final multiOp = e23.OpaqueAllEditions2023(multiWire);
  check(multiOp.which_choice == 22 && multiOp.has_choiceChild && !multiOp.has_choiceInt, 'multi op which');
  check(multiOp.choiceInt == 0, 'multi op superseded int returns default');
  check(multiOp.choiceChild?.label == 'fresh' && !(multiOp.choiceChild?.has_weight ?? true), 'multi op fresh child');

  // Opaque oneof clear inactive no-op, clear active strips ALL siblings (no resurrection!)
  multiOp.clear_choiceInt();
  check(multiOp.which_choice == 22, 'op clear inactive no-op');
  multiOp.clear_choiceChild();
  check(multiOp.which_choice == 0 && !multiOp.has_choiceChild && !multiOp.has_choiceInt, 'op clear active no resurrection');
  check(multiOp.marshalAppend().isEmpty, 'op clear active strips all siblings');

  // Opaque oneof branch switch strips previous siblings on splice
  final switchOp = e23.OpaqueAllEditions2023(multiWire);
  switchOp.choiceBool = false;
  check(switchOp.which_choice == 19 && switchOp.has_choiceBool && !switchOp.choiceBool, 'op switch to bool false');
  check(!switchOp.has_choiceChild && switchOp.choiceChild == null, 'op switch clears child');
  final switchedWire = switchOp.marshalAppend();
  final switchedDec = e23.AllEditions2023.decode(switchedWire);
  check(switchedDec.which_choice == 19 && switchedDec.has_choiceBool && !switchedDec.choiceBool && !switchedDec.has_choiceChild, 'op switch spliced roundtrip');

  // 4. Editions 2024: file IMPLICIT + field EXPLICIT overrides + oneof always explicit
  final imp = e24.ImplicitContainer(implicitA: 0, explicitB: 0, uZero: 0);
  final impWire = imp.encode();
  check(ob.findLastField(impWire, 1) == null, '2024 file IMPLICIT omits 0');
  check(ob.findLastField(impWire, 2) != null, '2024 field EXPLICIT encodes 0');
  check(ob.findLastField(impWire, 3) != null, '2024 oneof encodes 0 even in IMPLICIT file');
  final impDec = e24.ImplicitContainer.decode(impWire);
  check(impDec.has_explicitB && impDec.explicitB == 0, '2024 explicitB roundtrip');
  check(impDec.which_u == 3 && impDec.has_uZero && impDec.uZero == 0, '2024 oneof roundtrip');

  final nestedCont = e24.NestedContainer(
    explicitC: 0,
    implicitD: 0,
    inner: e24.NestedContainer_Inner(inheritedImplicit: 0, overriddenExplicit: 0),
  );
  final nestedContWire = nestedCont.encode();
  check(ob.findLastField(nestedContWire, 1) != null, '2024 field EXPLICIT encodes 0');
  check(ob.findLastField(nestedContWire, 2) == null, '2024 file IMPLICIT omits 0');
  final nestedContDec = e24.NestedContainer.decode(nestedContWire);
  check(nestedContDec.has_explicitC && nestedContDec.explicitC == 0, '2024 explicitC');
  check(nestedContDec.inner!.has_overriddenExplicit && nestedContDec.inner!.overriddenExplicit == 0, '2024 nested field EXPLICIT');
  final innerWire = nestedCont.inner!.encode();
  check(ob.findLastField(innerWire, 1) == null, '2024 inner field 1 IMPLICIT');
  check(ob.findLastField(innerWire, 2) != null, '2024 inner field 2 EXPLICIT');

  // 5. Editions 2026: STRICT visibility, STYLE2026, PROTO_LIMITS2026, DELIMITED, open enum, oneof
  final env = e26.Envelope(
    code: 0,
    kind: 555,
    delimitedItem: e26.Item(name: 'root', count: 0),
    delimitedItems: <e26.Item>[e26.Item(name: 'a', count: 1)],
    ok: false,
  );
  final envWire = env.encode();
  final envDec = e26.Envelope.decode(envWire);
  check(envDec == env, '2026 Envelope round-trip');
  check(envDec.has_code && envDec.code == 0, '2026 explicit code 0');
  check(envDec.has_kind && envDec.kind == 555, '2026 open enum 555');
  check(envDec.delimitedItem!.has_count && envDec.delimitedItem!.count == 0, '2026 delimited child explicit 0');
  check(envDec.which_body == 6 && envDec.has_ok && !envDec.ok, '2026 oneof bool false');

  final opEnv = e26.OpaqueEnvelope(envWire);
  check(opEnv.has_code && opEnv.code == 0, '2026 op code');
  check(opEnv.kind == 555, '2026 op kind');
  check(opEnv.delimitedItemOpaque?.name == 'root', '2026 op delimitedItemOpaque');
  check(opEnv.which_body == 6 && opEnv.has_ok && !opEnv.ok, '2026 op oneof');
  opEnv.setItemOpaque(e26.OpaqueItem(e26.Item(name: 'patched', count: 9).encode()));
  check(opEnv.which_body == 7 && opEnv.has_item && !opEnv.has_ok, '2026 op setItemOpaque');
  final envPatched = e26.Envelope.decode(opEnv.marshalAppend());
  check(envPatched.which_body == 7 && envPatched.item?.name == 'patched' && !envPatched.has_ok, '2026 op spliced');

  print('ALL_EDITIONS_E2E_PASSED');
}
''');

      // Run dart analyze --fatal-infos on the generated code + harness!
      final analyzeRes = Process.runSync(
        Platform.resolvedExecutable,
        <String>['analyze', '--fatal-infos', tempDir.path],
      );
      expect(
        analyzeRes.exitCode,
        0,
        reason:
            'dart analyze failed:\n${analyzeRes.stdout}\n${analyzeRes.stderr}',
      );

      // Execute the compiled Dart verification harness!
      final runRes = Process.runSync(
        Platform.resolvedExecutable,
        <String>['run', harness.path],
        workingDirectory: tempDir.path,
      );
      expect(
        runRes.exitCode,
        0,
        reason:
            'harness failed:\nstdout: ${runRes.stdout}\nstderr: ${runRes.stderr}',
      );
      expect(runRes.stdout as String, contains('ALL_EDITIONS_E2E_PASSED'));
    });

    test(
        'protoc plugin cleanly rejects all forbidden Editions and proto2 features',
        () {
      void expectRejected(
        String name,
        Map<String, String> files,
        String targetFile,
        String expectedErrSubstr,
      ) {
        final caseDir = Directory('${tempDir.path}/neg_$name')..createSync();
        final outDir = Directory('${caseDir.path}/out')..createSync();
        for (final entry in files.entries) {
          File('${caseDir.path}/${entry.key}').writeAsStringSync(entry.value);
        }
        final res = _runProtocPlugin(
          protoDir: caseDir,
          outDir: outDir,
          pluginPath: pluginPath,
          protoFiles: <String>[targetFile],
        );
        expect(
          res.exitCode,
          isNot(0),
          reason: 'Case "$name" should have been rejected by plugin',
        );
        expect(
          res.stderr as String,
          contains(expectedErrSubstr),
          reason: 'Case "$name" stderr was:\n${res.stderr}',
        );
      }

      // 1. Enum-level CLOSED
      expectRejected(
        'closed_enum',
        <String, String>{
          'a.proto': '''
edition = "2023";
package neg.closed;
enum ClosedE {
  option features.enum_type = CLOSED;
  CLOSED_E_UNSPECIFIED = 0;
}
message M { ClosedE e = 1; }
''',
        },
        'a.proto',
        'CLOSED enums',
      );

      // 2. File-level CLOSED inherited by enum
      expectRejected(
        'file_closed_enum',
        <String, String>{
          'a.proto': '''
edition = "2023";
package neg.fclosed;
option features.enum_type = CLOSED;
enum InheritedClosed {
  INHERITED_CLOSED_UNSPECIFIED = 0;
}
''',
        },
        'a.proto',
        'CLOSED enums',
      );

      // 3. Cross-file CLOSED enum from proto2 dependency (singular)
      expectRejected(
        'cross_file_closed_singular',
        <String, String>{
          'legacy.proto': '''
syntax = "proto2";
package legacy;
enum LegacyClosed {
  LEGACY_CLOSED_ZERO = 0;
}
''',
          'app.proto': '''
edition = "2024";
package neg.cross;
import "legacy.proto";
message App {
  legacy.LegacyClosed status = 1;
}
''',
        },
        'app.proto',
        'CLOSED enums',
      );

      // 4. Cross-file CLOSED enum in map value
      expectRejected(
        'cross_file_closed_map',
        <String, String>{
          'legacy.proto': '''
syntax = "proto2";
package legacy;
enum LegacyClosed {
  LEGACY_CLOSED_ZERO = 0;
}
''',
          'app.proto': '''
edition = "2023";
package neg.crossmap;
import "legacy.proto";
message App {
  map<string, legacy.LegacyClosed> statuses = 1;
}
''',
        },
        'app.proto',
        'CLOSED enums',
      );

      // 5. LEGACY_REQUIRED
      expectRejected(
        'legacy_required',
        <String, String>{
          'a.proto': '''
edition = "2023";
package neg.req;
message M {
  int32 id = 1 [features.field_presence = LEGACY_REQUIRED];
}
''',
        },
        'a.proto',
        'LEGACY_REQUIRED',
      );

      // 6. utf8_validation = NONE on singular string
      expectRejected(
        'utf8_none_singular',
        <String, String>{
          'a.proto': '''
edition = "2023";
package neg.utf8;
message M {
  string raw = 1 [features.utf8_validation = NONE];
}
''',
        },
        'a.proto',
        'UTF-8 NONE',
      );

      // 7. utf8_validation = NONE on repeated string
      expectRejected(
        'utf8_none_repeated',
        <String, String>{
          'a.proto': '''
edition = "2023";
package neg.utf8rep;
message M {
  repeated string tags = 1 [features.utf8_validation = NONE];
}
''',
        },
        'a.proto',
        'UTF-8 NONE',
      );

      // 8. utf8_validation = NONE on oneof string member
      expectRejected(
        'utf8_none_oneof',
        <String, String>{
          'a.proto': '''
edition = "2023";
package neg.utf8oneof;
message M {
  oneof u {
    string s = 1 [features.utf8_validation = NONE];
  }
}
''',
        },
        'a.proto',
        'UTF-8 NONE',
      );

      // 9. utf8_validation = NONE inherited onto map<string, int32> key
      expectRejected(
        'utf8_none_map_key',
        <String, String>{
          'a.proto': '''
edition = "2023";
package neg.utf8mapk;
option features.utf8_validation = NONE;
message M {
  map<string, int32> m = 1;
}
''',
        },
        'a.proto',
        'UTF-8 NONE',
      );

      // 10. utf8_validation = NONE inherited onto map<int32, string> value
      expectRejected(
        'utf8_none_map_val',
        <String, String>{
          'a.proto': '''
edition = "2023";
package neg.utf8mapv;
option features.utf8_validation = NONE;
message M {
  map<int32, string> m = 1;
}
''',
        },
        'a.proto',
        'UTF-8 NONE',
      );

      // 11. Custom non-zero scalar default
      expectRejected(
        'nonzero_default_int',
        <String, String>{
          'a.proto': '''
edition = "2023";
package neg.defint;
message M {
  int32 count = 1 [default = 42];
}
''',
        },
        'a.proto',
        'non-zero default',
      );

      // 12. Custom non-zero enum default
      expectRejected(
        'nonzero_default_enum',
        <String, String>{
          'a.proto': '''
edition = "2023";
package neg.defenum;
enum Status {
  STATUS_UNSPECIFIED = 0;
  STATUS_OK = 1;
}
message M {
  Status st = 1 [default = STATUS_OK];
}
''',
        },
        'a.proto',
        'non-zero default',
      );

      // 13. Custom -0.0 float default (negative zero is non-zero in IEEE 754)
      expectRejected(
        'nonzero_default_neg_zero',
        <String, String>{
          'a.proto': '''
edition = "2023";
package neg.defnegzero;
message M {
  double d = 1 [default = -0.0];
}
''',
        },
        'a.proto',
        'non-zero default',
      );

      // 14. Non-option extensions & extension_range in Editions
      expectRejected(
        'non_option_extension',
        <String, String>{
          'a.proto': '''
edition = "2023";
package neg.ext;
message Base {
  extensions 100 to 199;
}
extend Base {
  string extra = 100;
}
''',
        },
        'a.proto',
        'extensions are not supported',
      );

      // 15. proto2 TYPE_GROUP still rejected
      expectRejected(
        'proto2_group',
        <String, String>{
          'a.proto': '''
syntax = "proto2";
package neg.p2group;
message M {
  optional group LegacyGroup = 1 {
    optional int32 x = 2;
  }
}
''',
        },
        'a.proto',
        'proto2 groups are not supported',
      );
    });
  });

  group('Tier 2 ProtobufOmniBufCodec Editions Audit', () {
    test(
        'preserves explicit zero/false/empty/empty-bytes/enum(0), DELIMITED, expanded/packed, and oneof',
        () {
      // Absent message encodes to empty bytes.
      final absent = _AuditEditionsMsg();
      expect(ProtobufOmniBufCodec.encode(absent), isEmpty);

      // Explicitly set zero/false/empty values including empty bytes!
      final presentZero = _AuditEditionsMsg()
        ..setField(1, 0)
        ..setField(2, 0.0)
        ..setField(3, false)
        ..setField(4, '')
        ..setField(5, Uint8List(0))
        ..setField(6, _AuditStatus.unspecified)
        ..setField(14, Int64.ZERO);

      final zeroWire = ProtobufOmniBufCodec.encode(presentZero);
      expect(zeroWire, isNotEmpty);
      expect(findLastBoolField(zeroWire, 3), WireType.boolFalse);
      // Field 5 (empty bytes) MUST be present on the wire despite List.isEmpty!
      expect(findLastFieldWithWireType(zeroWire, 5, WireType.bytes), isNotNull);

      final decodedZero = _AuditEditionsMsg();
      ProtobufOmniBufCodec.decodeInto(zeroWire, decodedZero);
      expect(decodedZero.getFieldOrNull(1), 0);
      expect(decodedZero.getFieldOrNull(2), 0.0);
      expect(decodedZero.getFieldOrNull(3), isFalse);
      expect(decodedZero.getFieldOrNull(4), '');
      expect(decodedZero.getFieldOrNull(5), isA<Uint8List>());
      expect((decodedZero.getFieldOrNull(5) as Uint8List), isEmpty);
      expect(decodedZero.getFieldOrNull(6), _AuditStatus.unspecified);
      expect(decodedZero.getFieldOrNull(14), Int64.ZERO);

      // DELIMITED (OG / PG), expanded (P3) & packed (K3), and oneof switching
      final rich = _AuditEditionsMsg()
        ..setField(
          7,
          _AuditChild()
            ..setField(1, 'del-single')
            ..setField(2, 0),
        )
        ..setField(10, 0); // oneof branch 10 with explicit 0
      (rich.getField(8) as List<_AuditChild>).add(
        _AuditChild()
          ..setField(1, 'del-item')
          ..setField(2, 7),
      );
      (rich.getField(9) as List<int>).addAll(<int>[1, 2]);
      (rich.getField(13) as List<int>).addAll(<int>[3, 4]);

      final richWire = ProtobufOmniBufCodec.encode(rich);
      final richDec = _AuditEditionsMsg();
      ProtobufOmniBufCodec.decodeInto(richWire, richDec);
      expect(
        (richDec.getField(7) as _AuditChild).getField(1),
        'del-single',
      );
      expect((richDec.getField(7) as _AuditChild).getFieldOrNull(2), 0);
      expect(
        ((richDec.getField(8) as List<_AuditChild>).single).getField(1),
        'del-item',
      );
      expect(richDec.getField(9), <int>[1, 2]);
      expect(richDec.getField(13), <int>[3, 4]);
      expect(richDec.getFieldOrNull(10), 0);
      expect(richDec.getFieldOrNull(11), isNull);

      // Switch oneof branch to submessage and verify old sibling cleared.
      rich.setField(12, _AuditChild()..setField(1, 'branch-child'));
      expect(rich.getFieldOrNull(10), isNull);
      final switchedDec = _AuditEditionsMsg();
      ProtobufOmniBufCodec.decodeInto(
        ProtobufOmniBufCodec.encode(rich),
        switchedDec,
      );
      expect(switchedDec.getFieldOrNull(10), isNull);
      expect(
        (switchedDec.getField(12) as _AuditChild).getField(1),
        'branch-child',
      );

      // Multi-sibling wire: last sibling wins on decode into GeneratedMessage.
      final multiW = OmniBufWriter()
        ..writeTag(10, WireType.sint)
        ..writeSint32(99)
        ..writeTag(11, WireType.string)
        ..writeString('');
      final multiDec = _AuditEditionsMsg();
      ProtobufOmniBufCodec.decodeInto(multiW.toBytes(), multiDec);
      expect(multiDec.getFieldOrNull(10), isNull);
      expect(multiDec.getFieldOrNull(11), '');

      // Unknown open enum integers (positive and negative) round-trip cleanly.
      for (final rawEnum in <int>[99, -7]) {
        final ew = OmniBufWriter()
          ..writeTag(6, WireType.sint)
          ..writeSint32(rawEnum);
        final enumMsg = _AuditEditionsMsg();
        ProtobufOmniBufCodec.decodeInto(ew.toBytes(), enumMsg);
        final reencoded = ProtobufOmniBufCodec.encode(enumMsg);
        final hit = findLastFieldWithWireType(reencoded, 6, WireType.sint);
        expect(hit, isNotNull);
        final (start, end, _) = hit!;
        expect(OmniBufReader(reencoded, start, end).readSint32(), rawEnum);
      }
    });
  });
}
