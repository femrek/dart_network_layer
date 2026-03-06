import 'dart:io';

typedef OnRequestCallback = void Function(HttpRequest request);

abstract final class TestServer {
  static Future<HttpServer> bindServer({
    required OnRequestCallback onRequest,
  }) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

    server.listen((HttpRequest request) {
      onRequest(request);
      request.response.close();
    });
    return server;
  }
}
