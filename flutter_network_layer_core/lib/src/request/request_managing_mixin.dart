import 'package:flutter_network_layer_core/flutter_network_layer_core.dart';

/// A mixin to add request canceling capability to a [RequestCommand].
mixin RequestManagingMixin<T extends Schema> {
  void Function()? _onCancel;
  double _sentProgress = 0;
  double _receivedProgress = 0;

  /// Cancels the in-flight request associated with this command.
  ///
  /// Call this method at any time after the request has been handed to an
  /// invoker (e.g. via [RequestCommand.invoke] or
  /// [INetworkInvoker.request]) and before it completes. The invoker will
  /// abort the HTTP call and return a [NetworkErrorResult] whose [error] is a
  /// [RequestCancelledError].
  ///
  /// **Lifecycle states and their effects:**
  ///
  /// | State | Effect of calling `cancel()` |
  /// |---|---|
  /// | Not yet submitted to an invoker | No-op — [_onCancel] is `null`. |
  /// | In-flight | Invoker aborts the request; result becomes `NetworkErrorResult<RequestCancelledError>`. |
  /// | Completed or already cancelled | Throws [RequestAlreadyCancelledError]. |
  ///
  /// **Throws**
  ///
  /// - [RequestAlreadyCancelledError] — if the request has already finished
  ///   (successfully, with an error, or via a previous cancellation). The
  ///   invoker replaces the cancel callback with one that throws this error
  ///   once the request leaves the in-flight state.
  ///
  /// Example:
  /// ```dart
  /// final command = GetUserCommand(userId: '42');
  /// final resultFuture = invoker.request(command);
  ///
  /// // Cancel if the user navigates away.
  /// command.cancel();
  ///
  /// final result = await resultFuture;
  /// if (result case NetworkErrorResult(:final RequestCancelledError error)) {
  ///   print('Request was cancelled: ${error.message}');
  /// }
  /// ```
  void cancel() {
    _onCancel?.call();
  }

  /// Internal setter used by the invoker to attach (or replace) the
  /// cancellation logic for this command.
  ///
  /// Invokers set this callback twice during the lifecycle of a request:
  ///
  /// 1. **Before sending** — set to a closure that cancels the underlying
  ///    HTTP token and removes the command from the active-request registry.
  /// 2. **After completion** (`finally` block) — replaced with a closure that
  ///    throws [RequestAlreadyCancelledError], preventing stale cancellations.
  ///
  /// This setter is not intended to be called from application code.
  set onCancel(void Function() callback) => _onCancel = callback;

  /// Getter for send progress.
  double get sentProgress => _sentProgress;

  /// Getter for receive progress.
  double get receivedProgress => _receivedProgress;

  /// Helper to update progress (used by Invoker)
  void updateProgress(int count, int total, {required bool isSend}) {
    if (total <= 0) return;
    final progress = count / total;
    if (isSend) {
      _sentProgress = progress;
    } else {
      _receivedProgress = progress;
    }
  }
}
