import 'package:dart_network_layer_core/dart_network_layer_core.dart';

/// Defines the strategy for logging network request lifecycles.
abstract interface class NetworkLoggerStrategy {
  /// Logs when a network request is started.
  void logRequest<T extends Schema>(RequestCommand<T> request);

  /// Logs when a network request completes successfully.
  ///
  /// The [result] is a [SpecifiedResponseResult] that either originated as a
  /// [SuccessResponseResult] or was validated as successful by the invoker's
  /// validateStatus check.
  void logSuccess<T extends Schema>(
      RequestCommand<T> request, SpecifiedResponseResult<T> result);

  /// Logs when a network request completes but with an unsuccessful
  /// status code.
  void logUnsuccessful<T extends Schema>(
      RequestCommand<T> request, SpecifiedResponseResult<T> result);

  /// Logs when a network request fails with an error.
  void logError<T extends Schema>(
      RequestCommand<T> request, NetworkErrorResult<T> result);
}
