/// The error type thrown when trying to cancel a request that has already
/// completed or been cancelled.
///
/// Example:
/// ```dart
/// try {
///   command.cancel();
/// } on RequestAlreadyCancelledError catch (e) {
///   print('Too late — request already finished: ${e.message}');
/// }
/// ```
final class RequestAlreadyCancelledError implements Exception {
  /// Creates a request already cancelled error.
  const RequestAlreadyCancelledError({
    required this.message,
    required this.stackTrace,
    this.error,
  });

  /// The error message describing the cancellation error.
  final String message;

  /// The stack trace at the point where the error was created.
  final StackTrace stackTrace;

  /// An optional underlying error that caused this cancellation error, if any.
  final Object? error;

  @override
  String toString() {
    return 'RequestAlreadyCancelledError: $message';
  }
}
