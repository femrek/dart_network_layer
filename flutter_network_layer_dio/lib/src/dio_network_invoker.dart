import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_network_layer_dio/flutter_network_layer_dio.dart';
import 'package:flutter_network_layer_dio/src/utils.dart';

/// The network manager class for managing api communication.
final class DioNetworkInvoker implements INetworkInvoker {
  /// Create a new instance of [DioNetworkInvoker] with the given [baseUrl].
  DioNetworkInvoker.fromBaseUrl(String baseUrl) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        responseType: ResponseType.plain,
      ),
    );
  }

  /// Create a new instance of [DioNetworkInvoker] with the given [Dio]
  /// instance.
  DioNetworkInvoker.withDio(this.dio);

  /// The Dio instance used for performing network requests.
  late final Dio dio;

  /// Holds active cancel tokens mapped to their specific command.
  ///
  /// **Mutation protocol — always remove before cancelling:**
  /// Whenever a token needs to be cancelled, its entry must be removed from
  /// this map *first*, and only then the token itself is cancelled. This means
  /// the `finally` block in [request] (which also calls
  /// `_activeRequests.remove`) will always find the slot already gone and
  /// performs a harmless no-op, eliminating any window where both a cancel call
  /// and the `finally` block could race to act on the same token.
  final Map<RequestCommand, CancelToken> _activeRequests = {};

  /// Returns a list of all currently processing commands.
  List<RequestCommand> get activeRequests => _activeRequests.keys.toList();

  /// Cancels a specific request if it is currently active.
  ///
  /// The entry is removed from [_activeRequests] **before** the token is
  /// cancelled, so the `finally` block in [request] always finds the slot
  /// already gone and performs a harmless no-op. This eliminates the window
  /// where both [cancelRequest] and the `finally` block could race to act on
  /// the same token.
  void cancelRequest(RequestCommand request) {
    // Remove first, cancel after — the finally block's remove is then a no-op.
    final token = _activeRequests.remove(request);
    if (token != null && !token.isCancelled) {
      token.cancel('Cancelled by user');
    }
  }

  /// Cancels all active requests.
  ///
  /// The map is drained atomically (snapshot + clear) before any token is
  /// cancelled, so concurrent completions in the `finally` block cannot
  /// interfere with the iteration.
  void cancelAll() {
    // Snapshot and clear atomically before cancelling any token.
    final tokens = Map<RequestCommand, CancelToken>.of(_activeRequests);
    _activeRequests.clear();
    for (final token in tokens.values) {
      if (!token.isCancelled) {
        token.cancel('Cancelled All');
      }
    }
  }

  @override
  Future<NetworkResult<T>> request<T extends Schema>(
      RequestCommand<T> request) async {
    final cancelToken = _setupCancelToken(request);

    final Object? payload;
    try {
      payload = await _resolveDioPayload(request.payload);
    } on NetworkError catch (e) {
      return NetworkErrorResult<T>(error: e);
    }

    try {
      final response = await dio.request<dynamic>(
        request.path,
        data: payload,
        queryParameters: convertQueryParameters(request.queryParameters),
        onSendProgress: (int sent, int total) {
          request.updateProgress(sent, total, isSend: true);
          request.onSendProgressUpdate?.call(sent, total);
        },
        onReceiveProgress: (int received, int total) {
          request.updateProgress(received, total, isSend: false);
          request.onReceiveProgressUpdate?.call(received, total);
        },
        cancelToken: cancelToken,
        options: Options(
          method: request.method.value,
          headers: request.headers,
        ),
      );

      return _processResponse(response, request);
    } on DioException catch (e, s) {
      return _handleDioException(e, s, request);
    } on Exception catch (e, s) {
      return NetworkErrorResult<T>(
        error: NetworkError(
          message: 'Request failed',
          error: e,
          stackTrace: s,
        ),
      );
    } finally {
      _activeRequests.remove(request);
      request.onCancel = () {
        throw RequestAlreadyCancelledError(
          message: 'Invalid state: Request was cancelled when it was already '
              'completed or cancelled.',
          stackTrace: StackTrace.current,
        );
      };
    }
  }

  CancelToken _setupCancelToken(RequestCommand request) {
    final token = CancelToken();
    _activeRequests[request] = token;
    request.onCancel = () => cancelRequest(request);
    return token;
  }

  /// Handles exceptions thrown by Dio, attempting to parse error responses
  /// defined in the request factories.
  NetworkResult<T> _handleDioException<T extends Schema>(
    DioException e,
    StackTrace s,
    RequestCommand<T> request,
  ) {
    if (CancelToken.isCancel(e)) {
      return NetworkErrorResult<T>(
        error: RequestCancelledError(
          message: 'Request was cancelled',
          error: e,
          stackTrace: s,
        ),
      );
    }

    final response = e.response;

    // If the response is null, return an internal error.
    if (response == null) {
      return NetworkErrorResult(
        error: NetworkError(
          message: 'Request failed: $e',
          error: e,
          stackTrace: s,
        ),
      );
    }

    final statusCode = response.statusCode;
    // If the response status code is null, return an internal error.
    if (statusCode == null) {
      return NetworkErrorResult(
        error: NetworkError(
          message: 'No status code in response',
          error: e,
          stackTrace: s,
        ),
      );
    }

    final responseData = response.data;
    final specifiedResponseFactory = request.responseFactories[statusCode];

    // Respond assuming error factory is the default if specific one isn't
    // found.
    if (specifiedResponseFactory == null) {
      return _createResult(
        factory: request.defaultErrorResponseFactory,
        statusCode: statusCode,
        responseData: responseData,
      );
    } else {
      return _createResult(
        factory: specifiedResponseFactory,
        statusCode: statusCode,
        responseData: responseData,
      );
    }
  }

  /// Validates the raw Dio response and maps it to a [NetworkResult].
  NetworkResult<T> _processResponse<T extends Schema>(
    Response<dynamic> response,
    RequestCommand<T> request,
  ) {
    final responseData = response.data;
    final statusCode = response.statusCode;

    // Return error if the response has no status code
    if (statusCode == null) {
      return NetworkErrorResult<T>(
        error: NetworkError(
          message: 'Response status code is null',
          stackTrace: StackTrace.current,
        ),
      );
    }

    // Handle IgnoredSchema (void/null body)
    if (responseData == null) {
      return SpecifiedResponseResult<T>(
        statusCode: statusCode,
        data: const IgnoredSchema(),
        type: IgnoredSchema,
      );
    }

    // Validate data types
    if (responseData is! String &&
        responseData is! Map<String, dynamic> &&
        responseData is! List<dynamic>) {
      return NetworkErrorResult<T>(
        error: NetworkError(
          message: 'Invalid response type: ${responseData.runtimeType}',
          stackTrace: StackTrace.current,
        ),
      );
    }

    final specifiedResponseFactory = request.responseFactories[statusCode];

    try {
      // Respond assuming success factory is the default if specific one isn't
      // found.
      if (specifiedResponseFactory == null) {
        return _createResult(
          factory: request.defaultResponseFactory,
          statusCode: statusCode,
          responseData: responseData,
          isDefault: true,
        );
      } else {
        return _createResult(
          factory: specifiedResponseFactory,
          statusCode: statusCode,
          responseData: responseData,
        );
      }
    } on Exception catch (e, s) {
      return NetworkErrorResult<T>(
        error: NetworkErrorInvalidResponseType(
          message: 'Failed to process response',
          statusCode: statusCode,
          error: e,
          stackTrace: s,
          response: responseData,
        ),
      );
    }
  }

  /// Resolves the raw request payload into a Dio-compatible format.
  Future<Object?> _resolveDioPayload(RequestSchema payload) async {
    switch (payload) {
      case final FormDataRequestSchema s:
        final rawPayload = s.toFormDataMapPayload();
        return FormData.fromMap(await _convertMultipartFiles(rawPayload));
      case final JsonRequestSchema s:
        return s.toJsonPayload();
      case final StringRequestSchema s:
        return s.toStringPayload();
      case final BinaryRequestSchema s:
        return s.toBinaryPayload();
      case final StreamRequestSchema s:
        return s.toStreamPayload();
      case final DynamicRequestSchema s:
        return s.toPayload();
    }
  }

  Future<Map<String, dynamic>> _convertMultipartFiles(
    Map<String, dynamic> data,
  ) async {
    final dioFormDataMap = <String, dynamic>{};
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value is MultipartFileSchema) {
        dioFormDataMap[key] = await value.toDioMultipartFile();
      } else if (value is List<MultipartFileSchema>) {
        final fileFutures = value.map((e) => e.toDioMultipartFile());
        dioFormDataMap[key] = await Future.wait(fileFutures);
      } else {
        dioFormDataMap[key] = value;
      }
    }
    return dioFormDataMap;
  }

  NetworkResult<T> _createResult<T extends Schema>({
    required SchemaFactory factory,
    required int statusCode,
    required dynamic responseData,
    bool isDefault = false,
  }) {
    switch (factory) {
      case final JsonSchemaFactory f:
        try {
          final dynamic json;
          switch (responseData) {
            case final String r:
              json = jsonDecode(r);
            case const (Map) || const (List):
              json = responseData;
            default:
              return NetworkErrorResult(
                error: NetworkErrorInvalidResponseType(
                  message: 'Invalid response type for JsonResponseFactory: '
                      '${responseData.runtimeType}',
                  stackTrace: StackTrace.current,
                  response: responseData,
                  statusCode: statusCode,
                ),
              );
          }

          final data = f.fromJson(json);
          if (isDefault) {
            return SuccessResponseResult(
              data: data as T,
              statusCode: statusCode,
            );
          } else {
            return SpecifiedResponseResult(
              data: data,
              statusCode: statusCode,
              type: f.type,
            );
          }
        } on FormatException catch (e, s) {
          return NetworkErrorResult<T>(
            error: NetworkErrorInvalidResponseType(
              message: 'Failed to parse response',
              statusCode: statusCode,
              response: responseData,
              error: e,
              stackTrace: s,
            ),
          );
        }
      case final StringSchemaFactory f:
        switch (responseData) {
          case final String s:
            final data = f.fromString(s);
            if (isDefault) {
              return SuccessResponseResult(
                data: data as T,
                statusCode: statusCode,
              );
            } else {
              return SpecifiedResponseResult(
                data: data,
                statusCode: statusCode,
                type: f.type,
              );
            }
          default:
            return NetworkErrorResult<T>(
              error: NetworkErrorInvalidResponseType(
                message: 'Invalid response type for CustomResponseFactory: '
                    '${responseData.runtimeType}',
                stackTrace: StackTrace.current,
                response: responseData,
                statusCode: statusCode,
              ),
            );
        }
      case final DynamicSchemaFactory f:
        final data = f.from(responseData);
        if (isDefault) {
          return SuccessResponseResult(
            data: data as T,
            statusCode: statusCode,
          );
        } else {
          return SpecifiedResponseResult(
            data: data,
            statusCode: statusCode,
            type: f.type,
          );
        }
    }
  }
}
