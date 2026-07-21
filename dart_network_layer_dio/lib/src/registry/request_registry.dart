import 'dart:collection';
import 'dart:math';

import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:dart_network_layer_dio/src/model/aggregated_request_state_impl.dart';
import 'package:dart_network_layer_dio/src/model/models.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

/// Callback for progress updates across all requests.
typedef OnProgressUpdateCallback = void Function(AggregatedRequestState);

/// Callback for updates to the request history list.
typedef OnHistoryUpdateCallback = void Function(RequestHistoryEntry?);

/// Owns and coordinates all active-request state:
/// progress tracking, cancel tokens, and request history.
class RequestRegistry {
  final AggregatedRequestStateImpl _progresses = AggregatedRequestStateImpl();

  // --- cancel token map ---
  final Map<RequestCommand, CancelToken> _cancelTokens = Map.identity();

  // --- history ---
  final List<RequestHistoryEntry> _history = [];
  int? _maxHistoryLength = 64;

  /// Callback to be invoked when the history list is updated.
  OnHistoryUpdateCallback? onHistoryUpdate;

  // --- progress callback ---
  /// Callback to be invoked when progress changes across any tracked request.
  OnProgressUpdateCallback? onProgressUpdate;

  /// Returns the aggregated progress state for all active requests.
  AggregatedRequestState get activeRequests => _progresses;

  /// An unmodifiable view of all completed request history entries.
  List<RequestHistoryEntry> get requestHistory =>
      UnmodifiableListView(_history);

  /// Map of request commands to their current [CancelToken].
  @visibleForTesting
  Map<RequestCommand, CancelToken> get requestMap => _cancelTokens;

  /// Gets or sets the maximum length of the request history.
  int? get maxHistoryLength => _maxHistoryLength;

  set maxHistoryLength(int? length) {
    _maxHistoryLength = length;
    _notifyHistoryUpdate(null);
  }

  /// Sets up a cancel token for the given request and registers it.
  CancelToken registerRequest(RequestCommand request) {
    final token = CancelToken();
    _cancelTokens[request] = token;
    // ignore: invalid_use_of_internal_member, this is the registry
    request.setOnCancel(() => cancelRequest(request));

    // progress
    _progresses
      ..getOrCreateProgress(request)
      ..markProgressChanged();
    onProgressUpdate?.call(_progresses);
    return token;
  }

  /// Removes the token without cancelling it. Used in `finally` blocks.
  void unregisterRequest(RequestCommand request) {
    _cancelTokens.remove(request);
  }

  /// Cancels a specific request if it is currently active.
  void cancelRequest(RequestCommand request) {
    // Remove first, cancel after
    final token = _cancelTokens.remove(request);
    if (token != null && !token.isCancelled) {
      token.cancel('Cancelled by user');
    }
  }

  /// Cancels all active requests.
  void cancelAll() {
    final tokens = Map<RequestCommand, CancelToken>.of(_cancelTokens);
    _cancelTokens.clear();
    for (final token in tokens.values) {
      if (!token.isCancelled) {
        token.cancel('Cancelled All');
      }
    }
  }

  /// Updates the progress for a specific request and notifies listeners.
  void updateProgress({
    required RequestCommand request,
    required int count,
    required int total,
    required bool isSend,
  }) {
    _progresses.getOrCreateProgress(request)
      ..status = isSend ? ProgressStatus.sending : ProgressStatus.receiving
      ..progress = count
      ..total = total >= 0 ? total : 0
      ..unknownTotal = total < 0
      ..progressPercent = total > 0 && count > 0 ? min(count / total, 1) : 0.0;
    _progresses.markProgressChanged();
    onProgressUpdate?.call(_progresses);

    if (isSend) {
      request.onSendProgressUpdate?.call(count, total);
    } else {
      request.onReceiveProgressUpdate?.call(count, total);
    }
  }

  /// Updates the status of a request's progress and finalizes if ended.
  void finalizeRequest(RequestCommand request, ProgressStatus status) {
    assert(
        status.end, 'finalizeRequest should only be called with an end status');

    final progress = _progresses.removeProgress(request)?..endRequest(status);
    if (progress != null && _maxHistoryLength != 0) {
      final historyEntry = RequestHistoryEntry.fromProgress(progress);
      _history.add(historyEntry);
      _notifyHistoryUpdate(historyEntry);
    }
  }

  void _notifyHistoryUpdate(RequestHistoryEntry? added) {
    final maxLength = _maxHistoryLength;
    if (maxLength != null && _history.length > maxLength) {
      _history.removeRange(0, _history.length - maxLength);
    }
    onHistoryUpdate?.call(added);
  }
}
