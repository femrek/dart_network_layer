import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:dart_network_layer_dio/src/feature/base/base3_network_invoker_dio.dart';
import 'package:dio/dio.dart';

/// The network manager class for managing api communication.
class DioNetworkInvoker extends Base3NetworkInvokerDio
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
