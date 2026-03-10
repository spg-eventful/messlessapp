import 'package:logging/logging.dart';
import 'package:messless/ws/backend_service.dart';
import 'package:messless/ws/exceptions/id_conflict_exception.dart';
import 'package:messless/ws/websocket_response.dart';
import 'package:web_socket_client/web_socket_client.dart';

class BackendClient {
  static final logger = Logger((BackendClient).toString());
  static final socket = WebSocket(
    Uri.parse("ws://10.0.2.2:8080/ws"),
  ); // TODO: put in some sort of config
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
      logger.info(res);
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
}
