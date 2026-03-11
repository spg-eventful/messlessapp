import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:messless/secure_storage.dart';
import 'package:messless/ws/auth_state.dart';
import 'package:messless/ws/backend_service.dart';
import 'package:messless/ws/exceptions/id_conflict_exception.dart';
import 'package:messless/ws/exceptions/jwt_auth_exception.dart';
import 'package:messless/ws/schema/auth/jwt.dart';
import 'package:messless/ws/schema/auth/request/basic_auth.dart';
import 'package:messless/ws/schema/auth/request/jwt_auth.dart';
import 'package:messless/ws/schema/error/generic_error.dart';
import 'package:messless/ws/websocket_response.dart';
import 'package:web_socket_client/web_socket_client.dart';

import 'exceptions/basic_auth_exception.dart';

class BackendClient {
  static const String authStorageKey = "JWT_TOKEN";
  static final logger = Logger((BackendClient).toString());
  static final socket = WebSocket(Uri.parse(dotenv.get("BACKEND_WS_URL")));
  static final authState = AuthState();
  static var currentId = 0;
  static var initialized = false;

  // id: callback
  static final Map<int, Function> requestsAwaitingResponse = {};

  static void ensureInitialized() {
    if (initialized) return;
    init();
  }

  static void init() {
    if (initialized) {
      logger.warning(
        "init was called on an already initialized ws client! ignoring ...",
      );
      return;
    }
    initialized = true;

    socket.messages.listen(_handleIncomingMessage);
    socket.connection.listen(_handleStateChange);
  }

  static void _handleStateChange(ConnectionState state) {
    // TODO: Handle reconnect authentication
    logger.info("Connection state changed: $state");
  }

  static void _handleIncomingMessage(dynamic message) {
    logger.fine("Received message: $message");
    try {
      var res = WebSocketResponse.fromStringified(message);
      logger.finer(res);
      var req = requestsAwaitingResponse[res.id];
      if (req == null) {
        logger.warning(
          "Received a message from the server without anyone waiting for it! ignoring ...",
        );
        return;
      }
      req.call(res);
      requestsAwaitingResponse.remove(res.id);
    } catch (e) {
      logger.warning("Unable to decode message! ignoring ...");
      logger.warning(e);
    }
  }

  static void sendRaw(dynamic message) {
    socket.send(message);
  }

  static void sendIdentified(int id, String message, Function callback) {
    if (requestsAwaitingResponse.containsKey(id)) throw IdConflict(id);
    requestsAwaitingResponse[id] = callback;
    sendRaw(message);
  }

  static BackendService service(String name) => BackendService(name);

  static Future<void> authenticate(BasicAuth? basicAuth) async {
    if (basicAuth != null) {
      // Basic Auth Strategy
      var res = await BackendClient.service(
        "auth",
      ).create(jsonEncode(basicAuth));
      if (res.status != HttpStatus.created) {
        throw BasicAuthException(GenericError.fromJson(jsonDecode(res.body!)));
      }

      await storage.write(key: authStorageKey, value: res.body);
      authState.authenticatedConnection = AuthenticatedConnection(
        Jwt.decode(res.body!),
      );
      return;
    }

    // JWT Strategy
    var jwt = await storage.read(key: authStorageKey);
    if (jwt == null) throw JwtAuthException("jwt not found in storage!");

    var res = await BackendClient.service(
      "auth",
    ).create(jsonEncode(JwtAuth(jwt)));
    if (res.status != HttpStatus.ok) {
      throw JwtAuthException(
        GenericError.fromJson(jsonDecode(res.body!)).message,
      );
    }

    authState.authenticatedConnection = AuthenticatedConnection(
      Jwt.decode(res.body!),
    );
  }
}
