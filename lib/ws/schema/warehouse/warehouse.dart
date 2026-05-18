import 'package:json_annotation/json_annotation.dart';

part 'warehouse.g.dart';

@JsonSerializable()
class Warehouse {
  Warehouse(this.id, this.label, this.latitude, this.longitude, this.company);

  final int id;
  final String label;
  final double latitude;
  final double longitude;
  final int company;

  factory Warehouse.fromJson(Map<String, dynamic> json) =>
      _$WarehouseFromJson(json);

  Map<String, dynamic> toJson() => _$WarehouseToJson(this);
}
