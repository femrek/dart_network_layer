import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:test/test.dart';

void main() {
  group('QueryParameter', () {
    test('toLogString() (default hideValue: true) -> key=***', () {
      const param = QueryParameter(key: 'key', value: 'secret');
      expect(param.toLogString(), equals('key=***'));
    });

    test(
      'toLogString(hideValue: false) with string value -> key=somevalue',
      () {
        const param = QueryParameter(key: 'key', value: 'somevalue');
        expect(param.toLogString(hideValue: false), equals('key=somevalue'));
      },
    );

    test('toLogString(hideValue: false) with int value -> key=42', () {
      const param = QueryParameter(key: 'key', value: 42);
      expect(param.toLogString(hideValue: false), equals('key=42'));
    });

    test('toLogString(hideValue: false) with null value -> key=', () {
      const param = QueryParameter(key: 'key', value: null);
      expect(param.toLogString(hideValue: false), equals('key='));
    });

    test(
      'toLogString(hideValue: true) always returns *** '
      'regardless of value type',
      () {
        const paramString = QueryParameter(key: 'key', value: 'val');
        const paramInt = QueryParameter(key: 'key', value: 123);
        const paramNull = QueryParameter(key: 'key', value: null);

        expect(paramString.toLogString(), equals('key=***'));
        expect(paramInt.toLogString(), equals('key=***'));
        expect(paramNull.toLogString(), equals('key=***'));
      },
    );

    test('key field stored correctly', () {
      const param = QueryParameter(key: 'myKey', value: 'val');
      expect(param.key, equals('myKey'));
    });

    test('value field stored correctly', () {
      const param = QueryParameter(key: 'myKey', value: 99);
      expect(param.value, equals(99));
    });
  });
}
