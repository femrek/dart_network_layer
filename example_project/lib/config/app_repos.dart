import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:dio/dio.dart';
import 'package:example_project/config/custom_network_invoker.dart';
import 'package:openapi/api.dart';

/// Holds all the repositories of the app, which are used to access data from
/// different servers.
final class AppRepos {
  /// Creates an instance of [AppRepos].
  AppRepos() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.url0_generatedServerUrl,
        responseType: ResponseType.plain,
        followRedirects: true,
      ),
    );
    dio.interceptors.add(
      LogInterceptor(
        request: false,
        requestHeader: false,
        responseBody: true,
        logPrint: print,
      ),
    );
    example = CustomNetworkInvoker(dio);
  }

  /// The example repository, which is used to access data from the example
  /// server.
  late final DioNetworkInvoker example;
}
