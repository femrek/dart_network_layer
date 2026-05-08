# Quick Start with OpenAPI

This project supports an OpenAPI-first flow where generated request commands
extend `RequestCommand<T extends Schema>` and can be sent directly via
`DioNetworkInvoker`.

The reference implementation is in:

- `example_project/modules/openapi/lib/`
- `example_project/lib/network/app_repos.dart`
- `example_project/lib/widgets/requests/`

## 1) Generate and export your API module

Your generated module should export:

- request commands (for example, `GetTableCommand`, `BulkUploadCommand`)
- schema models (`Schema` classes)
- shared base request class (optional customization point)

Example export file: `example_project/modules/openapi/lib/api.dart`.

## 2) Create an invoker from generated server config

```dart
import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:dio/dio.dart';
import 'package:openapi/api.dart';

final dio = Dio(
  BaseOptions(
	baseUrl: ApiConfig.url0_generatedServerUrl,
	responseType: ResponseType.plain,
	followRedirects: true,
  ),
);

final invoker = DioNetworkInvoker.fromDio(dio);
```

## 3) Send generated commands

```dart
import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:openapi/api.dart';

Future<void> loadTable(DioNetworkInvoker invoker) async {
  final result = await invoker.send(GetTableCommand(id: 1));

  switch (result) {
	case SuccessResponseResult<TableDTO>(:final data):
	  print('Table loaded: ${data.name}');
	case SpecifiedResponseResult(:final statusCode, :final data):
	  print('Handled response ($statusCode): $data');
	case NetworkErrorResult(:final error):
	  print('Request failed: ${error.message}');
  }
}
```

## 4) Generated command anatomy

A generated command typically defines:

- `path`
- `method`
- optional `queryParameters`
- `payload`
- `defaultResponseFactory`
- `defaultErrorResponseFactory`
- optional `responseFactories` for status-specific schemas

See `example_project/modules/openapi/lib/requests/tables/list_tables_command.dart`.

## 5) Customize all generated commands at once

Generated commands can extend a shared base class like
`OpenapiDefinitionBaseRequest<T>`. You can customize this class in your template
to add common headers or behavior to every generated request.

## 6) File endpoints work the same way

Generated commands can include:

- multipart uploads (`FormDataRequestSchema` + `MultipartFileSchema`)
- binary responses (`BinarySchema` + `BinaryResponseType`)

See `docs/SENDING_FILES.md` and `docs/RECIEVING_FILES.md`.

