import '../descriptor.dart';
import 'naming.dart';

/// Shared type-resolution and descriptor lookup state for emitting a `.proto` file.
class CodegenContext {
  final String currentFile;
  final Map<String, ProtoMessageDescriptor> mapEntries;
  final Map<String, TypeRef> typeRegistry;
  final Map<String, String> depAliases;
  final Set<String> usedDeps = <String>{};

  CodegenContext({
    required this.currentFile,
    required this.mapEntries,
    required this.typeRegistry,
    required this.depAliases,
  });

  bool isMessageType(ProtoFieldDescriptor f) =>
      f.type == PbType.messageType || f.isDelimitedMessage;

  bool isMapField(ProtoFieldDescriptor f) =>
      f.label == 3 &&
      isMessageType(f) &&
      mapEntries.containsKey(normalizeFqn(f.typeName));

  (ProtoFieldDescriptor keyField, ProtoFieldDescriptor valField) mapEntryFor(
    ProtoFieldDescriptor f,
  ) {
    final entry = mapEntries[normalizeFqn(f.typeName)]!;
    final kf = entry.fields.firstWhere((e) => e.number == 1);
    final vf = entry.fields.firstWhere((e) => e.number == 2);
    return (kf, vf);
  }

  String typeOf(String fqn) {
    final ref = typeRegistry[normalizeFqn(fqn)];
    if (ref != null && ref.fileName != currentFile) {
      usedDeps.add(ref.fileName);
    }
    return resolveTypeName(fqn, currentFile, typeRegistry, depAliases);
  }

  String opaqueTypeOf(String fqn) {
    final ref = typeRegistry[normalizeFqn(fqn)];
    if (ref != null && ref.fileName != currentFile) {
      usedDeps.add(ref.fileName);
    }
    return resolveOpaqueTypeName(fqn, currentFile, typeRegistry, depAliases);
  }
}
