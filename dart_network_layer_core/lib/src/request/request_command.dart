import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:dart_network_layer_core/src/request/request_managing_mixin.dart';
import 'package:dart_network_layer_core/src/request/request_result_mixin.dart';

/// The callback for the progress of the request. Can be used to trace uploading
/// or downloading data.
typedef OnProgressCallback = void Function(int done, int total);

/// The interface/class to configure a request type.
///
/// An implementation should provide the necessary information about the request
/// such as the path, method, payload type, payload data, headers, progress
/// callbacks, etc.
///
/// [T] is the type of the successful response model.
abstract class RequestCommand<T extends Schema>
    with RequestManagingMixin, RequestResultMixin<T> {
  /// The path of the request.
  String get path;

  /// The factory instance to deserialize the response.
  SchemaFactory<T> get defaultResponseFactory;

  /// The factory instance to deserialize the error response.
  SchemaFactory get defaultErrorResponseFactory;

  /// The factories for different status codes. This can be used to provide
  /// different response factories for different status codes. For example, if
  /// the server returns a 400 status code, the error response factory can be
  /// different from the one for 500 status code.
  Map<int, SchemaFactory> get responseFactories => const {};

  /// The method of the request. GET, POST, PUT, DELETE, etc.
  HttpRequestMethod get method => HttpRequestMethod.get;

  /// The payload data of the request. Applicable in the form of Json, form data
  /// or string
  RequestSchema get payload => const EmptyRequestSchema();

  /// The query parameters of the request.
  List<QueryParameter> get queryParameters => const [];

  /// The headers of the request.
  Map<String, dynamic> get headers => const {};

  /// The callback for the progress of the request.
  OnProgressCallback? get onSendProgressUpdate => null;

  /// The callback for the progress of the response.
  OnProgressCallback? get onReceiveProgressUpdate => null;

  /// How to handle binary responses.
  ///
  /// When non-null, the invoker will treat this request as a binary download
  /// rather than a normal JSON/text request.
  ///
  /// Use [InMemoryBinaryResponse] to receive raw bytes in memory, or
  /// [FileBinaryResponse] to save the response to a file at a specified path.
  ///
  /// When null (default), the response is treated as a normal response.
  BinaryResponseType get binaryResponseType => const InMemoryBinaryResponse();
}
