import 'package:dart_network_layer_core/dart_network_layer_core.dart';

import 'test_network_invoker.dart';
import 'test_response_samples.dart';

final class _RequestTest1Schema extends JsonRequestSchema {
  const _RequestTest1Schema({
    required this.field1,
  });

  final String field1;

  @override
  Map<String, dynamic> toJsonPayload() {
    return {
      'field1': field1,
    };
  }
}

final class RequestTest1 extends RequestCommand<ResponseTest1> {
  RequestTest1({
    required String field1,
  }) : _schema = _RequestTest1Schema(field1: field1);

  final _RequestTest1Schema _schema;

  @override
  RequestSchema get payload => _schema;

  @override
  String get path => '/basic_test';

  @override
  SchemaFactory<ResponseTest1> get defaultResponseFactory =>
      ResponseTest1Factory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

final class _RequestTest1ErrorSchema extends JsonRequestSchema {
  const _RequestTest1ErrorSchema({
    required this.field1,
  });

  final String field1;

  @override
  Map<String, dynamic> toJsonPayload() {
    return {
      'shouldReturnError': field1,
    };
  }
}

final class RequestTest1Error extends RequestCommand<ResponseTest1> {
  RequestTest1Error({
    required String field1,
  }) : _schema = _RequestTest1ErrorSchema(field1: field1);

  final _RequestTest1ErrorSchema _schema;

  @override
  RequestSchema get payload => _schema;

  @override
  String get path => '/basic_test_error';

  @override
  SchemaFactory<ResponseTest1> get defaultResponseFactory =>
      ResponseTest1Factory();

  @override
  SchemaFactory get defaultErrorResponseFactory => ResponseTestErrorFactory();

  @override
  Map<int, SchemaFactory> get responseFactories => {
        400: ResponseTestErrorFactory(),
      };
}

final class RequestTestWithInvoker extends RequestCommand<ResponseTest1> {
  RequestTestWithInvoker({
    required String field1,
    required int port,
    required String host,
  })  : _schema = _RequestTest1Schema(field1: field1),
        invoker = TestNetworkInvoker(
          port: port,
          host: host,
        );

  final _RequestTest1Schema _schema;

  @override
  RequestSchema get payload => _schema;

  @override
  String get path => '/test_with_invoker';

  @override
  SchemaFactory<ResponseTest1> get defaultResponseFactory =>
      ResponseTest1Factory();

  @override
  final INetworkInvoker? invoker;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}
