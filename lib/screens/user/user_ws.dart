import 'dart:convert';

import '../../ws/backend_client.dart';
import '../../ws/helper.dart';
import '../../ws/schema/user/user.dart';

class UserWs {

  static Future<void> create({
    required String email,
    required String plainPassword,
    required String userRole,
    required String phone,
    required String firstName,
    required String lastName,
    int? companyId,
  }) async {
    final res = await BackendClient.service('users').create(
      jsonEncode({
        "email": email,
        "plainPassword": plainPassword,
        "role": userRole,
        "phone": phone,
        "firstName": firstName,
        "lastName": lastName,
        "companyId": companyId}),
    );
    HelperWs.ensureStatus(res.status, {200, 201});
  }

  static Future<List<User>> find() async {
    final res = await BackendClient.service('users').find();

    HelperWs.ensureStatus(res.status, {200});

    final decoded = jsonDecode(res.body ?? '[]');

    if (decoded is! List) {
      throw const FormatException('Expected user list');
    }

    return decoded.map((e) => User.fromJson(e)).toList();
  }

  static Future<User> getById(int id) async {
    final res = await BackendClient.service('users').get(id);
    HelperWs.ensureStatus(res.status, {200});
    return User.fromJson(jsonDecode(res.body.toString()));
  }

  static Future<void> update({
    required int id,
    required String email,
    required String userRole,
    required String phone,
    required String firstName,
    required String lastName,
    int? companyId,
  }) async {
    final res = await BackendClient.service('users').update(
      jsonEncode({
        "\$id": id,
        "email": email,
        "role": userRole,
        "phone": phone,
        "firstName": firstName,
        "lastName": lastName,
        "company": companyId}),
    );

    HelperWs.ensureStatus(res.status, {200});
  }

  static Future<void> delete(int id) async {
    final res = await BackendClient.service('users').delete(id);
    HelperWs.ensureStatus(res.status, {200, 204});
  }

}