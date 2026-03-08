//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:dart_network_layer_core/dart_network_layer_core.dart';

class Widget extends Schema {
  /// Returns a new [Widget] instance.
  Widget({
    this.id,
    this.name,
    required this.widgetType,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  final String? id;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  final String? name;

  final String widgetType;

  /// The factory instance for creating [Widget] from JSON.
  static const factory = WidgetFactory();

  @override
  bool operator ==(Object other) => identical(this, other) || other is Widget &&
    other.id == id &&
    other.name == name &&
    other.widgetType == widgetType;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (name == null ? 0 : name!.hashCode) +
    (widgetType.hashCode);

  @override
  String toString() => 'Widget[id=$id, name=$name, widgetType=$widgetType]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
      json[r'widgetType'] = this.widgetType;
    return json;
  }

  /// Returns a new [Widget] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Widget? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Widget[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Widget[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Widget(
        id: json[r'id'] is String ? json[r'id'] as String : null,
        name: json[r'name'] is String ? json[r'name'] as String : null,
        widgetType: json[r'widgetType'] as String,
      );
    }
    return null;
  }

  static List<Widget> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Widget>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Widget.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Widget> mapFromJson(dynamic json) {
    final map = <String, Widget>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Widget.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Widget-objects as value to a dart map
  static Map<String, List<Widget>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Widget>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Widget.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'widgetType',
  };
}

/// Factory for creating [Widget] instances from JSON data.
class WidgetFactory extends JsonSchemaFactory<Widget> {
  const WidgetFactory();

  @override
  Widget fromJson(dynamic json) => Widget.fromJson(json)!;
}

