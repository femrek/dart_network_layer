//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'button_widget.dart';
import 'text_widget.dart';

class WidgetPaginationResponseDataInner extends Schema {
  /// Returns a new [WidgetPaginationResponseDataInner] instance.
  WidgetPaginationResponseDataInner({
    this.id,
    this.name,
    required this.widgetType,
    this.actionUrl,
    this.style,
    this.content,
    this.fontSize,
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

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  final String? content;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  final int? fontSize;

  /// The factory instance for creating [WidgetPaginationResponseDataInner] from JSON.
  static const factory = WidgetPaginationResponseDataInnerFactory();

  @override
  bool operator ==(Object other) => identical(this, other) || other is WidgetPaginationResponseDataInner &&
    other.id == id &&
    other.name == name &&
    other.widgetType == widgetType &&
    other.actionUrl == actionUrl &&
    other.style == style &&
    other.content == content &&
    other.fontSize == fontSize;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (name == null ? 0 : name!.hashCode) +
    (widgetType.hashCode) +
    (actionUrl == null ? 0 : actionUrl!.hashCode) +
    (style == null ? 0 : style!.hashCode) +
    (content == null ? 0 : content!.hashCode) +
    (fontSize == null ? 0 : fontSize!.hashCode);

  @override
  String toString() => 'WidgetPaginationResponseDataInner[id=$id, name=$name, widgetType=$widgetType, actionUrl=$actionUrl, style=$style, content=$content, fontSize=$fontSize]';

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
    if (this.content != null) {
      json[r'content'] = this.content;
    } else {
      json[r'content'] = null;
    }
    if (this.fontSize != null) {
      json[r'fontSize'] = this.fontSize;
    } else {
      json[r'fontSize'] = null;
    }
    return json;
  }

  /// Returns a new [WidgetPaginationResponseDataInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static WidgetPaginationResponseDataInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "WidgetPaginationResponseDataInner[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "WidgetPaginationResponseDataInner[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return WidgetPaginationResponseDataInner(
        id: json[r'id'] is String ? json[r'id'] as String : null,
        name: json[r'name'] is String ? json[r'name'] as String : null,
        widgetType: json[r'widgetType'] as String,
        actionUrl: json[r'actionUrl'] is String ? json[r'actionUrl'] as String : null,
        style: json[r'style'] is String ? json[r'style'] as String : null,
        content: json[r'content'] is String ? json[r'content'] as String : null,
        fontSize: json[r'fontSize'] is int ? json[r'fontSize'] as int : null,
      );
    }
    return null;
  }

  static List<WidgetPaginationResponseDataInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WidgetPaginationResponseDataInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WidgetPaginationResponseDataInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, WidgetPaginationResponseDataInner> mapFromJson(dynamic json) {
    final map = <String, WidgetPaginationResponseDataInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = WidgetPaginationResponseDataInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of WidgetPaginationResponseDataInner-objects as value to a dart map
  static Map<String, List<WidgetPaginationResponseDataInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<WidgetPaginationResponseDataInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = WidgetPaginationResponseDataInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'widgetType',
  };
}

/// Factory for creating [WidgetPaginationResponseDataInner] instances from JSON data.
class WidgetPaginationResponseDataInnerFactory extends JsonSchemaFactory<WidgetPaginationResponseDataInner> {
  const WidgetPaginationResponseDataInnerFactory();

  @override
  WidgetPaginationResponseDataInner fromJson(dynamic json) => WidgetPaginationResponseDataInner.fromJson(json)!;
}

