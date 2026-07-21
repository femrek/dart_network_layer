import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:test/test.dart';

class _TestJsonPayload extends JsonRequestSchema {
  const _TestJsonPayload();

  @override
  Map<String, dynamic> toJsonPayload() => {'key': 'value'};

  @override
  String toLogString() => 'TestJsonPayload(key: value)';
}

class _TestRequest extends RequestCommand<IgnoredSchema> {
  _TestRequest({
    this.testPath = '/test',
    this.testMethod = HttpRequestMethod.get,
    this.testHeaders = const {},
    this.testQueryParameters = const [],
    RequestSchema? testPayload,
    this.testLogHeaderValues = false,
    this.testLogPayload = false,
    this.testLogQueryParamValues = false,
  }) : testPayload = testPayload ?? const EmptyRequestSchema();

  final String testPath;
  final HttpRequestMethod testMethod;
  final Map<String, dynamic> testHeaders;
  final List<QueryParameter> testQueryParameters;
  final RequestSchema testPayload;
  final bool testLogHeaderValues;
  final bool testLogPayload;
  final bool testLogQueryParamValues;

  @override
  String get path => testPath;

  @override
  HttpRequestMethod get method => testMethod;

  @override
  Map<String, dynamic> get headers => testHeaders;

  @override
  List<QueryParameter> get queryParameters => testQueryParameters;

  @override
  RequestSchema get payload => testPayload;

  @override
  bool get logHeaderValues => testLogHeaderValues;

  @override
  bool get logRequestPayload => testLogPayload;

  @override
  bool get logQueryParamValues => testLogQueryParamValues;

