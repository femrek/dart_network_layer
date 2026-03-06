import 'package:flutter_network_layer_dio/flutter_network_layer_dio.dart';

/// Represents the progress state of a single network request.
class RequestProgressState {
  /// Creates a [RequestProgressState] for the given [request].
  RequestProgressState({
    required this.request,
    required this.total,
    required this.progress,
    required this.progressPercent,
    required this.unknownTotal,
    required ProgressStatus status,
  }) : _status = status;

  /// The request associated with this snapshot.
  final RequestCommand request;

  ProgressStatus _status;

  /// The total bytes of the request or response.
  int total;

  /// The number of bytes transferred so far.
  int progress;

  /// The transfer completion ratio, between 0.0 and 1.0.
  double progressPercent;

  /// Whether the total size is unknown (e.g., for chunked transfers).
  bool unknownTotal;

  /// The current status of the request.
  ProgressStatus get status => _status;

  set status(ProgressStatus newStatus) {
    final newStatusInvalid = status.end && !newStatus.end;
    if (!newStatusInvalid) {
      _status = newStatus;
      if (newStatus.end) {
        progress = total;
        progressPercent = 1.0;
      }
    }
  }
}
