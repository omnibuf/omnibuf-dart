// ignore_for_file: file_names

import 'dart:io';
import 'dart:typed_data';

import 'package:omnibuf/src/codegen.dart';
import 'package:omnibuf/src/descriptor.dart';

/// `protoc` / `buf` code generator plugin for OmniBuf Dart (Tier 1).
Future<void> main() async {
  final builder = BytesBuilder(copy: false);
  await for (final chunk in stdin) {
    builder.add(chunk);
  }
  final input = builder.takeBytes();
  try {
    final req = CodeGeneratorRequest.decode(input);
    final resp = generateOmniBufDart(req);
    stdout.add(resp.encode());
    await stdout.flush();
  } catch (e, st) {
    final resp = CodeGeneratorResponse()..error = '$e\n$st';
    stdout.add(resp.encode());
    await stdout.flush();
  }
}
