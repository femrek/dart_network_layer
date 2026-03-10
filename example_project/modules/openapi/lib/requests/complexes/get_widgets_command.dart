//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:dart_network_layer_core/dart_network_layer_core.dart';

import '../../base/base_request.dart';

import '../../model/widget_pagination_response.dart';


/// Get Polymorphic UI Widgets
/// Returns a paginated list of heterogeneous widgets using a discriminator field.
///
/// GET /api/v1/complex-json/widgets
class GetWidgetsCommand extends OpenapiDefinitionBaseRequest<WidgetPaginationResponse> {
  GetWidgetsCommand({
    this.page,
  });

  /// Page number
  final int? page;

  @override
  String get path {
    var p = r'/api/v1/complex-json/widgets';
    return p;
  }

  @override
  List<QueryParameter> get queryParameters => [
    if (page != null) QueryParameter(key: r'page', value: page),
  ];

  @override
  HttpRequestMethod get method => HttpRequestMethod.get;

  @override
  SchemaFactory<WidgetPaginationResponse> get defaultResponseFactory => WidgetPaginationResponse.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => AnyDataSchema.factory;

  @override
  Map<int, SchemaFactory> get responseFactories => {
    200: WidgetPaginationResponse.factory,
  };

  @override
  RequestSchema get payload =>
      const EmptyRequestSchema();
}
