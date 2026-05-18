import 'dart:convert';

import 'package:messless/ws/helper.dart';

import '../../ws/backend_client.dart';
import '../../ws/schema/company/company.dart';

class CompanyWs {


  static Future<void> create({
    required String name,
    required double latitude,
    required double longitude,
  }) async {
    final res = await BackendClient.service('companies').create(
      jsonEncode({"label": name, "latitude": latitude, "longitude": longitude}),
    );
    HelperWs.ensureStatus(res.status, {200, 201});
  }

  static Future<List<Company>> find() async {
    final res = await BackendClient.service('companies').find();

    HelperWs.ensureStatus(res.status, {200});

    final decoded = jsonDecode(res.body ?? '[]');

    if (decoded is! List) {
      throw const FormatException('Expected company list');
    }

    return decoded.map((e) => Company.fromJson(e)).toList();
  }

  static Future<Company> getById(int id) async {
    final res = await BackendClient.service('companies').get(id);
    HelperWs.ensureStatus(res.status, {200});
    return Company.fromJson(jsonDecode(res.body.toString()));
  }

  static Future<void> update({
    required int id,
    required String name,
    required double latitude,
    required double longitude,
  }) async {
    final res = await BackendClient.service('companies').update(
      jsonEncode({
        "\$id": id,
        "label": name,
        "latitude": latitude,
        "longitude": longitude,
      }),
    );

    HelperWs.ensureStatus(res.status, {200});
  }

  static Future<void> delete(int id) async {
    final res = await BackendClient.service('companies').delete(id);
    HelperWs.ensureStatus(res.status, {200, 204});
  }
}