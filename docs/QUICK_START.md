# Quick Start

This guide shows the current manual usage flow of Dart Network Layer:

1. Define response schema(s)
2. Define request payload schema(s)
3. Create request command(s)
4. Create an invoker and call `send`

## 1) Add dependency

```yaml
dependencies:
  dart_network_layer_dio: ^latest
```

## 2) Define a response schema and factory

```dart
import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';

final class UserSchema extends Schema {
  const UserSchema({
	required this.id,
	required this.name,
  });

  final int id;
  final String name;

  static const factory = _UserSchemaFactory();
}

final class _UserSchemaFactory extends JsonSchemaFactory<UserSchema> {
  const _UserSchemaFactory();

  @override
  UserSchema fromJson(dynamic json) {
	final map = json as Map<String, dynamic>;
	return UserSchema(
	  id: map['id'] as int,
	  name: map['name'] as String,
	);
  }
}
```

## 3) Define a request payload schema

```dart
import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';

final class CreateUserPayload extends JsonRequestSchema {
  const CreateUserPayload({required this.name});

  final String name;

  @override
  Map<String, dynamic> toJsonPayload() {
	return {'name': name};
  }
}
```

## 4) Define a request command

```dart
import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';

final class CreateUserCommand extends RequestCommand<UserSchema> {
  CreateUserCommand({required this.payloadSchema});

  final CreateUserPayload payloadSchema;

  @override
  String get path => '/users';

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  RequestSchema get payload => payloadSchema;

  @override
  SchemaFactory<UserSchema> get defaultResponseFactory => UserSchema.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => AnyDataSchema.factory;
}
```

## 5) Send request with Dio invoker

```dart
import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';

Future<void> main() async {
  final invoker = DioNetworkInvoker.fromBaseUrl('https://api.example.com');

  final result = await invoker.send(
	CreateUserCommand(
	  payloadSchema: const CreateUserPayload(name: 'Faruk'),
	),
  );

  switch (result) {
	case SuccessResponseResult(:final data):
	  print('Created user: ${data.id} / ${data.name}');
	case SpecifiedResponseResult(:final statusCode, :final data):
	  print('Handled response ($statusCode): $data');
	case NetworkErrorResult(:final error):
	  print('Network error: ${error.message}');
  }
}
```

## Use an existing Dio instance

This is the same pattern used in `example_project/lib/network/app_repos.dart`.

```dart
import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:dio/dio.dart';

final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  responseType: ResponseType.plain,
));

final invoker = DioNetworkInvoker.fromDio(dio);
```

