# openapi.api.TablesDeleteManyTablesApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://dummyapi.femrek.dev*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteManyTables**](TablesDeleteManyTablesApi.md#) | **DELETE** /api/v1/tables | DeleteMany: Delete multiple entities


# **deleteManyTables**
> List<int> deleteManyTables(id)

DeleteMany: Delete multiple entities

Deletes multiple entities in a single operation. Implements ra-spring-data-provider's deleteMany operation for bulk deletions. Returns a list of deleted entity IDs. 

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = TablesDeleteManyTablesApi();
final id = [[1,2,3]]; // List<int> | List of entity IDs to delete

try {
    final result = api_instance.deleteManyTables(id);
    print(result);
} catch (e) {
    print('Exception when calling TablesDeleteManyTablesApi->deleteManyTables: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | [**List<int>**](int.md)| List of entity IDs to delete | [optional] [default to const []]

### Return type

**List<int>**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

