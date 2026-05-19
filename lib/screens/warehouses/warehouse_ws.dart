import 'dart:convert';

import 'package:messless/ws/backend_client.dart';
import 'package:messless/ws/schema/warehouse/warehouse.dart';
import '../../services/user_role.dart';

import '../../ws/schema/company/company.dart';

class WarehouseWs {
  static int get currentCompanyId => _currentCompanyId();
  static int? _activeCompanyId;

  static Future<List<Warehouse>> findAll() async {
    final response = await BackendClient.service('warehouses').find();
    _ensureStatus(response.status, {200});
    List<dynamic> jsonList = jsonDecode(response.body.toString());
    return jsonList.map((json) => Warehouse.fromJson(json)).toList();
  }

  static Future<Warehouse> getById(int id) async {
    final res = await BackendClient.service('warehouses').get(id);
    _ensureStatus(res.status, {200});
    return Warehouse.fromJson(jsonDecode(res.body.toString()));
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

  static Future<List<Company>> findCompanies() async {
    final res = await BackendClient.service('companies').find();

    _ensureStatus(res.status, {200});

    final decoded = jsonDecode(res.body ?? '[]');

    if (decoded is! List) {
      throw const FormatException('Expected company list');
    }

    return decoded.map((e) => Company.fromJson(e)).toList();
  }

  static void setActiveCompanyId(int id) {
    _activeCompanyId = id;
  }

  static void clearActiveCompanyId() {
    _activeCompanyId = null;
  }

  static int get activeCompanyId {
    if (UserRole.isAdmin) {
      if (_activeCompanyId == null) {
        throw StateError('Admin hat keine Company ausgewählt');
      }
      return _activeCompanyId!;
    }
    return currentCompanyId;
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

  static void _ensureStatus(int? status, Set<int> ok) {
    if (status == null || !ok.contains(status)) {
      throw StateError('Unexpected warehouse response status: $status');
    }
  }
}
