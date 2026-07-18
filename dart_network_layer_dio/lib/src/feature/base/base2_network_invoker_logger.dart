import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:dart_network_layer_dio/src/feature/base/base1_network_invoker_invoke_request.dart';
import 'package:dart_network_layer_dio/src/feature/l2_invoke_request/mixin_request.dart';
import 'package:dio/dio.dart';

/// Second-level implementation adding request execution capability.
///
/// This abstract class represents the second layer of the network invoker
/// hierarchy. It adds the actual request invocation capability through
/// [MixinRequest], completing the core request execution pipeline.
///
/// **Features:**
/// - Handles JSON, form data, binary, and stream payloads
/// - Manages upload and download progress tracking
/// - Implements request cancellation with [CancelToken]
/// - Supports both regular responses and file downloads
/// - Parses multiple response types based on status codes
abstract class Base2NetworkInvokerLogger
    extends Base1NetworkInvokerInvokeRequest
    with MixinRequest
    implements INetworkInvoker {
  /// Creates a new instance with the provided [dio] instance.
  ///
  /// The [dio] instance is used for all HTTP network operations,
  /// configuration, and interceptor chain processing.
  Base2NetworkInvokerLogger(super.dio);
}
