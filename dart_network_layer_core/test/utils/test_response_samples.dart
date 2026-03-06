import 'package:dart_network_layer_core/dart_network_layer_core.dart';

final class ResponseTest1 extends Schema {
  ResponseTest1({required this.field1});

  final String field1;
}

class ResponseTest1Factory extends JsonSchemaFactory<ResponseTest1> {
  factory ResponseTest1Factory() => _instance;

  ResponseTest1Factory._internal();

  static final ResponseTest1Factory _instance =
      ResponseTest1Factory._internal();

  @override
  ResponseTest1 fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw Exception('Invalid JSON: $json');
    }
    return ResponseTest1(
      field1: json['field1'] as String,
    );
  }
}

final class ResponseTestError extends Schema {
  ResponseTestError({
    this.message,
    this.errorField,
  });

  final String? message;
  final String? errorField;
}

final class ResponseTestErrorFactory
    extends JsonSchemaFactory<ResponseTestError> {
  factory ResponseTestErrorFactory() => _instance;

  ResponseTestErrorFactory._internal();

  static final ResponseTestErrorFactory _instance =
      ResponseTestErrorFactory._internal();

  @override
  ResponseTestError fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw Exception('Invalid JSON: $json');
    }
    return ResponseTestError(
      message: json['message'] as String?,
      errorField: json['errorField'] as String?,
    );
  }
}
