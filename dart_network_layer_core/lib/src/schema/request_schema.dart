import 'package:dart_network_layer_core/dart_network_layer_core.dart';

/// A sealed class representing the base schema for all request payloads.
///
/// This class serves as the parent for all request schema types and ensures
/// that only predefined subtypes can exist. Subclasses define specific payload
/// formats such as JSON, form data, binary, string, stream, or dynamic content.
///
/// See also:
/// - [FormDataRequestSchema] for multipart/form-data requests
/// - [JsonRequestSchema] for JSON payload requests
/// - [StringRequestSchema] for plain text requests
/// - [BinaryRequestSchema] for binary data requests
/// - [StreamRequestSchema] for streaming data requests
/// - [DynamicRequestSchema] for flexible payload types
sealed class RequestSchema extends Schema {
  /// const constructor to allow subclasses to be const.
  const RequestSchema();
}

/// Abstract class for request schemas that represent form data payloads.
///
/// This class is used for multipart/form-data or
/// application/x-www-form-urlencoded content types. Subclasses must implement
/// [toFormDataMapPayload] to convert the schema to a map representation that
/// can include files ([MultipartFileSchema]) and regular fields.
///
/// Example:
/// ```dart
/// class UploadFileRequest extends FormDataRequestSchema {
///   const UploadFileRequest({required this.file, required this.description});
///
///   final MultipartFileSchema file;
///   final String description;
///
///   @override
///   Map<String, dynamic> toFormDataMapPayload() {
///     return {'file': file, 'description': description};
///   }
/// }
/// ```
abstract class FormDataRequestSchema extends RequestSchema {
  /// const constructor to allow subclasses to be const.
  const FormDataRequestSchema();

  /// Converts this schema to a map representation for form data payloads.
  ///
  /// The returned map should contain field names as keys and their values,
  /// which can be strings, numbers, booleans, or [MultipartFileSchema]
  /// instances for file uploads.
  ///
  /// Returns a [Map] where keys are field names and values are field data.
  Map<String, dynamic> toFormDataMapPayload();
}

/// Abstract class for request schemas that represent JSON payloads.
///
/// This class is used for requests with application/json content type.
/// Subclasses must implement [toJsonPayload] to convert the schema to a
/// JSON-serializable format (Map, List, or primitive types).
///
/// Example:
/// ```dart
/// class CreateUserRequest extends JsonRequestSchema {
///   const CreateUserRequest({required this.name, required this.email});
///
///   final String name;
///   final String email;
///
///   @override
///   Map<String, dynamic> toJsonPayload() {
///     return {'name': name, 'email': email};
///   }
/// }
/// ```
abstract class JsonRequestSchema extends RequestSchema {
  /// const constructor to allow subclasses to be const.
  const JsonRequestSchema();

  /// Converts this schema to a JSON-serializable payload.
  ///
  /// The returned value should be JSON-serializable, typically a [Map],
  /// [List], [String], [num], [bool], or null.
  ///
  /// Returns a JSON-serializable representation of this schema.
  dynamic toJsonPayload();
}

/// Abstract class for request schemas that represent plain text payloads.
///
/// This class is used for requests with text/plain or similar content types.
/// Subclasses must implement [toStringPayload] to convert the schema to a
/// string representation.
///
/// Example:
/// ```dart
/// class TextMessageRequest extends StringRequestSchema {
///   const TextMessageRequest(this.message);
///
///   final String message;
///
///   @override
///   String toStringPayload() {
///     return message;
///   }
/// }
/// ```
abstract class StringRequestSchema extends RequestSchema {
  /// const constructor to allow subclasses to be const.
  const StringRequestSchema();

  /// Converts this schema to a string payload.
  ///
  /// Returns a [String] representation of this schema that will be sent
  /// as the request body.
  String toStringPayload();
}

/// Abstract class for request schemas that represent binary payloads.
///
/// This class is used for requests with application/octet-stream or similar
/// binary content types. Subclasses must implement [toBinaryPayload] to convert
/// the schema to a list of bytes.
///
/// Example:
/// ```dart
/// class ImageUploadRequest extends BinaryRequestSchema {
///   const ImageUploadRequest(this.imageBytes);
///
///   final List<int> imageBytes;
///
///   @override
///   List<int> toBinaryPayload() {
///     return imageBytes;
///   }
/// }
/// ```
abstract class BinaryRequestSchema extends RequestSchema {
  /// const constructor to allow subclasses to be const.
  const BinaryRequestSchema();

  /// Converts this schema to a binary payload.
  ///
  /// Returns a [List] of bytes that will be sent as the request body.
  List<int> toBinaryPayload();
}

/// Abstract class for request schemas that represent streaming payloads.
///
/// This class is used for requests where the payload is too large to fit in
/// memory or needs to be streamed from a source. Subclasses must implement
/// [toStreamPayload] to provide a stream of byte chunks.
///
/// Example:
/// ```dart
/// class VideoUploadRequest extends StreamRequestSchema {
///   const VideoUploadRequest(this.videoFile);
///
///   final File videoFile;
///
///   @override
///   Stream<List<int>> toStreamPayload() {
///     return videoFile.openRead();
///   }
/// }
/// ```
abstract class StreamRequestSchema extends RequestSchema {
  /// const constructor to allow subclasses to be const.
  const StreamRequestSchema();

  /// Converts this schema to a stream of binary data.
  ///
  /// Returns a [Stream] of byte lists that will be streamed as the request
  /// body.
  Stream<List<int>> toStreamPayload();
}

/// Abstract class for request schemas with dynamic payload types.
///
/// This class is used when the payload type is not known at compile time or
/// when maximum flexibility is needed. Subclasses must implement [toPayload]
/// to return the appropriate payload format.
///
/// Example:
/// ```dart
/// class FlexibleRequest extends DynamicRequestSchema {
///   const FlexibleRequest(this.data);
///
///   final dynamic data;
///
///   @override
///   dynamic toPayload() {
///     return data;
///   }
/// }
/// ```
abstract class DynamicRequestSchema extends RequestSchema {
  /// const constructor to allow subclasses to be const.
  const DynamicRequestSchema();

  /// Converts this schema to a dynamic payload.
  ///
  /// Returns any type of payload that will be processed by the network invoker.
  /// The actual handling depends on the implementation of the network layer.
  dynamic toPayload();
}
