import 'dart:async';
import 'dart:io';

import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:http_test_server/http_test_server.dart';
import 'package:test/test.dart';

import 'data/request/request_test_user.dart';
import 'data/test_paths.dart';

void main() {
  // -------------------------------------------------------------------------
  // RequestHistoryEntry
  // -------------------------------------------------------------------------
  group('RequestHistoryEntry', () {
    test('duration is correctly computed from start and end time', () {
      final start = DateTime(2025, 1, 1, 12);
      final end = DateTime(2025, 1, 1, 12, 0, 2);

      final entry = RequestHistoryEntry(
        request: RequestTestUser(),
        status: ProgressStatus.success,
        startTime: start,
        endTime: end,
      );

      expect(entry.duration, const Duration(seconds: 2));
    });

    test('fromProgress uses current time as endTime', () {
      final request = RequestTestUser();
      final progress = RequestProgressState(
        request: request,
        status: ProgressStatus.pending,
        total: 0,
        progress: 0,
        progressPercent: 0,
        startTime: DateTime.now().subtract(
          const Duration(milliseconds: 100),
        ),
        unknownTotal: false,
      )..status = ProgressStatus.success;

      final before = DateTime.now();
      final entry = RequestHistoryEntry.fromProgress(progress);
      final after = DateTime.now();

      expect(entry.request, same(request));
      expect(entry.status, ProgressStatus.success);
      expect(
        entry.endTime.isAfter(before) || entry.endTime.isAtSameMomentAs(before),
        isTrue,
      );
      expect(
        entry.endTime.isBefore(after) || entry.endTime.isAtSameMomentAs(after),
        isTrue,
      );
    });

    test('assert fires when status is not terminal', () {
      expect(
        () => RequestHistoryEntry(
          request: RequestTestUser(),
          status: ProgressStatus.pending,
          startTime: DateTime(2025),
          endTime: DateTime(2025, 1, 1, 0, 0, 1),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('assert fires when endTime is not after startTime', () {
      final now = DateTime(2025, 6, 1, 10);
      expect(
        () => RequestHistoryEntry(
          request: RequestTestUser(),
          status: ProgressStatus.success,
          startTime: now,
          endTime: now,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('stores all fields correctly', () {
      final request = RequestTestUser();
      final start = DateTime(2025, 3);
      final end = DateTime(2025, 3, 1, 0, 0, 5);

      final entry = RequestHistoryEntry(
        request: request,
        status: ProgressStatus.error,
        startTime: start,
        endTime: end,
      );

      expect(entry.request, same(request));
      expect(entry.status, ProgressStatus.error);
      expect(entry.startTime, start);
      expect(entry.endTime, end);
      expect(entry.duration, const Duration(seconds: 5));
    });
  });

  // -------------------------------------------------------------------------
  // MixinManageRequestHistory – unit-level (no HTTP)
  // -------------------------------------------------------------------------
  group('MixinManageRequestHistory – maxHistoryLength', () {
    test('requestHistory is empty by default', () {
      final invoker = DioNetworkInvoker.fromBaseUrl('http://localhost');
      expect(invoker.requestHistory, isEmpty);
    });

    test('default maxHistoryLength is 64', () {
      final invoker = DioNetworkInvoker.fromBaseUrl('http://localhost');
      expect(invoker.maxHistoryLength, 64);
    });

    test('setting maxHistoryLength to null disables the cap', () {
      final invoker = DioNetworkInvoker.fromBaseUrl('http://localhost')
        ..maxHistoryLength = null;
      expect(invoker.maxHistoryLength, isNull);
    });

    test('setting maxHistoryLength to 0 keeps no history', () {
      final invoker = DioNetworkInvoker.fromBaseUrl('http://localhost')
        ..maxHistoryLength = 0;
      expect(invoker.maxHistoryLength, 0);
    });

    test('requestHistory returns an unmodifiable view', () {
      final invoker = DioNetworkInvoker.fromBaseUrl('http://localhost');
      expect(
        () => invoker.requestHistory.add(
          RequestHistoryEntry(
            request: RequestTestUser(),
            status: ProgressStatus.success,
            startTime: DateTime(2025),
            endTime: DateTime(2025, 1, 1, 0, 0, 1),
          ),
        ),
        throwsUnsupportedError,
      );
    });
  });

  // -------------------------------------------------------------------------
  // Integration – history after real HTTP requests
  // -------------------------------------------------------------------------
  group('MixinManageRequestHistory – integration', () {
    test('successful request is recorded in history', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testUser],
          ),
          handler: (_) async => '{"id":"1","name":"test","age":20}',
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final request = RequestTestUser();
      await invoker.request(request);

      expect(
        invoker.requestHistory,
        hasLength(1),
        reason: 'one completed request should appear in history',
      );
      expect(
        invoker.requestHistory.first.status,
        ProgressStatus.success,
        reason: 'entry status should be success',
      );
      expect(
        invoker.requestHistory.first.request,
        same(request),
        reason: 'entry should reference the original request command',
      );

      await server.close();
    });

    test('failed request is recorded with error status', () async {
      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testUser],
          ),
          handler: (req) async {
            req.response.statusCode = HttpStatus.internalServerError;
            req.response.write('error');
            return req.response;
          },
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      await invoker.request(RequestTestUser());

      expect(invoker.requestHistory, hasLength(1));
      expect(
        invoker.requestHistory.first.status,
        ProgressStatus.error,
        reason: 'server error should produce an error history entry',
      );

      await server.close();
    });

    test('cancelled request is recorded with cancelled status', () async {
      final completer = Completer<void>();

      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testUser],
          ),
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
      final future = invoker.request(request);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      invoker.cancelRequest(request);
      await future;

      expect(invoker.requestHistory, hasLength(1));
      expect(
        invoker.requestHistory.first.status,
        ProgressStatus.cancelled,
        reason: 'cancelled request should produce a cancelled history entry',
      );

      completer.complete();
      await server.close();
    });

    test('multiple requests accumulate in history in order', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testUser],
          ),
          handler: (_) async => '{"id":"1","name":"test","age":20}',
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      await invoker.request(RequestTestUser());
      await invoker.request(RequestTestUser());
      await invoker.request(RequestTestUser());

      expect(
        invoker.requestHistory,
        hasLength(3),
        reason: 'three completed requests should produce three entries',
      );

      await server.close();
    });

    test('history entries have positive duration', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testUser],
          ),
          handler: (_) async => '{"id":"1","name":"test","age":20}',
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      await invoker.request(RequestTestUser());

      expect(
        invoker.requestHistory.first.duration.inMicroseconds,
        greaterThan(0),
      );

      await server.close();
    });

    test('maxHistoryLength=0 keeps no history', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testUser],
          ),
          handler: (_) async => '{"id":"1","name":"test","age":20}',
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      )..maxHistoryLength = 0;

      await invoker.request(RequestTestUser());

      expect(
        invoker.requestHistory,
        isEmpty,
        reason: 'maxHistoryLength=0 must keep no history',
      );

      await server.close();
    });

    test('maxHistoryLength caps old entries, keeping most recent', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testUser],
          ),
          handler: (_) async => '{"id":"1","name":"test","age":20}',
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      )..maxHistoryLength = 2;

      // Third request pushes out the first.
      await invoker.request(RequestTestUser());
      await invoker.request(RequestTestUser());
      await invoker.request(RequestTestUser());

      expect(
        invoker.requestHistory,
        hasLength(2),
        reason: 'history must not exceed maxHistoryLength',
      );

      await server.close();
    });

    test('reducing maxHistoryLength trims existing entries', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testUser],
          ),
          handler: (_) async => '{"id":"1","name":"test","age":20}',
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      await invoker.request(RequestTestUser());
      await invoker.request(RequestTestUser());
      await invoker.request(RequestTestUser());

      expect(invoker.requestHistory, hasLength(3));

      // Shrink limit — should immediately trim.
      invoker.maxHistoryLength = 1;

      expect(
        invoker.requestHistory,
        hasLength(1),
        reason: 'existing history must be trimmed after lowering the cap',
      );

      await server.close();
    });

    test(
        'setting maxHistoryLength to null after cap '
        'disables trimming', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testUser],
          ),
          handler: (_) async => '{"id":"1","name":"test","age":20}',
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      )..maxHistoryLength = 2;

      await invoker.request(RequestTestUser());
      await invoker.request(RequestTestUser());
      await invoker.request(RequestTestUser());

      expect(invoker.requestHistory, hasLength(2));

      // Remove the cap.
      invoker.maxHistoryLength = null;

      // New requests accumulate without limit.
      await invoker.request(RequestTestUser());
      await invoker.request(RequestTestUser());

      expect(
        invoker.requestHistory,
        hasLength(4),
        reason: 'null limit should allow unbounded accumulation',
      );

      await server.close();
    });
  });
}
