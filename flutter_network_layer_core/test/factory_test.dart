import 'dart:convert';

import 'package:flutter_network_layer_core/flutter_network_layer_core.dart';
import 'package:http/http.dart' as http;
import 'package:http_test_server/http_test_server.dart';
import 'package:test/test.dart';

void main() {
  group('Default Response Factory with Generic Type Control', () {
    test('should maintain generic type T in defaultResponseFactory', () {
      final request = UserRequest();
      final factory = request.defaultResponseFactory;

      expect(factory, isA<SchemaFactory<UserResponse>>());
      expect(factory, isA<JsonSchemaFactory<UserResponse>>());
    });

    test('should deserialize success response using defaultResponseFactory',
        () {
      final request = UserRequest();
      final factory =
          request.defaultResponseFactory as JsonSchemaFactory<UserResponse>;

      final json = {'name': 'John Doe', 'id': 123};
      final result = factory.fromJson(json);

      expect(result, isA<UserResponse>());
      expect(result.name, equals('John Doe'));
      expect(result.id, equals(123));
    });

    test('should handle different generic types for different requests', () {
      final userRequest = UserRequest();
      final productRequest = ProductRequest();

      expect(userRequest.defaultResponseFactory,
          isA<SchemaFactory<UserResponse>>());
      expect(productRequest.defaultResponseFactory,
          isA<SchemaFactory<ProductResponse>>());
      expect(userRequest.defaultResponseFactory.runtimeType,
          isNot(equals(productRequest.defaultResponseFactory.runtimeType)));
    });

    test('should use JsonResponseFactory for JSON responses', () {
      final request = UserRequest();
      final factory = request.defaultResponseFactory;

      switch (factory) {
        case JsonSchemaFactory<UserResponse>():
          expect(factory, isA<JsonSchemaFactory<UserResponse>>());
        case StringSchemaFactory<UserResponse>():
          fail('Should not be a CustomResponseFactory');
        case DynamicSchemaFactory<UserResponse>():
          fail('Should not be a DynamicSchemaFactory');
      }
    });

    test('should use CustomResponseFactory for custom responses', () {
      final request = PlainTextRequest();
      final factory = request.defaultResponseFactory;

      switch (factory) {
        case JsonSchemaFactory<PlainTextResponse>():
          fail('Should not be a JsonResponseFactory');
        case StringSchemaFactory<PlainTextResponse>():
          expect(factory, isA<StringSchemaFactory<PlainTextResponse>>());
        case DynamicSchemaFactory<PlainTextResponse>():
          fail('Should not be a DynamicSchemaFactory');
      }
    });

    test('should deserialize custom response using defaultResponseFactory', () {
      final request = PlainTextRequest();
      final factory = request.defaultResponseFactory
          as StringSchemaFactory<PlainTextResponse>;

      const plainString = 'Success message';
      final result = factory.fromString(plainString);

      expect(result, isA<PlainTextResponse>());
      expect(result.message, equals('Success message'));
    });
  });

  group('Default Error Response Factory', () {
    test('should return correct type for defaultErrorResponseFactory', () {
      final request = UserRequestWithError();
      final errorFactory = request.defaultErrorResponseFactory;

      expect(errorFactory, isA<SchemaFactory>());
      expect(errorFactory, isA<JsonSchemaFactory<ErrorResponse>>());
    });

    test('should deserialize error response using defaultErrorResponseFactory',
        () {
      final request = UserRequestWithError();
      final errorFactory = request.defaultErrorResponseFactory
          as JsonSchemaFactory<ErrorResponse>;

      final json = {'message': 'Not found', 'code': 404};
      final result = errorFactory.fromJson(json);

      expect(result, isA<ErrorResponse>());
      expect(result.message, equals('Not found'));
      expect(result.code, equals(404));
    });

    test('should use IgnoredSchema as default error factory when not specified',
        () {
      final request = UserRequest();
      final errorFactory = request.defaultErrorResponseFactory;

      expect(errorFactory, equals(IgnoredSchema.factory));
      expect(errorFactory, isA<StringSchemaFactory<IgnoredSchema>>());
    });

    test('should distinguish between success and error factories', () {
      final request = UserRequestWithError();
      final successFactory = request.defaultResponseFactory;
      final errorFactory = request.defaultErrorResponseFactory;

      expect(
          successFactory.runtimeType, isNot(equals(errorFactory.runtimeType)));
      expect(successFactory, isA<SchemaFactory<UserResponse>>());
      expect(errorFactory, isA<SchemaFactory<ErrorResponse>>());
    });

    test('should handle different error response types', () {
      final userRequest = UserRequestWithError();
      final productRequest = ProductRequestWithError();

      expect(userRequest.defaultErrorResponseFactory,
          isA<JsonSchemaFactory<ErrorResponse>>());
      expect(productRequest.defaultErrorResponseFactory,
          isA<JsonSchemaFactory<ValidationErrorResponse>>());
    });

    test('should use custom error factory for plain text errors', () {
      final request = PlainTextRequestWithError();
      final errorFactory = request.defaultErrorResponseFactory;

      switch (errorFactory) {
        case JsonSchemaFactory():
          fail('Should not be a JsonResponseFactory');
        case StringSchemaFactory():
          expect(
              errorFactory, isA<StringSchemaFactory<PlainTextErrorResponse>>());
        case DynamicSchemaFactory():
          fail('Should not be a DynamicSchemaFactory');
      }
    });
  });

  group('Integration Tests with Network Invoker', () {
    late TestServer server;
    late _TestNetworkInvoker invoker;

    setUp(() async {
      server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/user/success']),
          handler: (request) async => '{"name": "Jane Doe", "id": 456}',
        ),
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/user/error']),
          handler: (request) async =>
              '{"message": "User not found", "code": 404}',
          responseStatusCode: 404,
        ),
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/product/success']),
          handler: (request) async => '{"title": "Laptop", "price": 999.99}',
        ),
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/product/error']),
          handler: (request) async =>
              '{"field": "price", "error": "Must be positive"}',
          responseStatusCode: 400,
        ),
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/text/success']),
          handler: (request) async => 'Plain text success',
        ),
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/text/error']),
          handler: (request) async => 'Plain text error',
          responseStatusCode: 500,
        ),
      ]);

      invoker = _TestNetworkInvoker(port: server.port);
      await invoker.init('http://${server.server.address.address}');
    });

    test('should use defaultResponseFactory for successful JSON response',
        () async {
      final request = UserRequestSuccess();
      final result = await invoker.request(request);

      expect(result, isA<SuccessResponseResult<UserResponse>>());
      if (result is SuccessResponseResult<UserResponse>) {
        expect(result.data.name, equals('Jane Doe'));
        expect(result.data.id, equals(456));
        expect(result.statusCode, equals(200));
      }
    });

    test('should use defaultErrorResponseFactory for error JSON response',
        () async {
      final request = UserRequestError();
      final result = await invoker.request(request);

      expect(result, isA<SpecifiedResponseResult<UserResponse>>());
      if (result is SpecifiedResponseResult<UserResponse>) {
        expect(result.statusCode, equals(404));
        expect(result.data, isA<ErrorResponse>());
        final errorData = result.data as ErrorResponse;
        expect(errorData.message, equals('User not found'));
        expect(errorData.code, equals(404));
      }
    });

    test('should maintain type safety with different generic types', () async {
      final userRequest = UserRequestSuccess();
      final productRequest = ProductRequestSuccess();

      final userResult = await invoker.request(userRequest);
      final productResult = await invoker.request(productRequest);

      expect(userResult, isA<SuccessResponseResult<UserResponse>>());
      expect(productResult, isA<SuccessResponseResult<ProductResponse>>());

      if (userResult is SuccessResponseResult<UserResponse>) {
        expect(userResult.data, isA<UserResponse>());
      }
      if (productResult is SuccessResponseResult<ProductResponse>) {
        expect(productResult.data, isA<ProductResponse>());
      }
    });

    test('should use custom error factory for different error types', () async {
      final request = ProductRequestError();
      final result = await invoker.request(request);

      expect(result, isA<SpecifiedResponseResult<ProductResponse>>());
      if (result is SpecifiedResponseResult<ProductResponse>) {
        expect(result.statusCode, equals(400));
        expect(result.data, isA<ValidationErrorResponse>());
        final errorData = result.data as ValidationErrorResponse;
        expect(errorData.field, equals('price'));
        expect(errorData.error, equals('Must be positive'));
      }
    });

    test('should use CustomResponseFactory for plain text success', () async {
      final request = PlainTextRequestSuccess();
      final result = await invoker.request(request);

      expect(result, isA<SuccessResponseResult<PlainTextResponse>>());
      if (result is SuccessResponseResult<PlainTextResponse>) {
        expect(result.data.message, equals('Plain text success'));
        expect(result.statusCode, equals(200));
      }
    });

    test('should use CustomResponseFactory for plain text error', () async {
      final request = PlainTextRequestError();
      final result = await invoker.request(request);

      expect(result, isA<SpecifiedResponseResult<PlainTextResponse>>());
      if (result is SpecifiedResponseResult<PlainTextResponse>) {
        expect(result.statusCode, equals(500));
        expect(result.data, isA<PlainTextErrorResponse>());
        final errorData = result.data as PlainTextErrorResponse;
        expect(errorData.errorMessage, equals('Plain text error'));
      }
    });

    test('should use IgnoredSchema when no error factory specified', () async {
      final request = UserRequestSuccessNoErrorFactory();
      // This would normally fail, but we're testing the factory type

      expect(
          request.defaultErrorResponseFactory, equals(IgnoredSchema.factory));
    });
  });
}

