# openapi.api.BulksGetSampleImageApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://dummyapi.femrek.dev*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getSampleImage**](BulksGetSampleImageApi.md#) | **GET** /api/v1/bulk/image | Get Sample Image


# **getSampleImage**
> MultipartFileSchema getSampleImage()

Get Sample Image

Returns a static PNG image from server resources. Tests binary image responses.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = BulksGetSampleImageApi();

try {
    final result = api_instance.getSampleImage();
    print(result);
} catch (e) {
    print('Exception when calling BulksGetSampleImageApi->getSampleImage: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MultipartFileSchema**](MultipartFileSchema.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: image/png, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

