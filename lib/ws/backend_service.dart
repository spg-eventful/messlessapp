import 'dart:async';

import 'package:messless/ws/websocket_request.dart';
import 'package:messless/ws/websocket_response.dart';
import 'package:messless/ws/backend_client.dart';

class BackendService {
  BackendService(this.wsClient, this.name);

  final BackendClient wsClient;
  final String name;

  Future<WebSocketResponse> create(String? body) async {
    final completer = Completer<WebSocketResponse>();
    final id = wsClient.currentId++;
    final reqBody = WebSocketRequest(id, WebSocketMethod.create, name, body);

    wsClient.sendIdentified(
      id,
      reqBody.stringify(),
      (res) => {completer.complete(res)},
    );

    return completer.future;
  }
}
