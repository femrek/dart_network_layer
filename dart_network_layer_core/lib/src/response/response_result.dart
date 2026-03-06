import 'package:dart_network_layer_core/dart_network_layer_core.dart';

/// The standard response result of a request. [T] is the type of the success
/// response model.
sealed class NetworkResult<T extends Schema> {
  /// Creates a network result.
  const NetworkResult();
}

/// The standard response result of a request. It can be either a success
/// response result or an error response result. [T] is the type of the success
/// response model.
sealed class ResponseResult<T extends Schema> extends NetworkResult<T> {
  /// Creates a response result with the given status code.
  const ResponseResult({
    required this.statusCode,
  });

  /// The HTTP status code of the response.
  final int statusCode;
}

/// The standard response result of a request.
final class SuccessResponseResult<T extends Schema> extends ResponseResult<T> {
  /// Creates a success response result.
  ///
  /// [data] is the payload of the response. It must be an [Schema] and
  /// not null. An empty response model can be used if there is no data.
  /// [statusCode] is the status code of the response. Mostly, it is 200 for
  /// success responses.
  SuccessResponseResult({
    required this.data,
    required super.statusCode,
  });

  /// The payload of the response.
  final T data;
}

/// A response result for specific status codes that are handled differently.
///
/// This is used when the response matches a status code in
/// [RequestCommand.responseFactories] or uses the default error response
/// factory.
final class SpecifiedResponseResult<T extends Schema>
    extends ResponseResult<T> {
  /// Creates a specified response result.
  ///
  /// [statusCode] is the HTTP status code of the response.
  /// [data] is the parsed response data.
  SpecifiedResponseResult({
    required super.statusCode,
    required this.data,
    required this.type,
  });

  /// The response data parsed using the specified factory.
  final Schema data;

  /// The Schema class type of the response data.
  ///
  /// This is specified on response factories of the request command.
  final Type type;
}

/// The error response result of a request, if no response is received from the
/// server. It can be used for network errors, timeouts, or any other errors
/// that occur before receiving a response from the server.
final class NetworkErrorResult<T extends Schema> extends NetworkResult<T> {
  /// Creates a no response result, if no response is received from the server.
  /// [error] is the error that caused the failure. It must not be null.
  NetworkErrorResult({
    required this.error,
  });

  /// The error that caused the request to fail.
  final NetworkErrorBase error;
}
