# openapi.api.ComplexesGetWidgetsApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://dummyapi.femrek.dev*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getWidgets**](ComplexesGetWidgetsApi.md#) | **GET** /api/v1/complex-json/widgets | Get Polymorphic UI Widgets


# **getWidgets**
> WidgetPaginationResponse getWidgets(page)

Get Polymorphic UI Widgets

Returns a paginated list of heterogeneous widgets using a discriminator field.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ComplexesGetWidgetsApi();
final page = 1; // int | Page number

try {
    final result = api_instance.getWidgets(page);
    print(result);
} catch (e) {
    print('Exception when calling ComplexesGetWidgetsApi->getWidgets: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **page** | **int**| Page number | [optional] [default to 1]

### Return type

[**WidgetPaginationResponse**](WidgetPaginationResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

