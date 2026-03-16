import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

/// A custom network invoker that extends the [DioNetworkInvoker] and can be
/// used to add custom functionality or configuration to the network invoker.
class CustomNetworkInvoker extends DioNetworkInvoker {
  /// Creates an instance of [CustomNetworkInvoker] with the given [Dio]
  /// instance. You can customize the [Dio] instance before passing it to the
  /// super constructor.
  CustomNetworkInvoker(super.dio) : super.fromDio();

  final Logger _log = Logger('CustomNetworkInvoker');

  @override
  Future<NetworkResult<T>> request<T extends Schema>(
    RequestCommand<T> request,
  ) async {
    _log.info(
      'CustomNetworkInvoker: Making a request to'
      ' ${request.method} ${request.path}',
    );
    final result = await super.request(request);

    switch (result) {
      case SuccessResponseResult(:final statusCode, :final data):
        _log.info(
          'CustomNetworkInvoker: Request succeeded with '
          'status code $statusCode\n$data',
        );
      case SpecifiedResponseResult(:final statusCode, :final data):
        _log.info(
          'CustomNetworkInvoker: Request received a '
          'specified response with status code $statusCode\n$data',
        );
      case NetworkErrorResult(:final error):
        _log.severe(
          'CustomNetworkInvoker: ERROR ${error.message}\n${error.stackTrace}',
        );
    }

    return result;
  }
}
