# openapi.api.TablesUpdateManyTablesApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://dummyapi.femrek.dev*

Method | HTTP request | Description
------------- | ------------- | -------------
[**updateManyTables**](TablesUpdateManyTablesApi.md#) | **PUT** /api/v1/tables | UpdateMany: Update multiple entities


# **updateManyTables**
> List<int> updateManyTables(requestBody, id)

UpdateMany: Update multiple entities

Updates multiple entities with the same field values in a single operation. Implements ra-spring-data-provider's updateMany operation for bulk updates. Returns a list of updated entity IDs. 

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = TablesUpdateManyTablesApi();
final requestBody = Map<String, Object>(); // Map<String, Object> | 
final id = [[1,2,3]]; // List<int> | List of entity IDs to update

try {
    final result = api_instance.updateManyTables(requestBody, id);
    print(result);
} catch (e) {
    print('Exception when calling TablesUpdateManyTablesApi->updateManyTables: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **requestBody** | [**Map<String, Object>**](Object.md)|  | 
 **id** | [**List<int>**](int.md)| List of entity IDs to update | [optional] [default to const []]

### Return type

**List<int>**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

