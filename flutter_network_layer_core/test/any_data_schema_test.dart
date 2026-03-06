// ignore_for_file: avoid_dynamic_calls any type test

import 'dart:typed_data';

import 'package:flutter_network_layer_core/flutter_network_layer_core.dart';
import 'package:test/test.dart';

void main() {
  group('AnyDataSchema', () {
    group('constructor', () {
      test('should create instance with Map data', () {
        const data = {'key': 'value', 'number': 42};
        const schema = AnyDataSchema(data: data);

        expect(schema.data, equals(data));
        expect(schema.data, isA<Map<dynamic, dynamic>>());
      });

      test('should create instance with List data', () {
        const data = [1, 2, 3, 'four'];
        const schema = AnyDataSchema(data: data);

        expect(schema.data, equals(data));
        expect(schema.data, isA<List<dynamic>>());
      });

      test('should create instance with nested Map data', () {
        const data = {
          'user': {'name': 'John', 'age': 30},
          'items': [1, 2, 3],
        };
        const schema = AnyDataSchema(data: data);

        expect(schema.data, equals(data));
        expect(schema.data['user']['name'], equals('John'));
        expect(schema.data['items'], equals([1, 2, 3]));
      });

      test('should create instance with nested List data', () {
        const data = [
          {'id': 1},
          {'id': 2},
          [3, 4, 5],
        ];
        const schema = AnyDataSchema(data: data);

        expect(schema.data, equals(data));
        expect(schema.data[0]['id'], equals(1));
        expect(schema.data[2], equals([3, 4, 5]));
      });

      test('should create instance with String data', () {
        const data = 'plain string';
        const schema = AnyDataSchema(data: data);

        expect(schema.data, equals(data));
        expect(schema.data, isA<String>());
      });

      test('should create instance with int data', () {
        const data = 42;
        const schema = AnyDataSchema(data: data);

        expect(schema.data, equals(data));
        expect(schema.data, isA<int>());
      });

      test('should create instance with double data', () {
        const data = 3.14;
        const schema = AnyDataSchema(data: data);

        expect(schema.data, equals(data));
        expect(schema.data, isA<double>());
      });

      test('should create instance with bool data', () {
        const schema = AnyDataSchema(data: true);

        expect(schema.data, isTrue);
        expect(schema.data, isA<bool>());
      });

      test('should create instance with null data', () {
        const schema = AnyDataSchema(data: null);

        expect(schema.data, isNull);
      });

      test('should create instance with Uint8List (bytes) data', () {
        final data = Uint8List.fromList([0x48, 0x65, 0x6c, 0x6c, 0x6f]);
        final schema = AnyDataSchema(data: data);

        expect(schema.data, equals(data));
        expect(schema.data, isA<Uint8List>());
      });
    });

    group('factory', () {
      test('should have a static factory instance', () {
        expect(
          AnyDataSchema.factory,
          isA<DynamicSchemaFactory<AnyDataSchema>>(),
        );
      });

      test('should parse Map from dynamic data', () {
        const data = {'message': 'success', 'code': 200};
        final schema = AnyDataSchema.factory.from(data);

        expect(schema, isA<AnyDataSchema>());
        expect(schema.data, equals(data));
      });

      test('should parse List from dynamic data', () {
        const data = ['item1', 'item2', 'item3'];
        final schema = AnyDataSchema.factory.from(data);

        expect(schema, isA<AnyDataSchema>());
        expect(schema.data, equals(data));
      });

      test('should parse empty Map from dynamic data', () {
        const data = <String, dynamic>{};
        final schema = AnyDataSchema.factory.from(data);

        expect(schema, isA<AnyDataSchema>());
        expect(schema.data, equals(data));
        expect(schema.data, isEmpty);
      });

      test('should parse empty List from dynamic data', () {
        const data = <dynamic>[];
        final schema = AnyDataSchema.factory.from(data);

        expect(schema, isA<AnyDataSchema>());
        expect(schema.data, equals(data));
        expect(schema.data, isEmpty);
      });

      test('should parse complex nested structure from dynamic data', () {
        const data = {
          'users': [
            {'id': 1, 'name': 'Alice'},
            {'id': 2, 'name': 'Bob'},
          ],
          'metadata': {
            'total': 2,
            'page': 1,
          },
        };
        final schema = AnyDataSchema.factory.from(data);

        expect(schema, isA<AnyDataSchema>());
        expect(schema.data['users'], isA<List<dynamic>>());
        expect(schema.data['users'].length, equals(2));
        expect(schema.data['metadata']['total'], equals(2));
      });

      test('should accept String data', () {
        final schema = AnyDataSchema.factory.from('plain string');

        expect(schema, isA<AnyDataSchema>());
        expect(schema.data, equals('plain string'));
        expect(schema.data, isA<String>());
      });

      test('should accept int data', () {
        final schema = AnyDataSchema.factory.from(42);

        expect(schema, isA<AnyDataSchema>());
        expect(schema.data, equals(42));
        expect(schema.data, isA<int>());
      });

      test('should accept double data', () {
        final schema = AnyDataSchema.factory.from(3.14);

        expect(schema, isA<AnyDataSchema>());
        expect(schema.data, equals(3.14));
        expect(schema.data, isA<double>());
      });

      test('should accept bool data', () {
        final schema = AnyDataSchema.factory.from(true);

        expect(schema, isA<AnyDataSchema>());
        expect(schema.data, isTrue);
        expect(schema.data, isA<bool>());
      });

      test('should accept null data', () {
        final schema = AnyDataSchema.factory.from(null);

        expect(schema, isA<AnyDataSchema>());
        expect(schema.data, isNull);
      });

      test('should accept Uint8List (bytes) data', () {
        final data = Uint8List.fromList([0x48, 0x65, 0x6c, 0x6c, 0x6f]);
        final schema = AnyDataSchema.factory.from(data);

        expect(schema, isA<AnyDataSchema>());
        expect(schema.data, equals(data));
        expect(schema.data, isA<Uint8List>());
      });
    });

    group('Schema inheritance', () {
      test('should extend Schema', () {
        const schema = AnyDataSchema(data: <dynamic, dynamic>{});
        expect(schema, isA<Schema>());
      });
    });
  });
}
