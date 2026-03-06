import 'package:flutter_network_layer_dio/flutter_network_layer_dio.dart';
import 'package:meta/meta.dart';

/// An immutable record of a single completed network request.
@immutable
final class RequestHistoryEntry {
  /// Creates a [RequestHistoryEntry] with the given fields.
  ///
  /// [status] must be a terminal [ProgressStatus] and [endTime] must be
  /// after [startTime].
  RequestHistoryEntry({
    required this.request,
    required this.status,
    required this.startTime,
    required this.endTime,
  })  : assert(status.end, 'RequestHistoryEntry must have an end status'),
        assert(endTime.isAfter(startTime), 'endTime must be after startTime') {
    _duration = endTime.difference(startTime);
  }

  /// Creates a [RequestHistoryEntry] from a [RequestProgressState].
  ///
  /// Uses [DateTime.now] as the end time.
  factory RequestHistoryEntry.fromProgress(RequestProgressState progress) {
    return RequestHistoryEntry(
      request: progress.request,
      status: progress.status,
      startTime: progress.startTime,
      endTime: DateTime.now(),
    );
  }

  /// The request command that was executed.
  final RequestCommand request;

  /// The terminal status of the request (success, error, or cancelled).
  final ProgressStatus status;

  /// The time at which the request was created / started.
  final DateTime startTime;

  /// The time at which the request reached its terminal status.
  final DateTime endTime;

  /// The elapsed time between [startTime] and [endTime].
  Duration get duration => _duration;

  late final Duration _duration;
}
