import 'package:messless/ws/exceptions/auth_exception.dart';

import '../schema/error/generic_error.dart';

class BasicAuthException implements AuthException {
  const BasicAuthException(this.genericError);

  final GenericError genericError;

  @override
  String toString() => "Unable to perform authentication. $genericError";
}
