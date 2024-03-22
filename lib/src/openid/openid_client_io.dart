library openid_client.io;

import 'openid_client.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

export 'openid_client.dart';

class Authenticator {
  final Flow flow;

  final Function(String url) urlLancher;

  final int port;

  String popToken;

  Authenticator.fromFlow(
    this.flow, {
    Function(String url)? urlLancher,
    this.popToken = '',
  })  : port = flow.redirectUri.port,
        urlLancher = urlLancher ?? _runBrowser;

  Authenticator(Client client,
      {this.port = 4000,
      this.urlLancher = _runBrowser,
      this.popToken = '',
      Iterable<String> scopes = const [],
      Uri? redirectUri})
      : flow = redirectUri == null
            ? Flow.authorizationCode(client)
            : Flow.authorizationCodeWithPKCE(client)
          ..scopes.addAll(scopes)
          ..redirectUri = redirectUri ?? Uri.parse('http://localhost:$port/')
          ..dPoPToken = popToken;

  Future<Credential> authorize() async {
    var state = flow.authenticationUri.queryParameters['state']!;

    _requestsByState[state] = Completer();
    await _startServer(port);
    urlLancher(flow.authenticationUri.toString());

    var response = await _requestsByState[state]!.future;

    return flow.callback(response);
  }

  /// cancel the ongoing auth flow, i.e. when the user closed the webview/browser without a successful login
  Future<void> cancel() async {
    final state = flow.authenticationUri.queryParameters['state'];
    _requestsByState[state!]?.completeError(Exception('Flow was cancelled'));
    final server = await _requestServers.remove(port)!;
    await server.close();
  }

  static final Map<int, Future<HttpServer>> _requestServers = {};
  static final Map<String, Completer<Map<String, String>>> _requestsByState =
      {};

  static Future<HttpServer> _startServer(int port) {
    return _requestServers[port] ??=
        (HttpServer.bind(InternetAddress.anyIPv4, port)
          ..then((requestServer) async {
            print('server started $port');
            await for (var request in requestServer) {
              request.response.statusCode = 200;
              request.response.headers.set('Content-type', 'text/html');
              request.response.writeln('<html>'
                  '<h1>Login successful. You can now close this window!</h1>'
                  '<script>window.close();</script>'
                  '</html>');
              await request.response.close();
              var result = request.requestedUri.queryParameters;

              if (!result.containsKey('state')) continue;
              await processResult(result);
            }

            await _requestServers.remove(port);
          }));
  }

  /// Process the Result from a auth Request
  /// You can call this manually if you are redirected to the app by an external browser
  static Future<void> processResult(Map<String, String> result) async {
    var r = _requestsByState.remove(result['state'])!;
    r.complete(result);
    if (_requestsByState.isEmpty) {
      for (var s in _requestServers.values) {
        await (await s).close();
      }
      _requestServers.clear();
    }
  }
}

void _runBrowser(String url) {
  if ((defaultTargetPlatform == TargetPlatform.linux) ||
      (defaultTargetPlatform == TargetPlatform.macOS) ||
      (defaultTargetPlatform == TargetPlatform.windows)) {
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
        throw UnsupportedError('Unsupported platform: $defaultTargetPlatform');
    }
  }
}

extension FlowX on Flow {
  Future<Credential> authorize({Function(String url)? urlLauncher}) {
    return Authenticator.fromFlow(this, urlLancher: urlLauncher).authorize();
  }
}
