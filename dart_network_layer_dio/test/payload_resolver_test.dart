import 'dart:io';

import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:dart_network_layer_dio/src/strategy/impl/dio_payload_resolver.dart';
import 'package:dio/dio.dart' show FormData;
import 'package:test/test.dart';

class _Json extends JsonRequestSchema {
  const _Json();

  @override
  Map<String, dynamic> toJsonPayload() => {'key': 'value'};
}

class _Str extends StringRequestSchema {
  const _Str();

  @override
  String toStringPayload() => 'hello';
}

class _Bin extends BinaryRequestSchema {
  const _Bin();

  @override
  List<int> toBinaryPayload() => [1, 2, 3];
}

class _Stream extends StreamRequestSchema {
  const _Stream();

  @override
  Stream<List<int>> toStreamPayload() => Stream.value([1, 2, 3]);
}

class _Dyn extends DynamicRequestSchema {
  const _Dyn();

  @override
  dynamic toPayload() => {'dynamic': true};
}

class _FormText extends FormDataRequestSchema {
  const _FormText();

  @override
  Map<String, dynamic> toFormDataMapPayload() =>
      {'field1': 'value1', 'field2': 42};
}

class _FormWithFile extends FormDataRequestSchema {
  const _FormWithFile(this.file);

  final ByteMultipartFileSchema file;

  @override
  Map<String, dynamic> toFormDataMapPayload() =>
      {'file': file, 'description': 'test'};
}

class _FormWithFiles extends FormDataRequestSchema {
  const _FormWithFiles(this.files);

  final List<MultipartFileSchema> files;

  @override
  Map<String, dynamic> toFormDataMapPayload() => {'files': files};
}

class _FormWithFileSchema extends FormDataRequestSchema {
  const _FormWithFileSchema(this.file);

  final FileMultipartFileSchema file;

  @override
  Map<String, dynamic> toFormDataMapPayload() =>
      {'file': file, 'description': 'test'};
}

void main() {
  group('DioPayloadResolver', () {
    const resolver = DioPayloadResolver();

    test('EmptyRequestSchema -> resolves to null', () async {
      expect(await resolver.resolve(const EmptyRequestSchema()), isNull);
    });

    test('JsonRequestSchema -> resolves to Map<String, dynamic>', () async {
      final res = await resolver.resolve(const _Json());
      expect(res, isA<Map<String, dynamic>>());
      expect(res, {'key': 'value'});
    });

    test('StringRequestSchema -> resolves to String hello', () async {
      final res = await resolver.resolve(const _Str());
      expect(res, 'hello');
    });

    test('BinaryRequestSchema -> resolves to List<int> [1, 2, 3]', () async {
      final res = await resolver.resolve(const _Bin());
      expect(res, [1, 2, 3]);
    });

    test('StreamRequestSchema -> resolves to a Stream', () async {
      final res = await resolver.resolve(const _Stream());
      expect(res, isA<Stream<List<int>>>());
    });

    test('DynamicRequestSchema -> resolves to the return value of toPayload()',
        () async {
      final res = await resolver.resolve(const _Dyn());
      expect(res, {'dynamic': true});
    });

    test('FormDataRequestSchema (text only) -> resolves to FormData', () async {
      final res = await resolver.resolve(const _FormText());
      expect(res, isA<FormData>());
      final formData = res! as FormData;
      expect(
          formData.fields.any((f) => f.key == 'field1' && f.value == 'value1'),
          isTrue);
    });

    test(
        'FormDataRequestSchema with ByteMultipartFileSchema '
        '-> resolves to FormData', () async {
      const file =
          ByteMultipartFileSchema(filename: 'test.txt', data: [1, 2, 3]);
      final res = await resolver.resolve(const _FormWithFile(file));
      expect(res, isA<FormData>());
      final formData = res! as FormData;
      expect(formData.files.isNotEmpty, isTrue);
    });

    test(
        'FormDataRequestSchema with FileMultipartFileSchema '
        '-> resolves to FormData', () async {
      final tempFile =
          await File('${Directory.systemTemp.path}/test_upload.txt')
              .writeAsString('content');
      final fileSchema = FileMultipartFileSchema(
          filename: 'test.txt', filePath: tempFile.path, length: 7);

      final res = await resolver.resolve(_FormWithFileSchema(fileSchema));
      expect(res, isA<FormData>());

      await tempFile.delete();
    });

    test(
        'FormDataRequestSchema with List<MultipartFileSchema> (byte files) '
        '-> resolves to FormData', () async {
      const file1 = ByteMultipartFileSchema(filename: '1.txt', data: [1]);
      const file2 = ByteMultipartFileSchema(filename: '2.txt', data: [2]);
      final res = await resolver.resolve(const _FormWithFiles([file1, file2]));
      expect(res, isA<FormData>());
      final formData = res! as FormData;
      expect(formData.files.length, 2);
    });
  });
}
