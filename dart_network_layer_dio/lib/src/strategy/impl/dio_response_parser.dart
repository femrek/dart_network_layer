import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:dart_network_layer_dio/src/strategy/response_parser.dart';
import 'package:dio/dio.dart';

/// A [ResponseParser] that converts Dio responses and exceptions into
/// standard [NetworkResult]s.
class DioResponseParser implements ResponseParser {
  /// Creates a [DioResponseParser].
  const DioResponseParser();

  @override
  Future<NetworkResult<T>> parse<T extends Schema>(
    Response<dynamic> response,
    RequestCommand<T> request, {
    String? downloadedFilePath,
  }) async {
    final responseData = downloadedFilePath ?? response.data;
    final statusCode = response.statusCode;
    final headers = response.headers;

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
        headers: headers.map,
      );
    }

    final specifiedResponseFactory = request.responseFactories[statusCode];

    try {
      if (specifiedResponseFactory == null) {
        return await _createResult<T>(
          factory: request.defaultResponseFactory,
          statusCode: statusCode,
          responseData: responseData,
          headers: headers,
          isDefault: true,
        );
      } else {
        final defaultResult = await _createResult<T>(
          factory: request.defaultResponseFactory,
          statusCode: statusCode,
          responseData: responseData,
          headers: headers,
          isDefault: true,
        );
        if (defaultResult is! NetworkErrorResult<T>) {
          return defaultResult;
        }

        return await _createResult<T>(
          factory: specifiedResponseFactory,
          statusCode: statusCode,
          responseData: responseData,
          headers: headers,
        );
      }
    } on Object catch (e, s) {
      return NetworkErrorResult<T>(
        error: NetworkErrorInvalidResponseType(
          message: 'Failed to process response',
          statusCode: statusCode,
          error: e is Exception ? e : Exception(e.toString()),
          stackTrace: s,
          response: responseData,
        ),
      );
    }
  }

  @override
  Future<NetworkResult<T>> handleDioException<T extends Schema>(
    DioException e,
    StackTrace s,
    RequestCommand<T> request,
  ) async {
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
    if (response == null) {
      return NetworkErrorResult<T>(
        error: NetworkError(
          message: 'Request failed: $e',
          error: e,
          stackTrace: s,
        ),
      );
    }

    final statusCode = response.statusCode;
    if (statusCode == null) {
      return NetworkErrorResult<T>(
        error: NetworkError(
          message: 'No status code in response',
          error: e,
          stackTrace: s,
        ),
      );
    }

    final responseData = response.data;
    final headers = response.headers;
    final specifiedResponseFactory = request.responseFactories[statusCode];

    if (specifiedResponseFactory == null) {
      return _createResult(
        factory: request.defaultErrorResponseFactory,
        statusCode: statusCode,
        responseData: responseData,
        headers: headers,
      );
    } else {
      return _createResult(
        factory: specifiedResponseFactory,
        statusCode: statusCode,
        responseData: responseData,
        headers: headers,
      );
    }
  }

  Future<NetworkResult<T>> _createResult<T extends Schema>({
    required SchemaFactory factory,
    required int statusCode,
    required dynamic responseData,
    required Headers headers,
    bool isDefault = false,
  }) async {
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
              return NetworkErrorResult<T>(
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
              headers: headers.map,
            );
          } else {
            return SpecifiedResponseResult<T>(
              data: data,
              statusCode: statusCode,
              type: f.type,
              headers: headers.map,
            );
          }
        } on Object catch (e, s) {
          return NetworkErrorResult<T>(
            error: NetworkErrorInvalidResponseType(
              message: 'Failed to parse response',
              statusCode: statusCode,
              response: responseData,
              error: e is Exception ? e : Exception(e.toString()),
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
                headers: headers.map,
              );
            } else {
              return SpecifiedResponseResult<T>(
                data: data,
                statusCode: statusCode,
                type: f.type,
                headers: headers.map,
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
            headers: headers.map,
          );
        } else {
          return SpecifiedResponseResult<T>(
            data: data,
            statusCode: statusCode,
            type: f.type,
            headers: headers.map,
          );
        }
      case final BinarySchemaFactory f:
        if (f.binaryResponseType is StreamBinaryResponse) {
          if (responseData is! ResponseBody) {
            return NetworkErrorResult<T>(
              error: NetworkErrorInvalidResponseType(
                message: 'Invalid response type for StreamBinarySchema: '
                    '${responseData.runtimeType}',
                stackTrace: StackTrace.current,
                response: responseData,
                statusCode: statusCode,
              ),
            );
          }
          if (isDefault) {
            return SuccessResponseResult(
              data: f.from(responseData.stream) as T,
              statusCode: statusCode,
              headers: headers.map,
            );
          } else {
            return SpecifiedResponseResult<T>(
              data: f.from(responseData.stream),
              statusCode: statusCode,
              type: f.type,
              headers: headers.map,
            );
          }
        }
        final binaryResponseData =
            await _extractBinaryResponseData(responseData);
        if (binaryResponseData == null) {
          return NetworkErrorResult<T>(
            error: NetworkErrorInvalidResponseType(
              message: 'Invalid response type for BinarySchemaFactory: '
                  '${responseData.runtimeType}',
              stackTrace: StackTrace.current,
              response: responseData,
              statusCode: statusCode,
            ),
          );
        }
        final data = f.from(binaryResponseData);
        if (isDefault) {
          return SuccessResponseResult(
            data: data as T,
            statusCode: statusCode,
            headers: headers.map,
          );
        } else {
          return SpecifiedResponseResult<T>(
            data: data,
            statusCode: statusCode,
            type: f.type,
            headers: headers.map,
          );
        }
    }
  }

  Future<Object?> _extractBinaryResponseData(dynamic responseData) async {
    if (responseData is List<int> || responseData is String) {
      return responseData;
    }

    if (responseData is ResponseBody) {
      final bytesBuilder = BytesBuilder(copy: false);
      await for (final chunk in responseData.stream) {
        bytesBuilder.add(chunk);
      }
      return bytesBuilder.takeBytes();
    }

    return null;
  }
}
