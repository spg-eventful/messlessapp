import 'dart:convert';

import 'package:messless/ws/backend_client.dart';

class WarehouseWs {
  static bool get isManagerOrHigher => _roleAsInt() >= 3;

  static bool get isAdmin => _roleAsInt() == 5;

  static int get currentCompanyId => _currentCompanyId();
  static int? _activeCompanyId;

  static Future<List<Map<String, dynamic>>> findAll() async {
    final res = await BackendClient.service('warehouses').find();
    _ensureStatus(res.status, {200});
    return _asList(res.body);
  }

  static Future<Map<String, dynamic>> getById(int id) async {
    final res = await BackendClient.service('warehouses').get(id);
    _ensureStatus(res.status, {200});
    return _asMap(res.body);
  }

  static Future<void> create({
    required String name,
    required double latitude,
    required double longitude,
    required int companyId,
  }) async {
    final res = await BackendClient.service('warehouses').create(
      jsonEncode({
        "label": name,
        "latitude": latitude,
        "longitude": longitude,
        "companyId": companyId,
      }),
    );
    _ensureStatus(res.status, {200, 201});
  }

  static Future<void> update({
    required int id,
    required String name,
    required double latitude,
    required double longitude,
    required int companyId,
  }) async {
    final res = await BackendClient.service('warehouses').update(
      jsonEncode({
        "\$id": id,
        "label": name,
        "latitude": latitude,
        "longitude": longitude,
        "companyId": companyId,
      }),
    );

    _ensureStatus(res.status, {200});
  }

  static Future<void> delete(int id) async {
    final res = await BackendClient.service('warehouses').delete(id);
    _ensureStatus(res.status, {200, 204});
  }

  static Future<List<Map<String, dynamic>>> findCompanies() async {
    final res = await BackendClient.service('companies').find();

    _ensureStatus(res.status, {200});

    final decoded = jsonDecode(res.body ?? '[]');

    if (decoded is! List) {
      throw const FormatException('Expected company list');
    }

    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static String titleOf(Map<String, dynamic> json) {
    final value = json['label'];

    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return 'Warehouse #${idOf(json)}';
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
    return currentCompanyId;
  }

  static int idOf(Map<String, dynamic> json) {
    final value = json['id'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    throw const FormatException('Warehouse id missing or invalid.');
  }

  static int? companyIdOf(Map<String, dynamic> json) {
    final company = json['company'];

    if (company is int) return company;

    return null;
  }

  static int _currentCompanyId() {
    final user =
        BackendClient.authState.authenticatedConnection?.user as dynamic;

    if (user == null) {
      throw StateError('User not authenticated');
    }

    final company = user.company;

    if (company is int) return company;

    throw StateError('Invalid company format on user');
  }

  static int _roleAsInt() {
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
            return 0;
        }
      }
    } catch (_) {}

    return 0;
  }

  static void _ensureStatus(int? status, Set<int> ok) {
    if (status == null || !ok.contains(status)) {
      throw StateError('Unexpected warehouse response status: $status');
    }
  }

  static List<Map<String, dynamic>> _asList(String? body) {
    final decoded = jsonDecode(body ?? '[]');
    if (decoded is! List) {
      throw const FormatException('Expected a JSON list.');
    }

    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Map<String, dynamic> _asMap(String? body) {
    final decoded = jsonDecode(body ?? '{}');
    if (decoded is! Map) {
      throw const FormatException('Expected a JSON object.');
    }

    return Map<String, dynamic>.from(decoded);
  }
}
