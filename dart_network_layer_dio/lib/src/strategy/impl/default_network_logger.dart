import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:dart_network_layer_dio/src/strategy/network_logger_strategy.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

/// A default implementation of [NetworkLoggerStrategy] using the
/// `logging` package.
class DefaultNetworkLogger implements NetworkLoggerStrategy {
  /// Creates a [DefaultNetworkLogger] with the given [logger].
  DefaultNetworkLogger({
    Logger? logger,
    this.includeHeaderValuesOfRequest,
    this.includePayloadOfRequest,
    this.includeQueryParameterValuesOfRequest,
  }) : logger = logger ?? Logger('DioNetworkInvoker');

  /// The logger instance used to output logs.
  @protected
  final Logger logger;

  /// Whether to include header values in the request log output.
  @protected
  final bool? includeHeaderValuesOfRequest;

  /// Whether to include payload in the request log output.
  @protected
  final bool? includePayloadOfRequest;

  /// Whether to include query parameter values in the request log output.
  @protected
  final bool? includeQueryParameterValuesOfRequest;

  /// Logs a message with the given [level], [message], and optional error [e]
  /// and stack trace [s].
  void log(Level level, String message, [Object? e, StackTrace? s]) {
    logger.log(level, message, e, s);
  }

  @override
  void logRequest<T extends Schema>(RequestCommand<T> request) {
    log(
      Level.FINE,
      request.logString(
        includeHeaderValues: includeHeaderValuesOfRequest,
        includePayload: includePayloadOfRequest,
        includeQueryParameterValues: includeQueryParameterValuesOfRequest,
      ),
    );
  }

  @override
  void logSuccess<T extends Schema>(
    RequestCommand<T> request,
    SpecifiedResponseResult<T> result,
  ) {
    log(
      Level.INFO,
      'Response: ${result.statusCode} ${result.data.runtimeType} '
      'Request path: ${request.path}',
    );
  }

  @override
  void logUnsuccessful<T extends Schema>(
    RequestCommand<T> request,
    SpecifiedResponseResult<T> result,
  ) {
    log(
      Level.WARNING,
      'Response: ${result.statusCode} ${result.data.runtimeType} '
      'Request path: ${request.path}',
    );
  }

  @override
  void logError<T extends Schema>(
    RequestCommand<T> request,
    NetworkErrorResult<T> result,
  ) {
    final error = result.error;
    switch (error) {
      case NetworkErrorInvalidResponseType():
      case NetworkErrorInvalidPayload():
      case NetworkError():
        log(
          Level.SEVERE,
          'Error while request path: ${request.path} '
          'Response: ${error.runtimeType} '
          'Error: ${error.message}',
          error,
          error.stackTrace,
        );
      case RequestCancelledError():
        log(
          Level.INFO,
          'Request canceled: ${error.message} '
          'Request path: ${request.path}',
        );
    }
  }
}
