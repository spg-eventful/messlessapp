import 'package:messless/ws/schema/auth/jwt.dart';

class AuthenticatedConnection {
  AuthenticatedConnection(this.jwt);

  final Jwt jwt;
}

class AuthState {
  AuthenticatedConnection? authenticatedConnection;

  get isAuthenticated => authenticatedConnection != null;
}
