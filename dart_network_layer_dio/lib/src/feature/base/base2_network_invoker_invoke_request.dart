import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:dart_network_layer_dio/src/feature/base/base1_network_invoker_logger.dart';
import 'package:dart_network_layer_dio/src/feature/l2_%20logging/mixin_logger.dart';
import 'package:dio/dio.dart';

/// Third-level implementation adding logging capabilities and Dio instance.
///
/// This abstract class represents the third layer of actual implementation
/// by extending [Base1NetworkInvokerLogger] and adding logging
/// capabilities.
///
/// **Mixins added:**
/// - [MixinLogger] - provides logging functionality
///
/// **Responsibilities:**
/// - Integrate logging capabilities
/// - Hold the [dio] instance for HTTP operations
/// - Serve as a bridge between request management and request execution
///
/// This class should not be instantiated directly. Use
/// [DioNetworkInvoker] instead.
abstract class Base2NetworkInvokerInvokeRequest
    extends Base1NetworkInvokerLogger
    with MixinLogger
    implements INetworkInvoker {
  /// Creates a new instance with the provided [dio] instance.
  ///
  /// The [dio] instance is used by all request management mixins to
  /// perform HTTP operations and access configuration options.
  Base2NetworkInvokerInvokeRequest({
    required this.dio,
    super.logger,
  });

  /// Dio instance used for all HTTP network requests.
  ///
  /// This instance is shared across all request management operations
  /// and provides HTTP client functionality, configuration, and
  /// interceptor support.
  final Dio dio;
}
