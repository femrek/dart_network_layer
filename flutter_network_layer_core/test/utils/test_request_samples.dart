import 'package:flutter_network_layer_core/flutter_network_layer_core.dart';

import 'test_response_samples.dart';

final class RequestTest1 extends RequestCommand<ResponseTest1> {
  RequestTest1({
    required this.field1,
  });

  final String field1;

  @override
  Map<String, dynamic> get payload => {
        'field1': field1,
      };

  @override
  String get path => '/basic_test';

  @override
  SchemaFactory<ResponseTest1> get defaultResponseFactory =>
      ResponseTest1Factory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

final class RequestTest1Error extends RequestCommand<ResponseTest1> {
  RequestTest1Error({
    required this.field1,
  });

  final String field1;

  @override
  Map<String, dynamic> get payload => {
        'shouldReturnError': field1,
      };

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
