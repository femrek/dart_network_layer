// ignore_for_file: avoid_print just an example

import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';

void main() async {
  final request = RequestUser(id: 1);
  final response = await AppNetworkManager.networkInvoker.request(request);
  switch (response) {
    case SuccessResponseResult(:final data):
      print('DATA: $data');
    case final SpecifiedResponseResult r:
      print('ERROR: Status ${r.statusCode}');
      print(r.data);
    case NetworkErrorResult(:final error):
      print('ERROR: ${error.message}');
  }
}

abstract final class AppNetworkManager {
  static final INetworkInvoker networkInvoker = DioNetworkInvoker.fromBaseUrl(
    'https://jsonplaceholder.typicode.com',
  );
}

final class ResponseUser extends Schema {
  const ResponseUser({
    required this.id,
    required this.name,
  });

  const ResponseUser.empty()
      : id = 0,
        name = '';

  final int id;
  final String name;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() => toJson().toString();
}

final class ResponseUserFactory extends JsonSchemaFactory<ResponseUser> {
  factory ResponseUserFactory() => _instance;

  const ResponseUserFactory._internal();

  static const ResponseUserFactory _instance = ResponseUserFactory._internal();

  @override
  ResponseUser fromJson(dynamic json) {
    assert(json is Map<String, dynamic>, 'json is not a Map<String, dynamic>');
    final map = json as Map<String, dynamic>;

    return ResponseUser(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }
}

final class RequestUser extends RequestCommand<ResponseUser> {
  RequestUser({
    required this.id,
  });

  final int id;

  @override
  String get path => '/users/$id';

  @override
  SchemaFactory<ResponseUser> get defaultResponseFactory =>
      ResponseUserFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}
