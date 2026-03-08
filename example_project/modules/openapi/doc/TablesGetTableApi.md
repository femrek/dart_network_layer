# openapi.api.TablesGetTableApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://dummyapi.femrek.dev*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getTable**](TablesGetTableApi.md#) | **GET** /api/v1/tables/{id} | GetOne: Get single entity by ID


# **getTable**
> Table getTable(id)

GetOne: Get single entity by ID

Retrieves a single entity by its unique identifier. Implements ra-spring-data-provider's getOne operation. 

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = TablesGetTableApi();
final id = 1; // int | Unique identifier of the entity to retrieve

try {
    final result = api_instance.getTable(id);
    print(result);
} catch (e) {
    print('Exception when calling TablesGetTableApi->getTable: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**| Unique identifier of the entity to retrieve | 

### Return type

[**Table**](Table.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