// Test Schema Classes
class UserResponse extends Schema {
  UserResponse({required this.name, required this.id});

  final String name;
  final int id;
}

class UserResponseFactory extends JsonSchemaFactory<UserResponse> {
  @override
  UserResponse fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw Exception('Invalid JSON: $json');
    }
    return UserResponse(
      name: json['name'] as String,
      id: json['id'] as int,
    );
  }
}

class ProductResponse extends Schema {
  ProductResponse({required this.title, required this.price});

  final String title;
  final double price;
}

class ProductResponseFactory extends JsonSchemaFactory<ProductResponse> {
  @override
  ProductResponse fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw Exception('Invalid JSON: $json');
    }
    return ProductResponse(
      title: json['title'] as String,
      price: json['price'] as double,
    );
  }
}

class ErrorResponse extends Schema {
  ErrorResponse({required this.message, required this.code});

  final String message;
  final int code;
}

class ErrorResponseFactory extends JsonSchemaFactory<ErrorResponse> {
  @override
  ErrorResponse fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw Exception('Invalid JSON: $json');
    }
    return ErrorResponse(
      message: json['message'] as String,
      code: json['code'] as int,
    );
  }
}

class ValidationErrorResponse extends Schema {
  ValidationErrorResponse({required this.field, required this.error});

