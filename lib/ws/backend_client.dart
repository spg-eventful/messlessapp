import 'package:logging/logging.dart';
import 'package:messless/ws/backend_service.dart';
import 'package:messless/ws/exceptions/error_id_conflict.dart';
import 'package:messless/ws/websocket_response.dart';
import 'package:web_socket_client/web_socket_client.dart';

class BackendClient {
  final logger = Logger("WebSocket");
  final socket = WebSocket(
    Uri.parse("ws://10.0.2.2:8080/ws"),
  ); // TODO: put in some sort of config
  var currentId = 0;
  var initialized = false;

  // id: callback
  final Map<int, Function> requestsAwaitingResponse = {};

  void init() {
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

  void _handleStateChange(ConnectionState state) {
    // TODO: Handle reconnect authentication
    logger.info("socket.connection.state: $state");
  }

  void _handleIncomingMessage(dynamic message) {
    logger.info("Received message: $message");
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

  void sendRaw(dynamic message) {
    socket.send(message);
  }

  void sendIdentified(int id, String message, Function callback) {
    if (requestsAwaitingResponse.containsKey(id)) throw IdConflict(id);
    requestsAwaitingResponse[id] = callback;
    sendRaw(message);
  }

  BackendService service(String name) => BackendService(this, name);
}
