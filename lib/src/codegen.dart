import 'codegen/context.dart';
import 'codegen/eager_emitter.dart';
import 'codegen/naming.dart';
import 'codegen/opaque_emitter.dart';
import 'descriptor.dart';

/// Generates idiomatic OmniBuf Dart source code for a [CodeGeneratorRequest].
CodeGeneratorResponse generateOmniBufDart(CodeGeneratorRequest req) {
  final resp = CodeGeneratorResponse();
  final targetSet = req.fileToGenerate.toSet();

  final mapEntries = <String, ProtoMessageDescriptor>{};
  final typeRegistry = <String, TypeRef>{};
  final knownFiles = <String>{};

  void collectFile(ProtoFileDescriptor f) {
    knownFiles.add(f.name);
    final pkgScope = f.packageName.isEmpty ? '' : '.${f.packageName}';

    void collectEnum(ProtoEnumDescriptor e, String scope, String dartPrefix) {
      final fqn = '$scope.${e.name}';
      final dartName = escapeTypeName(
        dartPrefix.isEmpty ? e.name : '${dartPrefix}_${e.name}',
      );
      typeRegistry[fqn] = TypeRef(
        fileName: f.name,
        dartName: dartName,
        opaqueName: 'Opaque$dartName',
      );
    }

    void collectMsg(ProtoMessageDescriptor m, String scope, String dartPrefix) {
      final fqn = '$scope.${m.name}';
      if (m.isMapEntry) {
        mapEntries[fqn] = m;
        return;
      }
      final dartName = escapeTypeName(
        dartPrefix.isEmpty ? m.name : '${dartPrefix}_${m.name}',
      );
      typeRegistry[fqn] = TypeRef(
        fileName: f.name,
        dartName: dartName,
        opaqueName: 'Opaque$dartName',
      );
      for (final e in m.enumTypes) {
        collectEnum(e, fqn, dartName);
      }
      for (final nested in m.nestedTypes) {
        collectMsg(nested, fqn, dartName);
      }
    }

    for (final e in f.enums) {
      collectEnum(e, pkgScope, '');
    }
    for (final m in f.messages) {
      collectMsg(m, pkgScope, '');
    }
  }

  for (final f in req.protoFiles) {
    collectFile(f);
  }

  for (final f in req.protoFiles) {
    if (targetSet.isNotEmpty && !targetSet.contains(f.name)) continue;
    final outName = outputFileName(f.name);
    final content = _generateFile(f, mapEntries, typeRegistry, knownFiles);
    resp.files.add(CodeGeneratorResponseFile(name: outName, content: content));
  }
  return resp;
}

String _generateFile(
  ProtoFileDescriptor file,
  Map<String, ProtoMessageDescriptor> mapEntries,
  Map<String, TypeRef> typeRegistry,
  Set<String> knownFiles,
) {
  final sb = StringBuffer();
  sb.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.');
  sb.writeln('// Source: ${file.name}');
  sb.writeln(
    '// ignore_for_file: unused_import, constant_identifier_names, non_constant_identifier_names, prefer_final_locals, unnecessary_this, camel_case_types',
  );
  sb.writeln();
  sb.writeln("import 'dart:typed_data';");
  sb.writeln();
  sb.writeln("import 'package:omnibuf/omnibuf.dart' as ob;");

  final depAliases = <String, String>{};
  final depImports = <String>[];
  var depIndex = 0;
  for (final dep in file.dependencies) {
    if (dep == file.name) continue;
    final relPath = relativeImportPath(file.name, dep);
    if (knownFiles.contains(dep)) {
      final alias = 'dep_${depIndex++}';
      depAliases[dep] = alias;
      depImports.add("import '$relPath' as $alias;");
    } else {
      depImports.add("import '$relPath';");
    }
  }
  if (depImports.isNotEmpty) {
    depImports.sort();
    sb.writeln();
    for (final line in depImports) {
      sb.writeln(line);
    }
  }
  sb.writeln();

  final ctx = CodegenContext(
    currentFile: file.name,
    mapEntries: mapEntries,
    typeRegistry: typeRegistry,
    depAliases: depAliases,
  );

  final pkgScope = file.packageName.isEmpty ? '' : '.${file.packageName}';
  for (final e in file.enums) {
    _generateEnum(sb, e, escapeTypeName(e.name));
  }

  for (final m in file.messages) {
    if (m.isMapEntry) continue;
    _generateMessageTree(sb, m, pkgScope, '', ctx);
  }

  return sb.toString();
}

void _generateEnum(StringBuffer sb, ProtoEnumDescriptor e, String enumName) {
  sb.writeln('abstract final class $enumName {');
  final used = <String>{};
  for (var i = 0; i < e.values.length; i++) {
    final (rawName, value) = e.values[i];
    var vName = escapeEnumValueName(rawName, i);
    while (used.contains(vName)) {
      vName = '${vName}_$i';
    }
    used.add(vName);
    sb.writeln('  static const int $vName = $value;');
  }
  sb.writeln('}');
  sb.writeln();
}

void _generateMessageTree(
  StringBuffer sb,
  ProtoMessageDescriptor m,
  String scope,
  String dartPrefix,
  CodegenContext ctx,
) {
  final fqn = '$scope.${m.name}';
  final className = escapeTypeName(
    dartPrefix.isEmpty ? m.name : '${dartPrefix}_${m.name}',
  );
  final fullName = fqn.startsWith('.') ? fqn.substring(1) : fqn;

  for (final e in m.enumTypes) {
    final nestedEnumName = escapeTypeName('${className}_${e.name}');
    _generateEnum(sb, e, nestedEnumName);
  }

  final sortedFields = List<ProtoFieldDescriptor>.of(m.fields)
    ..sort((a, b) => a.number.compareTo(b.number));
  final fieldNames = assignFieldNames(sortedFields);

  emitEagerMessage(sb, className, fullName, sortedFields, fieldNames, ctx);
  emitOpaqueMessage(sb, className, sortedFields, fieldNames, ctx);

  for (final nested in m.nestedTypes) {
    if (nested.isMapEntry) continue;
    _generateMessageTree(sb, nested, fqn, className, ctx);
  }
}
