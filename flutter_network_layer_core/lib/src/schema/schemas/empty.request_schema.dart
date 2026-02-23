import 'package:flutter_network_layer_core/flutter_network_layer_core.dart';

final class EmptyRequestSchema extends DynamicRequestSchema {
  const EmptyRequestSchema();

  @override
  dynamic toPayload() {
    return null;
  }
}
