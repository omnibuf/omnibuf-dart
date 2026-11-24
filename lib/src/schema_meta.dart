import 'dart:typed_data';

import 'errors.dart';
import 'options.dart';
import 'wire.dart';

/// Optional inline naming metadata encoded at Field #0 (`Tag = 0x19`, `WireSubMsg = 12`).
class SchemaMeta {
  /// Optional message name (e.g. `"PeerUpdate"` or `"omnibuf.bench.PeerUpdate"`).
  String typeName;

  /// Maps field number -> field name. An empty string clears an inherited name.
  final Map<int, String> fields;

  /// Maps parent field number -> child [SchemaMeta] for nested messages,
  /// arrays of messages, and maps with message values.
  final Map<int, SchemaMeta> children;

  SchemaMeta({
    this.typeName = '',
    Map<int, String>? fields,
    Map<int, SchemaMeta>? children,
  })  : fields = fields ?? <int, String>{},
        children = children ?? <int, SchemaMeta>{};

  /// Returns a deep copy of this metadata tree.
  SchemaMeta clone() => _clone(0, Set<SchemaMeta>.identity());

  SchemaMeta _clone(int depth, Set<SchemaMeta> visiting) {
    if (depth > DecodeOptions.defaultMaxDepth || !visiting.add(this)) {
      throw const OmniBufSerializeException(
        'SchemaMeta cycle or recursion depth limit exceeded',
      );
    }
    try {
      return SchemaMeta(
        typeName: typeName,
        fields: Map<int, String>.of(fields),
        children: {
          for (final entry in children.entries)
            entry.key: entry.value._clone(depth + 1, visiting),
        },
      );
    } finally {
      visiting.remove(this);
    }
  }

  /// Merges [other] into this [SchemaMeta] according to OmniBuf v1 DRAFT-1 Section 8.2:
  /// - Later non-empty `typeName` wins.
  /// - Later `fields` entries override per field number (including `""` clearing to `field_<N>`).
  /// - `children` entries merge recursively by field number.
  ///
  /// When [preserveEmpty] is `true`, empty-string `""` tombstones are retained in
  /// `fields` so a subsequent merge onto an inherited parent schema still clears
  /// inherited names.
  void mergeFrom(SchemaMeta other, {bool preserveEmpty = false}) {
    _mergeFrom(
      other,
      preserveEmpty,
      0,
      Set<SchemaMeta>.identity(),
      Set<SchemaMeta>.identity(),
    );
  }

  void _mergeFrom(
    SchemaMeta other,
    bool preserveEmpty,
    int depth,
    Set<SchemaMeta> visitingDst,
    Set<SchemaMeta> visitingSrc,
  ) {
    if (depth > DecodeOptions.defaultMaxDepth ||
        !visitingDst.add(this) ||
        !visitingSrc.add(other)) {
      throw const OmniBufSerializeException(
        'SchemaMeta cycle or recursion depth limit exceeded',
      );
    }
    try {
      if (other.typeName.isNotEmpty) {
        typeName = other.typeName;
      }
      for (final entry in other.fields.entries) {
        if (entry.value.isEmpty && !preserveEmpty) {
          fields.remove(entry.key);
        } else {
          fields[entry.key] = entry.value;
        }
      }
      for (final entry in other.children.entries) {
        final existing = children[entry.key];
        if (existing != null) {
          existing._mergeFrom(
            entry.value,
            preserveEmpty,
            depth + 1,
            visitingDst,
            visitingSrc,
          );
        } else {
          children[entry.key] = entry.value._clone(depth + 1, visitingSrc);
        }
      }
    } finally {
      visitingDst.remove(this);
      visitingSrc.remove(other);
    }
  }

  /// Writes this [SchemaMeta] as Field #0 (`Tag = 0x19`) into [w].
  /// Guards against cyclic [children] graphs via identity set and depth limit.
  void writeField0(OmniBufWriter w, {int maxDepth = 16}) {
    w.writeByte(WireType.field0EncodedTag);
    _writeBody(w, 0, maxDepth, Set<SchemaMeta>.identity());
  }

  void _writeBody(
    OmniBufWriter w,
    int depth,
    int maxDepth,
    Set<SchemaMeta> visiting,
  ) {
    if (depth > DecodeOptions.defaultMaxDepth || !visiting.add(this)) {
      throw const OmniBufSerializeException(
        'SchemaMeta cycle or recursion depth limit exceeded',
      );
    }
    try {
      final slot = w.reserveLen2();
      if (typeName.isNotEmpty) {
        w.writeTag(1, WireType.string);
        w.writeString(typeName);
      }
      if (fields.isNotEmpty) {
        w.writeTag(2, WireType.map);
        final mSlot = w.reserveLen2();
        w.writeByte(WireType.uint);
        w.writeByte(WireType.string);
        final keys = fields.keys.toList()..sort();
        w.writeVarint(keys.length);
        for (final k in keys) {
          w.writeVarint(k);
          w.writeString(fields[k]!);
        }
        w.patchLen2(mSlot);
      }
      if (children.isNotEmpty && depth + 2 <= maxDepth) {
        w.writeTag(3, WireType.map);
        final mSlot = w.reserveLen2();
        w.writeByte(WireType.uint);
        w.writeByte(WireType.subMsg);
        final keys = children.keys.toList()..sort();
        w.writeVarint(keys.length);
        for (final k in keys) {
          w.writeVarint(k);
          children[k]!._writeBody(w, depth + 2, maxDepth, visiting);
        }
        w.patchLen2(mSlot);
      }
      w.patchLen2(slot);
    } finally {
      visiting.remove(this);
    }
  }

