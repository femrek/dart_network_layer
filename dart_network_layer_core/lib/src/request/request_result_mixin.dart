import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:meta/meta.dart';

/// Mixin that stores the result of a completed network request.
///
/// Apply this mixin to a [RequestCommand] to allow the invoker to attach
/// the [NetworkResult] once the request finishes.
mixin RequestResultMixin<T extends Schema> {
  NetworkResult<T>? _result;

  /// The result of the request, or `null` if not yet completed.
  NetworkResult<T>? get result => _result;

  /// This is an internal setter used by the invoker to set the result of the
  /// request. It should not be used outside of invoker implementations. The
  /// invoker calls this method once the request is completed (either
  /// successfully or with an error) to store the result in the command for
  /// later retrieval.
  @mustCallSuper
  // ignore: use_setters_to_change_properties - method provides better control flow
  void setResult(NetworkResult<T> result) => _result = result;
}
