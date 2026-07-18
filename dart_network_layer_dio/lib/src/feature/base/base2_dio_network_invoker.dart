import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:dart_network_layer_dio/src/feature/base/base0_manage_request_network_invoker.dart';
import 'package:dart_network_layer_dio/src/feature/base/base1_invoke_request_network_invoker.dart';
import 'package:dart_network_layer_dio/src/feature/l2_invoke_request/mixin_request.dart';
import 'package:dio/dio.dart';

/// Second-level implementation adding request execution capability.
///
/// This abstract class represents the second layer of the network invoker
/// hierarchy. It adds the actual request invocation capability through
/// [MixinRequest], completing the core request execution pipeline.
///
/// **Mixins added:**
/// - [MixinRequest] - implements [INetworkInvoker.send] for request
///   execution with full lifecycle management
///
/// **Responsibilities:**
/// - Execute [RequestCommand] instances via the [send] method
/// - Handle various request payload types (JSON, form data, binary, etc.)
/// - Manage response parsing and schema deserialization
/// - Track and report request/response progress
/// - Handle errors and cancellation gracefully
///
/// **Hierarchy:**
/// - [Base0RequestManagingNetworkInvoker] (base0) - state tracking
/// - [Base1InvokeRequestNetworkInvoker] (base1) - progress/cancel/history
/// - [Base2DioNetworkInvoker] (base2) - request execution
/// - [DioNetworkInvoker] (concrete) - public API with factories
///
/// **Features:**
/// - Handles JSON, form data, binary, and stream payloads
/// - Manages upload and download progress tracking
/// - Implements request cancellation with [CancelToken]
/// - Supports both regular responses and file downloads
/// - Parses multiple response types based on status codes
///
/// This class should not be instantiated directly. Use
/// [DioNetworkInvoker] instead to create invoker instances.
///
/// **Example:**
/// ```dart
/// final invoker = DioNetworkInvoker.fromBaseUrl(
///   'https://api.example.com'
/// );
/// final result = await invoker.send(MyCommand());
/// ```
abstract class Base2DioNetworkInvoker extends Base1InvokeRequestNetworkInvoker
    with MixinRequest
    implements INetworkInvoker {
  /// Creates a new instance with the provided [dio] instance.
  ///
  /// The [dio] instance is used for all HTTP network operations,
  /// configuration, and interceptor chain processing.
  Base2DioNetworkInvoker(super.dio);
}
