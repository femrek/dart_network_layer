// ignore_for_file: one_member_abstracts, this is a strategy interface

import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:dart_network_layer_dio/src/registry/request_registry.dart';
import 'package:dio/dio.dart';

/// Defines the strategy for dispatching requests to the network.
abstract interface class RequestDispatcher {
  /// Dispatches the [request] using the resolved [payload] and returns
  /// the result.
  Future<NetworkResult<T>> dispatch<T extends Schema>(
    RequestCommand<T> request,
    Object? payload,
    CancelToken cancelToken,
    RequestRegistry registry,
  );
}
