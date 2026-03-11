class AuthenticatedConnection {}

class AuthState {
  AuthenticatedConnection? authenticatedConnection;

  get isAuthenticated => authenticatedConnection != null;
}
