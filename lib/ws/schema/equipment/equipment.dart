import 'package:json_annotation/json_annotation.dart';

part 'equipment.g.dart';

@JsonSerializable()
class Equipment {
  Equipment(
    this.id,
    this.label,
    this.latitude,
    this.longitude,
    this.belongsToWarehouse,
    this.storage,
  );

  final int id;
  final String label;
  final double latitude;
  final double longitude;
  final int belongsToWarehouse;
  final int? storage;

  factory Equipment.fromJson(Map<String, dynamic> json) =>
      _$EquipmentFromJson(json);

  Map<String, dynamic> toJson() => _$EquipmentToJson(this);
}
