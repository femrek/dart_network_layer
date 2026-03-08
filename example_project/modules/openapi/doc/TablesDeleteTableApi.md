# openapi.api.TablesDeleteTableApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://dummyapi.femrek.dev*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteTable**](TablesDeleteTableApi.md#) | **DELETE** /api/v1/tables/{id} | Delete: Delete a single entity


# **deleteTable**
> deleteTable(id)

Delete: Delete a single entity

Deletes a single entity by its unique identifier. Implements ra-spring-data-provider's delete operation. 

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = TablesDeleteTableApi();
final id = 1; // int | Unique identifier of the entity to delete

try {
    api_instance.deleteTable(id);
} catch (e) {
    print('Exception when calling TablesDeleteTableApi->deleteTable: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**| Unique identifier of the entity to delete | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

