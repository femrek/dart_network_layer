# openapi.api.BulksBulkUploadApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://dummyapi.femrek.dev*

Method | HTTP request | Description
------------- | ------------- | -------------
[**bulkUpload**](BulksBulkUploadApi.md#) | **POST** /api/v1/bulk/upload | Bulk Upload Data


# **bulkUpload**
> UploadResponse bulkUpload(file, metadata)

Bulk Upload Data

Uploads a bulk data file along with metadata. Tests multipart/form-data with mixed parts.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = BulksBulkUploadApi();
final file = BINARY_DATA_HERE; // MultipartFileSchema | The binary file to upload
final metadata = ; // UploadMetadata | 

try {
    final result = api_instance.bulkUpload(file, metadata);
    print(result);
} catch (e) {
    print('Exception when calling BulksBulkUploadApi->bulkUpload: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **file** | **MultipartFileSchema**| The binary file to upload | 
 **metadata** | [**UploadMetadata**](UploadMetadata.md)|  | [optional] 

### Return type

[**UploadResponse**](UploadResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: */*, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

