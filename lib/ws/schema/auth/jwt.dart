import 'dart:convert';

class Jwt {
  Jwt(this.aud, this.iss, this.sub, this.exp, this.id);

  factory Jwt.decode(String stringified) {
    // a JWT has 3 components
    // Header.Payload.Signature
    // We only want the signature
    Map<String, dynamic> payload = jsonDecode(
      base64Decode(stringified.split(".")[1]).toString(),
    );
    return Jwt(
      payload["aud"],
      payload["iss"],
      payload["sub"],
      payload["exp"],
      int.parse(payload["id"]),
    );
  }

  final String aud;
  final String iss;
  final String sub;
  final int exp;

  // extra claim with user id
  final int id;

  get userId => id;

  get email => sub;
}
