/// The base class for errors that occur in the invokers of this package.
///
/// This classes are used to log internal errors or
sealed class NetworkErrorBase implements Exception {
  const NetworkErrorBase({
    required this.message,
    required this.stackTrace,
    this.error,
  });

  /// The explanation of the error.
  final String message;

  /// The stack trace of the point where the error is thrown.
  final StackTrace stackTrace;

  /// The thrown error object if it is forwarding.
  final Object? error;
}

/// The error type for errors occurred in the network invoker about the response
/// type.
final class NetworkErrorInvalidResponseType extends NetworkErrorBase {
  /// Creates a network error response.
  NetworkErrorInvalidResponseType({
    required super.message,
    required super.stackTrace,
    required this.response,
    required this.statusCode,
    super.error,
  });

  /// The response data that caused the error.
  final dynamic response;

  /// The HTTP status code of the response.
  final int statusCode;

  @override
  String toString() {
    return 'NetworkErrorInvalidResponseType: $message';
  }
}

/// The error type for errors occurred in the network invoker about the payload
/// type.
final class NetworkErrorInvalidPayload extends NetworkErrorBase {
  /// Creates a network error response.
  NetworkErrorInvalidPayload({
    required super.message,
    required super.stackTrace,
    super.error,
  });

  @override
  String toString() {
    return 'NetworkErrorInvalidPayload: $message';
  }
}

/// The error type for errors occurred in the network invoker about the invoker
/// instance being null.
final class NullInvokerError extends NetworkErrorBase {
  /// Creates a null invoker error.
  const NullInvokerError({
    required super.message,
    required super.stackTrace,
    super.error,
  });

  @override
  String toString() {
    return 'NullInvokerError: $message';
  }
}

/// The error type thrown when a request is cancelled while it is still
/// in-flight.
///
/// Example:
/// ```dart
/// final result = await invoker.request(command);
/// if (result case NetworkErrorResult(:final RequestCancelledError error)) {
///   print('Request was cancelled: ${error.message}');
/// }
/// ```
final class RequestCancelledError extends NetworkErrorBase {
  /// Creates a request cancelled error.
  const RequestCancelledError({
    required super.message,
    required super.stackTrace,
    super.error,
  });

  @override
  String toString() {
    return 'RequestCancelledError: $message';
  }
}

/// The error type thrown when trying to cancel a request that has already
/// completed or been cancelled.
///
/// Example:
/// ```dart
/// try {
///   command.cancel();
/// } on RequestAlreadyCancelledError catch (e) {
///   print('Too late — request already finished: ${e.message}');
/// }
/// ```
final class RequestAlreadyCancelledError extends NetworkErrorBase {
  /// Creates a request already cancelled error.
  const RequestAlreadyCancelledError({
    required super.message,
    required super.stackTrace,
    super.error,
  });

  @override
  String toString() {
    return 'RequestAlreadyCancelledError: $message';
  }
}

/// The error type for general type of errors occurred in the network invoker.
final class NetworkError extends NetworkErrorBase {
  /// Creates a network error.
  const NetworkError({
    required super.message,
    required super.stackTrace,
    super.error,
    this.statusCode,
    this.response,
  });

  /// The response data if available.
  final dynamic response;

  /// The HTTP status code if available.
  final int? statusCode;

  @override
  String toString() {
    return 'NetworkError: $message';
  }
}
