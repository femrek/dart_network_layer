import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:dart_network_layer_dio/src/feature/base/base0_manage_request_network_invoker.dart';
import 'package:dart_network_layer_dio/src/feature/base/base2_dio_network_invoker.dart';
import 'package:dart_network_layer_dio/src/feature/l1_manage_request/mixin_manage_request_cancel.dart';
import 'package:dart_network_layer_dio/src/feature/l1_manage_request/mixin_manage_request_history.dart';
import 'package:dart_network_layer_dio/src/feature/l1_manage_request/mixin_manage_request_progress.dart';
import 'package:dio/dio.dart';

/// First-level implementation of request management for Dio invokers.
///
/// This abstract class represents the first layer of actual implementation
/// by extending [Base0RequestManagingNetworkInvoker] and adding request
/// lifecycle management capabilities.
///
/// **Mixins added:**
/// - [MixinManageRequestProgress] - tracks upload/download progress
/// - [MixinManageRequestCancel] - implements request cancellation
/// - [MixinManageRequestHistory] - maintains request history
///
/// **Responsibilities:**
/// - Integrate progress, cancellation, and history tracking
/// - Hold the [dio] instance for HTTP operations
/// - Serve as a bridge between state management and request execution
///
/// **Hierarchy:**
/// - [Base0RequestManagingNetworkInvoker] (base0) - request state tracking
/// - [Base1InvokeRequestNetworkInvoker] (base1) - progress/cancel/history
/// - [Base2DioNetworkInvoker] (base2) - request execution
/// - [DioNetworkInvoker] (concrete) - public API with factories
///
/// This class should not be instantiated directly. Use
/// [DioNetworkInvoker] instead.
abstract class Base1InvokeRequestNetworkInvoker
    extends Base0RequestManagingNetworkInvoker
    with
        MixinManageRequestProgress,
        MixinManageRequestCancel,
        MixinManageRequestHistory
    implements INetworkInvoker {
  /// Creates a new instance with the provided [dio] instance.
  ///
  /// The [dio] instance is used by all request management mixins to
  /// perform HTTP operations and access configuration options.
  Base1InvokeRequestNetworkInvoker(this.dio);

  /// Dio instance used for all HTTP network requests.
  ///
  /// This instance is shared across all request management operations
  /// and provides HTTP client functionality, configuration, and
  /// interceptor support.
  final Dio dio;
}
