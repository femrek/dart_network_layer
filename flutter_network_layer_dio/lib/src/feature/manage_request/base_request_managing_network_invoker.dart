import 'package:flutter_network_layer_dio/flutter_network_layer_dio.dart';

/// Base class for managing network requests and their progress.
///
/// Implements [INetworkInvoker] and provides request tracking and progress
/// snapshotting.
abstract class BaseRequestManagingNetworkInvoker implements INetworkInvoker {
  /// Tracks progress for all requests.
  final AggregatedProgressState progressesSnapshot = AggregatedProgressState();
}
