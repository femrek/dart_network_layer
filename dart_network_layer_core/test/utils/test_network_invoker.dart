import 'dart:convert';

import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:http/http.dart' as http;

class TestNetworkInvoker implements INetworkInvoker {
  TestNetworkInvoker({
    required this.port,
    String? host,
  }) {
    if (host != null) {
      baseUrl = '$host:$port';
    }
  }

  final int port;
  late final String baseUrl;

  Future<void> init(String baseUrl) async {
    this.baseUrl = '$baseUrl:$port';
  }

  @override
  Future<NetworkResult<T>> send<T extends Schema>(
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
                headers: {},
              );
            }(),
          StringSchemaFactory(:final fromString, :final type) => () {
              final model = fromString(response.body);
              return SpecifiedResponseResult<T>(
                statusCode: response.statusCode,
                data: model,
                type: type,
                headers: {},
              );
            }(),
          DynamicSchemaFactory(:final from, :final type) =>
            SpecifiedResponseResult<T>(
              statusCode: response.statusCode,
              data: from(response.body),
              type: type,
              headers: {},
            ),
          BinarySchemaFactory(:final from) => () {
              final model = from(response.bodyBytes);
              return SpecifiedResponseResult<T>(
                statusCode: response.statusCode,
                data: model,
                type: T,
                headers: {},
              );
            }(),
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
              headers: {},
            );
          }(),
        StringSchemaFactory(:final fromString, :final type) => () {
            final model = fromString(response.body);
            return SpecifiedResponseResult<T>(
              statusCode: response.statusCode,
              data: model,
              type: type,
              headers: {},
            );
          }(),
        DynamicSchemaFactory(:final from, :final type) =>
          SpecifiedResponseResult<T>(
            statusCode: response.statusCode,
            data: from(response.body),
            type: type,
            headers: {},
          ),
        BinarySchemaFactory(:final from) => () {
            final model = from(response.bodyBytes);
            return SpecifiedResponseResult<T>(
              statusCode: response.statusCode,
              data: model,
              type: T,
              headers: {},
            );
          }(),
      };
    }

    final body = response.body;

    return switch (request.defaultResponseFactory) {
      JsonSchemaFactory<T>(:final fromJson) => () {
          final jsonData = jsonDecode(body);
          final model = fromJson(jsonData);
          return SuccessResponseResult(
            data: model,
            statusCode: 200,
            headers: {},
          );
        }(),
      StringSchemaFactory<T>(:final fromString) => () {
          final model = fromString(body);
          return SuccessResponseResult(
            data: model,
            statusCode: 200,
            headers: {},
          );
        }(),
      DynamicSchemaFactory<T>(:final from) => () {
          final model = from(body);
          return SuccessResponseResult(
            data: model,
            statusCode: 200,
            headers: {},
          );
        }(),
      BinarySchemaFactory<BinarySchema>(:final from) => () {
          final model = from(response.bodyBytes) as T;
          return SuccessResponseResult(
            data: model,
            statusCode: 200,
            headers: {},
          );
        }(),
    };
  }
}
