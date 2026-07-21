import 'dart:typed_data';

import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:dart_network_layer_dio/src/strategy/impl/dio_response_parser.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

class _JsonRequest extends RequestCommand<_JsonResponse> {
  @override
  String get path => '/test';

  @override
  SchemaFactory<_JsonResponse> get defaultResponseFactory =>
      _JsonResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class _JsonResponse extends Schema {
  const _JsonResponse({required this.value});

  final String value;
}

class _JsonResponseFactory extends JsonSchemaFactory<_JsonResponse> {
  @override
  _JsonResponse fromJson(dynamic json) {
    return _JsonResponse(
        value: (json as Map<String, dynamic>)['value'] as String);
  }
}

class _StringRequest extends RequestCommand<_StringResponse> {
  @override
  String get path => '/test';

  @override
  SchemaFactory<_StringResponse> get defaultResponseFactory =>
      _StringResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class _StringResponse extends Schema {
  const _StringResponse({required this.value});

  final String value;
}

class _StringResponseFactory extends StringSchemaFactory<_StringResponse> {
  @override
  _StringResponse fromString(String s) => _StringResponse(value: s);
}

class _DynamicRequest extends RequestCommand<AnyDataSchema> {
  @override
  String get path => '/test';

  @override
  SchemaFactory<AnyDataSchema> get defaultResponseFactory =>
      AnyDataSchema.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class _BinaryRequest extends RequestCommand<InMemoryBinarySchema> {
  @override
  String get path => '/test';

  @override
  BinaryResponseType get binaryResponseType => const InMemoryBinaryResponse();

  @override
  SchemaFactory<InMemoryBinarySchema> get defaultResponseFactory =>
      BinarySchemaFactory<InMemoryBinarySchema>(
          binaryResponseType: binaryResponseType);

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

Response<dynamic> _mockResponse({
  dynamic data,
  int? statusCode = 200,
  Headers? headers,
}) {
  return Response(
    requestOptions: RequestOptions(path: '/test'),
    data: data,
    statusCode: statusCode,
    headers: headers ?? Headers(),
  );
}

void main() {
  group('DioResponseParser.parse()', () {
    const parser = DioResponseParser();

    test('null statusCode -> NetworkErrorResult', () async {
      final res =
          await parser.parse(_mockResponse(statusCode: null), _JsonRequest());
      expect(res, isA<NetworkErrorResult>());
    });

    test('null responseData -> SpecifiedResponseResult with IgnoredSchema data',
        () async {
      final res = await parser.parse(_mockResponse(), _JsonRequest());
      expect(res, isA<SpecifiedResponseResult>());
      expect((res as SpecifiedResponseResult).data, isA<IgnoredSchema>());
    });

    test('valid JSON string + JsonSchemaFactory -> SuccessResponseResult',
        () async {
      final res = await parser.parse(
          _mockResponse(data: '{"value":"test"}'), _JsonRequest());
      expect(res, isA<SuccessResponseResult>());
      expect(
          ((res as SuccessResponseResult).data as _JsonResponse).value, 'test');
    });

    test('invalid JSON string + JsonSchemaFactory -> NetworkErrorResult',
        () async {
      final res =
          await parser.parse(_mockResponse(data: 'not json'), _JsonRequest());
      expect(res, isA<NetworkErrorResult>());
    });

    test('valid string + StringSchemaFactory -> SuccessResponseResult',
        () async {
      final res = await parser.parse(
          _mockResponse(data: 'test string'), _StringRequest());
      expect(res, isA<SuccessResponseResult>());
      expect(((res as SuccessResponseResult).data as _StringResponse).value,
          'test string');
    });

    test('non-string data + StringSchemaFactory -> NetworkErrorResult',
        () async {
      final res =
          await parser.parse(_mockResponse(data: 123), _StringRequest());
      expect(res, isA<NetworkErrorResult>());
    });

    test('any data + DynamicSchemaFactory -> SuccessResponseResult', () async {
      final res = await parser.parse(
          _mockResponse(data: {'a': 'b'}), _DynamicRequest());
      expect(res, isA<SuccessResponseResult>());
    });

    test(
        'Uint8List + BinarySchemaFactory (InMemory) '
        '-> SuccessResponseResult<InMemoryBinarySchema>', () async {
      final res = await parser.parse(
          _mockResponse(data: Uint8List.fromList([1, 2, 3])), _BinaryRequest());
      expect(res, isA<SuccessResponseResult<InMemoryBinarySchema>>());
    });

    test(
        'List<int> + BinarySchemaFactory (InMemory) '
        '-> SuccessResponseResult<InMemoryBinarySchema>', () async {
      final res =
          await parser.parse(_mockResponse(data: [1, 2, 3]), _BinaryRequest());
      expect(res, isA<SuccessResponseResult<InMemoryBinarySchema>>());
    });

    test('wrong type + BinarySchemaFactory (InMemory) -> NetworkErrorResult',
        () async {
      final res =
          await parser.parse(_mockResponse(data: 'string'), _BinaryRequest());
      expect(res, isA<NetworkErrorResult>());
    });
  });

  group('DioResponseParser.handleDioException()', () {
    const parser = DioResponseParser();

    test('cancel exception -> NetworkErrorResult with RequestCancelledError',
        () async {
      // CancelToken.isCancel checks the exception type, no token needed here.
      final cancelException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.cancel,
      );

      final res = await parser.handleDioException(
          cancelException, StackTrace.empty, _JsonRequest());
      expect(res, isA<NetworkErrorResult>());
      expect((res as NetworkErrorResult).error, isA<RequestCancelledError>());
    });

    test(
        'DioException with no response -> NetworkErrorResult with NetworkError',
        () async {
      final ex = DioException(
        requestOptions: RequestOptions(path: '/test'),
      );
      final res =
          await parser.handleDioException(ex, StackTrace.empty, _JsonRequest());
      expect(res, isA<NetworkErrorResult>());
      expect((res as NetworkErrorResult).error, isA<NetworkError>());
    });

    test(
        'DioException with response but null statusCode '
        '-> NetworkErrorResult with NetworkError', () async {
      final ex = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(requestOptions: RequestOptions(path: '/test')),
        type: DioExceptionType.badResponse,
      );
      final res =
          await parser.handleDioException(ex, StackTrace.empty, _JsonRequest());
      expect(res, isA<NetworkErrorResult>());
      expect((res as NetworkErrorResult).error, isA<NetworkError>());
    });

    test(
        'DioException with 400 response + no specifiedFactory '
        '-> uses defaultErrorResponseFactory', () async {
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
          data: 'error message',
          headers: Headers(),
        ),
        type: DioExceptionType.badResponse,
      );
      final res = await parser.handleDioException(
          dioEx, StackTrace.empty, _JsonRequest());
      expect(res, isA<SpecifiedResponseResult>());
      expect((res as SpecifiedResponseResult).data, isA<IgnoredSchema>());
    });

    test(
        'DioException with 400 response + specifiedFactory in '
        'responseFactories[400] -> uses specified factory', () async {
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
          data: 'error message',
          headers: Headers(),
        ),
        type: DioExceptionType.badResponse,
      );
      final res = await parser.handleDioException(
          dioEx, StackTrace.empty, _MultiFactoryRequest());
      expect(res, isA<SpecifiedResponseResult>());
      expect(
        (res as SpecifiedResponseResult).data,
        isA<_StringResponse>(),
      );
    });
  });
}

class _MultiFactoryRequest extends RequestCommand<IgnoredSchema> {
  @override
  String get path => '/test';

  @override
  SchemaFactory<IgnoredSchema> get defaultResponseFactory =>
      IgnoredSchema.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;

  @override
  Map<int, SchemaFactory> get responseFactories => {
        400: _StringResponseFactory(),
      };
}
