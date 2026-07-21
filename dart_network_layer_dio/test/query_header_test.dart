import 'dart:convert';
import 'dart:io';

import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:http_test_server/http_test_server.dart';
import 'package:test/test.dart';

class _QueryRequest extends RequestCommand<AnyDataSchema> {
  _QueryRequest(this._params);

  final List<QueryParameter> _params;

  @override
  String get path => '/test/query';

  @override
  List<QueryParameter> get queryParameters => _params;

  @override
  SchemaFactory<AnyDataSchema> get defaultResponseFactory =>
      AnyDataSchema.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class _HeaderRequest extends RequestCommand<AnyDataSchema> {
  _HeaderRequest(this._headers);

  final Map<String, dynamic> _headers;

  @override
  String get path => '/test/query';

  @override
  Map<String, dynamic> get headers => _headers;

  @override
  SchemaFactory<AnyDataSchema> get defaultResponseFactory =>
      AnyDataSchema.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

void main() {
  group('Query parameters integration', () {
    test('Single query param key=value -> sent in request URL and echoed back',
        () async {
      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/test/query']),
          handler: (req) async {
            final queryParams = req.requestedUri.queryParameters;
            req.response
              ..statusCode = HttpStatus.ok
              ..write(jsonEncode(queryParams));
            return req.response;
          },
        ),
      ]);

      final invoker =
          DioNetworkInvoker.fromBaseUrl('http://localhost:${server.port}');
      final res = await invoker.send(
          _QueryRequest([const QueryParameter(key: 'key', value: 'value')]));

      expect(res, isA<SuccessResponseResult>());
      final data = (res as SuccessResponseResult).data as AnyDataSchema;
      final decoded = jsonDecode(data.data as String) as Map<String, dynamic>;
      expect(decoded['key'], 'value');

      await server.close();
    });

    test('Multiple query params -> all echoed back', () async {
      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/test/query']),
          handler: (req) async {
            final queryParams = req.requestedUri.queryParameters;
            req.response
              ..statusCode = HttpStatus.ok
              ..write(jsonEncode(queryParams));
            return req.response;
          },
        ),
      ]);

      final invoker =
          DioNetworkInvoker.fromBaseUrl('http://localhost:${server.port}');
      final res = await invoker.send(_QueryRequest([
        const QueryParameter(key: 'k1', value: 'v1'),
        const QueryParameter(key: 'k2', value: 'v2'),
      ]));

      expect(res, isA<SuccessResponseResult>());
      final data = (res as SuccessResponseResult).data as AnyDataSchema;
      final decoded = jsonDecode(data.data as String) as Map<String, dynamic>;
      expect(decoded['k1'], 'v1');
      expect(decoded['k2'], 'v2');

      await server.close();
    });

    test('Request with no query params -> clean response', () async {
      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/test/query']),
          handler: (req) async {
            final queryParams = req.requestedUri.queryParameters;
            req.response
              ..statusCode = HttpStatus.ok
              ..write(jsonEncode(queryParams));
            return req.response;
          },
        ),
      ]);

      final invoker =
          DioNetworkInvoker.fromBaseUrl('http://localhost:${server.port}');
      final res = await invoker.send(_QueryRequest([]));

      expect(res, isA<SuccessResponseResult>());
      final data = (res as SuccessResponseResult).data as AnyDataSchema;
      final decoded = jsonDecode(data.data as String) as Map<String, dynamic>;
      expect(decoded, isEmpty);

      await server.close();
    });

    test('Null value query param -> sent as empty string', () async {
      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/test/query']),
          handler: (req) async {
            final queryParams = req.requestedUri.queryParameters;
            req.response
              ..statusCode = HttpStatus.ok
              ..write(jsonEncode(queryParams));
            return req.response;
          },
        ),
      ]);

      final invoker =
          DioNetworkInvoker.fromBaseUrl('http://localhost:${server.port}');
      final res = await invoker
          .send(_QueryRequest([const QueryParameter(key: 'key', value: null)]));

      expect(res, isA<SuccessResponseResult>());
      final data = (res as SuccessResponseResult).data as AnyDataSchema;
      final decoded = jsonDecode(data.data as String) as Map<String, dynamic>;
      expect(decoded['key'], '');

      await server.close();
    });
  });

  group('Headers integration', () {
    test('Custom header -> received by server', () async {
      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/test/query']),
          handler: (req) async {
            final headerValue = req.headers['x-custom-header']?.first ?? '';
            req.response
              ..statusCode = HttpStatus.ok
              ..write(jsonEncode({'header': headerValue}));
            return req.response;
          },
        ),
      ]);

      final invoker =
          DioNetworkInvoker.fromBaseUrl('http://localhost:${server.port}');
      final res =
          await invoker.send(_HeaderRequest({'x-custom-header': 'my-value'}));

      expect(res, isA<SuccessResponseResult>());
      final data = (res as SuccessResponseResult).data as AnyDataSchema;
      final decoded = jsonDecode(data.data as String) as Map<String, dynamic>;
      expect(decoded['header'], 'my-value');

      await server.close();
    });

    test('Multiple headers -> all received', () async {
      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/test/query']),
          handler: (req) async {
            final h1 = req.headers['x-h1']?.first ?? '';
            final h2 = req.headers['x-h2']?.first ?? '';
            req.response
              ..statusCode = HttpStatus.ok
              ..write(jsonEncode({'h1': h1, 'h2': h2}));
            return req.response;
          },
        ),
      ]);

      final invoker =
          DioNetworkInvoker.fromBaseUrl('http://localhost:${server.port}');
      final res =
          await invoker.send(_HeaderRequest({'x-h1': 'v1', 'x-h2': 'v2'}));

      expect(res, isA<SuccessResponseResult>());
      final data = (res as SuccessResponseResult).data as AnyDataSchema;
      final decoded = jsonDecode(data.data as String) as Map<String, dynamic>;
      expect(decoded['h1'], 'v1');
      expect(decoded['h2'], 'v2');

      await server.close();
    });
  });
}
