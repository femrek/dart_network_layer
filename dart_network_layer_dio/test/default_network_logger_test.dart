import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

class _TestJsonPayload extends JsonRequestSchema {
  const _TestJsonPayload();

  @override
  Map<String, dynamic> toJsonPayload() => {'key': 'value'};

  @override
  String toLogString() => 'TestJsonPayload(key: value)';
}

class _MockRequestCommand extends RequestCommand<IgnoredSchema> {
  _MockRequestCommand({
    this.testHeaders = const {},
    this.testQueryParameters = const [],
    this.testPayload = const EmptyRequestSchema(),
  });

  final Map<String, dynamic> testHeaders;
  final List<QueryParameter> testQueryParameters;
  final RequestSchema testPayload;

  @override
  String get path => '/log-test';

  @override
  SchemaFactory<IgnoredSchema> get defaultResponseFactory =>
      IgnoredSchema.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;

  @override
  Map<String, dynamic> get headers => testHeaders;

  @override
  List<QueryParameter> get queryParameters => testQueryParameters;

  @override
  RequestSchema get payload => testPayload;
}

void main() {
  group('DefaultNetworkLogger', () {
    late Logger testLogger;
    late List<LogRecord> logs;

    setUp(() {
      hierarchicalLoggingEnabled = true;
      testLogger = Logger('TestLogger')..level = Level.ALL;
      logs = [];
      testLogger.onRecord.listen(logs.add);
    });

    test('default constructor uses DioNetworkInvoker name', () {
      final defaultLogger = DefaultNetworkLogger();
      // ignore: invalid_use_of_protected_member, testing protected final field
      expect(defaultLogger.logger.name, equals('DioNetworkInvoker'));
    });

    test('logRequest with all flags null propagates default logging values',
        () {
      final strategy = DefaultNetworkLogger(logger: testLogger);
      final request = _MockRequestCommand(
        testHeaders: {'Content-Type': 'application/json'},
        testQueryParameters: [const QueryParameter(key: 'q', value: 'search')],
        testPayload: const _TestJsonPayload(),
      );

      strategy.logRequest(request);

      expect(logs, hasLength(1));
      expect(logs.first.level, equals(Level.FINE));
      expect(
        logs.first.message,
        contains('Headers: Content-Type'),
      );
      expect(logs.first.message, isNot(contains('Content-Type:')));
    });

    test('logRequest with flags set to true prints values', () {
      final strategy = DefaultNetworkLogger(
        logger: testLogger,
        includeHeaderValuesOfRequest: true,
        includePayloadOfRequest: true,
        includeQueryParameterValuesOfRequest: true,
      );
      final request = _MockRequestCommand(
        testHeaders: {'Content-Type': 'application/json'},
        testQueryParameters: [const QueryParameter(key: 'q', value: 'search')],
        testPayload: const _TestJsonPayload(),
      );

      strategy.logRequest(request);

      expect(logs, hasLength(1));
      expect(logs.first.message, contains('Headers: Content-Type:'));
      expect(logs.first.message, contains('Query Parameters: q=search'));
      expect(logs.first.message, contains('Payload: TestJsonPayload'));
    });

    test('logRequest with flags set to false hides values', () {
      final strategy = DefaultNetworkLogger(
        logger: testLogger,
        includeHeaderValuesOfRequest: false,
        includePayloadOfRequest: false,
        includeQueryParameterValuesOfRequest: false,
      );
      final request = _MockRequestCommand(
        testHeaders: {'Content-Type': 'application/json'},
        testQueryParameters: [const QueryParameter(key: 'q', value: 'search')],
        testPayload: const _TestJsonPayload(),
      );

      strategy.logRequest(request);

      expect(logs, hasLength(1));
      expect(logs.first.message, contains('Headers: Content-Type'));
      expect(logs.first.message, isNot(contains('application/json')));
      expect(logs.first.message, contains('Query Parameters: q'));
      expect(logs.first.message, isNot(contains('search')));
      expect(logs.first.message, contains('Payload: _TestJsonPayload'));
      expect(logs.first.message, isNot(contains('TestJsonPayload(')));
    });

    test('logSuccess logs response summary at Level.INFO', () {
      final strategy = DefaultNetworkLogger(logger: testLogger);
      final request = _MockRequestCommand();
      final result = SuccessResponseResult<IgnoredSchema>(
        data: const IgnoredSchema(),
        statusCode: 200,
        headers: const {},
      );

      strategy.logSuccess(request, result);

      expect(logs, hasLength(1));
      expect(logs.first.level, equals(Level.INFO));
      expect(
        logs.first.message,
        equals('Response: 200 IgnoredSchema Request path: /log-test'),
      );
    });

    test('logUnsuccessful logs response summary at Level.WARNING', () {
      final strategy = DefaultNetworkLogger(logger: testLogger);
      final request = _MockRequestCommand();
      final result = SpecifiedResponseResult<IgnoredSchema>(
        data: const IgnoredSchema(),
        statusCode: 400,
        headers: const {},
        type: IgnoredSchema,
      );

      strategy.logUnsuccessful(request, result);

      expect(logs, hasLength(1));
      expect(logs.first.level, equals(Level.WARNING));
      expect(
        logs.first.message,
        equals('Response: 400 IgnoredSchema Request path: /log-test'),
      );
    });

    test('logError for NetworkError logs at Level.SEVERE with details', () {
      final strategy = DefaultNetworkLogger(logger: testLogger);
      final request = _MockRequestCommand();
      const error = NetworkError(
        message: 'Something went wrong',
        stackTrace: StackTrace.empty,
      );
      final result = NetworkErrorResult<IgnoredSchema>(error: error);

      strategy.logError(request, result);

      expect(logs, hasLength(1));
      expect(logs.first.level, equals(Level.SEVERE));
      expect(
        logs.first.message,
        contains('Error while request path: /log-test'),
      );
      expect(logs.first.message, contains('Error: Something went wrong'));
      expect(logs.first.error, equals(error));
      expect(logs.first.stackTrace, equals(StackTrace.empty));
    });

    test('logError for RequestCancelledError logs at Level.INFO', () {
      final strategy = DefaultNetworkLogger(logger: testLogger);
      final request = _MockRequestCommand();
      const error = RequestCancelledError(
        message: 'user cancelled',
        stackTrace: StackTrace.empty,
      );
      final result = NetworkErrorResult<IgnoredSchema>(error: error);

      strategy.logError(request, result);

      expect(logs, hasLength(1));
      expect(logs.first.level, equals(Level.INFO));
      expect(
        logs.first.message,
        equals('Request canceled: user cancelled Request path: /log-test'),
      );
    });
  });
}
