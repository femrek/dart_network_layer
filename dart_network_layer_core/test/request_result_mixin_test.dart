import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:dart_network_layer_core/src/request/request_result_mixin.dart';
import 'package:test/test.dart';

class _ResultTarget with RequestResultMixin<IgnoredSchema> {}

void main() {
  group('RequestResultMixin', () {
    final successResult = SuccessResponseResult<IgnoredSchema>(
      data: const IgnoredSchema(),
      statusCode: 200,
      headers: const {},
    );

    final errorResult = NetworkErrorResult<IgnoredSchema>(
      error: NetworkError(
        message: 'test',
        stackTrace: StackTrace.current,
      ),
    );

    test('result is null before setResult() is called', () {
      final target = _ResultTarget();
      expect(target.result, isNull);
    });

    test('result equals the value passed to setResult()', () {
      final target = _ResultTarget()
        // ignore: invalid_use_of_internal_member, testing internal mixin setter
        ..setResult(successResult);
      expect(target.result, equals(successResult));
    });

    test('setResult() called twice overwrites the first value', () {
      final target = _ResultTarget()
        // ignore: invalid_use_of_internal_member, first result set
        ..setResult(successResult)
        // ignore: invalid_use_of_internal_member, overwrite with second result
        ..setResult(errorResult);
      expect(target.result, equals(errorResult));
    });

    test('result reflects the last value set', () {
      final target = _ResultTarget()
        // ignore: invalid_use_of_internal_member, testing last result set
        ..setResult(errorResult);
      expect(target.result, same(errorResult));
    });
  });
}
