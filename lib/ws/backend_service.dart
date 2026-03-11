import 'dart:async';

import 'package:messless/ws/backend_client.dart';
import 'package:messless/ws/websocket_request.dart';
import 'package:messless/ws/websocket_response.dart';

class BackendService {
  BackendService(this.name);

  final String name;

  /// Create a single entity
  Future<WebSocketResponse> create(String? body) async =>
      _makeRequest(WebSocketMethod.create, body);

  /// Updates must include a $id: int
  Future<WebSocketResponse> update(String body) async =>
      _makeRequest(WebSocketMethod.update, body);

  /// Get a single entity
  Future<WebSocketResponse> get(int id) async =>
      _makeRequest(WebSocketMethod.read, id.toString());

  /// Find multiple entities
  Future<WebSocketResponse> find() async =>
      _makeRequest(WebSocketMethod.read, null);

  /// Delete a single entity
  Future<WebSocketResponse> delete(int id) async =>
      _makeRequest(WebSocketMethod.delete, id.toString());

  Future<WebSocketResponse> _makeRequest(
    WebSocketMethod method,
    String? body,
  ) async {
    BackendClient.ensureInitialized();
    final completer = Completer<WebSocketResponse>();
    final id = BackendClient.currentId++;

    BackendClient.sendIdentified(
      id,
      WebSocketRequest(id, method, name, body).stringify(),
      (res) => {completer.complete(res)},
    );

    return completer.future;
  }
}
