# openapi.api.TablesUpdateTableApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://dummyapi.femrek.dev*

Method | HTTP request | Description
------------- | ------------- | -------------
[**updateTable**](TablesUpdateTableApi.md#) | **PUT** /api/v1/tables/{id} | Update: Update an existing entity


# **updateTable**
> Table updateTable(id, requestBody)

Update: Update an existing entity

Updates an existing entity with the provided field values. Implements ra-spring-data-provider's update operation with support for partial updates. Only the fields provided in the request body will be updated. 

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = TablesUpdateTableApi();
final id = 1; // int | Unique identifier of the entity to update
final requestBody = Map<String, Object>(); // Map<String, Object> | 

try {
    final result = api_instance.updateTable(id, requestBody);
    print(result);
} catch (e) {
    print('Exception when calling TablesUpdateTableApi->updateTable: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**| Unique identifier of the entity to update | 
 **requestBody** | [**Map<String, Object>**](Object.md)|  | 

### Return type

[**Table**](Table.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

