import 'package:messless/ws/schema/auth/jwt.dart';
import 'package:messless/ws/schema/user/user.dart';

class AuthenticatedConnection {
  AuthenticatedConnection(this.jwt, this.user);

  final Jwt jwt;
  final User user;
}

class AuthState {
  AuthenticatedConnection? authenticatedConnection;

  get isAuthenticated => authenticatedConnection != null;
}
