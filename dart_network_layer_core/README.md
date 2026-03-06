# Dart Network Layer

**dart_network_layer_core:** [GitHub][gh_dart_network_layer_core] | [pub.dev][pd_dart_network_layer_core]

# dart_network_layer_core

The core package of the Dart Network Layer project.

Provides the frame for the following implementations:

- [dart_network_layer_dio][gh_dart_network_layer_dio] ([pub.dev][pd_dart_network_layer_dio])

## Usage

**Recommended to use with the above implementations.** However, you can implement your own network layer.

<details>
<summary>Click to see how to implement</summary>

- Create a `INetworkInvoker` implementation like that. This is already implemented in mentioned implementation packages.

```dart
// Network Invoker Implementation

import 'package:dart_network_layer_core/dart_network_layer_core.dart';

class NetworkInvoker implements INetworkInvoker {
  @override
  Future<void> init(String baseUrl) async {
    // Create your network client here.
  }

  @override
  Future<ResponseResult<T>> request<T extends ResponseModel>(RequestCommand<T> request) async {
    // Process your request with the network client.
  }
}
```

- Create your own response models like that. These models are specific to api response, so they need to be implemented
  in product level.

```dart
import 'package:dart_network_layer_core/dart_network_layer_core.dart';

class ResponseExample extends JsonResponseModel {
  final String id;
  final String name;
  final int age;

  const ResponseExample({
    required this.id,
    required this.name,
    required this.age,
  });

  const ResponseExample.empty()
      : id = '',
        name = '',
        age = 0;

  @override
  factory ResponseExample.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw Exception('Invalid json type');
    }

    return ResponseExample(
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

- Create your own request models like that. These models are specific to api request, so they need to be implemented
  in product level.

```dart
import 'package:dart_network_layer_core/dart_network_layer_core.dart';

class RequestUser implements RequestCommand<ResponseUser> {
  @override
  Map<String, dynamic> get data => const {};

  @override
  Map<String, dynamic> get headers => const {};

  @override
  HttpRequestMethod get method => HttpRequestMethod.get;

  @override
  OnProgressCallback? onReceiveProgressUpdate;

  @override
  OnProgressCallback? onSendProgressUpdate;

  @override
  String get path => '/example';

  @override
  RequestPayloadType get payloadType => RequestPayloadType.json;

  @override
  ResponseExample get sampleModel => const ResponseExample.empty();
}
```

Or, the `RequestCommand` can be extended. Default values of the fields of the `RequestCommand` are already implemented
in this method. But you can override them if you need.

```dart
import 'package:dart_network_layer_core/dart_network_layer_core.dart';

class RequestUser extends RequestCommand<ResponseUser> {
  @override
  String get path => '/example';

  @override
  ResponseExample get sampleModel => const ResponseExample.empty();
}
```

- Finally, you can use the network layer in your project.

```dart
import 'package:dart_network_layer_core/dart_network_layer_core.dart';

void main() async {
  // create and init the invoker
  final networkInvoker = NetworkInvoker();
  networkInvoker.init('https://api.example.com');

  // send the request
  final response = await networkInvoker.request(RequestUser());

  // handle the response
  response.when(
    success: (data) {
      print(data);
    },
    error: (error) {
      print(error);
    },
  );
}
```

</details>

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
