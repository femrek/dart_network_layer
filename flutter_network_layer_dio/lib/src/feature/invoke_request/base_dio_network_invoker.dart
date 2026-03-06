import 'package:dio/dio.dart';
import 'package:flutter_network_layer_core/flutter_network_layer_core.dart';
import 'package:flutter_network_layer_dio/src/feature/manage_request/base_request_managing_network_invoker.dart';
import 'package:flutter_network_layer_dio/src/feature/manage_request/mixin_manage_request_cancel.dart';
import 'package:flutter_network_layer_dio/src/feature/manage_request/mixin_manage_request_progress.dart';

/// Base class for Dio-powered network invokers.
///
/// Extends [BaseRequestManagingNetworkInvoker] and mixes in progress and
/// cancel management. Implements [INetworkInvoker] for network operations.
abstract class BaseDioNetworkInvoker extends BaseRequestManagingNetworkInvoker
    with MixinManageRequestProgress, MixinManageRequestCancel
    implements INetworkInvoker {
  /// Creates a new instance of [BaseDioNetworkInvoker] with the provided [dio]
  /// instance for making network requests.
  BaseDioNetworkInvoker(this.dio);

  /// Dio instance used for network requests.
  final Dio dio;
}
