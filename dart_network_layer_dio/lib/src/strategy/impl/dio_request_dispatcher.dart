import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:dart_network_layer_dio/src/registry/request_registry.dart';
import 'package:dart_network_layer_dio/src/strategy/request_dispatcher.dart';
import 'package:dart_network_layer_dio/src/strategy/response_parser.dart';
import 'package:dart_network_layer_dio/src/util/utils.dart';
import 'package:dio/dio.dart';

/// A [RequestDispatcher] that uses Dio to perform HTTP requests.
class DioRequestDispatcher implements RequestDispatcher {
  /// Creates a [DioRequestDispatcher] with the given [dio] and
  /// [responseParser].
  const DioRequestDispatcher({
    required this.dio,
    required this.responseParser,
  });

  /// The underlying [Dio] client.
  final Dio dio;

  /// The strategy used for parsing responses.
  final ResponseParser responseParser;

  @override
  Future<NetworkResult<T>> dispatch<T extends Schema>(
    RequestCommand<T> request,
    Object? payload,
    CancelToken cancelToken,
    RequestRegistry registry,
  ) async {
    try {
      late final Response<dynamic> response;
      String? downloadedFilePath;
      final binaryResponseType = request.binaryResponseType;

      if (binaryResponseType is FileBinaryResponse) {
        response = await dio.download(
          request.path,
          binaryResponseType.savePath,
          data: payload,
          queryParameters: convertQueryParameters(request.queryParameters),
          onReceiveProgress: (int received, int total) {
            registry.updateProgress(
              request: request,
              count: received,
              total: total,
              isSend: false,
            );
          },
          cancelToken: cancelToken,
          options: Options(
            method: request.method.value,
            headers: request.headers,
          ),
        );
        downloadedFilePath = binaryResponseType.savePath;
      } else {
        late final ResponseType responseType;

        // if (T is BinarySchema) doesn't work with generics.
        // ignore: literal_only_boolean_expressions
        if (<T>[] is List<BinarySchema>) {
          if (binaryResponseType is InMemoryBinaryResponse) {
            responseType = ResponseType.bytes;
          } else if (binaryResponseType is StreamBinaryResponse) {
            responseType = ResponseType.stream;
          } else {
            responseType = ResponseType.plain;
          }
        } else {
          responseType = ResponseType.plain;
        }

        response = await dio.request<dynamic>(
          request.path,
          data: payload,
          queryParameters: convertQueryParameters(request.queryParameters),
          onSendProgress: (int sent, int total) {
            registry.updateProgress(
              request: request,
              count: sent,
              total: total,
              isSend: true,
            );
          },
          onReceiveProgress: (int received, int total) {
            registry.updateProgress(
              request: request,
              count: received,
              total: total,
              isSend: false,
            );
          },
          cancelToken: cancelToken,
          options: Options(
            method: request.method.value,
            headers: request.headers,
            responseType: responseType,
          ),
        );
      }

      return await responseParser.parse<T>(
        response,
        request,
        downloadedFilePath: downloadedFilePath,
      );
    } on DioException catch (e, s) {
      return responseParser.handleDioException<T>(e, s, request);
    } on Object catch (e, s) {
      return NetworkErrorResult<T>(
        error: NetworkError(
          message: 'Request failed: $e',
          error: e is Exception ? e : Exception(e.toString()),
          stackTrace: s,
        ),
      );
    } finally {
      registry.unregisterRequest(request);
      // ignore: invalid_use_of_internal_member, the invoker is responsible for this
      request.setOnCancel(() {
        throw RequestAlreadyCancelledError(
          message: 'Invalid state: Request was cancelled when it was already '
              'completed or cancelled.',
          stackTrace: StackTrace.current,
        );
      });
    }
  }
}
