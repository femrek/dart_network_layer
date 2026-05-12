import 'package:dart_network_layer_core/dart_network_layer_core.dart';

/// A mixin that provides the functionality to send a request using an invoker.
mixin RequestInvokerMixin<T extends Schema> {
  /// The invoker to send the request.
  ///
  /// This field should be set at the subclass of [RequestCommand]. After
  /// setting this field, the [send] method can be called to send the request
  /// directly and get the response result.
  INetworkInvoker? get invoker => null;

  /// Sends the request using the invoker and returns the response result.
  ///
  /// This function can be called after setting the [invoker] field.
  Future<NetworkResult<T>> send() async {
    final invoker = this.invoker;
    if (invoker == null) {
      throw StateError(
        'The invoker is not set. '
        'Please set the invoker before sending the request.',
      );
    }
    return invoker.send(this as RequestCommand<T>);
  }
}
