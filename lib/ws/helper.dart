import 'backend_client.dart';

class HelperWs {
  static bool get isManagerOrHigher => roleAsInt() >= 3;

  static bool get isAdmin => roleAsInt() == 5;

  static int? _activeCompanyId;

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

  static void setActiveCompanyId(int id) {
    _activeCompanyId = id;
  }

  static void clearActiveCompanyId() {
    _activeCompanyId = null;
  }

  static int get activeCompanyId {
    if (isAdmin) {
      if (_activeCompanyId == null) {
        throw StateError('Admin hat keine Company ausgewählt');
      }
      return _activeCompanyId!;
    }
    return currentCompanyId();
  }

  static int currentCompanyId() {
    final user =
    BackendClient.authState.authenticatedConnection?.user as dynamic;

    if (user == null) {
      throw StateError('User not authenticated');
    }

    final company = user.company;

    if (company is int) return company;

    throw StateError('Invalid company format on user');
  }

  static void ensureStatus(int? status, Set<int> ok) {
    if (!ok.contains(status)) {
      throw ArgumentError('Unexpected response status: $status');
    }
  }
}