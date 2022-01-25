library openid_client.io;

import 'openid_client.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
export 'openid_client.dart';
import 'package:url_launcher/url_launcher.dart';

class Authenticator {
  final Flow flow;

  final Function(String url) urlLancher;

  final int port;

  String popToken;

  Authenticator(Client client,
      {this.port = 4000,
      this.urlLancher = _runBrowser,
      this.popToken = '',
      Iterable<String> scopes = const [],
      Uri redirectUri})
      : flow = redirectUri == null
            ? Flow.authorizationCode(client)
            : Flow.authorizationCodeWithPKCE(client)
          ..scopes.addAll(scopes)
          ..redirectUri = redirectUri ?? Uri.parse('http://localhost:$port/')
          ..dPoPToken = popToken;

  Future<Credential> authorize() async {
    var state = flow.authenticationUri.queryParameters['state'];
    _requestsByState[state] = Completer();
    await _startServer(port);
    
    urlLancher(flow.authenticationUri.toString());
    var response = await _requestsByState[state].future;

    return flow.callback(response);
  }

  /// cancel the ongoing auth flow, i.e. when the user closed the webview/browser without a successful login
  Future<void> cancel() async {
    final state = flow.authenticationUri.queryParameters['state'];
    _requestsByState[state]?.completeError(Exception('Flow was cancelled'));
    final server = await _requestServers.remove(port);
    await server.close();
  }

  static final Map<int, Future<HttpServer>> _requestServers = {};
  static final Map<String, Completer<Map<String, String>>> _requestsByState =
      {};

  static Future<HttpServer> _startServer(int port) {
    return _requestServers[port] ??=
        (HttpServer.bind(InternetAddress.anyIPv4, port)
          ..then((requestServer) async {
            await for (var request in requestServer) {
              request.response.statusCode = 200;
              request.response.headers.set('Content-type', 'text/html');
              request.response.writeln('<html>'
                  '<h1>Login successful. Close this window!</h1>'
                  '<script>window.close();</script>'
                  '</html>');
              await request.response.close();
              var result = request.requestedUri.queryParameters;

              if (!result.containsKey('state')) continue;
              var r = _requestsByState.remove(result['state']);
              r.complete(result);
              if (_requestsByState.isEmpty) {
                for (var s in _requestServers.values) {
                  await (await s).close();
                }
                _requestServers.clear();
              }
            }

            await _requestServers.remove(port);
          }));
  }
}

void _runBrowser(String url) {
  if ((defaultTargetPlatform == TargetPlatform.linux) || (defaultTargetPlatform == TargetPlatform.macOS) || (defaultTargetPlatform == TargetPlatform.windows)) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
        Process.run('x-www-browser', [url]);
        break;
      case TargetPlatform.macOS:
        Process.run('open', [url]);
        break;
      case TargetPlatform.windows:
        Process.run('chrome', [url]);
        break;
      default:
        throw UnsupportedError(
            'Unsupported platform: $defaultTargetPlatform');
    }
  }
}
