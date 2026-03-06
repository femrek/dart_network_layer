import 'package:flutter_network_layer_dio/flutter_network_layer_dio.dart';

/// Concrete implementation of [AggregatedRequestState] that lazily
/// recalculates aggregated values when the progress data has changed.
final class AggregatedRequestStateImpl extends AggregatedRequestState {
  @override
  int get allTotal {
    _ensureCalculated();
    return _allTotal;
  }

  @override
  int get allProgress {
    _ensureCalculated();
    return _allProgress;
  }

  @override
  double get allProgressPercent {
    _ensureCalculated();
    return _allProgressPercent;
  }

  int _allTotal = 0;
  int _allProgress = 0;
  double _allProgressPercent = 0;
  bool _progressChanged = false;

  /// Returns the existing snapshot for [request], or creates a new one.
  RequestProgressState getOrCreateProgress(RequestCommand request) {
    return progressMap[request] ??= RequestProgressState(
      request: request,
      status: ProgressStatus.pending,
      total: 0,
      progress: 0,
      progressPercent: 0,
      unknownTotal: false,
      startTime: DateTime.now(),
    );
  }

  /// Removes the snapshot for [request] and marks progress as changed.
  RequestProgressState? removeProgress(RequestCommand request) {
    final result = progressMap.remove(request);
    if (result != null) markProgressChanged();
    return result;
  }

  /// call when one of the request's progress changed, to mark the snapshot need
  /// to recalculate the total progress.
  void markProgressChanged() {
    if (!_progressChanged) _progressChanged = true;
  }

  void _ensureCalculated() {
    if (_progressChanged) {
      _calculate();
      _progressChanged = false;
    }
  }

  void _calculate() {
    final progresses = progressMap.values;
    _allTotal = progresses.fold(0, (sum, e) => sum + e.total);
    _allProgress = progresses.fold(0, (sum, e) => sum + e.progress);
    _allProgressPercent = _allTotal > 0 ? _allProgress / _allTotal : 0.0;
  }
}
