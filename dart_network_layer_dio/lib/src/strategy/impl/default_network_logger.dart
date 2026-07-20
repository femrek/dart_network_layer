import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:dart_network_layer_dio/src/strategy/network_logger_strategy.dart';
import 'package:logging/logging.dart';

/// A default implementation of [NetworkLoggerStrategy] using the
/// `logging` package.
class DefaultNetworkLogger implements NetworkLoggerStrategy {
  /// Creates a [DefaultNetworkLogger] with the given [logger].
  DefaultNetworkLogger({Logger? logger})
      : logger = logger ?? Logger('DioNetworkInvoker');

  /// The logger instance used to output logs.
  final Logger logger;

  void _log(Level level, String message, [Object? e, StackTrace? s]) {
    logger.log(level, message, e, s);
  }

  @override
  void logRequest<T extends Schema>(RequestCommand<T> request) {
    _log(Level.FINE, request.logString());
  }

  @override
  void logSuccess<T extends Schema>(
      RequestCommand<T> request, SuccessResponseResult<T> result) {
    _log(
      Level.INFO,
      'Response: ${result.statusCode} ${result.data.runtimeType} '
      'Request path: ${request.path}',
    );
  }

  @override
  void logUnsuccessful<T extends Schema>(
      RequestCommand<T> request, SpecifiedResponseResult<T> result) {
    _log(
      Level.WARNING,
      'Response: ${result.statusCode} ${result.data.runtimeType} '
      'Request path: ${request.path}',
    );
  }

  @override
  void logError<T extends Schema>(
      RequestCommand<T> request, NetworkErrorResult<T> result) {
    _log(
      Level.SEVERE,
      'Response: ${result.error.runtimeType} '
      'Request path: ${request.path}',
      result.error,
      result.error.stackTrace,
    );
  }

  @override
  void logCancel<T extends Schema>(
      RequestCommand<T> request, NetworkErrorResult<T> result) {
    assert(
      result.error is RequestCancelledError,
      'Expected RequestCancelledError',
    );
    _log(
      Level.INFO,
      'Request canceled: ${result.error.message} '
      'Request path: ${request.path}',
    );
  }
}
