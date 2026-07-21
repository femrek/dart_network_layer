import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:test/test.dart';

void main() {
  group('SuccessResponseResult', () {
    test('properties and inheritance', () {
      final headers = {
        'Content-Type': ['application/json']
      };
      final result = SuccessResponseResult<IgnoredSchema>(
        data: const IgnoredSchema(),
        statusCode: 200,
        headers: headers,
      );

      expect(result.data, isA<IgnoredSchema>());
      expect(result.statusCode, equals(200));
      expect(result.headers, equals(headers));
      expect(result.type, equals(IgnoredSchema));

      expect(result, isA<SpecifiedResponseResult>());
      expect(result, isA<ResponseResult>());
      expect(result, isA<NetworkResult>());
    });
  });

  group('SpecifiedResponseResult', () {
    test('properties and inheritance', () {
      final headers = {
        'Error-Header': ['test']
      };
      final result = SpecifiedResponseResult<IgnoredSchema>(
        data: const IgnoredSchema(),
        statusCode: 400,
        type: IgnoredSchema,
        headers: headers,
      );

      expect(result.data, isA<IgnoredSchema>());
      expect(result.statusCode, equals(400));
      expect(result.type, equals(IgnoredSchema));
      expect(result.headers, equals(headers));

      expect(result, isA<ResponseResult>());
      expect(result, isA<NetworkResult>());
    });
  });

  group('NetworkErrorResult', () {
    test('properties and inheritance', () {
      const error =
          NetworkError(message: 'timeout', stackTrace: StackTrace.empty);
      final result = NetworkErrorResult<IgnoredSchema>(error: error);

      expect(result.error, equals(error));
      expect(result, isA<NetworkResult>());
      expect(result, isNot(isA<ResponseResult>()));
    });
  });

  group('Sealed exhaustive matching', () {
    test('switch on NetworkResult covers all cases without requiring a default',
        () {
      NetworkResult<IgnoredSchema> getResult(int type) {
        if (type == 0) {
          return SuccessResponseResult<IgnoredSchema>(
            data: const IgnoredSchema(),
            statusCode: 200,
            headers: const {},
          );
        } else if (type == 1) {
          return SpecifiedResponseResult<IgnoredSchema>(
            data: const IgnoredSchema(),
            statusCode: 400,
            type: IgnoredSchema,
            headers: const {},
          );
        } else {
          return NetworkErrorResult<IgnoredSchema>(
            error: const NetworkError(
                message: 'error', stackTrace: StackTrace.empty),
          );
        }
      }

      for (var i = 0; i < 3; i++) {
        final result = getResult(i);

        // This switch must compile without a default case
        final matchedType = switch (result) {
          SuccessResponseResult() => 'success',
          SpecifiedResponseResult() => 'specified',
          NetworkErrorResult() => 'error',
        };

        if (i == 0) expect(matchedType, equals('success'));
        if (i == 1) expect(matchedType, equals('specified'));
        if (i == 2) expect(matchedType, equals('error'));
      }
    });
  });
}
