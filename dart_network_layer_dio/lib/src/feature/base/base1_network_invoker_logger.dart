import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:dart_network_layer_dio/src/feature/base/base0_network_invoker_manage_request.dart';
import 'package:dart_network_layer_dio/src/feature/l1_manage_request/mixin_manage_request_cancel.dart';
import 'package:dart_network_layer_dio/src/feature/l1_manage_request/mixin_manage_request_history.dart';
import 'package:dart_network_layer_dio/src/feature/l1_manage_request/mixin_manage_request_progress.dart';
import 'package:logging/logging.dart';

/// Second-level implementation of request management for network invokers.
///
/// This abstract class represents the second layer of the network invoker
/// hierarchy. It extends [Base0NetworkInvokerRequestManaging] and adds request
/// lifecycle management capabilities.
///
/// **Mixins added:**
/// - [MixinManageRequestProgress] - tracks upload/download progress
/// - [MixinManageRequestCancel] - implements request cancellation
/// - [MixinManageRequestHistory] - maintains request history
///
/// **Responsibilities:**
/// - Integrate progress, cancellation, and history tracking
/// - Hold the optional [logger] instance
abstract class Base1NetworkInvokerLogger
    extends Base0NetworkInvokerRequestManaging
    with
        MixinManageRequestProgress,
        MixinManageRequestCancel,
        MixinManageRequestHistory
    implements INetworkInvoker {
  /// Creates a new instance with an optional [logger].
  Base1NetworkInvokerLogger({this.logger});

  /// The Logger instance to use in logging operations.
  Logger? logger;
}
