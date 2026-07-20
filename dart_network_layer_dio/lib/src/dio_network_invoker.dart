import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:dart_network_layer_dio/src/feature/base/base3_network_invoker_dio.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

/// The network manager class for managing api communication.
class DioNetworkInvoker extends Base3NetworkInvokerDio
    implements INetworkInvoker {
  /// Create a new instance of [DioNetworkInvoker] with the given [Dio]
  /// instance.
  ///
  /// set [logger] to custom logger, if not provided, default logger will be
  /// used with name [_defaultLoggerName].
  DioNetworkInvoker({
    required super.dio,
    super.logger,
  }) {
    logger ??= Logger(_defaultLoggerName);
  }

  /// Create a new instance of [DioNetworkInvoker] with the given [baseUrl].
  ///
  /// The default constructor is recommended to use, this constructor is
  /// provided for convenience.
  DioNetworkInvoker.fromBaseUrl(String baseUrl)
      : super(
          dio: Dio(
            BaseOptions(
              baseUrl: baseUrl,
              responseType: ResponseType.plain,
            ),
          ),
          logger: Logger(_defaultLoggerName),
        );

  static const String _defaultLoggerName = 'DioNetworkInvoker';
}
