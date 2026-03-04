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

  @override
  Future<NetworkResult<T>> request<T extends Schema>(
      RequestCommand<T> request) async {
    // 1. Prepare Payload
    final Object? payload;
    try {
      payload = await _resolveDioPayload(request.payload);
    } on NetworkError catch (e) {
      return NetworkErrorResult<T>(error: e);
    }

    // 2. Perform Request
    try {
      final response = await dio.request<dynamic>(
        request.path,
        data: payload,
        onSendProgress: request.onSendProgressUpdate,
        onReceiveProgress: request.onReceiveProgressUpdate,
        options: Options(
          method: request.method.value,
          headers: request.headers,

        ),
      );

      // 3. Process Successful Dio Response
      return _processResponse(response, request);
    } on DioException catch (e, s) {
      // 4. Handle Dio Specific Errors
      return _handleDioException(e, s, request);
    } on Exception catch (e, s) {
      // 5. Handle Generic Errors
      return NetworkErrorResult<T>(
        error: NetworkError(
          message: 'Request failed',
          error: e,
          stackTrace: s,
        ),
      );
    }
  }

  /// Handles exceptions thrown by Dio, attempting to parse error responses
  /// defined in the request factories.
  NetworkResult<T> _handleDioException<T extends Schema>(
      DioException e,
      StackTrace s,
      RequestCommand<T> request,
      ) {
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