  final String field;
  final String error;
}

class ValidationErrorResponseFactory
    extends JsonSchemaFactory<ValidationErrorResponse> {
  @override
  ValidationErrorResponse fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw Exception('Invalid JSON: $json');
    }
    return ValidationErrorResponse(
      field: json['field'] as String,
      error: json['error'] as String,
    );
  }
}

class PlainTextResponse extends Schema {
  PlainTextResponse({required this.message});

  final String message;
}

class PlainTextResponseFactory extends StringSchemaFactory<PlainTextResponse> {
  @override
  PlainTextResponse fromString(String plainString) {
    return PlainTextResponse(message: plainString);
  }
}

class PlainTextErrorResponse extends Schema {
  PlainTextErrorResponse({required this.errorMessage});

  final String errorMessage;
}

class PlainTextErrorResponseFactory
    extends StringSchemaFactory<PlainTextErrorResponse> {
  @override
  PlainTextErrorResponse fromString(String plainString) {
    return PlainTextErrorResponse(errorMessage: plainString);
  }
}

// Test Request Classes
class UserRequest extends RequestCommand<UserResponse> {
  @override
  String get path => '/user';

  @override
  SchemaFactory<UserResponse> get defaultResponseFactory =>
      UserResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class UserRequestWithError extends RequestCommand<UserResponse> {
  @override
  String get path => '/user';

  @override
  SchemaFactory<UserResponse> get defaultResponseFactory =>
      UserResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => ErrorResponseFactory();
}

class UserRequestSuccess extends RequestCommand<UserResponse> {
  @override
  String get path => '/user/success';

  @override
  SchemaFactory<UserResponse> get defaultResponseFactory =>
      UserResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => ErrorResponseFactory();
}

class UserRequestError extends RequestCommand<UserResponse> {
  @override
  String get path => '/user/error';

