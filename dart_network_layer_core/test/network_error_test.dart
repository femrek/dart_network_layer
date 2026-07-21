import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:test/test.dart';

void main() {
  group('NetworkErrorInvalidResponseType', () {
    test('properties and format', () {
      final error = NetworkErrorInvalidResponseType(
        message: 'invalid type',
        response: 'raw data',
        statusCode: 500,
        stackTrace: StackTrace.empty,
      );

      expect(error.toString(), startsWith('NetworkErrorInvalidResponseType:'));
      expect(error.toString(), contains('invalid type'));
      expect(error.message, equals('invalid type'));
      expect(error.response, equals('raw data'));
      expect(error.statusCode, equals(500));
      expect(error.stackTrace, equals(StackTrace.empty));

      expect(error, isA<NetworkErrorBase>());
      expect(error, isA<Exception>());
    });
  });

  group('NetworkErrorInvalidPayload', () {
    test('properties and format', () {
      final error = NetworkErrorInvalidPayload(
        message: 'invalid payload',
        stackTrace: StackTrace.empty,
      );

      expect(error.toString(), startsWith('NetworkErrorInvalidPayload:'));
      expect(error.toString(), contains('invalid payload'));

      expect(error, isA<NetworkErrorBase>());
    });
  });

  group('RequestCancelledError', () {
    test('properties and format', () {
      const error = RequestCancelledError(
        message: 'cancelled manually',
        stackTrace: StackTrace.empty,
      );

      expect(error.toString(), startsWith('RequestCancelledError:'));
      expect(error.toString(), contains('cancelled manually'));

      expect(error, isA<NetworkErrorBase>());
      expect(error, isA<Exception>());
    });
  });

  group('NetworkError', () {
    test('properties and format', () {
      const error = NetworkError(
        message: 'general error',
        statusCode: 404,
        response: 'not found',
        stackTrace: StackTrace.empty,
      );

      expect(error.toString(), startsWith('NetworkError:'));
      expect(error.toString(), contains('general error'));
      expect(error.statusCode, equals(404));
      expect(error.response, equals('not found'));

      expect(error, isA<NetworkErrorBase>());
    });

    test('statusCode is null when not provided', () {
      const error = NetworkError(
        message: 'general error',
        stackTrace: StackTrace.empty,
      );

      expect(error.statusCode, isNull);
    });
  });

  group('RequestAlreadyCancelledError', () {
    test('properties and format', () {
      final innerError = Exception('inner');
      final error = RequestAlreadyCancelledError(
        message: 'already cancelled',
        stackTrace: StackTrace.empty,
        error: innerError,
      );

      expect(error.toString(), startsWith('RequestAlreadyCancelledError:'));
      expect(error.toString(), contains('already cancelled'));
      expect(error.message, equals('already cancelled'));
      expect(error.stackTrace, equals(StackTrace.empty));
      expect(error.error, equals(innerError));

      expect(error, isA<Exception>());
      expect(error, isNot(isA<NetworkErrorBase>()));
    });

    test('error is null when not provided', () {
      const error = RequestAlreadyCancelledError(
        message: 'already cancelled',
        stackTrace: StackTrace.empty,
      );

      expect(error.error, isNull);
    });
  });
}
