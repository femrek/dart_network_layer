# Receiving Files

Binary endpoints should return `BinarySchema` and configure
`RequestCommand.binaryResponseType`.

Reference implementation:
`example_project/modules/openapi/lib/requests/bulks/bulk_download_command.dart`.

## 1) Define a binary download command

```dart
import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';

final class DownloadReportCommand extends RequestCommand<BinarySchema> {
  DownloadReportCommand({
	required this.reportId,
	this.responseType = const InMemoryBinaryResponse(),
  });

  final String reportId;
  final BinaryResponseType responseType;

  @override
  String get path => '/reports/$reportId/download';

  @override
  HttpRequestMethod get method => HttpRequestMethod.get;

  @override
  BinaryResponseType get binaryResponseType => responseType;

  @override
  SchemaFactory<BinarySchema> get defaultResponseFactory =>
	  BinarySchemaFactory(binaryResponseType: responseType);

  @override
  SchemaFactory get defaultErrorResponseFactory => AnyDataSchema.factory;

  @override
  OnProgressCallback? get onReceiveProgressUpdate =>
	  (done, total) => print('download progress: $done/$total');
}
```

## 2) Receive bytes in memory

```dart
final result = await invoker.send(
  DownloadReportCommand(reportId: 'daily-1'),
);

switch (result) {
  case SuccessResponseResult<BinarySchema>(:final data):
	final binary = data as InMemoryBinarySchema;
	print('Bytes length: ${binary.bytes.length}');
  case NetworkErrorResult(:final error):
	print(error.message);
  default:
	print('Non-success response');
}
```

## 3) Save directly to file

```dart
final result = await invoker.send(
  DownloadReportCommand(
	reportId: 'daily-1',
	responseType: const FileBinaryResponse('/tmp/daily-report.zip'),
  ),
);

if (result case SuccessResponseResult<BinarySchema>(:final data)) {
  final fileSchema = data as FileBinarySchema;
  print('Saved to: ${fileSchema.filePath}');
}
```

## 4) Use streaming or raw-string mode

```dart
// Stream mode
final streamResult = await invoker.send(
  DownloadReportCommand(
	reportId: 'daily-1',
	responseType: const StreamBinaryResponse(),
  ),
);

// Raw string mode
final textResult = await invoker.send(
  DownloadReportCommand(
	reportId: 'csv-1',
    responseType: const RawStringBinaryResponse(),
  ),
);
```


