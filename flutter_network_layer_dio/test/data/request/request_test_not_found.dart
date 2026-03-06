import 'package:flutter_network_layer_core/flutter_network_layer_core.dart';

import '../response/response_empty.dart';

class RequestTestNotFound extends RequestCommand<ResponseEmpty> {
  @override
  String get path => '/not-found';

  @override
  SchemaFactory<ResponseEmpty> get defaultResponseFactory =>
      ResponseEmptyFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}
