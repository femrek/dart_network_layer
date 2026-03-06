import 'package:dio/dio.dart';
import 'package:flutter_network_layer_core/flutter_network_layer_core.dart';
import 'package:flutter_network_layer_dio/src/feature/invoke_request/base_dio_network_invoker.dart';
import 'package:flutter_network_layer_dio/src/feature/invoke_request/mixin_request.dart';

/// The network manager class for managing api communication.
final class DioNetworkInvoker extends BaseDioNetworkInvoker
    with MixinRequest
    implements INetworkInvoker {
  /// Create a new instance of [DioNetworkInvoker] with the given [baseUrl].
  DioNetworkInvoker.fromBaseUrl(String baseUrl)
      : super(Dio(
          BaseOptions(
            baseUrl: baseUrl,
            responseType: ResponseType.plain,
          ),
        ));

  /// Create a new instance of [DioNetworkInvoker] with the given [Dio]
  /// instance.
  DioNetworkInvoker.fromDio(super.dio);
}
