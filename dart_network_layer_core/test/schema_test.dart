import 'dart:typed_data';

import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:test/test.dart';

void main() {
  group('IgnoredSchema', () {
    test('properties', () {
      const schema = IgnoredSchema();
      expect(schema.toLogString(), equals('IgnoredSchema()'));
      expect(IgnoredSchema.factory, isA<StringSchemaFactory<IgnoredSchema>>());
      expect(
          IgnoredSchema.factory.fromString('anything'), isA<IgnoredSchema>());
      expect(IgnoredSchema.factory.fromString('anything'),
          same(const IgnoredSchema()));
      expect(schema, isA<Schema>());
    });
  });

  group('EmptyRequestSchema', () {
    test('properties', () {
      const schema = EmptyRequestSchema();
      expect(schema.toPayload(), isNull);
      expect(schema.toLogString(), equals('EmptyRequestSchema()'));
      expect(schema, isA<DynamicRequestSchema>());
      expect(schema, isA<RequestSchema>());
      expect(schema, isA<Schema>());
    });
  });

  group('BinarySchema subtypes', () {
    test('InMemoryBinarySchema', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final schema = InMemoryBinarySchema(bytes: bytes);
      expect(schema.bytes, equals(bytes));
      expect(schema.toLogString(), contains('bytes length: 3'));
      expect(schema, isA<BinarySchema>());
      expect(schema, isA<Schema>());
    });

    test('FileBinarySchema', () {
      const schema = FileBinarySchema(filePath: '/test/path');
      expect(schema.filePath, equals('/test/path'));
      expect(schema.toLogString(), contains('filePath: /test/path'));
      expect(schema, isA<BinarySchema>());
    });

    test('StreamBinarySchema', () {
      const stream = Stream<Uint8List>.empty();
      const schema = StreamBinarySchema(stream: stream);
      expect(schema.stream, equals(stream));
      expect(schema.toLogString(),
          equals('StreamBinarySchema(stream: Stream<Uint8List>)'));
      expect(schema, isA<BinarySchema>());
    });

    test('RawStringBinarySchema', () {
      const schema = RawStringBinarySchema(data: 'test');
      expect(schema.data, equals('test'));
      expect(schema.toLogString(), contains('data length: 4'));
      expect(schema, isA<BinarySchema>());
    });
  });

  group('BinarySchemaFactory', () {
    test('from() with InMemoryBinaryResponse + Uint8List', () {
      const factory = BinarySchemaFactory<InMemoryBinarySchema>(
        binaryResponseType: InMemoryBinaryResponse(),
      );
      final bytes = Uint8List.fromList([1, 2, 3]);
      final schema = factory.from(bytes);
      expect(schema, isA<InMemoryBinarySchema>());
      expect((schema as InMemoryBinarySchema).bytes, equals(bytes));
    });

    test('from() with InMemoryBinaryResponse + List<int>', () {
      const factory = BinarySchemaFactory<InMemoryBinarySchema>(
        binaryResponseType: InMemoryBinaryResponse(),
      );
      final bytes = <int>[1, 2, 3];
      final schema = factory.from(bytes);
      expect(schema, isA<InMemoryBinarySchema>());
      expect((schema as InMemoryBinarySchema).bytes, equals(bytes));
    });

    test('from() with InMemoryBinaryResponse + wrong type -> ArgumentError',
        () {
      const factory = BinarySchemaFactory<InMemoryBinarySchema>(
        binaryResponseType: InMemoryBinaryResponse(),
      );
      expect(() => factory.from('wrong'), throwsArgumentError);
    });

    test('from() with StreamBinaryResponse + Stream<Uint8List>', () {
      const factory = BinarySchemaFactory<StreamBinarySchema>(
        binaryResponseType: StreamBinaryResponse(),
      );
      const stream = Stream<Uint8List>.empty();
      final schema = factory.from(stream);
      expect(schema, isA<StreamBinarySchema>());
    });

    test('from() with StreamBinaryResponse + wrong type -> ArgumentError', () {
      const factory = BinarySchemaFactory<StreamBinarySchema>(
        binaryResponseType: StreamBinaryResponse(),
      );
      expect(() => factory.from('wrong'), throwsArgumentError);
    });

    test('from() with FileBinaryResponse + String path', () {
      const factory = BinarySchemaFactory<FileBinarySchema>(
        binaryResponseType: FileBinaryResponse('/save/path'),
      );
      final schema = factory.from('any string');
      expect(schema, isA<FileBinarySchema>());
      expect((schema as FileBinarySchema).filePath, equals('/save/path'));
    });

    test('from() with FileBinaryResponse + wrong type -> ArgumentError', () {
      const factory = BinarySchemaFactory<FileBinarySchema>(
        binaryResponseType: FileBinaryResponse('/save/path'),
      );
      expect(() => factory.from(123), throwsArgumentError);
    });

    test('from() with RawStringBinaryResponse + String', () {
      const factory = BinarySchemaFactory<RawStringBinarySchema>(
        binaryResponseType: RawStringBinaryResponse(),
      );
      final schema = factory.from('test data');
      expect(schema, isA<RawStringBinarySchema>());
      expect((schema as RawStringBinarySchema).data, equals('test data'));
    });

    test('from() with RawStringBinaryResponse + wrong type -> ArgumentError',
        () {
      const factory = BinarySchemaFactory<RawStringBinarySchema>(
        binaryResponseType: RawStringBinaryResponse(),
      );
      expect(() => factory.from(123), throwsArgumentError);
    });

    // Explicit methods tests
    test('explicit factory methods', () {
      const factory = BinarySchemaFactory<InMemoryBinarySchema>(
        binaryResponseType: InMemoryBinaryResponse(),
      );

      final inMemory1 = factory.fromBytes(Uint8List.fromList([1]));
      expect(inMemory1.bytes, isA<Uint8List>());

      final inMemory2 = factory.fromBytes(<int>[1]);
      expect(inMemory2.bytes, isA<Uint8List>());

      final streamSchema = factory.fromStream(const Stream<Uint8List>.empty());
      expect(streamSchema, isA<StreamBinarySchema>());

      final fileSchema = factory.fromFilePath('/path');
      expect(fileSchema.filePath, equals('/path'));

      final rawSchema = factory.fromString('raw');
      expect(rawSchema.data, equals('raw'));
    });
  });

  group('BinaryResponseType subtypes', () {
    test('properties', () {
      const inMem = InMemoryBinaryResponse();
      expect(inMem, isA<BinaryResponseType>());

      const streamResp = StreamBinaryResponse();
      expect(streamResp, isA<BinaryResponseType>());

      const rawResp = RawStringBinaryResponse();
      expect(rawResp, isA<BinaryResponseType>());

      const fileResp = FileBinaryResponse('/path');
      expect(fileResp.savePath, equals('/path'));
      expect(fileResp, isA<BinaryResponseType>());
    });
  });

  group('HttpRequestMethod', () {
    test('values check', () {
      expect(HttpRequestMethod.get.value, equals('GET'));
      expect(HttpRequestMethod.post.value, equals('POST'));
      expect(HttpRequestMethod.patch.value, equals('PATCH'));
      expect(HttpRequestMethod.put.value, equals('PUT'));
      expect(HttpRequestMethod.delete.value, equals('DELETE'));
      expect(HttpRequestMethod.head.value, equals('HEAD'));

      expect(HttpRequestMethod.values.length, equals(6));
    });
  });
}
