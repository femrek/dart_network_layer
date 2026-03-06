import 'dart:collection';

import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:meta/meta.dart';

/// Aggregates progress snapshots for all active network requests.
abstract class AggregatedRequestState {
  /// Map of active request commands to their current progress state.
  @protected
  final Map<RequestCommand, RequestProgressState> progressMap = {};

  /// Returns the progress state for the given [command], or `null` if
  /// the request is not currently tracked.
  RequestProgressState? getProgress(RequestCommand command) =>
      progressMap[command];

  /// Returns an unmodifiable list of all tracked request progress states.
  List<RequestProgressState> get allProgresses =>
      UnmodifiableListView(progressMap.values);

  /// Returns an unmodifiable list of all tracked request commands.
  List<RequestCommand> get allRequests =>
      UnmodifiableListView(progressMap.keys);

  /// The combined total bytes across all tracked requests.
  int get allTotal;

  /// The combined transferred bytes across all tracked requests.
  int get allProgress;

  /// The overall transfer ratio across all tracked requests (0.0–1.0).
  double get allProgressPercent;
}
