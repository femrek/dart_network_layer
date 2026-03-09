# openapi.api.ComplexesPatchRecordApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://dummyapi.femrek.dev*

Method | HTTP request | Description
------------- | ------------- | -------------
[**patchRecord**](ComplexesPatchRecordApi.md#) | **PATCH** /api/v1/complex-json/records/{id} | Partial Update (PATCH)


# **patchRecord**
> Map<String, Object> patchRecord(id, body)

Partial Update (PATCH)

Accepts a flexible payload to test how the client drops nulls or omits fields.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ComplexesPatchRecordApi();
final id = id_example; // String | 
final body = Object(); // Object | Dynamic payload for partial updates

try {
    final result = api_instance.patchRecord(id, body);
    print(result);
} catch (e) {
    print('Exception when calling ComplexesPatchRecordApi->patchRecord: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **body** | **Object**| Dynamic payload for partial updates | 

### Return type

[**Map<String, Object>**](Object.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

