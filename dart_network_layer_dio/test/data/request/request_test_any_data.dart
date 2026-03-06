import 'package:dart_network_layer_core/dart_network_layer_core.dart';

import '../test_paths.dart';

class RequestTestAnyData extends RequestCommand<AnyDataSchema> {
  @override
  String get path => TestPaths.testAnyData;

  @override
  SchemaFactory<AnyDataSchema> get defaultResponseFactory =>
      AnyDataSchema.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class RequestTestAnyDataList extends RequestCommand<AnyDataSchema> {
  @override
  String get path => TestPaths.testAnyDataList;

  @override
  SchemaFactory<AnyDataSchema> get defaultResponseFactory =>
      AnyDataSchema.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}
