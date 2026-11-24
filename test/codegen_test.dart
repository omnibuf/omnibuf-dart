import 'dart:typed_data';

import 'package:omnibuf/src/codegen.dart';
import 'package:omnibuf/src/descriptor.dart';
import 'package:test/test.dart';

void main() {
  group('Tier 1 Codegen', () {
    test('generates Dart source for CodeGeneratorRequest', () {
      final fd = ProtoFileDescriptor()
        ..name = 'sample.proto'
        ..packageName = 'demo';
      final md = ProtoMessageDescriptor()..name = 'Ping';
      md.fields.add(
        ProtoFieldDescriptor()
          ..name = 'id'
          ..number = 1
          ..label = 1
          ..type = 13,
      );
      fd.messages.add(md);

      final req = CodeGeneratorRequest()
        ..fileToGenerate.add('sample.proto')
        ..protoFiles.add(fd);
      final resp = generateOmniBufDart(req);
      expect(resp.error, isEmpty);
      expect(resp.files.single.name, 'sample.omnibuf.dart');
      expect(resp.files.single.content, contains('class Ping'));
      expect(resp.files.single.content, contains('class OpaquePing'));
    });

    test('emits relative imports, nested types/enums, keyword escaping & this.',
        () {
      final sharedFd = ProtoFileDescriptor()
        ..name = 'common/shared.proto'
        ..packageName = 'common';
      sharedFd.messages.add(ProtoMessageDescriptor()..name = 'SharedMeta');

      final mainFd = ProtoFileDescriptor()
        ..name = 'pkg/main.proto'
        ..packageName = 'pkg'
        ..dependencies.add('common/shared.proto');

      final innerMd = ProtoMessageDescriptor()..name = 'Inner';
      innerMd.fields.add(
        ProtoFieldDescriptor()
          ..name = 'value'
          ..number = 1
          ..label = 1
          ..type = 13,
      );
      final nestedEnum = ProtoEnumDescriptor()
        ..name = 'Status'
        ..values.add(('OK', 0))
        ..values.add(('default', 1));

      final mapEntry = ProtoMessageDescriptor()
        ..name = 'U32MapEntry'
        ..isMapEntry = true;
      mapEntry.fields.addAll([
        ProtoFieldDescriptor()
          ..name = 'key'
          ..number = 1
          ..label = 1
          ..type = 13, // uint32
        ProtoFieldDescriptor()
          ..name = 'value'
          ..number = 2
          ..label = 1
          ..type = 9, // string
      ]);

      final s32MapEntry = ProtoMessageDescriptor()
        ..name = 'S32MapEntry'
        ..isMapEntry = true;
      s32MapEntry.fields.addAll([
        ProtoFieldDescriptor()
          ..name = 'key'
          ..number = 1
          ..label = 1
          ..type = 17, // sint32
        ProtoFieldDescriptor()
          ..name = 'value'
          ..number = 2
          ..label = 1
          ..type = 9, // string
      ]);

      final outerMd = ProtoMessageDescriptor()..name = 'Outer';
      outerMd.nestedTypes.addAll([innerMd, mapEntry, s32MapEntry]);
      outerMd.enumTypes.add(nestedEnum);
      outerMd.fields.addAll([
        ProtoFieldDescriptor()
          ..name = 'class'
          ..number = 1
          ..label = 1
          ..type = 9,
        ProtoFieldDescriptor()
          ..name = 'reset'
          ..number = 2
          ..label = 1
          ..type = 13,
        ProtoFieldDescriptor()
          ..name = '_leading'
          ..number = 3
          ..label = 1
          ..type = 13,
        ProtoFieldDescriptor()
          ..name = '___'
          ..number = 4
          ..label = 1
          ..type = 13,
        ProtoFieldDescriptor()
          ..name = 'w'
          ..number = 5
          ..label = 1
          ..type = 13,
        ProtoFieldDescriptor()
          ..name = 'inner'
          ..number = 6
          ..label = 1
          ..type = 11
          ..typeName = '.pkg.Outer.Inner',
        ProtoFieldDescriptor()
          ..name = 'shared'
          ..number = 7
          ..label = 1
          ..type = 11
          ..typeName = '.common.SharedMeta',
        ProtoFieldDescriptor()
          ..name = 'u32_map'
          ..number = 8
          ..label = 3
          ..type = 11
          ..typeName = '.pkg.Outer.U32MapEntry',
        ProtoFieldDescriptor()
          ..name = 's32_map'
          ..number = 9
          ..label = 3
          ..type = 11
          ..typeName = '.pkg.Outer.S32MapEntry',
      ]);
      mainFd.messages.add(outerMd);

      final req = CodeGeneratorRequest()
        ..fileToGenerate.add('pkg/main.proto')
        ..protoFiles.addAll([sharedFd, mainFd]);
      final resp = generateOmniBufDart(req);
      expect(resp.error, isEmpty);
      final code = resp.files.single.content;
      expect(
          code, contains("import '../common/shared.omnibuf.dart' as dep_0;"));
      expect(code, contains('abstract final class Outer_Status'));
      expect(code, contains('static const int default_ = 1;'));
      expect(code, contains('class Outer_Inner'));
      expect(code, contains('class OpaqueOuter_Inner'));
      expect(code, contains('String class_;'));
      expect(code, contains('int reset_;'));
      expect(code, contains('int leading;'));
      expect(code, contains('int field4;'));
      expect(code, contains('this.w'));
      expect(code, contains('Outer_Inner? inner;'));
      expect(code, contains('dep_0.SharedMeta? shared;'));
      expect(code, contains('(a & 0xFFFFFFFF).compareTo(b & 0xFFFFFFFF)'));
      expect(code, contains('a.toSigned(32).compareTo(b.toSigned(32))'));
    });

    test(
        'emits value equality, hashCode, toString, and avoids nested estimateBodyBytes',
        () {
      final fd = ProtoFileDescriptor()
        ..name = 'eq.proto'
        ..packageName = 'demo';
      final child = ProtoMessageDescriptor()..name = 'Child';
      child.fields.add(
        ProtoFieldDescriptor()
          ..name = 'x'
          ..number = 1
          ..label = 1
          ..type = 13,
      );
      final parent = ProtoMessageDescriptor()..name = 'Parent';
      parent.fields.addAll([
        ProtoFieldDescriptor()
          ..name = 'raw'
          ..number = 1
          ..label = 1
          ..type = 12,
        ProtoFieldDescriptor()
          ..name = 'child'
          ..number = 2
          ..label = 1
          ..type = 11
          ..typeName = '.demo.Child',
      ]);
      fd.messages.addAll([child, parent]);

      final req = CodeGeneratorRequest()
        ..fileToGenerate.add('eq.proto')
        ..protoFiles.add(fd);
      final code = generateOmniBufDart(req).files.single.content;
      expect(code, contains('bool operator ==(Object other)'));
      expect(code, contains('int get hashCode =>'));
      expect(code, contains('String toString() =>'));
      expect(code, contains('ob.bytesEquals(this.raw, other.raw)'));
      expect(code, isNot(contains('reserveLenAuto(sub.estimateBodyBytes')));
    });

    test('descriptor reader rejects varint overflow and out-of-bounds lengths',
        () {
      // 11-byte varint with continuation bits set
      final overflowVarint = Uint8List.fromList(List.filled(11, 0x80));
      expect(
        () => CodeGeneratorRequest.decode(overflowVarint),
        throwsA(isA<FormatException>()),
      );

      // Field 1 (string, wt=2) claiming length 100 with only 2 bytes remaining
      final badLen = Uint8List.fromList([0x0A, 100, 0x41, 0x42]);
      expect(
        () => CodeGeneratorRequest.decode(badLen),
        throwsA(isA<FormatException>()),
      );

      // Unknown field (fnum=9, wt=1 fixed64) with only 2 bytes remaining
      final badFixed64 = Uint8List.fromList([(9 << 3) | 1, 0x01, 0x02]);
      expect(
        () => CodeGeneratorRequest.decode(badFixed64),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
