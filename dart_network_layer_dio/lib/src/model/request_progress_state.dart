import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';

/// Represents the progress state of a single network request.
final class RequestProgressState {
  /// Creates a [RequestProgressState] for the given [request].
  RequestProgressState({
    required this.request,
    required this.total,
    required this.progress,
    required this.progressPercent,
    required this.unknownTotal,
    required this.startTime,
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

  /// The timestamp when the request started, used for calculating transfer
  /// speed.
  DateTime startTime;

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

  /// Finalizes the request with [endStatus], setting progress to total
  /// and [progressPercent] to 1.0. [endStatus] must be a terminal status.
  void endRequest(ProgressStatus endStatus) {
    assert(
        endStatus.end, 'endRequest should only be called with an end status');
    status = endStatus;
    progress = total;
    progressPercent = 1.0;
  }
}
