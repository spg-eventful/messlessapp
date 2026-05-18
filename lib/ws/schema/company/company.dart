import 'package:json_annotation/json_annotation.dart';

part 'company.g.dart';

@JsonSerializable()
class Company {
  Company(this.id, this.label, this.longitude, this.latitude);

  final int id;
  final String label;
  final double longitude;
  final double latitude;

  factory Company.fromJson(Map<String, dynamic> json) =>
      _$CompanyFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyToJson(this);
}