// request      ID;METHOD;SERVICE;BODY
// response     ID;STATUS_CODE;BODY?

class WebSocketResponseDecodeError implements Exception {
  WebSocketResponseDecodeError(this.responseBody, {this.message});

  final String responseBody;
  String? message;

  @override
  String toString() =>
      "Unable to decode websocket response: $responseBody! $message";
}

class WebSocketResponse {
  WebSocketResponse(this.id, this.status, this.body);

  final int id;
  final int status;
  final String? body;

  @override
  String toString() => "WebSocketResponse($id, $status, $body)";

  static WebSocketResponse fromStringified(String message) {
    var separated = message.split(";");
    // TODO 2 or 3?
    if (separated.length <= 2) {
      throw WebSocketResponseDecodeError(message, message: "wrong length");
    }

    var id = int.tryParse(separated[0]);
    if (id == null) {
      throw WebSocketResponseDecodeError(
        message,
        message: "id not a parsable int",
      );
    }

    var status = int.tryParse(separated[1]);
    if (status == null) {
      throw WebSocketResponseDecodeError(
        message,
        message: "status not a parsable int",
      );
    }

    var body = (separated.length > 2) ? separated.sublist(2).join(";") : null;
    return WebSocketResponse(id, status, body);
  }
}
