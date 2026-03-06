import 'package:flutter_network_layer_core/flutter_network_layer_core.dart';

import '../response/response_test_user.dart';
import '../test_paths.dart';

class RequestTestUser extends RequestCommand<ResponseTestUser> {
  @override
  String get path => TestPaths.testUser;

  @override
  SchemaFactory<ResponseTestUser> get defaultResponseFactory =>
      ResponseTestUserFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}
