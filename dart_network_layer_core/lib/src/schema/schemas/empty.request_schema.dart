import 'package:dart_network_layer_core/dart_network_layer_core.dart';

/// A [RequestSchema] implementation that represents an empty request payload.
///
/// Use this for HTTP requests that do not require a body, such as GET or
/// DELETE requests without a payload.
///
/// Example:
/// ```dart
/// class GetUserCommand extends RequestCommand<User> {
///   @override
///   RequestSchema get payload => const EmptyRequestSchema();
///   // ...
/// }
/// ```
final class EmptyRequestSchema extends DynamicRequestSchema {
  /// Creates a const instance of [EmptyRequestSchema].
  const EmptyRequestSchema();

  @override
  dynamic toPayload() {
    return null;
  }
}