  /// Decodes a [SchemaMeta] submessage (starting at its `ByteLen` prefix).
  static SchemaMeta decodeSubMsg(
    OmniBufReader r,
    int depth,
    int maxDepth, {
    int maxElements = DecodeOptions.defaultMaxCollectionElements,
    DecodeBudget? budget,
  }) {
    final effectiveBudget = budget ?? DecodeBudget(maxElements);
    effectiveBudget.consume(1);
    final nextDepth = depth + 1;
    if (nextDepth > maxDepth) {
      throw OmniBufDepthLimitException(maxDepth);
    }
    final len = r.readCheckedLength();
    final subEnd = r.pos + len;
    final sub = r.subReader(r.pos, subEnd);
    final meta = SchemaMeta();
    // Track raw field overrides (including empty string "") so mergeFrom can clear inherited names.
    final rawFields = <int, String>{};
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
        case 1: // type_name
          if (wt == WireType.string) {
            meta.typeName = sub.readString(budget: effectiveBudget);
          } else {
            skipAndValidateValue(
              sub,
              wt,
              nextDepth,
              maxDepth,
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
            final (kt, vt, count) = mBody.readMapHeader(
              maxElements: effectiveBudget.maxElements,
            );
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
              final v = mBody.readString(budget: effectiveBudget);
              rawFields[k] = v;
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
            final (kt, vt, count) = mBody.readMapHeader(
              maxElements: effectiveBudget.maxElements,
            );
            effectiveBudget.consume(count);
            if (kt != WireType.uint || vt != WireType.subMsg) {
              throw OmniBufTypeMismatchException(
                'SchemaMeta.children expects map<uint, submsg>, got <$kt, $vt>',
              );
            }
            // Within a single WireMap, duplicate key replaces prior value outright.
            final mapChildren = <int, SchemaMeta>{};
            for (var i = 0; i < count; i++) {
              final k = mBody.readVarint();
              if (k < 1 || k > WireType.maxFieldNumber) {
                throw OmniBufParseException(
                  'SchemaMeta.children key $k out of valid field number range',
                );
              }
              final child = decodeSubMsg(
                mBody,
                mapDepth,
                maxDepth,
                maxElements: effectiveBudget.maxElements,
                budget: effectiveBudget,
              );
              mapChildren[k] = child;
            }
            if (mBody.pos != mEnd) {
              throw const OmniBufParseException(
                'SchemaMeta.children trailing bytes',
              );
            }
            sub.pos = mEnd;
            // Across multiple field #3 occurrences in the same SchemaMeta, merge recursively.
            for (final entry in mapChildren.entries) {
              final existing = meta.children[entry.key];
              if (existing != null) {
                existing.mergeFrom(entry.value, preserveEmpty: true);
              } else {
                meta.children[entry.key] = entry.value;
              }
            }
          } else {
            skipAndValidateValue(
              sub,
              wt,
              nextDepth,
              maxDepth,
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
            validateStrings: true,
            maxElements: effectiveBudget.maxElements,
            budget: effectiveBudget,
          );
      }
    }
    meta.fields.addAll(rawFields);
    r.pos = subEnd;
    return meta;
  }

  /// Extracts and merges all top-level Field #0 blocks from [data], if any exist.
  static SchemaMeta? readFromPacket(
    Uint8List data, {
    int maxDepth = DecodeOptions.defaultMaxDepth,
    int maxElements = DecodeOptions.defaultMaxCollectionElements,
    int maxAllocBytes = DecodeOptions.defaultMaxAllocBytes,
  }) {
    if (maxDepth < 1 || maxDepth > DecodeOptions.defaultMaxDepth) {
      throw RangeError.range(
          maxDepth, 1, DecodeOptions.defaultMaxDepth, 'maxDepth');
    }
    final budget = DecodeBudget(maxElements, maxAllocBytes: maxAllocBytes);
    final r = OmniBufReader(data);
    SchemaMeta? merged;
    while (r.hasMore) {
      final tag = r.readTag();
      final fnum = tag >> 4;
      final wt = tag & 0x0F;
      if (fnum == 0) {
        final block = decodeSubMsg(
          r,
          0,
          maxDepth,
          maxElements: maxElements,
          budget: budget,
        );
        if (merged == null) {
          merged = SchemaMeta();
          merged.mergeFrom(block);
        } else {
          merged.mergeFrom(block);
        }
      } else {
        fastSkipValue(r, wt);
      }
    }
    return merged;
  }
}
