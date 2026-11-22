import 'dart:convert';
import 'dart:typed_data';

/// Minimal self-contained Protobuf binary decoder/encoder for
/// `google.protobuf.compiler.CodeGeneratorRequest`,
/// `google.protobuf.compiler.CodeGeneratorResponse`, and
/// `google.protobuf.FileDescriptorSet`.
///
/// Allows `protoc-gen-omnibuf-dart` and `FileDescriptorSet`-backed codecs to
/// parse descriptors without requiring generated descriptor stubs.

class ProtoFileDescriptor {
  String name = '';
  String packageName = '';
  final List<ProtoMessageDescriptor> messages = [];
  final List<ProtoEnumDescriptor> enums = [];
}

class ProtoMessageDescriptor {
  String name = '';
  final List<ProtoFieldDescriptor> fields = [];
  final List<ProtoMessageDescriptor> nestedTypes = [];
  final List<ProtoEnumDescriptor> enumTypes = [];
  bool isMapEntry = false;
}

class ProtoFieldDescriptor {
  String name = '';
  int number = 0;
  int label = 1; // 1=OPTIONAL, 2=REQUIRED, 3=REPEATED
  int type = 0; // google.protobuf.FieldDescriptorProto.Type
  String typeName = '';
  String jsonName = '';
}

class ProtoEnumDescriptor {
  String name = '';
  final List<(String, int)> values = [];
}

class CodeGeneratorRequest {
  final List<String> fileToGenerate = [];
  String parameter = '';
  final List<ProtoFileDescriptor> protoFiles = [];

  static CodeGeneratorRequest decode(Uint8List bytes) {
    final req = CodeGeneratorRequest();
    final r = _PbReader(bytes);
    while (r.hasMore) {
      final tag = r.readVarint();
      final fnum = tag >> 3;
      final wt = tag & 7;
      switch (fnum) {
        case 1: // file_to_generate
          req.fileToGenerate.add(r.readString());
        case 2: // parameter
          req.parameter = r.readString();
        case 15: // proto_file
          req.protoFiles.add(_decodeFileDescriptor(r.readBytes()));
        default:
          r.skip(wt);
      }
    }
    return req;
  }
}

class CodeGeneratorResponseFile {
  final String name;
  final String content;
  const CodeGeneratorResponseFile({required this.name, required this.content});
}

class CodeGeneratorResponse {
  String error = '';
  int supportedFeatures = 1; // FEATURE_PROTO3_OPTIONAL
  final List<CodeGeneratorResponseFile> files = [];

  Uint8List encode() {
    final w = _PbWriter();
    if (error.isNotEmpty) {
      w.writeString(1, error);
    }
    if (supportedFeatures != 0) {
      w.writeVarintField(2, supportedFeatures);
    }
    for (final f in files) {
      final fw = _PbWriter();
      fw.writeString(1, f.name);
      fw.writeString(15, f.content);
      w.writeBytes(15, fw.toBytes());
    }
    return w.toBytes();
  }
}

/// Decodes a `google.protobuf.FileDescriptorSet` binary blob.
List<ProtoFileDescriptor> decodeFileDescriptorSet(Uint8List bytes) {
  final files = <ProtoFileDescriptor>[];
  final r = _PbReader(bytes);
  while (r.hasMore) {
    final tag = r.readVarint();
    final fnum = tag >> 3;
    final wt = tag & 7;
    if (fnum == 1 && wt == 2) {
      files.add(_decodeFileDescriptor(r.readBytes()));
    } else {
      r.skip(wt);
    }
  }
  return files;
}

ProtoFileDescriptor _decodeFileDescriptor(Uint8List bytes) {
  final fd = ProtoFileDescriptor();
  final r = _PbReader(bytes);
  while (r.hasMore) {
    final tag = r.readVarint();
    final fnum = tag >> 3;
    final wt = tag & 7;
    switch (fnum) {
      case 1:
        fd.name = r.readString();
      case 2:
        fd.packageName = r.readString();
      case 4:
        fd.messages.add(_decodeMessageDescriptor(r.readBytes()));
      case 5:
        fd.enums.add(_decodeEnumDescriptor(r.readBytes()));
      default:
        r.skip(wt);
    }
  }
  return fd;
}

