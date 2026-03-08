//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:dart_network_layer_core/dart_network_layer_core.dart';

class TableCreateDTO extends Schema {
  /// Returns a new [TableCreateDTO] instance.
  TableCreateDTO({
    this.name,
    this.capacity,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  final String? name;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  final int? capacity;

  /// The factory instance for creating [TableCreateDTO] from JSON.
  static const factory = TableCreateDTOFactory();

  @override
  bool operator ==(Object other) => identical(this, other) || other is TableCreateDTO &&
    other.name == name &&
    other.capacity == capacity;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name == null ? 0 : name!.hashCode) +
    (capacity == null ? 0 : capacity!.hashCode);

  @override
  String toString() => 'TableCreateDTO[name=$name, capacity=$capacity]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
    if (this.capacity != null) {
      json[r'capacity'] = this.capacity;
    } else {
      json[r'capacity'] = null;
    }
    return json;
  }

  /// Returns a new [TableCreateDTO] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TableCreateDTO? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "TableCreateDTO[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "TableCreateDTO[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return TableCreateDTO(
        name: json[r'name'] is String ? json[r'name'] as String : null,
        capacity: json[r'capacity'] is int ? json[r'capacity'] as int : null,
      );
    }
    return null;
  }

  static List<TableCreateDTO> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TableCreateDTO>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TableCreateDTO.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TableCreateDTO> mapFromJson(dynamic json) {
    final map = <String, TableCreateDTO>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TableCreateDTO.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TableCreateDTO-objects as value to a dart map
  static Map<String, List<TableCreateDTO>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TableCreateDTO>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TableCreateDTO.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

/// Factory for creating [TableCreateDTO] instances from JSON data.
class TableCreateDTOFactory extends JsonSchemaFactory<TableCreateDTO> {
  const TableCreateDTOFactory();

  @override
  TableCreateDTO fromJson(dynamic json) => TableCreateDTO.fromJson(json)!;
}

