import 'package:dart_network_layer_core/dart_network_layer_core.dart';

/// Base class to define the type of responses from the server.
///
/// Factory implementations such as [JsonSchemaFactory], [StringSchemaFactory]
/// or [DynamicSchemaFactory]. should be provided in the request command to
/// parse the response data.
abstract class Schema {
  /// const constructor to allow subclasses to be const.
  const Schema();
}