  @override
  SchemaFactory<IgnoredSchema> get defaultResponseFactory =>
      IgnoredSchema.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

void main() {
  group('RequestCommand defaults', () {
    test('default properties are correct', () {
      final request = _TestRequest();
      expect(request.method, equals(HttpRequestMethod.get));
      expect(request.queryParameters, isEmpty);
      expect(request.headers, isEmpty);
      expect(request.payload, isA<EmptyRequestSchema>());
      expect(request.binaryResponseType, isA<InMemoryBinaryResponse>());
      expect(request.responseFactories, isEmpty);
      expect(request.logHeaderValues, isFalse);
      expect(request.logRequestPayload, isFalse);
      expect(request.logQueryParamValues, isFalse);
    });
  });

  group('getHeaderLogString', () {
    test('empty headers', () {
      final request = _TestRequest();
      expect(request.getHeaderLogString(request.headers), equals('none'));
    });

    test('single header, no values', () {
      final request = _TestRequest(
        testHeaders: {'Content-Type': 'application/json'},
      );
      expect(
        request.getHeaderLogString(request.headers),
        equals('Content-Type'),
      );
    });

    test('multiple headers, no values', () {
      final request = _TestRequest(
        testHeaders: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );
      expect(
        request.getHeaderLogString(request.headers),
        equals('Content-Type, Accept'),
      );
    });

    test('single header, with values', () {
      final request = _TestRequest(
        testHeaders: {'Content-Type': 'application/json'},
      );
      expect(
        request.getHeaderLogString(request.headers, includeValues: true),
        equals('Content-Type: application/json'),
      );
    });

    test('sensitive keys with values are masked', () {
      final sensitiveHeaders = {
        'Authorization': 'Bearer 123',
        'password': 'my-password',
        'token': 'my-token',
        'secret': 'my-secret',
        'cookie': 'my-cookie',
        'apikey': 'my-apikey',
        'api_key': 'my-api_key',
      };

      final request = _TestRequest(testHeaders: sensitiveHeaders);
      final logStr =
          request.getHeaderLogString(request.headers, includeValues: true);

      expect(logStr, contains('Authorization: ***'));
      expect(logStr, contains('password: ***'));
      expect(logStr, contains('token: ***'));
      expect(logStr, contains('secret: ***'));
      expect(logStr, contains('cookie: ***'));
      expect(logStr, contains('apikey: ***'));
      expect(logStr, contains('api_key: ***'));
    });

    test('non-sensitive key with values shows value', () {
      final request = _TestRequest(
        testHeaders: {'Custom-Header': 'custom-value'},
      );
      expect(
        request.getHeaderLogString(request.headers, includeValues: true),
        equals('Custom-Header: custom-value'),
      );
    });

    test('includeValues=false overrides logHeaderValues=true', () {
      final request = _TestRequest(
        testHeaders: {'Custom-Header': 'custom-value'},
        testLogHeaderValues: true,
      );
      expect(
        request.getHeaderLogString(request.headers, includeValues: false),
        equals('Custom-Header'),
      );
    });

    test('includeValues=true overrides logHeaderValues=false', () {
      final request = _TestRequest(
        testHeaders: {'Custom-Header': 'custom-value'},
      );
      expect(
        request.getHeaderLogString(request.headers, includeValues: true),
        equals('Custom-Header: custom-value'),
      );
    });

    test('logHeaderValues = true includes values by default', () {
      final request = _TestRequest(
        testHeaders: {'Custom-Header': 'custom-value'},
        testLogHeaderValues: true,
      );
      expect(
        request.getHeaderLogString(request.headers),
        equals('Custom-Header: custom-value'),
      );
    });
  });

  group('getQueryParameterLogString', () {
    test('empty list', () {
      final request = _TestRequest();
      expect(
        request.getQueryParameterLogString(request.queryParameters),
        equals('none'),
      );
    });

    test('single param, no values', () {
      final request = _TestRequest(
        testQueryParameters: [
          const QueryParameter(key: 'page', value: 1),
        ],
      );
      expect(
        request.getQueryParameterLogString(request.queryParameters),
        equals('page'),
      );
    });

    test('multiple params, no values', () {
      final request = _TestRequest(
        testQueryParameters: [
          const QueryParameter(key: 'page', value: 1),
          const QueryParameter(key: 'limit', value: 10),
        ],
      );
      expect(
        request.getQueryParameterLogString(request.queryParameters),
        equals('page, limit'),
      );
    });

    test('single param, with values', () {
      final request = _TestRequest(
        testQueryParameters: [
          const QueryParameter(key: 'page', value: 1),
        ],
      );
      expect(
        request.getQueryParameterLogString(
          request.queryParameters,
          includeValues: true,
        ),
        equals('page=1'),
      );
    });

    test('multiple params, with values', () {
      final request = _TestRequest(
        testQueryParameters: [
          const QueryParameter(key: 'page', value: 1),
          const QueryParameter(key: 'limit', value: 10),
        ],
      );
      expect(
        request.getQueryParameterLogString(
          request.queryParameters,
          includeValues: true,
        ),
        equals('page=1&limit=10'),
      );
    });

    test('sensitive keys are masked', () {
      final request = _TestRequest(
        testQueryParameters: [
          const QueryParameter(key: 'Authorization', value: 'secret'),
          const QueryParameter(key: 'token', value: 'secret2'),
        ],
      );
      final logStr = request.getQueryParameterLogString(
        request.queryParameters,
        includeValues: true,
      );
      expect(logStr, contains('Authorization=***'));
      expect(logStr, contains('token=***'));
    });

    test('includeValues=false overrides logQueryParamValues=true', () {
      final request = _TestRequest(
        testQueryParameters: [const QueryParameter(key: 'page', value: 1)],
        testLogQueryParamValues: true,
      );
      expect(
        request.getQueryParameterLogString(
          request.queryParameters,
          includeValues: false,
        ),
        equals('page'),
      );
    });

    test('includeValues=true overrides logQueryParamValues=false', () {
      final request = _TestRequest(
        testQueryParameters: [const QueryParameter(key: 'page', value: 1)],
      );
      expect(
        request.getQueryParameterLogString(
          request.queryParameters,
          includeValues: true,
        ),
        equals('page=1'),
      );
    });

    test('logQueryParamValues = true includes values by default', () {
      final request = _TestRequest(
        testQueryParameters: [const QueryParameter(key: 'page', value: 1)],
        testLogQueryParamValues: true,
      );
      expect(
        request.getQueryParameterLogString(request.queryParameters),
        equals('page=1'),
      );
    });
  });

  group('getPayloadLogString', () {
    test('EmptyRequestSchema returns none', () {
      final request = _TestRequest();
      expect(request.getPayloadLogString(request.payload), equals('none'));
    });

    test('non-empty payload, no include: returns runtimeType name', () {
      final request = _TestRequest(testPayload: const _TestJsonPayload());
      expect(
        request.getPayloadLogString(request.payload),
        equals('_TestJsonPayload'),
      );
    });

    test('non-empty payload, includePayload: true: returns toLogString()', () {
      final request = _TestRequest(testPayload: const _TestJsonPayload());
      expect(
        request.getPayloadLogString(request.payload, includePayload: true),
        equals('TestJsonPayload(key: value)'),
      );
    });

    test('logRequestPayload = true includes payload by default', () {
      final request = _TestRequest(
        testPayload: const _TestJsonPayload(),
        testLogPayload: true,
      );
      expect(
        request.getPayloadLogString(request.payload),
        equals('TestJsonPayload(key: value)'),
      );
    });
  });

  group('logString', () {
    test('produces correct format with defaults', () {
      final request = _TestRequest();
      expect(
        request.logString(),
        equals(
          '_TestRequest: get /test, Headers: none, '
          'Query Parameters: none, Payload: none',
        ),
      );
    });

    test('with non-default method and path', () {
      final request = _TestRequest(
        testMethod: HttpRequestMethod.post,
        testPath: '/custom',
      );
      expect(request.logString(), contains('post /custom'));
    });

    test('propagates inclusion flags correctly', () {
      final request = _TestRequest(
        testHeaders: {'H': 'V'},
        testQueryParameters: [const QueryParameter(key: 'Q', value: 'P')],
        testPayload: const _TestJsonPayload(),
      );

      expect(
        request.logString(
          includeHeaderValues: true,
          includeQueryParameterValues: true,
          includePayload: true,
        ),
        equals(
          '_TestRequest: get /test, Headers: H: V, '
          'Query Parameters: Q=P, Payload: TestJsonPayload(key: value)',
        ),
      );
    });
  });
}
