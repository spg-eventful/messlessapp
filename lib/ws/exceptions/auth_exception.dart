class AuthException implements Exception {
  const AuthException();

  @override
  String toString() => "Unable to perform authentication!";
}
