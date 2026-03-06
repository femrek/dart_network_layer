import 'dart:math';

import 'package:flutter_network_layer_dio/flutter_network_layer_dio.dart';
import 'package:flutter_network_layer_dio/src/feature/manage_request/base_request_managing_network_invoker.dart';
import 'package:meta/meta.dart';

/// Callback for progress updates across all requests.
typedef OnProgressUpdateCallback = void Function(AggregatedProgressState);

/// Mixin for managing request progress and notifying listeners.
mixin MixinManageRequestProgress on BaseRequestManagingNetworkInvoker {
  /// Internal callback for progress updates.
  OnProgressUpdateCallback? _onUpdateRequestProgress;

  /// Sets the callback to be invoked on progress updates.
  set onUpdateRequestProgress(OnProgressUpdateCallback? onUpdate) {
    _onUpdateRequestProgress = onUpdate;
  }

  /// Tracks progress for all requests.
  final AggregatedProgressState progressesSnapshot = AggregatedProgressState();

  /// Updates the progress for a specific request and notifies listeners.
  @protected
  void updateAnyRequestProgress({
    required RequestCommand request,
    required int count,
    required int total,
    required bool isSend,
  }) {
    progressesSnapshot.getOrCreateProgress(request)
      ..status = isSend ? ProgressStatus.sending : ProgressStatus.receiving
      ..progress = count
      ..total = total >= 0 ? total : 0
      ..unknownTotal = total < 0
      ..progressPercent = total > 0 && count > 0 ? min(count / total, 1) : 0.0;
    progressesSnapshot.markProgressChanged();
    _onUpdateRequestProgress?.call(progressesSnapshot);

    if (isSend) {
      request.onSendProgressUpdate?.call(count, total);
    } else {
      request.onReceiveProgressUpdate?.call(count, total);
    }
  }

  /// Creates a progress entry for a new request.
  @protected
  void createRequestProgress(RequestCommand request) {
    progressesSnapshot.getOrCreateProgress(request);
  }

  /// Updates the status of a request's progress and finalizes if ended.
  @protected
  void resultRequestProgress(RequestCommand request, ProgressStatus status) {
    final progress = progressesSnapshot.getOrCreateProgress(request)
      ..status = status;
    if (status.end) {
      progress
        ..progress = progress.total
        ..progressPercent = 1.0;
    }
  }
}
