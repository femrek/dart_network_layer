import 'package:flutter_network_layer_core/flutter_network_layer_core.dart';

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
abstract class RequestCommand<T extends Schema> {
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

  /// The headers of the request.
  Map<String, dynamic> get headers => const {};

  /// The callback for the progress of the request.
  OnProgressCallback? get onSendProgressUpdate => null;

  /// The callback for the progress of the response.
  OnProgressCallback? get onReceiveProgressUpdate => null;

  /// The network invoker to perform the request. used in [invoke].
  ///
  /// This is useful when the request command needs to invoke itself (e.g., for
  /// retrying the request) or when the invoker needs to be accessed in the
  /// request command (e.g., for accessing the network configuration or
  /// cancelling the request).
  INetworkInvoker? get invoker => null;

  /// Invokes the request using the provided network invoker.
  ///
  /// This is a convenience method that calls [INetworkInvoker.request] with
  /// this request command.
  ///
  /// Returns a [NetworkResult] with the response data.
  Future<NetworkResult<T>> invoke([INetworkInvoker? invoker]) {
    final i = invoker ?? this.invoker;
    if (i == null) {
      return Future.value(NetworkErrorResult(
        error: NullInvokerError(
          message: 'No network invoker provided for the request command.',
          stackTrace: StackTrace.current,
        ),
      ));
    }
    return i.request(this);
  }
}
