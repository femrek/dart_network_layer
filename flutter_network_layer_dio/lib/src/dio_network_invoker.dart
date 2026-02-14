import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_network_layer_dio/flutter_network_layer_dio.dart';

/// The network manager class for managing to api communication.
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
      RequestCommand<Schema> request) async {
    final requestPayload = request.payload;

    final Response<dynamic> response;
    final Object? payload;

    switch (request.payloadType) {
      case RequestPayloadType.formData:
        if (requestPayload == null) {
          payload = null;
        } else if (requestPayload is Map<String, dynamic>) {
          payload = FormData.fromMap(requestPayload);
        } else {
          return NetworkErrorResult(
            error: NetworkErrorInvalidPayload(
              message:
                  'Invalid payload type. Payload must be Map<String, dynamic> '
                  'when payloadType is RequestPayloadType.formData.',
              stackTrace: StackTrace.current,
            ),
          );
        }
      case RequestPayloadType.other:
        payload = requestPayload;
    }

    // perform request
    try {
      response = await dio.request<dynamic>(
        request.path,
        data: payload,
        onSendProgress: request.onSendProgressUpdate,
        onReceiveProgress: request.onReceiveProgressUpdate,
        options: Options(
          method: request.method.value,
          headers: request.headers,
        ),
      );
    } on DioException catch (e, s) {
      // if the response is null, return an internal error.
      final response = e.response;
      if (response == null) {
        return NetworkErrorResult(
          error: NetworkError(
            message: 'Request failed: $e',
            error: e,
            stackTrace: s,
          ),
        );
      }

      // if the response status code is null, return an internal error.
      final statusCode = response.statusCode;
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

      // respond by assume error factory is the default.
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
    } on Exception catch (e, s) {
      return NetworkErrorResult<T>(
        error: NetworkError(
          message: 'Request failed',
          error: e,
          stackTrace: s,
        ),
      );
    }

    final responseData = response.data;
    final statusCode = response.statusCode;

    // return error if the response has no status code or data
    if (statusCode == null) {
      return NetworkErrorResult<T>(
        error: NetworkError(
          message: 'Response status code is null',
          stackTrace: StackTrace.current,
        ),
      );
    }
    if (responseData == null) {
      return SpecifiedResponseResult<T>(
        statusCode: statusCode,
        data: const IgnoredSchema(),
        type: IgnoredSchema,
      );
    }
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
      // respond by assume success factory is the default.
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
