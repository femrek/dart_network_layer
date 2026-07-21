import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:dart_network_layer_dio/src/model/models.dart';
import 'package:dart_network_layer_dio/src/registry/request_registry.dart';
import 'package:dart_network_layer_dio/src/strategy/impl/default_network_logger.dart';
import 'package:dart_network_layer_dio/src/strategy/impl/dio_payload_resolver.dart';
import 'package:dart_network_layer_dio/src/strategy/impl/dio_request_dispatcher.dart';
import 'package:dart_network_layer_dio/src/strategy/impl/dio_response_parser.dart';
import 'package:dart_network_layer_dio/src/strategy/network_logger_strategy.dart';
import 'package:dart_network_layer_dio/src/strategy/payload_resolver.dart';
import 'package:dart_network_layer_dio/src/strategy/request_dispatcher.dart';
import 'package:dart_network_layer_dio/src/strategy/response_parser.dart';
import 'package:dio/dio.dart';

/// The network manager class for managing api communication.
class DioNetworkInvoker implements INetworkInvoker {
  /// Create a new instance of [DioNetworkInvoker] with the given [Dio]
  /// instance.
  DioNetworkInvoker({
    required this.dio,
    RequestRegistry? registry,
    PayloadResolver? payloadResolver,
    ResponseParser? responseParser,
    RequestDispatcher? requestDispatcher,
    NetworkLoggerStrategy? networkLoggerStrategy,
  }) {
    this.registry = registry ?? RequestRegistry();
    this.payloadResolver = payloadResolver ?? const DioPayloadResolver();
    this.responseParser = responseParser ?? const DioResponseParser();
    this.requestDispatcher = requestDispatcher ??
        DioRequestDispatcher(
          dio: dio,
          responseParser: this.responseParser,
        );
    this.networkLoggerStrategy =
        networkLoggerStrategy ?? DefaultNetworkLogger();
  }

  /// Create a new instance of [DioNetworkInvoker] with the given [baseUrl].
  ///
  /// The default constructor is recommended to use, this constructor is
  /// provided for convenience.
  DioNetworkInvoker.fromBaseUrl(String baseUrl)
      : this(
          dio: Dio(
            BaseOptions(
              baseUrl: baseUrl,
              responseType: ResponseType.plain,
            ),
          ),
        );

  /// The Dio instance used for network requests.
  final Dio dio;

  /// The registry for tracking active requests, cancel tokens, and history.
  late final RequestRegistry registry;

  /// The resolver for converting request schemas to Dio-compatible payloads.
  late final PayloadResolver payloadResolver;

  /// The parser for converting raw Dio responses into [NetworkResult]s.
  late final ResponseParser responseParser;

  /// The dispatcher for executing network requests via Dio.
  late final RequestDispatcher requestDispatcher;

  /// The strategy for logging network request lifecycles.
  late final NetworkLoggerStrategy networkLoggerStrategy;

  /// The aggregated state of all currently active requests.
  AggregatedRequestState get activeRequests => registry.activeRequests;

  /// The history of completed network requests.
  List<RequestHistoryEntry> get requestHistory => registry.requestHistory;

  /// Gets the maximum length of the request history.
  int? get maxHistoryLength => registry.maxHistoryLength;

  /// Sets the maximum length of the request history.
  set maxHistoryLength(int? length) {
    registry.maxHistoryLength = length;
  }

  /// Sets the callback to be invoked when the request history is updated.
  set onHistoryUpdate(OnHistoryUpdateCallback? onUpdate) {
    registry.onHistoryUpdate = onUpdate;
  }

  /// Gets the callback to be invoked when the request history is updated.
  OnHistoryUpdateCallback? get onHistoryUpdate => registry.onHistoryUpdate;

  /// Sets the callback to be invoked on progress updates.
  set onUpdateRequestProgress(OnProgressUpdateCallback? onUpdate) {
    registry.onProgressUpdate = onUpdate;
  }

  /// Gets the callback to be invoked on progress updates.
  OnProgressUpdateCallback? get onUpdateRequestProgress =>
      registry.onProgressUpdate;

  /// Cancels all active network requests.
  void cancelAll() {
    registry.cancelAll();
  }

  /// Cancels a specific network request.
  void cancelRequest(RequestCommand request) {
    registry.cancelRequest(request);
  }

  @override
  Future<NetworkResult<T>> send<T extends Schema>(
      RequestCommand<T> request) async {
    networkLoggerStrategy.logRequest(request);

    final cancelToken = registry.registerRequest(request);

    final Object? payload;
    try {
      payload = await payloadResolver.resolve(request.payload);
    } on NetworkError catch (e) {
      // Clean up the registry entry — the request never made it to the
      // dispatcher, so its finally block will not run.
      registry.unregisterRequest(request);
      // ignore: invalid_use_of_internal_member, this is the network invoker
      request.setOnCancel(() {
        throw RequestAlreadyCancelledError(
          message: 'Invalid state: Request was cancelled when it was already '
              'completed or cancelled.',
          stackTrace: StackTrace.current,
        );
      });
      final errorResult = NetworkErrorResult<T>(error: e);
      _setProgressStatus<T>(request, errorResult);
      // ignore: invalid_use_of_internal_member, this is the network invoker
      request.setResult(errorResult);
      networkLoggerStrategy.logError(request, errorResult);
      return errorResult;
    }

    final result = await requestDispatcher.dispatch<T>(
      request,
      payload,
      cancelToken,
      registry,
    );

    _setProgressStatus<T>(request, result);
    // ignore: invalid_use_of_internal_member, this is the network invoker
    request.setResult(result);

    switch (result) {
      case final SuccessResponseResult<T> r:
        networkLoggerStrategy.logSuccess(request, r);
      case final SpecifiedResponseResult<T> r:
        if (dio.options.validateStatus(r.statusCode)) {
          networkLoggerStrategy.logSuccess(request, r);
        } else {
          networkLoggerStrategy.logUnsuccessful(request, r);
        }
      case final NetworkErrorResult<T> r:
        networkLoggerStrategy.logError(request, r);
    }

    return result;
  }

  void _setProgressStatus<T extends Schema>(
      RequestCommand<T> request, NetworkResult<T> result) {
    switch (result) {
      case SuccessResponseResult<T>():
        registry.finalizeRequest(request, ProgressStatus.success);
      case final SpecifiedResponseResult<T> r:
        if (dio.options.validateStatus(r.statusCode)) {
          registry.finalizeRequest(request, ProgressStatus.success);
        } else {
          registry.finalizeRequest(request, ProgressStatus.unsuccessful);
        }
      case final NetworkErrorResult<T> r:
        switch (r.error) {
          case NetworkErrorInvalidResponseType():
          case NetworkErrorInvalidPayload():
          case NetworkError():
            registry.finalizeRequest(request, ProgressStatus.error);
          case RequestCancelledError():
            registry.finalizeRequest(request, ProgressStatus.cancelled);
        }
    }
  }
}
