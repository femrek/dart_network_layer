# Flutter Network Layer

**dart_network_layer_dio:** [GitHub][gh_dart_network_layer_dio] | [pub.dev][pd_dart_network_layer_dio]

# dart_network_layer_dio

Provides the implementation of the network layer with
[Dio][pd_dio] package. So, it includes the implementation of network invoker with Dio that is defined
in [dart_network_layer_core.][gh_dart_network_layer_core]

## Table of Contents

- [General Information](#general-information)
    - [Command Pattern Like Request Management](#command-pattern-like-request-management)
    - [Implementation with Dio](#implementation-with-dio)
- [Features](#features)
- [Use in Your Project](#use-in-your-project)
- [Listen_to the Logs of the Package](#listen-to-the-logs-of-the-package)
- [Dio Interceptors](#dio-interceptors)
- [License](#license)

## General Information

This is an API request layer for Dart/Flutter projects.

- The usage of this package:
    - Create your `ResponseModel`'s to define the type of the response. (`GetTodoResponse` is the example in the
      following class diagram)
    - Create your `RequestCommand`'s to define the properties of the request. (e.g., method, url path, headers, payload,
      etc.) (`GetTodoRequestCommand` and `PostTodoRequestCommand` are the examples in the following class diagram)
    - Create your `INetworkInvoker` object from an implementation of this package. (`DioNetworkInvoker`). Using
      `get_it` is highly recommended to create a singleton instance of the `INetworkInvoker`.
    - In business logic, create a `RequestCommand` object and send it to the `INetworkInvoker` object to get the
      response.

<img width="1266" alt="Screenshot 2025-01-11 at 02 58 01" src="https://github.com/user-attachments/assets/1c10872a-8c3d-4fb5-9d26-221ccac74c85" />

Figure: Class diagram of an example flutter application (Production section in the figure) with
dart_network_layer_core and dart_network_layer_dio.

### Command Pattern Like Request Management

This package uses an architecture that is similar to the command pattern to manage requests.

Each request is a command that can be executed as a parameter of the `request` method of the `INetworkInvoker`
interface.

You can create a request by implementing the `RequestCommand` class.  
It defines the HTTP method (`GET`, `POST`, etc.), headers, payload, and other request details.

To send the request, call the `request` method of the `INetworkInvoker`.

### Implementation with Dio

[Dio][pd_dio] is a powerful HTTP client for Dart/Flutter projects. This package provides an implementation of the
`INetworkInvoker` interface with Dio named `DioNetworkInvoker`.

## Features

- Modular and easily pluggable architecture.
- Command-pattern-like request management.
- Easy integration with dependency injection frameworks like `get_it`.
- Logging trigger function to integrate with logger of the product level.

## Use in Your Project

**Tests:**
The tests in the `test` directory demonstrates how to use the network layer. Also, the `example` application is a simple
Dart program that uses this package to fetch data from a server.

**Example Project:**
[example_flutter_dio][gh_example_flutter_dio] is a good example that shows how to use `dart_network_layer_dio` in a
Flutter project. This example also includes `get_it` to create a singleton instance of the `INetworkInvoker` with the
`DioNetworkInvoker`implementation. As logger, `logger` package is used in this example and `onLog` function of the
`DioNetworkInvoker` is set to receive logs from this package.

Follow the steps below to use the network layer in your Dart/Flutter project:

- Add the network module as a dependency in the `pubspec.yaml` file of the project.

```yaml
dependencies:
  dart_network_layer_dio: <version code> # check the version code in the pubspec.yaml file of the module.
```

- Create your own response models like the following example. Also, you can use auto generation tools like
  `json_serializable` to generate these models. The only point is that these models should implement the
  `JsonResponseModel` or `CustomResponseModel` and providing valid serialization methods.

```dart
import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';

final class ResponseUser extends JsonResponseModel {
  const ResponseUser({
    required this.id,
    required this.name,
    required this.age,
  });

  const ResponseUser.empty()
      : id = '',
        name = '',
        age = 0;

  final String id;
  final String name;
  final int age;

  @override
  ResponseUser fromJson(dynamic json) {
    assert(json is Map<String, dynamic>, 'json is not a Map<String, dynamic>');
    final map = json as Map<String, dynamic>;

    return ResponseUser(
      id: map['id'] as String,
      name: map['name'] as String,
      age: map['age'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
    };
  }
}
```

- Create your own request models (commands) like the following example. This class has to include information about the
  request will be sent to the server.

```dart
import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';

final class RequestUser extends RequestCommand<ResponseUser> {
  @override
  Object? get payload => const {};

  @override
  Map<String, dynamic> get headers => const {};

  @override
  HttpRequestMethod get method => HttpRequestMethod.get;

  @override
  OnProgressCallback? onReceiveProgressUpdate;

  @override
  OnProgressCallback? onSendProgressUpdate;

  @override
  String get path => '/user';

  @override
  RequestPayloadType get payloadType => RequestPayloadType.other;

  @override
  ResponseUser get sampleModel => const ResponseUser.empty();
}
```

- Finally, you can use the network invoker named `DioNetworkInvoker` to send the request to the server. The following
  example demonstrates how to send a request to the server and handle the response.

```dart
import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';

import 'request_user.dart';
import 'response_user.dart';

void main() async {
  final INetworkInvoker nm = DioNetworkInvoker();
  final RequestCommand<ResponseUser> request = await nm.request(RequestUser());
  request.when(
    success: (response) {
      print('Response: $response');
    },
    failure: (error) {
      print('Error: $error');
    },
  );
}
```

## Listen to the Logs of the Package

The package provides a logging trigger function to integrate with the logger of the product level. The logging trigger
function can be set by calling the `setLoggingTrigger` function of the `NetworkModule` class.

```dart
// pass the logging trigger function when creating the network invoker.
final INetworkInvoker nm = DioNetworkInvoker(
  onLog: _onLog,
);

void _onLog(LogLevel level, String message) {
  // You can use your own logger here.
  // For a simple example, you can print the logs to the console like that.
  print('[$level] $message');

  if (!level.maySensitiveData) {
    // The log message does not contain request or response data for this condition.
  }
}
```

## Dio Interceptors

Dio interceptors can be added to the network invoker by passing them as a parameter to the constructor of the
`DioNetworkInvoker` class. They are added to the Dio instance when the `init` method is called. Check the Dio
documentation for more information about interceptors.

```dart

final INetworkInvoker nm = DioNetworkInvoker(
  dioInterceptors: [
    YourInterceptor(),
  ],
);
```

## License

```
MIT License

Copyright (c) 2025 Faruk Emre

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

[gh_dart_network_layer_core]: https://github.com/femrek/dart_network_layer/tree/main/dart_network_layer_core

[pd_dart_network_layer_core]: https://pub.dev/packages/dart_network_layer_core

[gh_dart_network_layer_dio]: https://github.com/femrek/dart_network_layer/tree/main/dart_network_layer_dio

[pd_dart_network_layer_dio]: https://pub.dev/packages/dart_network_layer_dio

[gh_example_flutter_dio]: https://github.com/femrek/dart_network_layer/tree/main/example_flutter_dio

[pd_dio]: https://pub.dev/packages/dio

