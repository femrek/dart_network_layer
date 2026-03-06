import 'package:dio/dio.dart';
import 'package:flutter_network_layer_core/flutter_network_layer_core.dart';

/// Converts a list of [QueryParameter] into a Map suitable for Dio's query
/// parameters.
Map<String, dynamic> convertQueryParameters(List<QueryParameter> data) {
  final result = <String, dynamic>{};

  for (final param in data) {
    final key = param.key;
    // 1. Convert null to an empty string immediately
    final value = param.value ?? '';

    if (result.containsKey(key)) {
      final existingValue = result[key];

      final mergedValues = <dynamic>[];
      ListFormat? preservedFormat;

      // 2. Extract values and format from the EXISTING entry
      if (existingValue is ListParam) {
        mergedValues.addAll(existingValue.value);
        preservedFormat = existingValue.format;
      } else if (existingValue is List) {
        mergedValues.addAll(existingValue);
      } else {
        mergedValues.add(existingValue);
      }

      // 3. Extract values and format from the NEW incoming entry
      if (value is ListParam) {
        mergedValues.addAll(value.value);
        preservedFormat = value.format;
      } else if (value is List) {
        mergedValues.addAll(value);
      } else {
        mergedValues.add(value); // If it was null, this adds the '' to the list
      }

      // 4. Re-wrap the merged result.
      if (preservedFormat != null) {
        result[key] = ListParam<dynamic>(mergedValues, preservedFormat);
      } else {
        result[key] = mergedValues;
      }

    } else {
      // First time seeing this key, assign it directly.
      // If it was null, result[key] becomes ''
      result[key] = value;
    }
  }

  return result;
}
