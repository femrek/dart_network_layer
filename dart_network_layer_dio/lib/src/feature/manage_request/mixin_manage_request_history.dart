import 'dart:collection';

import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:dart_network_layer_dio/src/feature/manage_request/base_request_managing_network_invoker.dart';
import 'package:meta/meta.dart';

/// Callback for updates to the request history list.
///
/// Provides the added [RequestHistoryEntry], if a new entry was added.
///
/// If the function is called without new entry (e.g. when trimming the history
/// after changing [MixinManageRequestHistory.maxHistoryLength]), the parameter
/// will be `null`.
///
/// See also [MixinManageRequestHistory.maxHistoryLength] for controlling the
/// size of the history list and [MixinManageRequestHistory.requestHistory] for
/// accessing the current history entries anytime.
typedef OnHistoryUpdateCallback = void Function(RequestHistoryEntry?);

/// Mixin that tracks a history of completed network requests.
///
/// Maintains a capped, unmodifiable list of [RequestHistoryEntry] items,
/// each recorded when a request reaches a terminal [ProgressStatus].
mixin MixinManageRequestHistory on BaseRequestManagingNetworkInvoker {
  final List<RequestHistoryEntry> _requestHistory = [];
  int? _maxHistoryLength = 64;
  OnHistoryUpdateCallback? _onHistoryUpdate;

  /// Sets the callback to be invoked when the request history is updated.
  set onHistoryUpdate(OnHistoryUpdateCallback? onUpdate) {
    _onHistoryUpdate = onUpdate;
  }

  /// An unmodifiable view of all completed request history entries.
  ///
  /// Entries are ordered from oldest to newest and capped at
  /// [maxHistoryLength].
  List<RequestHistoryEntry> get requestHistory =>
      UnmodifiableListView(_requestHistory);

  /// Updates the status of a request's progress and finalizes if ended.
  @protected
  void resultRequestProgress(RequestCommand request, ProgressStatus status) {
    assert(status.end,
        'resultRequestProgress should only be called with an end status');

    final progress = progresses.removeProgress(request)?..endRequest(status);
    if (progress != null && _maxHistoryLength != 0) {
      final historyEntry = RequestHistoryEntry.fromProgress(progress);
      _requestHistory.add(historyEntry);
      _notifyHistoryUpdate(historyEntry);
    }
  }

  /// Gets or sets the maximum length of the request history.
  ///
  /// If set, the history will be trimmed to this length, keeping only the most
  /// recent entries.
  ///
  /// A value of `null` means no limit on history length. A value of `0` means
  /// no history will be kept.
  int? get maxHistoryLength => _maxHistoryLength;

  set maxHistoryLength(int? length) {
    _maxHistoryLength = length;
    _notifyHistoryUpdate(null);
  }

  void _notifyHistoryUpdate(RequestHistoryEntry? added) {
    final maxLength = _maxHistoryLength;
    if (maxLength != null && _requestHistory.length > maxLength) {
      _requestHistory.removeRange(0, _requestHistory.length - maxLength);
    }
    _onHistoryUpdate?.call(added);
  }
}
