//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'widget.dart';

class ButtonWidget extends Schema {
  /// Returns a new [ButtonWidget] instance.
  ButtonWidget({
    this.id,
    this.name,
    required this.widgetType,
    this.actionUrl,
    this.style,
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

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  final String? actionUrl;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  final String? style;

  /// The factory instance for creating [ButtonWidget] from JSON.
  static const factory = ButtonWidgetFactory();

  @override
  bool operator ==(Object other) => identical(this, other) || other is ButtonWidget &&
    other.id == id &&
    other.name == name &&
    other.widgetType == widgetType &&
    other.actionUrl == actionUrl &&
    other.style == style;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (name == null ? 0 : name!.hashCode) +
    (widgetType.hashCode) +
    (actionUrl == null ? 0 : actionUrl!.hashCode) +
    (style == null ? 0 : style!.hashCode);

  @override
  String toString() => 'ButtonWidget[id=$id, name=$name, widgetType=$widgetType, actionUrl=$actionUrl, style=$style]';

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
    if (this.actionUrl != null) {
      json[r'actionUrl'] = this.actionUrl;
    } else {
      json[r'actionUrl'] = null;
    }
    if (this.style != null) {
      json[r'style'] = this.style;
    } else {
      json[r'style'] = null;
    }
    return json;
  }

  /// Returns a new [ButtonWidget] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ButtonWidget? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ButtonWidget[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ButtonWidget[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ButtonWidget(
        id: json[r'id'] is String ? json[r'id'] as String : null,
        name: json[r'name'] is String ? json[r'name'] as String : null,
        widgetType: json[r'widgetType'] as String,
        actionUrl: json[r'actionUrl'] is String ? json[r'actionUrl'] as String : null,
        style: json[r'style'] is String ? json[r'style'] as String : null,
      );
    }
    return null;
  }

  static List<ButtonWidget> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ButtonWidget>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ButtonWidget.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ButtonWidget> mapFromJson(dynamic json) {
    final map = <String, ButtonWidget>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ButtonWidget.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ButtonWidget-objects as value to a dart map
  static Map<String, List<ButtonWidget>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ButtonWidget>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ButtonWidget.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'widgetType',
  };
}

/// Factory for creating [ButtonWidget] instances from JSON data.
class ButtonWidgetFactory extends JsonSchemaFactory<ButtonWidget> {
  const ButtonWidgetFactory();

  @override
  ButtonWidget fromJson(dynamic json) => ButtonWidget.fromJson(json)!;
}

