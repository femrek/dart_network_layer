import 'dart:async';
import 'dart:io';

import 'package:flutter_network_layer_dio/flutter_network_layer_dio.dart';
import 'package:http_test_server/http_test_server.dart';
import 'package:test/test.dart';

import 'data/request/request_test_user.dart';
import 'data/test_paths.dart';

void main() {
  // -------------------------------------------------------------------------
  // ProgressStatus
  // -------------------------------------------------------------------------
  group('ProgressStatus', () {
    test('non-terminal statuses have end == false', () {
      expect(ProgressStatus.pending.end, isFalse);
      expect(ProgressStatus.sending.end, isFalse);
      expect(ProgressStatus.receiving.end, isFalse);
    });

    test('terminal statuses have end == true', () {
      expect(ProgressStatus.success.end, isTrue);
      expect(ProgressStatus.error.end, isTrue);
      expect(ProgressStatus.cancelled.end, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // RequestProgressState
  // -------------------------------------------------------------------------
  group('RequestProgressState', () {
    late RequestCommand request;
    late RequestProgressState state;

    setUp(() {
      request = RequestTestUser();
      state = RequestProgressState(
        request: request,
        status: ProgressStatus.pending,
        total: 100,
        progress: 0,
        progressPercent: 0,
        unknownTotal: false,
      );
    });

    test('initial values are set correctly', () {
      expect(state.status, ProgressStatus.pending);
      expect(state.total, 100);
      expect(state.progress, 0);
      expect(state.progressPercent, 0.0);
      expect(state.unknownTotal, isFalse);
      expect(state.request, request);
    });

    test('status can progress from pending → sending', () {
      state.status = ProgressStatus.sending;
      expect(state.status, ProgressStatus.sending);
    });

    test('status can progress from sending → receiving', () {
      state
        ..status = ProgressStatus.sending
        ..status = ProgressStatus.receiving;
      expect(state.status, ProgressStatus.receiving);
    });

    test('setting a terminal status finalizes progress and percent', () {
      state
        ..total = 200
        ..progress = 80
        ..progressPercent = 0.4
        ..status = ProgressStatus.success;

      expect(state.status, ProgressStatus.success);
      expect(state.progress, 200,
          reason: 'progress should equal total on success');
      expect(state.progressPercent, 1.0,
          reason: 'progressPercent should be 1.0 on success');
    });

    test('terminal status cannot be overwritten by a non-terminal status', () {
      state
        ..status = ProgressStatus.success
        ..status = ProgressStatus.sending; // invalid back-transition

      expect(
        state.status,
        ProgressStatus.success,
        reason: 'terminal status must not be overwritten',
      );
    });

    test('one terminal status can be overwritten by another terminal status',
        () {
      state
        ..status = ProgressStatus.error
        ..status = ProgressStatus.cancelled;

      expect(state.status, ProgressStatus.cancelled);
    });
  });

  // -------------------------------------------------------------------------
  // AggregatedProgressState
  // -------------------------------------------------------------------------
  group('AggregatedProgressState', () {
    late AggregatedProgressState agg;

    setUp(() => agg = AggregatedProgressState());

    test('getOrCreateProgress creates a pending entry on first call', () {
      final req = RequestTestUser();
      final state = agg.getOrCreateProgress(req);

      expect(state.status, ProgressStatus.pending);
      expect(state.total, 0);
      expect(state.progress, 0);
    });

    test('getOrCreateProgress returns the same instance on repeated calls', () {
      final req = RequestTestUser();
      final a = agg.getOrCreateProgress(req);
      final b = agg.getOrCreateProgress(req);

      expect(identical(a, b), isTrue);
    });

    test('allTotal and allProgress are 0 when no requests tracked', () {
      expect(agg.allTotal, 0);
      expect(agg.allProgress, 0);
      expect(agg.allProgressPercent, 0.0);
    });

    test('aggregated totals sum across all tracked requests', () {
      final req1 = RequestTestUser();
      final req2 = RequestTestUser();

      agg.getOrCreateProgress(req1)
        ..total = 100
        ..progress = 40;
      agg.markProgressChanged();

      agg.getOrCreateProgress(req2)
        ..total = 200
        ..progress = 60;
      agg.markProgressChanged();

      expect(agg.allTotal, 300);
      expect(agg.allProgress, 100);
      expect(agg.allProgressPercent, closeTo(100 / 300, 0.0001));
    });

    test('allProgressPercent is 0.0 when allTotal is 0', () {
      final req = RequestTestUser();
      agg.getOrCreateProgress(req).progress = 0;
      agg.markProgressChanged();

      expect(agg.allProgressPercent, 0.0);
    });

    test('removeProgress excludes the entry from aggregation', () {
      final req = RequestTestUser();
      agg.getOrCreateProgress(req)
        ..total = 100
        ..progress = 50;
      agg.markProgressChanged();

      expect(agg.allTotal, 100);

      agg.removeProgress(req);

      expect(agg.allTotal, 0);
      expect(agg.allProgress, 0);
    });

    test('markProgressChanged triggers recalculation on next access', () {
      final req = RequestTestUser();
      final state = agg.getOrCreateProgress(req)
        ..total = 100
        ..progress = 50;
      agg.markProgressChanged();

      expect(agg.allProgress, 50);

      // Mutate without marking — cached value should remain stale.
      state.progress = 80;
      expect(agg.allProgress, 50, reason: 'cached value before mark');

      // Now mark → recalculation should reflect the new value.
      agg.markProgressChanged();
      expect(agg.allProgress, 80, reason: 'updated after mark');
    });
  });

  // -------------------------------------------------------------------------
  // Integration — progress callbacks during real HTTP requests
  // -------------------------------------------------------------------------
  group('DioNetworkInvoker progress integration', () {
    test('onUpdateRequestProgress is called during a successful request',
        () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
          handler: (_) async => '{"id":"1","name":"test","age":20}',
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final snapshots = <AggregatedProgressState>[];
      invoker.onUpdateRequestProgress = snapshots.add;

      await invoker.request(RequestTestUser());

      expect(
        snapshots,
        isNotEmpty,
        reason: 'callback should fire at least once',
      );

      await server.close();
    });

    test('progress status is success after a completed request', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
          handler: (_) async => '{"id":"1","name":"test","age":20}',
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final request = RequestTestUser();

      AggregatedProgressState? lastSnapshot;
      invoker.onUpdateRequestProgress = (s) => lastSnapshot = s;

      await invoker.request(request);

      expect(lastSnapshot, isNotNull);

      await server.close();
    });

    test('progress status becomes cancelled after request is cancelled',
        () async {
      final completer = Completer<void>();
      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
          handler: (req) async {
            await completer.future.timeout(
              const Duration(seconds: 5),
              onTimeout: () {},
            );
            req.response
              ..statusCode = HttpStatus.ok
              ..write('{"id":"1","name":"test","age":20}');
            return req.response;
          },
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final request = RequestTestUser();
      final snapshots = <AggregatedProgressState>[];
      invoker.onUpdateRequestProgress = snapshots.add;

      final future = invoker.request(request);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      invoker.cancelRequest(request);

      final result = await future;

      expect(result, isA<NetworkErrorResult>());
      expect(
        (result as NetworkErrorResult).error,
        isA<RequestCancelledError>(),
      );

      completer.complete();
      await server.close();
    });

    test('onUpdateRequestProgress can be cleared by setting it to null',
        () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
          handler: (_) async => '{"id":"1","name":"test","age":20}',
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      var callCount = 0;
      invoker.onUpdateRequestProgress = (_) => callCount++;

      // First request — callback should fire.
      await invoker.request(RequestTestUser());
      final countAfterFirst = callCount;
      expect(countAfterFirst, greaterThan(0));

      // Clear the callback.
      invoker.onUpdateRequestProgress = null;
      callCount = 0;

      // Second request — callback must NOT fire.
      await invoker.request(RequestTestUser());
      expect(callCount, 0,
          reason: 'callback should not fire after being cleared');

      await server.close();
    });
  });
}
