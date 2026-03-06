// The base of the network invoker.
// ignore_for_file: one_member_abstracts

import 'package:dart_network_layer_core/dart_network_layer_core.dart';

/// The interface to manage and perform the network requests.
abstract interface class INetworkInvoker {
  /// Performs a request and returns the response.
  Future<NetworkResult<T>> request<T extends Schema>(RequestCommand<T> request);
}
