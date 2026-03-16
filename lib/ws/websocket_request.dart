// request      ID;METHOD;SERVICE;BODY
// response     ID;STATUS_CODE;BODY?

enum WebSocketMethod {
  create("create"),
  read("read"),
  update("update"),
  delete("delete");

  const WebSocketMethod(this.value);

  final String value;
}

class WebSocketResponseDecodeError implements Exception {
  WebSocketResponseDecodeError(this.responseBody, {this.message});

  final String responseBody;
  String? message;

  @override
  String toString() =>
      "Unable to decode websocket response: $responseBody! $message";
}

class WebSocketRequest {
  WebSocketRequest(this.id, this.method, this.service, this.body);

  final int id;
  final WebSocketMethod method;
  final String service;
  final String? body;

  @override
  String toString() => "WebSocketRequest($id, ${method.value}, $service, $body)";
  String stringify() => "$id;${method.value};$service;${body ?? ""}";
}