ProtoMessageDescriptor _decodeMessageDescriptor(Uint8List bytes) {
  final md = ProtoMessageDescriptor();
  final r = _PbReader(bytes);
  while (r.hasMore) {
    final tag = r.readVarint();
    final fnum = tag >> 3;
    final wt = tag & 7;
    switch (fnum) {
      case 1:
        md.name = r.readString();
      case 2:
        md.fields.add(_decodeFieldDescriptor(r.readBytes()));
      case 3:
        md.nestedTypes.add(_decodeMessageDescriptor(r.readBytes()));
      case 4:
        md.enumTypes.add(_decodeEnumDescriptor(r.readBytes()));
      case 7: // options (MessageOptions)
        final optBytes = r.readBytes();
        final or = _PbReader(optBytes);
        while (or.hasMore) {
          final oTag = or.readVarint();
          final oNum = oTag >> 3;
          final oWt = oTag & 7;
          if (oNum == 7 && oWt == 0) {
            md.isMapEntry = or.readVarint() != 0;
          } else {
            or.skip(oWt);
          }
        }
      default:
        r.skip(wt);
    }
  }
  return md;
}

ProtoFieldDescriptor _decodeFieldDescriptor(Uint8List bytes) {
  final f = ProtoFieldDescriptor();
  final r = _PbReader(bytes);
  while (r.hasMore) {
    final tag = r.readVarint();
    final fnum = tag >> 3;
    final wt = tag & 7;
    switch (fnum) {
      case 1:
        f.name = r.readString();
      case 3:
        f.number = r.readVarint();
      case 4:
        f.label = r.readVarint();
      case 5:
        f.type = r.readVarint();
      case 6:
        f.typeName = r.readString();
      case 10:
        f.jsonName = r.readString();
      default:
        r.skip(wt);
    }
  }
  return f;
}

ProtoEnumDescriptor _decodeEnumDescriptor(Uint8List bytes) {
  final ed = ProtoEnumDescriptor();
  final r = _PbReader(bytes);
  while (r.hasMore) {
    final tag = r.readVarint();
    final fnum = tag >> 3;
    final wt = tag & 7;
    switch (fnum) {
      case 1:
        ed.name = r.readString();
      case 2:
        final vr = _PbReader(r.readBytes());
        var vName = '';
        var vNum = 0;
        while (vr.hasMore) {
          final vTag = vr.readVarint();
          final vFnum = vTag >> 3;
          final vWt = vTag & 7;
          if (vFnum == 1) {
            vName = vr.readString();
          } else if (vFnum == 2) {
            vNum = vr.readVarint();
          } else {
            vr.skip(vWt);
          }
        }
        ed.values.add((vName, vNum));
      default:
        r.skip(wt);
    }
  }
  return ed;
}

class _PbReader {
  final Uint8List buf;
  int pos = 0;

  _PbReader(this.buf);

  bool get hasMore => pos < buf.length;

  int readVarint() {
    var result = 0;
    var shift = 0;
    while (pos < buf.length) {
      final b = buf[pos++];
      result |= (b & 0x7F) << shift;
      if ((b & 0x80) == 0) return result;
      shift += 7;
    }
    throw FormatException('truncated protobuf varint');
  }

  Uint8List readBytes() {
    final len = readVarint();
    final end = pos + len;
    final slice = Uint8List.sublistView(buf, pos, end);
    pos = end;
    return slice;
  }

  String readString() => utf8.decode(readBytes());

  void skip(int wt) {
    switch (wt) {
      case 0:
        readVarint();
      case 1:
        pos += 8;
      case 2:
        final len = readVarint();
        pos += len;
      case 5:
        pos += 4;
      default:
        throw FormatException('unsupported protobuf wire type $wt');
    }
  }
}

class _PbWriter {
  final BytesBuilder _b = BytesBuilder(copy: false);

  void _writeVarint(int v) {
    var u = v;
    while (true) {
      if ((u & ~0x7F) == 0) {
        _b.addByte(u);
        return;
      }
      _b.addByte((u & 0x7F) | 0x80);
      u >>>= 7;
    }
  }

  void writeVarintField(int fieldNumber, int v) {
    _writeVarint((fieldNumber << 3) | 0);
    _writeVarint(v);
  }

  void writeBytes(int fieldNumber, Uint8List data) {
    _writeVarint((fieldNumber << 3) | 2);
    _writeVarint(data.length);
    _b.add(data);
  }

  void writeString(int fieldNumber, String s) {
    final bytes = Uint8List.fromList(utf8.encode(s));
    writeBytes(fieldNumber, bytes);
  }

  Uint8List toBytes() => _b.takeBytes();
}
