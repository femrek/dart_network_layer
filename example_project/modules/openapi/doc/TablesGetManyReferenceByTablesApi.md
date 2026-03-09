# openapi.api.TablesGetManyReferenceByTablesApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://dummyapi.femrek.dev*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getManyReferenceByTables**](TablesGetManyReferenceByTablesApi.md#) | **GET** /api/v1/tables/of/{target}/{targetId} | GetManyReference: Get entities that reference another entity


# **getManyReferenceByTables**
> List<TableDTO> getManyReferenceByTables(target, targetId, start, end, allParams, sort, order, embed)

GetManyReference: Get entities that reference another entity

Retrieves a paginated list of entities that reference another specific entity. Implements ra-spring-data-provider's getManyReference operation.  This operation is used to fetch entities related to a specific record. For example, retrieving all comments for a particular post, or all orders for a specific customer. Unlike getList, the filter is based on a reference relationship rather than arbitrary criteria.  The response includes an X-Total-Count header containing the total number of entities that reference the specified target entity. This is essential for pagination in React Admin.  Example: GET /api/comments/of/postId/123?_start=0&_end=10&_sort=createdAt&_order=DESC This retrieves comments where the postId field equals 123, paginated and sorted. 

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = TablesGetManyReferenceByTablesApi();
final target = userId; // String | Name of the field that references the target entity
final targetId = 123; // String | ID of the target entity being referenced
final start = 0; // int | Starting index for pagination (0-based, inclusive)
final end = 10; // int | Ending index for pagination (0-based, exclusive)
final allParams = Object; // Map<String, String> | Additional query parameters for filtering
final sort = id; // String | Field name to sort by
final order = DESC; // String | Sort direction (ASC or DESC)
final embed = embed_example; // String | Optional parameter to embed related resources (implementation-specific)

try {
    final result = api_instance.getManyReferenceByTables(target, targetId, start, end, allParams, sort, order, embed);
    print(result);
} catch (e) {
    print('Exception when calling TablesGetManyReferenceByTablesApi->getManyReferenceByTables: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **target** | **String**| Name of the field that references the target entity | 
 **targetId** | **String**| ID of the target entity being referenced | 
 **start** | **int**| Starting index for pagination (0-based, inclusive) | 
 **end** | **int**| Ending index for pagination (0-based, exclusive) | 
 **allParams** | [**Map<String, String>**](String.md)| Additional query parameters for filtering | [default to const {}]
 **sort** | **String**| Field name to sort by | [optional] [default to 'id']
 **order** | **String**| Sort direction (ASC or DESC) | [optional] [default to 'ASC']
 **embed** | **String**| Optional parameter to embed related resources (implementation-specific) | [optional] 

### Return type

[**List<TableDTO>**](TableDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

