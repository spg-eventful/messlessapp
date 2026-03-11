import 'auth_exception.dart';

class JwtAuthException implements AuthException {
  const JwtAuthException(this.message);

  final String message;

  @override
  String toString() => "Unable to perform authentication with JWT: $message";
}
