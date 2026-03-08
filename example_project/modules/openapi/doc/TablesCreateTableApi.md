# openapi.api.TablesCreateTableApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://dummyapi.femrek.dev*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createTable**](TablesCreateTableApi.md#) | **POST** /api/v1/tables | Create: Create a new entity


# **createTable**
> Table createTable(tableCreateDTO)

Create: Create a new entity

Creates a new entity with the provided data. Implements ra-spring-data-provider's create operation. Returns the created entity with generated ID and server-side defaults. 

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = TablesCreateTableApi();
final tableCreateDTO = TableCreateDTO(); // TableCreateDTO | 

try {
    final result = api_instance.createTable(tableCreateDTO);
    print(result);
} catch (e) {
    print('Exception when calling TablesCreateTableApi->createTable: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tableCreateDTO** | [**TableCreateDTO**](TableCreateDTO.md)|  | 

### Return type

[**Table**](Table.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

