// ignore_for_file: public_member_api_docs purpose of enum fields are clean.

/// Enum for HTTP request methods.
enum HttpRequestMethod {
  get('GET'),
  post('POST'),
  patch('PATCH'),
  put('PUT'),
  delete('DELETE'),
  head('HEAD'),
  ;

  const HttpRequestMethod(this.value);

  /// The string value of the HTTP request method.
  final String value;
}
