//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:dart_network_layer_core/dart_network_layer_core.dart';

class UploadMetadata extends Schema {
  /// Returns a new [UploadMetadata] instance.
  UploadMetadata({
    this.targetTable,
    this.overwrite,
  });

  /// The target table for the upload
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  final String? targetTable;

  /// Should existing records be overwritten?
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  final bool? overwrite;

  /// The factory instance for creating [UploadMetadata] from JSON.
  static const factory = UploadMetadataFactory();

  @override
  bool operator ==(Object other) => identical(this, other) || other is UploadMetadata &&
    other.targetTable == targetTable &&
    other.overwrite == overwrite;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (targetTable == null ? 0 : targetTable!.hashCode) +
    (overwrite == null ? 0 : overwrite!.hashCode);

  @override
  String toString() => 'UploadMetadata[targetTable=$targetTable, overwrite=$overwrite]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.targetTable != null) {
      json[r'targetTable'] = this.targetTable;
    } else {
      json[r'targetTable'] = null;
    }
    if (this.overwrite != null) {
      json[r'overwrite'] = this.overwrite;
    } else {
      json[r'overwrite'] = null;
    }
    return json;
  }

  /// Returns a new [UploadMetadata] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UploadMetadata? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UploadMetadata[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UploadMetadata[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UploadMetadata(
        targetTable: json[r'targetTable'] is String ? json[r'targetTable'] as String : null,
        overwrite: json[r'overwrite'] is bool ? json[r'overwrite'] as bool : null,
      );
    }
    return null;
  }

  static List<UploadMetadata> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UploadMetadata>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UploadMetadata.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UploadMetadata> mapFromJson(dynamic json) {
    final map = <String, UploadMetadata>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UploadMetadata.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UploadMetadata-objects as value to a dart map
  static Map<String, List<UploadMetadata>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UploadMetadata>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UploadMetadata.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

/// Factory for creating [UploadMetadata] instances from JSON data.
class UploadMetadataFactory extends JsonSchemaFactory<UploadMetadata> {
  const UploadMetadataFactory();

  @override
  UploadMetadata fromJson(dynamic json) => UploadMetadata.fromJson(json)!;
}

