import 'package:json_annotation/json_annotation.dart';

part 'equipment.g.dart';

@JsonSerializable()
class Equipment {
  Equipment(
    this.id,
    this.label,
    this.longitude,
    this.latitude, this.belongsToWarehouse,
  );

  final int id;
  final String label;
  final double longitude;
  final double latitude;
  final int belongsToWarehouse;

  factory Equipment.fromJson(Map<String, dynamic> json) => _$EquipmentFromJson(json);

  Map<String, dynamic> toJson() => _$EquipmentToJson(this);
}