import 'package:dart_network_layer_core/dart_network_layer_core.dart';

/// Base class to define the type of responses from the server.
///
/// Factory implementations such as [JsonSchemaFactory], [StringSchemaFactory]
/// or [DynamicSchemaFactory]. should be provided in the request command to
/// parse the response data.
abstract class Schema {
  /// const constructor to allow subclasses to be const.
  const Schema();

  /// A string representation of the schema for logging purposes.
  ///
  /// By default, it returns the runtime type of the schema, but subclasses can
  /// override this method to provide more detailed information if needed.
  String toLogString() {
    return runtimeType.toString();
  }
}
