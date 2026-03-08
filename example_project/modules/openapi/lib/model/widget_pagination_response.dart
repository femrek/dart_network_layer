//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'widget_pagination_response_data_inner.dart';

class WidgetPaginationResponse extends Schema {
  /// Returns a new [WidgetPaginationResponse] instance.
  WidgetPaginationResponse({
    this.data = const [],
    this.totalElements,
    this.currentPage,
    this.pageSize,
  });

  final List<WidgetPaginationResponseDataInner> data;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  final int? totalElements;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  final int? currentPage;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  final int? pageSize;

  /// The factory instance for creating [WidgetPaginationResponse] from JSON.
  static const factory = WidgetPaginationResponseFactory();

  @override
  bool operator ==(Object other) => identical(this, other) || other is WidgetPaginationResponse &&
    other.data == data &&
    other.totalElements == totalElements &&
    other.currentPage == currentPage &&
    other.pageSize == pageSize;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (data.hashCode) +
    (totalElements == null ? 0 : totalElements!.hashCode) +
    (currentPage == null ? 0 : currentPage!.hashCode) +
    (pageSize == null ? 0 : pageSize!.hashCode);

  @override
  String toString() => 'WidgetPaginationResponse[data=$data, totalElements=$totalElements, currentPage=$currentPage, pageSize=$pageSize]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'data'] = this.data;
    if (this.totalElements != null) {
      json[r'totalElements'] = this.totalElements;
    } else {
      json[r'totalElements'] = null;
    }
    if (this.currentPage != null) {
      json[r'currentPage'] = this.currentPage;
    } else {
      json[r'currentPage'] = null;
    }
    if (this.pageSize != null) {
      json[r'pageSize'] = this.pageSize;
    } else {
      json[r'pageSize'] = null;
    }
    return json;
  }

  /// Returns a new [WidgetPaginationResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static WidgetPaginationResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "WidgetPaginationResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "WidgetPaginationResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return WidgetPaginationResponse(
        data: WidgetPaginationResponseDataInner.listFromJson(json[r'data']),
        totalElements: json[r'totalElements'] is int ? json[r'totalElements'] as int : null,
        currentPage: json[r'currentPage'] is int ? json[r'currentPage'] as int : null,
        pageSize: json[r'pageSize'] is int ? json[r'pageSize'] as int : null,
      );
    }
    return null;
  }

  static List<WidgetPaginationResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WidgetPaginationResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WidgetPaginationResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, WidgetPaginationResponse> mapFromJson(dynamic json) {
    final map = <String, WidgetPaginationResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = WidgetPaginationResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of WidgetPaginationResponse-objects as value to a dart map
  static Map<String, List<WidgetPaginationResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<WidgetPaginationResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = WidgetPaginationResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

/// Factory for creating [WidgetPaginationResponse] instances from JSON data.
class WidgetPaginationResponseFactory extends JsonSchemaFactory<WidgetPaginationResponse> {
  const WidgetPaginationResponseFactory();

  @override
  WidgetPaginationResponse fromJson(dynamic json) => WidgetPaginationResponse.fromJson(json)!;
}

