import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:dart_network_layer_dio/src/feature/base/base2_network_invoker_invoke_request.dart';
import 'package:dart_network_layer_dio/src/feature/l3_invoke_request/mixin_request.dart';

/// Fourth-level implementation adding actual request execution capability.
///
/// This abstract class represents the fourth layer of the network invoker
/// hierarchy. It adds the actual request invocation capability through
/// [MixinRequest], completing the core request execution pipeline.
///
/// **Features:**
/// - Handles JSON, form data, binary, and stream payloads
/// - Supports both regular responses and file downloads
/// - Parses multiple response types based on status codes
abstract class Base3NetworkInvokerDio extends Base2NetworkInvokerInvokeRequest
    with MixinRequest
    implements INetworkInvoker {
  /// Creates a new instance with the provided [dio] instance.
  Base3NetworkInvokerDio({
    required super.dio,
    super.logger,
  });
}
