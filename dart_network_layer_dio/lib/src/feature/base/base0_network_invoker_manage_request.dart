import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:dart_network_layer_dio/src/model/aggregated_request_state_impl.dart';
import 'package:meta/meta.dart';

/// Base class for managing network request state and progress tracking.
///
/// This is the first level of the network invoker hierarchy. It provides
/// infrastructure for tracking active requests and their progress states.
///
/// **Responsibilities:**
/// - Track all active network requests through [progresses]
/// - Expose aggregated request state via [activeRequests]
/// - Serve as the foundation for higher-level invoker implementations
///
/// This class should not be used directly. Subclasses add specific
/// implementation details (progress management, cancellation, request
/// execution, etc.).
abstract class Base0NetworkInvokerRequestManaging implements INetworkInvoker {
  /// Tracks progress for all active requests.
  ///
  /// This [AggregatedRequestStateImpl] maintains the state of every
  /// request sent through this invoker, including progress updates,
  /// completion status, and error information.
  @protected
  final AggregatedRequestStateImpl progresses = AggregatedRequestStateImpl();

  /// Returns the aggregated progress state for all active requests.
  ///
  /// This exposes a read-only view of [progresses] to external
  /// listeners who want to observe request progress and completion.
  ///
  /// **Example:**
  /// ```dart
  /// final invoker = DioNetworkInvoker.fromBaseUrl(url);
  /// invoker.activeRequests.listen((state) {
  ///   print('Active requests: ${state.activeCount}');
  /// });
  /// ```
  AggregatedRequestState get activeRequests => progresses;
}
