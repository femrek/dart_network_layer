//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:dart_network_layer_core/dart_network_layer_core.dart';

import '../../base/base_request.dart';

import '../../model/category_node.dart';


/// Request schema for [ProcessCategoryTreeCommand].
class ProcessCategoryTreeRequestSchema extends JsonRequestSchema {
  const ProcessCategoryTreeRequestSchema({required this.data});

  final CategoryNode data;

  @override
  dynamic toJsonPayload() => data.toJson();
}

/// Create Category Tree
/// Accepts and returns a deeply nested, self-referencing tree structure.
///
/// POST /api/v1/complex-json/categories/tree
class ProcessCategoryTreeCommand extends OpenapiDefinitionBaseRequest<CategoryNode> {
  ProcessCategoryTreeCommand({
    required CategoryNode categoryNode,
  }) : _payload = ProcessCategoryTreeRequestSchema(data: categoryNode);

  final ProcessCategoryTreeRequestSchema _payload;


  @override
  String get path {
    var p = r'/api/v1/complex-json/categories/tree';
    return p;
  }


  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  SchemaFactory<CategoryNode> get defaultResponseFactory => CategoryNode.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;

  @override
  RequestSchema get payload =>
      _payload;

}
