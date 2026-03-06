/// Status of a network request's progress lifecycle.
enum ProgressStatus {
  /// The request has been created but not yet sent.
  pending(end: false),

  /// The request body is being sent to the server.
  sending(end: false),

  /// The response body is being received from the server.
  receiving(end: false),

  /// The request completed successfully.
  success(end: true),

  /// The request failed with an error.
  error(end: true),

  /// The request was cancelled before completion.
  cancelled(end: true),
  ;

  /// Whether this status represents a terminal (final) state.
  const ProgressStatus({required this.end});

  /// `true` if this status is a terminal state.
  final bool end;
}
