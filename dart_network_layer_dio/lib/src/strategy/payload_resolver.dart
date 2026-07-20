// ignore_for_file: one_member_abstracts, this is a strategy interface

import 'package:dart_network_layer_core/dart_network_layer_core.dart';

/// Defines the strategy for resolving request payloads.
abstract interface class PayloadResolver {
  /// Resolves the given [RequestSchema] into a payload object.
  Future<Object?> resolve(RequestSchema payload);
}
