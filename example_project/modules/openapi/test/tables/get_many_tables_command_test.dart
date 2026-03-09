//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:openapi/api.dart';
import 'package:test/test.dart';


/// tests for TablesGetManyTablesApi
void main() {
  // final instance = TablesGetManyTablesApi();

  group('tests for TablesGetManyTablesApi', () {
    // GetMany: Get multiple entities by IDs
    //
    // Retrieves multiple specific entities by their unique identifiers. Implements ra-spring-data-provider's getMany operation.  Unlike getList, this operation does not use pagination. It simply returns all entities with the specified IDs. This is commonly used when the client needs to fetch multiple specific records, such as when displaying relationships or selected items.  If an ID doesn't exist, it is typically omitted from the response rather than returning an error. The order of returned entities may not match the order of requested IDs.  Example: GET /api/posts/many?id=1&id=5&id=12 
    //
    //Future<List<TableDTO>> getManyTables(List<int> id) async
    test('test getManyTables', () async {
      // TODO
    });

  });
}