  @override
  SchemaFactory<UserResponse> get defaultResponseFactory =>
      UserResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => ErrorResponseFactory();
}

class UserRequestSuccessNoErrorFactory extends RequestCommand<UserResponse> {
  @override
  String get path => '/user/success';

  @override
  SchemaFactory<UserResponse> get defaultResponseFactory =>
      UserResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class ProductRequest extends RequestCommand<ProductResponse> {
  @override
  String get path => '/product';

  @override
  SchemaFactory<ProductResponse> get defaultResponseFactory =>
      ProductResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class ProductRequestWithError extends RequestCommand<ProductResponse> {
  @override
  String get path => '/product';

  @override
  SchemaFactory<ProductResponse> get defaultResponseFactory =>
      ProductResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory =>
      ValidationErrorResponseFactory();
}

class ProductRequestSuccess extends RequestCommand<ProductResponse> {
  @override
  String get path => '/product/success';

  @override
  SchemaFactory<ProductResponse> get defaultResponseFactory =>
      ProductResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory =>
      ValidationErrorResponseFactory();
}

class ProductRequestError extends RequestCommand<ProductResponse> {
  @override
  String get path => '/product/error';

  @override
  SchemaFactory<ProductResponse> get defaultResponseFactory =>
      ProductResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory =>
      ValidationErrorResponseFactory();
}

class PlainTextRequest extends RequestCommand<PlainTextResponse> {
  @override
  String get path => '/text';

  @override
  SchemaFactory<PlainTextResponse> get defaultResponseFactory =>
      PlainTextResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class PlainTextRequestWithError extends RequestCommand<PlainTextResponse> {
  @override
  String get path => '/text';

  @override
  SchemaFactory<PlainTextResponse> get defaultResponseFactory =>
      PlainTextResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory =>
      PlainTextErrorResponseFactory();
}

class PlainTextRequestSuccess extends RequestCommand<PlainTextResponse> {
  @override
  String get path => '/text/success';

  @override
  SchemaFactory<PlainTextResponse> get defaultResponseFactory =>
      PlainTextResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory =>
      PlainTextErrorResponseFactory();
}

class PlainTextRequestError extends RequestCommand<PlainTextResponse> {
  @override
  String get path => '/text/error';

  @override
  SchemaFactory<PlainTextResponse> get defaultResponseFactory =>
      PlainTextResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory =>
      PlainTextErrorResponseFactory();
}

// Test Network Invoker
class _TestNetworkInvoker implements INetworkInvoker {
  _TestNetworkInvoker({required this.port});

  final int port;
  late final String baseUrl;

  Future<void> init(String baseUrl) async {
    this.baseUrl = '$baseUrl:$port';
  }

  @override
  Future<NetworkResult<T>> request<T extends Schema>(
      RequestCommand<T> request) async {
    final response = await http.get(Uri.parse('$baseUrl${request.path}'));

    if (response.statusCode != 200) {
      // Use default error response factory
      return switch (request.defaultErrorResponseFactory) {
        JsonSchemaFactory(:final fromJson, :final type) => () {
            final jsonData = jsonDecode(response.body);
            final model = fromJson(jsonData);
            return SpecifiedResponseResult<T>(
              statusCode: response.statusCode,
              data: model,
              type: type,
            );
          }(),
        StringSchemaFactory(:final fromString, :final type) => () {
            final model = fromString(response.body);
            return SpecifiedResponseResult<T>(
              statusCode: response.statusCode,
              data: model,
              type: type,
            );
          }(),
        DynamicSchemaFactory(:final from, :final type) =>
          SpecifiedResponseResult<T>(
            statusCode: response.statusCode,
            data: from(response.body),
            type: type,
          ),
      };
    }

    // Use default response factory
    return switch (request.defaultResponseFactory) {
      JsonSchemaFactory<T>(:final fromJson) => () {
          final jsonData = jsonDecode(response.body);
          final model = fromJson(jsonData);
          return SuccessResponseResult(data: model, statusCode: 200);
        }(),
      StringSchemaFactory<T>(:final fromString) => () {
          final model = fromString(response.body);
          return SuccessResponseResult(data: model, statusCode: 200);
        }(),
      DynamicSchemaFactory<T>(:final from) => () {
          final model = from(response.body);
          return SuccessResponseResult(data: model, statusCode: 200);
        }(),
    };
  }
}
