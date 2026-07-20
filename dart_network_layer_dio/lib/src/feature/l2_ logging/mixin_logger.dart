import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:dart_network_layer_dio/src/feature/base/base1_network_invoker_logger.dart';
import 'package:logging/logging.dart';

/// Mixin adding logging capabilities to the network invoker.
mixin MixinLogger on Base1NetworkInvokerLogger {
  void log(LogType type, String message, [Object? e, StackTrace? s]) {
    logger?.log(type.defaultLevel, message, e, s);
  }

  void logRequest(RequestCommand requestCommand) {
    log(LogType.request, requestCommand.logString());
  }

  void logSuccess(RequestCommand request, SuccessResponseResult result) {
    log(
      LogType.response,
      'Response: ${result.statusCode} ${result.data.runtimeType} '
      'Request path: ${request.path}',
    );
  }

  void logUnsuccessful(
    RequestCommand request,
    SpecifiedResponseResult result,
  ) {
    log(
      LogType.unsuccessful,
      'Response: ${result.statusCode} ${result.data.runtimeType} '
      'Request path: ${request.path}',
    );
  }

  void logError(RequestCommand request, NetworkErrorResult result) {
    log(
      LogType.error,
      'Response: ${result.error.runtimeType} '
      'Request path: ${request.path}',
      result.error,
      result.error.stackTrace,
    );
  }

  void logCancel(RequestCommand request, NetworkErrorResult result) {
    assert(
      result.error is RequestCancelledError,
      'Expected RequestCancelledError',
    );
    log(
      LogType.canceled,
      'Request canceled: ${result.error.message} '
      'Request path: ${request.path}',
    );
  }
}

enum LogType {
  request(Level.FINE),
  response(Level.INFO),
  unsuccessful(Level.WARNING),
  error(Level.SEVERE),
  canceled(Level.INFO),
  ;

  const LogType(this.defaultLevel);

  final Level defaultLevel;
}
