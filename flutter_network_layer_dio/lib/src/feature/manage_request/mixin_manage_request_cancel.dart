import 'package:dio/dio.dart';
import 'package:flutter_network_layer_dio/flutter_network_layer_dio.dart';
import 'package:flutter_network_layer_dio/src/feature/manage_request/base_request_managing_network_invoker.dart';
import 'package:meta/meta.dart';

/// A mixin to add request canceling capability to a [RequestCommand].
mixin MixinManageRequestCancel on BaseRequestManagingNetworkInvoker {
  /// Holds active cancel tokens mapped to their specific command.
  ///
  /// **Mutation protocol — always remove before cancelling:**
  /// Whenever a token needs to be cancelled, its entry must be removed from
  /// this map *first*, and only then the token itself is cancelled. This means
  /// the `finally` block in [INetworkInvoker.request] (which also calls
  /// `_activeRequests.remove`) will always find the slot already gone and
  /// performs a harmless no-op, eliminating any window where both a cancel call
  /// and the `finally` block could race to act on the same token.
  @protected
  @visibleForTesting
  final Map<RequestCommand, CancelToken> requestMap = {};

  /// Sets up a cancel token for the given request and registers it in
  /// [requestMap].
  @protected
  CancelToken setupCancelToken(RequestCommand request) {
    final token = CancelToken();
    requestMap[request] = token;
    request.onCancel = () => cancelRequest(request);
    return token;
  }

  /// Cancels a specific request if it is currently active.
  ///
  /// The entry is removed from [requestMap] **before** the token is
  /// cancelled, so the `finally` block in [request] always finds the slot
  /// already gone and performs a harmless no-op. This eliminates the window
  /// where both [cancelRequest] and the `finally` block could race to act on
  /// the same token.
  void cancelRequest(RequestCommand request) {
    // Remove first, cancel after — the finally block's remove is then a no-op.
    final token = requestMap.remove(request);
    if (token != null && !token.isCancelled) {
      token.cancel('Cancelled by user');
    }
  }

  /// Cancels all active requests.
  ///
  /// The map is drained atomically (snapshot + clear) before any token is
  /// cancelled, so concurrent completions in the `finally` block cannot
  /// interfere with the iteration.
  void cancelAll() {
    // Snapshot and clear atomically before cancelling any token.
    final tokens = Map<RequestCommand, CancelToken>.of(requestMap);
    requestMap.clear();
    for (final token in tokens.values) {
      if (!token.isCancelled) {
        token.cancel('Cancelled All');
      }
    }
  }
}
