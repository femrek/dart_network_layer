# openapi.api.ComplexesProcessCategoryTreeApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://dummyapi.femrek.dev*

Method | HTTP request | Description
------------- | ------------- | -------------
[**processCategoryTree**](ComplexesProcessCategoryTreeApi.md#) | **POST** /api/v1/complex-json/categories/tree | Create Category Tree


# **processCategoryTree**
> CategoryNode processCategoryTree(categoryNode)

Create Category Tree

Accepts and returns a deeply nested, self-referencing tree structure.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ComplexesProcessCategoryTreeApi();
final categoryNode = CategoryNode(); // CategoryNode | 

try {
    final result = api_instance.processCategoryTree(categoryNode);
    print(result);
} catch (e) {
    print('Exception when calling ComplexesProcessCategoryTreeApi->processCategoryTree: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **categoryNode** | [**CategoryNode**](CategoryNode.md)|  | 

### Return type

[**CategoryNode**](CategoryNode.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

