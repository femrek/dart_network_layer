/// Represents a single query parameter as a key-value pair.
///
/// When appended to a URL the [value] is converted to a string via
/// `toString()`. A `null` value is treated as an empty string.
final class QueryParameter {
  /// Creates a query parameter with the given [key] and [value].
  const QueryParameter({
    required this.key,
    required this.value,
  });

  /// The parameter name as it appears in the URL query string.
  final String key;

  /// The parameter value. Accepts any type; converted to a string when the
  /// URL is built. `null` is treated as an empty string.
  final dynamic value;
}
