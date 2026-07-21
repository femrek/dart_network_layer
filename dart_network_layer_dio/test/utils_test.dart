import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:dart_network_layer_dio/src/util/utils.dart';
import 'package:dio/dio.dart' show ListFormat, ListParam;
import 'package:test/test.dart';

void main() {
  group('convertQueryParameters', () {
    test('empty list', () {
      final result = convertQueryParameters([]);
      expect(result, isEmpty);
    });

    test('single param with string value', () {
      final result = convertQueryParameters(
          [const QueryParameter(key: 'key', value: 'value')]);
      expect(result, {'key': 'value'});
    });

    test('single param with int value', () {
      final result =
          convertQueryParameters([const QueryParameter(key: 'key', value: 42)]);
      expect(result, {'key': 42});
    });

    test('single param with null value', () {
      final result = convertQueryParameters(
          [const QueryParameter(key: 'key', value: null)]);
      expect(result, {'key': ''});
    });

    test('two different keys', () {
      final result = convertQueryParameters([
        const QueryParameter(key: 'k1', value: 'v1'),
        const QueryParameter(key: 'k2', value: 'v2'),
      ]);
      expect(result, {'k1': 'v1', 'k2': 'v2'});
    });

    test('duplicate keys (both string values)', () {
      final result = convertQueryParameters([
        const QueryParameter(key: 'key', value: 'v1'),
        const QueryParameter(key: 'key', value: 'v2'),
      ]);
      expect(result, {
        'key': ['v1', 'v2']
      });
    });

    test('three entries same key', () {
      final result = convertQueryParameters([
        const QueryParameter(key: 'key', value: 'v1'),
        const QueryParameter(key: 'key', value: 'v2'),
        const QueryParameter(key: 'key', value: 'v3'),
      ]);
      expect(result, {
        'key': ['v1', 'v2', 'v3']
      });
    });

    test('ListParam value (multi format)', () {
      const param = QueryParameter(
          key: 'tags', value: ListParam<dynamic>(['a', 'b'], ListFormat.multi));
      final result = convertQueryParameters([param]);
      expect(result['tags'], isA<ListParam<dynamic>>());
      final lp = result['tags'] as ListParam<dynamic>;
      expect(lp.value, containsAll(['a', 'b']));
      expect(lp.format, ListFormat.multi);
    });

    test('ListParam (multi format) + duplicate scalar', () {
      final result = convertQueryParameters([
        const QueryParameter(
            key: 'tags',
            value: ListParam<dynamic>(['a', 'b'], ListFormat.multi)),
        const QueryParameter(key: 'tags', value: 'c'),
      ]);
      expect(result['tags'], isA<ListParam<dynamic>>());
      final lp = result['tags'] as ListParam<dynamic>;
      expect(lp.value, containsAll(['a', 'b', 'c']));
      expect(lp.format, ListFormat.multi);
    });

    test('two ListParam entries for same key', () {
      final result = convertQueryParameters([
        const QueryParameter(
            key: 'tags',
            value: ListParam<dynamic>(['a', 'b'], ListFormat.multi)),
        const QueryParameter(
            key: 'tags',
            value: ListParam<dynamic>(['c', 'd'], ListFormat.multi)),
      ]);
      expect(result['tags'], isA<ListParam<dynamic>>());
      final lp = result['tags'] as ListParam<dynamic>;
      expect(lp.value, containsAll(['a', 'b', 'c', 'd']));
      expect(lp.format, ListFormat.multi);
    });
  });
}
