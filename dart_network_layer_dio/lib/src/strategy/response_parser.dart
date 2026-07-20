import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:dio/dio.dart';

/// Defines the strategy for parsing network responses and errors.
abstract interface class ResponseParser {
  /// Parses a successful Dio [Response] into a [NetworkResult].
  Future<NetworkResult<T>> parse<T extends Schema>(
    Response<dynamic> response,
    RequestCommand<T> request, {
    String? downloadedFilePath,
  });

  /// Parses a [DioException] into a [NetworkResult].
  Future<NetworkResult<T>> handleDioException<T extends Schema>(
    DioException e,
    StackTrace s,
    RequestCommand<T> request,
  );
}
