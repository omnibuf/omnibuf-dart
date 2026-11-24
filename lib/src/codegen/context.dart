import '../descriptor.dart';
import 'naming.dart';

/// Shared type-resolution and descriptor lookup state for emitting a `.proto` file.
class CodegenContext {
  final String currentFile;
  final Map<String, ProtoMessageDescriptor> mapEntries;
  final Map<String, TypeRef> typeRegistry;
  final Map<String, String> depAliases;

  const CodegenContext({
    required this.currentFile,
    required this.mapEntries,
    required this.typeRegistry,
    required this.depAliases,
  });

  bool isMapField(ProtoFieldDescriptor f) =>
      f.label == 3 &&
      f.type == PbType.messageType &&
      mapEntries.containsKey(normalizeFqn(f.typeName));

  (ProtoFieldDescriptor keyField, ProtoFieldDescriptor valField) mapEntryFor(
    ProtoFieldDescriptor f,
  ) {
    final entry = mapEntries[normalizeFqn(f.typeName)]!;
    final kf = entry.fields.firstWhere((e) => e.number == 1);
    final vf = entry.fields.firstWhere((e) => e.number == 2);
    return (kf, vf);
  }

  String typeOf(String fqn) =>
      resolveTypeName(fqn, currentFile, typeRegistry, depAliases);

  String opaqueTypeOf(String fqn) =>
      resolveOpaqueTypeName(fqn, currentFile, typeRegistry, depAliases);
}
