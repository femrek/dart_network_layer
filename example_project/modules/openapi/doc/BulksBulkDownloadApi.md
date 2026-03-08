# openapi.api.BulksBulkDownloadApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://dummyapi.femrek.dev*

Method | HTTP request | Description
------------- | ------------- | -------------
[**bulkDownload**](BulksBulkDownloadApi.md#) | **GET** /api/v1/dummy/download/{datasetId} | Bulk Download Data


# **bulkDownload**
> MultipartFileSchema bulkDownload(datasetId)

Bulk Download Data

Downloads a generated bulk dataset. Tests binary octet-stream responses.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = BulksBulkDownloadApi();
final datasetId = users-2026; // String | ID of the dataset to download

try {
    final result = api_instance.bulkDownload(datasetId);
    print(result);
} catch (e) {
    print('Exception when calling BulksBulkDownloadApi->bulkDownload: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **datasetId** | **String**| ID of the dataset to download | 

### Return type

[**MultipartFileSchema**](MultipartFileSchema.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/octet-stream, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

