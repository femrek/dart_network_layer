import 'package:flutter_network_layer_dio/flutter_network_layer_dio.dart';
import 'package:flutter_network_layer_dio/src/model/aggregated_request_state_impl.dart';
import 'package:meta/meta.dart';

/// Base class for managing network requests and their progress.
///
/// Implements [INetworkInvoker] and provides request tracking and progress
/// snapshotting.
abstract class BaseRequestManagingNetworkInvoker implements INetworkInvoker {
  /// Tracks progress for all active requests.
  @protected
  final AggregatedRequestStateImpl progresses = AggregatedRequestStateImpl();

  /// Returns the aggregated progress state for all active requests.
  AggregatedRequestState get activeRequests => progresses;
}
