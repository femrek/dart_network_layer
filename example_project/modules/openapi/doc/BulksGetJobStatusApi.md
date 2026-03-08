# openapi.api.BulksGetJobStatusApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://dummyapi.femrek.dev*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getJobStatus**](BulksGetJobStatusApi.md#) | **GET** /api/v1/dummy/status/{jobId} | Get Job Status


# **getJobStatus**
> Map<String, Object> getJobStatus(jobId, level)

Get Job Status

Retrieves the status of a bulk job. Tests untyped maps and Enum parameters.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = BulksGetJobStatusApi();
final jobId = jobId_example; // String | 
final level = level_example; // String | Detail level required

try {
    final result = api_instance.getJobStatus(jobId, level);
    print(result);
} catch (e) {
    print('Exception when calling BulksGetJobStatusApi->getJobStatus: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**|  | 
 **level** | **String**| Detail level required | [optional] 

### Return type

[**Map<String, Object>**](Object.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

