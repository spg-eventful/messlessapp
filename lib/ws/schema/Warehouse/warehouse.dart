import 'package:json_annotation/json_annotation.dart';

part 'warehouse.g.dart';

@JsonSerializable()
class Warehouse {
  Warehouse(
    this.id,
    this.label,
    this.longitude,
    this.latitude,
  );

  final int id;
  final String label;
  final double longitude;
  final double latitude;

  factory Warehouse.fromJson(Map<String, dynamic> json) => _$WarehouseFromJson(json);

  Map<String, dynamic> toJson() => _$WarehouseToJson(this);
}