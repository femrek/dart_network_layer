# openapi.api.TablesGetManyTablesApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://dummyapi.femrek.dev*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getManyTables**](TablesGetManyTablesApi.md#) | **GET** /api/v1/tables/many | GetMany: Get multiple entities by IDs


# **getManyTables**
> List<Table> getManyTables(id)

GetMany: Get multiple entities by IDs

Retrieves multiple specific entities by their unique identifiers. Implements ra-spring-data-provider's getMany operation.  Unlike getList, this operation does not use pagination. It simply returns all entities with the specified IDs. This is commonly used when the client needs to fetch multiple specific records, such as when displaying relationships or selected items.  If an ID doesn't exist, it is typically omitted from the response rather than returning an error. The order of returned entities may not match the order of requested IDs.  Example: GET /api/posts/many?id=1&id=5&id=12 

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = TablesGetManyTablesApi();
final id = [[1,5,12]]; // List<int> | List of entity IDs to retrieve

try {
    final result = api_instance.getManyTables(id);
    print(result);
} catch (e) {
    print('Exception when calling TablesGetManyTablesApi->getManyTables: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | [**List<int>**](int.md)| List of entity IDs to retrieve | [default to const []]

### Return type

[**List<Table>**](Table.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

