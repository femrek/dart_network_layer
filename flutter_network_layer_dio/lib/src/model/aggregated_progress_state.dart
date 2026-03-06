import 'package:flutter_network_layer_dio/flutter_network_layer_dio.dart';

/// Aggregates progress snapshots for all active network requests.
final class AggregatedProgressState {
  final Map<RequestCommand, RequestProgressState> _progressMap = {};

  /// Returns the existing snapshot for [request], or creates a new one.
  RequestProgressState getOrCreateProgress(RequestCommand request) {
    return _progressMap[request] ??= RequestProgressState(
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
    final result = _progressMap.remove(request);
    if (result != null) markProgressChanged();
    return result;
  }

  /// The combined total bytes across all tracked requests.
  int get allTotal {
    if (_progressChanged) {
      _calculate();
      _progressChanged = false;
    }
    return _allTotal;
  }

  /// The combined transferred bytes across all tracked requests.
  int get allProgress {
    if (_progressChanged) {
      _calculate();
      _progressChanged = false;
    }
    return _allProgress;
  }

  /// The overall transfer ratio across all tracked requests (0.0–1.0).
  double get allProgressPercent {
    if (_progressChanged) {
      _calculate();
      _progressChanged = false;
    }
    return _allProgressPercent;
  }

  /// call when one of the request's progress changed, to mark the snapshot need
  /// to recalculate the total progress.
  void markProgressChanged() {
    if (!_progressChanged) _progressChanged = true;
  }

  int _allTotal = 0;
  int _allProgress = 0;
  double _allProgressPercent = 0;
  bool _progressChanged = false;

  void _calculate() {
    final progresses = _progressMap.values;
    _allTotal = progresses.fold(0, (sum, e) => sum + e.total);
    _allProgress = progresses.fold(0, (sum, e) => sum + e.progress);
    _allProgressPercent = _allTotal > 0 ? _allProgress / _allTotal : 0.0;
  }
}
