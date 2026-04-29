import 'package:json_annotation/json_annotation.dart';

part 'equipment_storage.g.dart';

@JsonSerializable()
class EquipmentStorage {
  EquipmentStorage(this.id, this.label, this.latitude, this.longitude);

  final int id;
  final String label;
  final double latitude;
  final double longitude;

  factory EquipmentStorage.fromJson(Map<String, dynamic> json) => _$EquipmentStorageFromJson(json);

  Map<String, dynamic> toJson() => _$EquipmentStorageToJson(this);
}
