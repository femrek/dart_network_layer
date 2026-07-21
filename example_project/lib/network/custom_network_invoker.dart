import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

/// A custom network invoker that extends the [DioNetworkInvoker] and can be
/// used to add custom functionality or configuration to the network invoker.
class CustomNetworkInvoker extends DioNetworkInvoker {
  /// Creates an instance of [CustomNetworkInvoker] with the given [Dio]
  /// instance. You can customize the [Dio] instance before passing it to the
  /// super constructor.
  CustomNetworkInvoker(Dio dio)
    : super(
        dio: dio,
      );

  final Logger _log = Logger('CustomNetworkInvoker');

  @override
  Future<NetworkResult<T>> send<T extends Schema>(
    RequestCommand<T> request,
  ) async {
    _log.info(
      'CustomNetworkInvoker: Making a request to'
      ' ${request.method} ${request.path}',
    );
    return super.send(request);
  }
}
