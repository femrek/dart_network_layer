// ignore_for_file: avoid_print just an example

import 'package:dart_network_layer_core/dart_network_layer_core.dart';

void main() async {
  final networkManager = NetworkManager();
  await networkManager.init('https://example.com');

  final response = await networkManager.request(RequestExample());
  switch (response) {
    case SuccessResponseResult(:final data):
      print(data.message);
    case SpecifiedResponseResult(:final statusCode):
      print('Error response received with status: $statusCode');
    case NetworkErrorResult(:final error):
      print('Network Error: ${error.message}');
  }
}

/// A dummy network manager that returns a dummy response.
class NetworkManager implements INetworkInvoker {
  Future<void> init(String baseUrl) async {}

  @override
  Future<NetworkResult<T>> request<T extends Schema>(
      RequestCommand<T> request) async {
    final dummyResponseJson = <String, dynamic>{'message': 'Hello, World!'};

    return switch (request.defaultResponseFactory) {
      JsonSchemaFactory<T>(:final fromJson) => () {
          final dummyResponse = fromJson(dummyResponseJson);
          return SuccessResponseResult(
            statusCode: 200,
            data: dummyResponse,
          );
        }(),
      StringSchemaFactory<T>() => NetworkErrorResult(
          error: NetworkErrorInvalidResponseType(
            message: 'The sample model is not a JSON response model.',
            stackTrace: StackTrace.current,
            response: null,
            statusCode: 0,
          ),
        ),
      DynamicSchemaFactory<T>(:final from) => () {
          final response = from(dummyResponseJson);
          return SuccessResponseResult(
            statusCode: 200,
            data: response,
          );
        }(),
      BinarySchemaFactory<BinarySchema>() => NetworkErrorResult(
          error: NetworkErrorInvalidResponseType(
            message: 'The sample model is not a binary response model.',
            stackTrace: StackTrace.current,
            response: null,
            statusCode: 0,
          ),
        ),
    };
  }
}

class RequestExample extends RequestCommand<ResponseExample> {
  @override
  Map<String, dynamic> get headers => const {};

  @override
  HttpRequestMethod get method => HttpRequestMethod.get;

  @override
  OnProgressCallback? get onReceiveProgressUpdate => null;

  @override
  OnProgressCallback? get onSendProgressUpdate => null;

  @override
  String get path => '/example';

  @override
  SchemaFactory<ResponseExample> get defaultResponseFactory =>
      ResponseExampleFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;

  @override
  String toString() {
    return 'RequestExample{path: $path, '
        'method: $method, '
        'data: $payload, '
        'headers: $headers, '
        'onSendProgressUpdate: $onSendProgressUpdate, '
        'onReceiveProgressUpdate: $onReceiveProgressUpdate, '
        'defaultResponseFactory: $defaultResponseFactory}';
  }
}

class ResponseExample extends Schema {
  const ResponseExample({required this.message});

  const ResponseExample.empty() : message = '';

  final String message;

  @override
  String toString() {
    return 'ResponseExample{message: $message}';
  }
}

class ResponseExampleFactory extends JsonSchemaFactory<ResponseExample> {
  factory ResponseExampleFactory() => _instance;

  const ResponseExampleFactory._internal();

  static const ResponseExampleFactory _instance =
      ResponseExampleFactory._internal();

  @override
  ResponseExample fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw ArgumentError.value(json, 'json', 'The value is not a map.');
    }

    return ResponseExample(message: json['message'] as String);
  }
}
