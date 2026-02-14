import 'dart:convert';

import 'package:flutter_network_layer_core/flutter_network_layer_core.dart';
import 'package:http/http.dart' as http;
import 'package:http_test_server/http_test_server.dart';
import 'package:test/test.dart';

import 'utils/test_request_samples.dart';
import 'utils/test_response_samples.dart';

void main() async {
  group('basic tests', () {
    test('Error Response', () async {
      // run the server
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/basic_test_error']),
          handler: (request) =>
              '{"message": "Bad Request", "errorField": "error_value"}',
          responseStatusCode: 400,
        ),
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/basic_test']),
          handler: (request) => '{"field1": "pong"}',
        ),
      ]);

      final invoker = _SampleNetworkInvoker(port: server.port);
      await invoker.init('http://${server.address.address}');

      // error response test
      {
        final request = RequestTest1Error(field1: 'trigger_error');
        final result = await invoker.request(request);

        expect(result, isA<SpecifiedResponseResult>());

        // result type check and cast
        if (result is SpecifiedResponseResult<ResponseTest1>) {
          expect(result.statusCode, 400);
          final errorData = result.data;
          expect(errorData, isA<ResponseTestError>());
          if (errorData is ResponseTestError) {
            expect(errorData.errorField, 'error_value');
            expect(errorData.message, 'Bad Request');
          } else {
            fail('Expected ResponseTestError but got ${errorData.runtimeType}');
          }
        } else {
          fail(
              'Expected SpecifiedResponseResult but got ${result.runtimeType}');
        }
      }

      // success response test
      {
        final request = RequestTest1(field1: 'ping');
        final result = await invoker.request(request);

        expect(result, isA<SuccessResponseResult>());

        // result type check
        if (result is SuccessResponseResult<ResponseTest1>) {
          expect(result.data.field1, 'pong');
          expect(result.statusCode, 200);
        } else {
          fail('Expected SuccessResponseResult but got ${result.runtimeType}');
        }
      }
    });
  });
}

class _SampleNetworkInvoker implements INetworkInvoker {
  _SampleNetworkInvoker({
    required this.port,
  });

  final int port;
  late final String baseUrl;

  Future<void> init(String baseUrl) async {
    this.baseUrl = '$baseUrl:$port';
  }

  @override
  Future<NetworkResult<T>> request<T extends Schema>(
      RequestCommand<T> request) async {
    final response = await http.get(Uri.parse('$baseUrl${request.path}'));

    // Check if there's a specified factory for this status code
    final specifiedFactory = request.responseFactories[response.statusCode];

    if (response.statusCode != 200) {
      if (specifiedFactory != null) {
        // Use the specified factory for this status code
        return switch (specifiedFactory) {
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

    final body = response.body;

    return switch (request.defaultResponseFactory) {
      JsonSchemaFactory<T>(:final fromJson) => () {
          final jsonData = jsonDecode(body);
          final model = fromJson(jsonData);
          return SuccessResponseResult(data: model, statusCode: 200);
        }(),
      StringSchemaFactory<T>(:final fromString) => () {
          final model = fromString(body);
          return SuccessResponseResult(data: model, statusCode: 200);
        }(),
      DynamicSchemaFactory<T>(:final from) => () {
          final model = from(body);
          return SuccessResponseResult(data: model, statusCode: 200);
        }(),
    };
  }
}
