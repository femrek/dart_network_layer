# Sending Files

Use `FormDataRequestSchema` together with `MultipartFileSchema` for uploads.

The same pattern is used in
`example_project/modules/openapi/lib/requests/bulks/bulk_upload_command.dart`.

## 1) Define multipart request schema

```dart
import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';

final class UploadAvatarPayload extends FormDataRequestSchema {
  const UploadAvatarPayload({
	required this.file,
	required this.userId,
  });

  final MultipartFileSchema file;
  final String userId;

  @override
  Map<String, dynamic> toFormDataMapPayload() {
	return {
	  'file': file,
	  'userId': userId,
	};
  }
}
```

## 2) Define command

```dart
import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';

final class UploadAvatarResponse extends Schema {
  const UploadAvatarResponse({required this.fileUrl});

  final String fileUrl;

  static const factory = _UploadAvatarResponseFactory();
}

final class _UploadAvatarResponseFactory
	extends JsonSchemaFactory<UploadAvatarResponse> {
  const _UploadAvatarResponseFactory();

  @override
  UploadAvatarResponse fromJson(dynamic json) {
	final map = json as Map<String, dynamic>;
	return UploadAvatarResponse(fileUrl: map['fileUrl'] as String);
  }
}

final class UploadAvatarCommand extends RequestCommand<UploadAvatarResponse> {
  UploadAvatarCommand(this.payloadSchema);

  final UploadAvatarPayload payloadSchema;

  @override
  String get path => '/users/avatar';

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  RequestSchema get payload => payloadSchema;

  @override
  SchemaFactory<UploadAvatarResponse> get defaultResponseFactory =>
	  UploadAvatarResponse.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => AnyDataSchema.factory;

  @override
  OnProgressCallback? get onSendProgressUpdate =>
	  (done, total) => print('upload progress: $done/$total');
}
```

## 3) Build multipart file input

### From file path

```dart
import 'dart:io';
import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';

final file = File('/tmp/avatar.jpg');
final multipart = FileMultipartFileSchema(
  filename: 'avatar.jpg',
  filePath: file.path,
  length: file.lengthSync(),
);
```

### From bytes

```dart
import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';

final multipart = ByteMultipartFileSchema(
  filename: 'avatar.jpg',
  data: bytes,
  length: bytes.length,
);
```

### From stream

```dart
import 'dart:io';
import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';

final file = File('/tmp/video.mp4');
final multipart = StreamMultipartFileSchema(
  filename: 'video.mp4',
  length: file.lengthSync(),
  streamBuilder: () => file.openRead(),
);
```

## 4) Send

```dart
final result = await invoker.send(
  UploadAvatarCommand(
	UploadAvatarPayload(
	  file: multipart,
	  userId: '42',
	),
  ),
);
```

