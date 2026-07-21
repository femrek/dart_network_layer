import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:test/test.dart';

class _TestRequest extends RequestCommand<IgnoredSchema> {
  @override
  String get path => '/test';

  @override
  SchemaFactory<IgnoredSchema> get defaultResponseFactory =>
      IgnoredSchema.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class _TrackingRequest extends RequestCommand<IgnoredSchema> {
  int sendCallCount = 0;

  @override
  String get path => '/test';

  @override
  OnProgressCallback? get onSendProgressUpdate =>
      (done, total) => sendCallCount++;

  @override
  SchemaFactory<IgnoredSchema> get defaultResponseFactory =>
      IgnoredSchema.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

void main() {
  group('RequestRegistry', () {
    group('registerRequest', () {
      test('requestMap contains the request', () {
        final registry = RequestRegistry();
        final req = _TestRequest();
        registry.registerRequest(req);
        expect(registry.requestMap.containsKey(req), isTrue);
      });

      test('requestMap[req] is a non-null CancelToken', () {
        final registry = RequestRegistry();
        final req = _TestRequest();
        registry.registerRequest(req);
        expect(registry.requestMap[req], isNotNull);
      });

      test('progress is tracked', () {
        final registry = RequestRegistry();
        final req = _TestRequest();
        registry.registerRequest(req);
        expect(registry.activeRequests.getProgress(req), isNotNull);
      });

      test('progress status is pending', () {
        final registry = RequestRegistry();
        final req = _TestRequest();
        registry.registerRequest(req);
        expect(registry.activeRequests.getProgress(req)?.status,
            ProgressStatus.pending);
      });

      test('onProgressUpdate is called once after registerRequest', () {
        final registry = RequestRegistry();
        var callCount = 0;
        registry.onProgressUpdate = (req) => callCount++;
        final req = _TestRequest();
        registry.registerRequest(req);
        expect(callCount, 1);
      });
    });

    group('unregisterRequest', () {
      test('requestMap does not contain the request', () {
        final registry = RequestRegistry();
        final req = _TestRequest();
        registry
          ..registerRequest(req)
          ..unregisterRequest(req);
        expect(registry.requestMap.containsKey(req), isFalse);
      });

      test('Token is NOT cancelled', () {
        final registry = RequestRegistry();
        final req = _TestRequest();
        registry.registerRequest(req);
        final token = registry.requestMap[req]!;
        registry.unregisterRequest(req);
        expect(token.isCancelled, isFalse);
      });
    });

    group('cancelRequest', () {
      test('requestMap does not contain the request', () {
        final registry = RequestRegistry();
        final req = _TestRequest();
        registry
          ..registerRequest(req)
          ..cancelRequest(req);
        expect(registry.requestMap.containsKey(req), isFalse);
      });

      test('cancel token isCancelled == true', () {
        final registry = RequestRegistry();
        final req = _TestRequest();
        registry.registerRequest(req);
        final token = registry.requestMap[req]!;
        registry.cancelRequest(req);
        expect(token.isCancelled, isTrue);
      });

      test('cancelRequest on a request not in the map is a no-op', () {
        final registry = RequestRegistry();
        final req = _TestRequest();
        expect(() => registry.cancelRequest(req), returnsNormally);
      });
    });

    group('cancelAll', () {
      test('requestMap is empty and all tokens are cancelled', () {
        final registry = RequestRegistry();
        final req1 = _TestRequest();
        final req2 = _TestRequest();
        registry
          ..registerRequest(req1)
          ..registerRequest(req2);

        final token1 = registry.requestMap[req1]!;
        final token2 = registry.requestMap[req2]!;

        registry.cancelAll();

        expect(registry.requestMap, isEmpty);
        expect(token1.isCancelled, isTrue);
        expect(token2.isCancelled, isTrue);
      });
    });

    group('updateProgress', () {
      test('updates status to sending', () {
        final registry = RequestRegistry();
        final req = _TestRequest();
        registry
          ..registerRequest(req)
          ..updateProgress(request: req, count: 50, total: 100, isSend: true);
        expect(registry.activeRequests.getProgress(req)?.status,
            ProgressStatus.sending);
      });

      test('updates status to receiving', () {
        final registry = RequestRegistry();
        final req = _TestRequest();
        registry
          ..registerRequest(req)
          ..updateProgress(request: req, count: 50, total: 100, isSend: false);
        expect(registry.activeRequests.getProgress(req)?.status,
            ProgressStatus.receiving);
      });

      test('progress and total fields updated correctly', () {
        final registry = RequestRegistry();
        final req = _TestRequest();
        registry
          ..registerRequest(req)
          ..updateProgress(request: req, count: 50, total: 100, isSend: true);
        final p = registry.activeRequests.getProgress(req);
        expect(p?.progress, 50);
        expect(p?.total, 100);
      });

      test('onProgressUpdate callback called', () {
        final registry = RequestRegistry();
        final req = _TestRequest();
        var count = 0;
        registry
          ..onProgressUpdate = (r) {
            count++;
          }
          ..registerRequest(req)
          ..updateProgress(request: req, count: 50, total: 100, isSend: true);
        expect(count, greaterThan(0));
      });

      test('progressPercent updated', () {
        final registry = RequestRegistry();
        final req = _TestRequest();
        registry
          ..registerRequest(req)
          ..updateProgress(request: req, count: 50, total: 100, isSend: true);
        expect(registry.activeRequests.getProgress(req)?.progressPercent, 0.5);
      });

      test('onSendProgressUpdate on the request called when isSend: true', () {
        final registry = RequestRegistry();
        final req = _TrackingRequest();
        registry
          ..registerRequest(req)
          ..updateProgress(request: req, count: 50, total: 100, isSend: true);
        expect(req.sendCallCount, 1);
      });
    });

    group('finalizeRequest', () {
      test('history has 1 entry', () {
        final registry = RequestRegistry();
        final req = _TestRequest();
        registry
          ..registerRequest(req)
          ..finalizeRequest(req, ProgressStatus.success);
        expect(registry.requestHistory, hasLength(1));
      });

      test('history entry has status == ProgressStatus.success', () {
        final registry = RequestRegistry();
        final req = _TestRequest();
        registry
          ..registerRequest(req)
          ..finalizeRequest(req, ProgressStatus.success);
        expect(registry.requestHistory.first.status, ProgressStatus.success);
      });

      test('history entry references same request object', () {
        final registry = RequestRegistry();
        final req = _TestRequest();
        registry
          ..registerRequest(req)
          ..finalizeRequest(req, ProgressStatus.success);
        expect(registry.requestHistory.first.request, same(req));
      });

      test('onHistoryUpdate callback is called with the new entry', () {
        final registry = RequestRegistry();
        RequestHistoryEntry? captured;
        registry.onHistoryUpdate = (entry) => captured = entry;
        final req = _TestRequest();
        registry
          ..registerRequest(req)
          ..finalizeRequest(req, ProgressStatus.success);
        expect(captured, isNotNull);
        expect(captured?.status, ProgressStatus.success);
      });

      test('requestMap still contains the token', () {
        final registry = RequestRegistry();
        final req = _TestRequest();
        registry
          ..registerRequest(req)
          ..finalizeRequest(req, ProgressStatus.success);
        expect(registry.requestMap.containsKey(req), isTrue);
      });
    });

    group('onHistoryUpdate', () {
      test('Setting maxHistoryLength calls onHistoryUpdate with null', () {
        final registry = RequestRegistry();
        var nullCalled = false;
        registry
          ..onHistoryUpdate = (entry) {
            if (entry == null) nullCalled = true;
          }
          ..maxHistoryLength = 10;
        expect(nullCalled, isTrue);
      });

      test('onHistoryUpdate receives null when no new entry was added', () {
        final registry = RequestRegistry();
        var nullCalled = false;
        registry
          ..onHistoryUpdate = (entry) {
            if (entry == null) nullCalled = true;
          }
          ..maxHistoryLength = 0;

        final req = _TestRequest();
        registry
          ..registerRequest(req)
          ..finalizeRequest(req, ProgressStatus.success);
        expect(nullCalled, isTrue);
      });
    });

    group('maxHistoryLength', () {
      test('Default is 64', () {
        expect(RequestRegistry().maxHistoryLength, 64);
      });

      test('Can be set to 0', () {
        final registry = RequestRegistry()..maxHistoryLength = 0;
        expect(registry.maxHistoryLength, 0);
      });

      test('Can be set to null (unlimited)', () {
        final registry = RequestRegistry()..maxHistoryLength = null;
        expect(registry.maxHistoryLength, isNull);
      });

      test('existing entries trimmed', () {
        final registry = RequestRegistry();
        final req1 = _TestRequest();
        final req2 = _TestRequest();

        registry
          ..registerRequest(req1)
          ..finalizeRequest(req1, ProgressStatus.success)
          ..registerRequest(req2)
          ..finalizeRequest(req2, ProgressStatus.success);

        expect(registry.requestHistory, hasLength(2));

        registry.maxHistoryLength = 1;
        expect(registry.requestHistory, hasLength(1));
        expect(registry.requestHistory.first.request, same(req2));
      });
    });
  });
}
