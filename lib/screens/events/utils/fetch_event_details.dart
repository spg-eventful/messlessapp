import 'dart:convert';

import '../../../ws/backend_client.dart';
import '../../../ws/schema/event/event.dart';

class FetchEventDetails {
  static Future<Event> fetchEvent(int id) async {
    try {
      var response = await BackendClient.service("events").get(id);
      if (response.body == null || response.body.toString().isEmpty) {
        throw Exception("No data for warehouse $id");
      }
      return Event.fromJson(jsonDecode(response.body.toString()));
    } catch (e) {
      rethrow;
    }
  }
}
