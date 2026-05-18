import 'dart:convert';
import 'dart:io';

import 'package:messless/ws/backend_client.dart';
import 'package:messless/ws/helper.dart';
import 'package:messless/ws/schema/warehouse/warehouse.dart';

import '../../ws/schema/company/company.dart';
import '../../ws/schema/user/user.dart';

class WarehouseWs {

  static Future<List<Warehouse>> findAll() async {
    final response = await BackendClient.service('warehouses').find();
    HelperWs.ensureStatus(response.status, {200});
    List<dynamic> jsonList = jsonDecode(response.body.toString());
    return jsonList.map((json) => Warehouse.fromJson(json)).toList();
  }

  static Future<Warehouse> getById(int id) async {
    final res = await BackendClient.service('warehouses').get(id);
    HelperWs.ensureStatus(res.status, {200});
    return Warehouse.fromJson(jsonDecode(res.body.toString()));
  }

  static Future<void> create({
    required String name,
    required double latitude,
    required double longitude,
    int? companyId,
  }) async {
    final resolvedCompanyId = companyId ?? HelperWs.activeCompanyId;
    final res = await BackendClient.service('warehouses').create(
      jsonEncode({
        "label": name,
        "latitude": latitude,
        "longitude": longitude,
        "companyId": resolvedCompanyId,
      }),
    );
    HelperWs.ensureStatus(res.status, {200, 201});
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

    HelperWs.ensureStatus(res.status, {200});
  }

  static Future<void> delete(int id) async {
    final res = await BackendClient.service('warehouses').delete(id);
    HelperWs.ensureStatus(res.status, {200, 204});
  }
}
