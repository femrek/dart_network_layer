//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:dart_network_layer_core/dart_network_layer_core.dart';

class UploadResponse extends Schema {
  /// Returns a new [UploadResponse] instance.
  UploadResponse({
    this.jobId,
    this.message,
  });

  /// The background job ID tracking the upload
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  final String? jobId;

  /// Human readable message
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  final String? message;

  /// The factory instance for creating [UploadResponse] from JSON.
  static const factory = UploadResponseFactory();

  @override
  bool operator ==(Object other) => identical(this, other) || other is UploadResponse &&
    other.jobId == jobId &&
    other.message == message;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (jobId == null ? 0 : jobId!.hashCode) +
    (message == null ? 0 : message!.hashCode);

  @override
  String toString() => 'UploadResponse[jobId=$jobId, message=$message]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.jobId != null) {
      json[r'jobId'] = this.jobId;
    } else {
      json[r'jobId'] = null;
    }
    if (this.message != null) {
      json[r'message'] = this.message;
    } else {
      json[r'message'] = null;
    }
    return json;
  }

  /// Returns a new [UploadResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UploadResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UploadResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UploadResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UploadResponse(
        jobId: json[r'jobId'] is String ? json[r'jobId'] as String : null,
        message: json[r'message'] is String ? json[r'message'] as String : null,
      );
    }
    return null;
  }

  static List<UploadResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UploadResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UploadResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UploadResponse> mapFromJson(dynamic json) {
    final map = <String, UploadResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UploadResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UploadResponse-objects as value to a dart map
  static Map<String, List<UploadResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UploadResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UploadResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

/// Factory for creating [UploadResponse] instances from JSON data.
class UploadResponseFactory extends JsonSchemaFactory<UploadResponse> {
  const UploadResponseFactory();

  @override
  UploadResponse fromJson(dynamic json) => UploadResponse.fromJson(json)!;
}

