import 'package:dart_network_layer_core/dart_network_layer_core.dart';

/// Defines the strategy for logging network request lifecycles.
abstract interface class NetworkLoggerStrategy {
  /// Logs when a network request is started.
  void logRequest<T extends Schema>(RequestCommand<T> request);

  /// Logs when a network request completes successfully.
  void logSuccess<T extends Schema>(
      RequestCommand<T> request, SuccessResponseResult<T> result);

  /// Logs when a network request completes but with an unsuccessful
  /// status code.
  void logUnsuccessful<T extends Schema>(
      RequestCommand<T> request, SpecifiedResponseResult<T> result);

  /// Logs when a network request fails with an error.
  void logError<T extends Schema>(
      RequestCommand<T> request, NetworkErrorResult<T> result);

  /// Logs when a network request is cancelled.
  void logCancel<T extends Schema>(
      RequestCommand<T> request, NetworkErrorResult<T> result);
}
