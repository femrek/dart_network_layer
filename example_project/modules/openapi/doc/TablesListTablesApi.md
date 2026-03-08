# openapi.api.TablesListTablesApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://dummyapi.femrek.dev*

Method | HTTP request | Description
------------- | ------------- | -------------
[**listTables**](TablesListTablesApi.md#) | **GET** /api/v1/tables | GetList: Get paginated list of entities with filtering


# **listTables**
> List<Table> listTables(start, end, allParams, sort, order, embed)

GetList: Get paginated list of entities with filtering

Retrieves a paginated list of entities with support for sorting and filtering. Implements ra-spring-data-provider's getList operation.  This method returns a subset of entities based on the pagination parameters (_start and _end). The results can be sorted by any field in ascending or descending order. Custom filters can be applied through additional query parameters passed in allParams.  The response includes an X-Total-Count header containing the total number of entities matching the filter criteria (not just the current page). This header is essential for ra-spring-data-provider to calculate pagination correctly.  Example: GET /api/posts?_start=0&_end=10&_sort=title&_order=ASC&status=published 

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = TablesListTablesApi();
final start = 0; // int | Starting index for pagination (0-based, inclusive)
final end = 10; // int | Ending index for pagination (0-based, exclusive)
final allParams = Object; // Map<String, String> | Additional query parameters for filtering by entity fields
final sort = id; // String | Field name to sort by
final order = ASC; // String | Sort direction (ASC or DESC)
final embed = embed_example; // String | Optional parameter to embed related resources (implementation-specific)

try {
    final result = api_instance.listTables(start, end, allParams, sort, order, embed);
    print(result);
} catch (e) {
    print('Exception when calling TablesListTablesApi->listTables: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **start** | **int**| Starting index for pagination (0-based, inclusive) | 
 **end** | **int**| Ending index for pagination (0-based, exclusive) | 
 **allParams** | [**Map<String, String>**](String.md)| Additional query parameters for filtering by entity fields | [default to const {}]
 **sort** | **String**| Field name to sort by | [optional] [default to 'id']
 **order** | **String**| Sort direction (ASC or DESC) | [optional] [default to 'ASC']
 **embed** | **String**| Optional parameter to embed related resources (implementation-specific) | [optional] 

### Return type

[**List<Table>**](Table.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

