import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:http_test_server/http_test_server.dart';
import 'package:test/test.dart';

class _UserSchema extends Schema {
  const _UserSchema({required this.name});

  final String name;
}

class _UserFactory extends JsonSchemaFactory<_UserSchema> {
  @override
  _UserSchema fromJson(dynamic json) =>
      _UserSchema(name: (json as Map<String, dynamic>)['name'] as String);
}

class _ErrorSchema extends Schema {
  const _ErrorSchema({required this.code});

  final int code;
}

class _ErrorFactory extends JsonSchemaFactory<_ErrorSchema> {
  @override
  _ErrorSchema fromJson(dynamic json) =>
      _ErrorSchema(code: (json as Map<String, dynamic>)['code'] as int);
}

class _ValidationErrorSchema extends Schema {
  const _ValidationErrorSchema({required this.field});

  final String field;
}

class _ValidationErrorFactory
    extends JsonSchemaFactory<_ValidationErrorSchema> {
  @override
  _ValidationErrorSchema fromJson(dynamic json) => _ValidationErrorSchema(
      field: (json as Map<String, dynamic>)['field'] as String);
}

class _UserRequest extends RequestCommand<_UserSchema> {
  @override
  String get path => '/api/user';

  @override
  SchemaFactory<_UserSchema> get defaultResponseFactory => _UserFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => _ErrorFactory();

  @override
  Map<int, SchemaFactory> get responseFactories =>
      {422: _ValidationErrorFactory()};
}

class _ErrorRequest extends RequestCommand<_UserSchema> {
  @override
  String get path => '/api/error';

  @override
  SchemaFactory<_UserSchema> get defaultResponseFactory => _UserFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => _ErrorFactory();

  @override
  Map<int, SchemaFactory> get responseFactories =>
      {422: _ValidationErrorFactory()};
}

class _ValidationRequest extends RequestCommand<_UserSchema> {
  @override
  String get path => '/api/validation';

  @override
  SchemaFactory<_UserSchema> get defaultResponseFactory => _UserFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => _ErrorFactory();

  @override
  Map<int, SchemaFactory> get responseFactories =>
      {422: _ValidationErrorFactory()};
}

void main() {
  group('responseFactories per-status-code', () {
    test('200 response -> uses defaultResponseFactory', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher:
              ServerEvent.standardMatcher(paths: ['/api/user'], method: 'GET'),
          handler: (_) async => '{"name": "Alice"}',
        ),
      ]);

      final invoker =
          DioNetworkInvoker.fromBaseUrl('http://localhost:${server.port}');
      final res = await invoker.send(_UserRequest());
      expect(res, isA<SuccessResponseResult>());
      expect((res as SuccessResponseResult).data, isA<_UserSchema>());
      expect(
          ((res as SuccessResponseResult).data as _UserSchema).name, 'Alice');

      await server.close();
    });

    test(
        '404 response (no matching factory) '
        '-> uses defaultErrorResponseFactory', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher:
              ServerEvent.standardMatcher(paths: ['/api/error'], method: 'GET'),
          handler: (_) async => '{"code": 404}',
          responseStatusCode: 404,
        ),
      ]);

      final invoker =
          DioNetworkInvoker.fromBaseUrl('http://localhost:${server.port}');
      final res = await invoker.send(_ErrorRequest());
      expect(res, isA<SpecifiedResponseResult>());
      expect((res as SpecifiedResponseResult).data, isA<_ErrorSchema>());
      expect(((res as SpecifiedResponseResult).data as _ErrorSchema).code, 404);

      await server.close();
    });

    test('422 response (matching factory) -> uses responseFactories[422]',
        () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(
              paths: ['/api/validation'], method: 'GET'),
          handler: (_) async => '{"field": "email"}',
          responseStatusCode: 422,
        ),
      ]);

      final invoker =
          DioNetworkInvoker.fromBaseUrl('http://localhost:${server.port}');
      final res = await invoker.send(_ValidationRequest());
      expect(res, isA<SpecifiedResponseResult>());
      expect(
          (res as SpecifiedResponseResult).data, isA<_ValidationErrorSchema>());
      expect(
          ((res as SpecifiedResponseResult).data as _ValidationErrorSchema)
              .field,
          'email');

      await server.close();
    });
  });
}
