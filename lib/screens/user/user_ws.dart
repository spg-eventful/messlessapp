import 'dart:convert';
import 'dart:io';

import '../../ws/backend_client.dart';
import '../../ws/schema/user/user.dart';

class UserWs {

  static Future<List<User>> find(int companyId) async {
    final res = await BackendClient.service('users').get(companyId);

    if (res.status != 200) {
      throw HttpException('Fehler beim Laden der User. Status: ${res.status}');
    }
    final decoded = jsonDecode(res.body ?? '[]');
    if (decoded is! List) {
      throw const FormatException('Expected user list from backend');
    }

    return decoded
        .map((e) => User.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

}