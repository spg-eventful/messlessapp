import 'dart:convert';

import '../../../ws/backend_client.dart';
import '../../../ws/schema/equipment/equipment.dart';
import '../../../ws/schema/technical_log_entry/technical_log_entry.dart';
import '../../../ws/schema/warehouse/warehouse.dart';

class EquipmentDetailsData {
  final Equipment equipment;
  final Warehouse warehouse;
  final List<TechnicalLogEntry>? technicalLogEntries;

  EquipmentDetailsData({
    required this.equipment,
    required this.warehouse,
    required this.technicalLogEntries,
  });

  static Future<Equipment> fetchEquipment(int id) async {
    try {
      var response = await BackendClient.service("equipments").get(id);
      if (response.body == null || response.body.toString().isEmpty) {
        throw Exception("No data for equipment $id");
      }
      return Equipment.fromJson(jsonDecode(response.body.toString()));
    } catch (e) {
      rethrow;
    }
  }

  static Future<Warehouse> fetchWarehouses(int id) async {
    try {
      var response = await BackendClient.service("warehouses").get(id);
      if (response.body == null || response.body.toString().isEmpty) {
        throw Exception("No data for warehouse $id");
      }
      return Warehouse.fromJson(jsonDecode(response.body.toString()));
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<TechnicalLogEntry>> fetchTechnicalLogs(int id) async {
    try {
      var response = await BackendClient.service(
        "technical-log-entries",
      ).findWithBody(jsonEncode({"equipmentId": id}));
      if (response.body == null || response.body.toString().isEmpty) {
        return [];
      }
      List<dynamic> jsonList = jsonDecode(response.body.toString());
      return jsonList.map((json) => TechnicalLogEntry.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<EquipmentDetailsData> loadData(int equipmentId) async {
    final equipment = await EquipmentDetailsData.fetchEquipment(equipmentId);
    final results = await Future.wait([
      fetchWarehouses(equipment.belongsToWarehouse),
      fetchTechnicalLogs(equipmentId),
    ]);

    return EquipmentDetailsData(
      equipment: equipment,
      warehouse: results[0] as Warehouse,
      technicalLogEntries: results[1] as List<TechnicalLogEntry>,
    );
  }
}