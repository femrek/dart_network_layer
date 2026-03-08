//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:openapi/api.dart';
import 'package:test/test.dart';


/// tests for TablesGetManyReferenceByTablesApi
void main() {
  // final instance = TablesGetManyReferenceByTablesApi();

  group('tests for TablesGetManyReferenceByTablesApi', () {
    // GetManyReference: Get entities that reference another entity
    //
    // Retrieves a paginated list of entities that reference another specific entity. Implements ra-spring-data-provider's getManyReference operation.  This operation is used to fetch entities related to a specific record. For example, retrieving all comments for a particular post, or all orders for a specific customer. Unlike getList, the filter is based on a reference relationship rather than arbitrary criteria.  The response includes an X-Total-Count header containing the total number of entities that reference the specified target entity. This is essential for pagination in React Admin.  Example: GET /api/comments/of/postId/123?_start=0&_end=10&_sort=createdAt&_order=DESC This retrieves comments where the postId field equals 123, paginated and sorted. 
    //
    //Future<List<Table>> getManyReferenceByTables(String target, String targetId, int start, int end, Map<String, String> allParams, { String sort, String order, String embed }) async
    test('test getManyReferenceByTables', () async {
      // TODO
    });

  });
}
