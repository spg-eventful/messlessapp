import '../ws/backend_client.dart';

class UserRole {
  static int roleAsInt() {
    final auth = BackendClient.authState.authenticatedConnection;
    final user = auth?.user as dynamic;

    if (user == null) return 0;

    try {
      final role = user.role;

      if (role is int) return role;

      if (role is String) {
        switch (role) {
          case 'Admin':
            return 5;
          case 'CompanyAdmin':
            return 4;
          case 'Manager':
            return 3;
          case 'Worker':
            return 2;
          case 'StageHand':
            return 1;
          default:
            return 1;
        }
      }
    } catch (_) {}

    return 0;
  }
  static bool get isAdmin => roleAsInt() == 5;

  static bool get isCompanyAdminOrHigher => UserRole.roleAsInt() == 4;

  static bool get isManagerOrHigher => roleAsInt() >= 3;

  static bool get isWorkerOrHigher => UserRole.roleAsInt() == 2;

  static bool get isStageHandOrHigher => UserRole.roleAsInt() == 1;
}