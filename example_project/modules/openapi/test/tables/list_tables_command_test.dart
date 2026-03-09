//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:openapi/api.dart';
import 'package:test/test.dart';


/// tests for TablesListTablesApi
void main() {
  // final instance = TablesListTablesApi();

  group('tests for TablesListTablesApi', () {
    // GetList: Get paginated list of entities with filtering
    //
    // Retrieves a paginated list of entities with support for sorting and filtering. Implements ra-spring-data-provider's getList operation.  This method returns a subset of entities based on the pagination parameters (_start and _end). The results can be sorted by any field in ascending or descending order. Custom filters can be applied through additional query parameters passed in allParams.  The response includes an X-Total-Count header containing the total number of entities matching the filter criteria (not just the current page). This header is essential for ra-spring-data-provider to calculate pagination correctly.  Example: GET /api/posts?_start=0&_end=10&_sort=title&_order=ASC&status=published 
    //
    //Future<List<TableDTO>> listTables(int start, int end, Map<String, String> allParams, { String sort, String order, String embed }) async
    test('test listTables', () async {
      // TODO
    });

  });
}
