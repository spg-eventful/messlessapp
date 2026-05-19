import 'package:intl/number_symbols.dart';
import 'package:json_annotation/json_annotation.dart';

part 'company.g.dart';

@JsonSerializable()
class Company {
  Company(
      this.id,
      this.label,
      this.latitude,
      this.longitude,
      );

  final int id;
  final String label;
  final double latitude;
  final double longitude;

  factory Company.fromJson(Map<String, dynamic> json) =>
      _$CompanyFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyToJson(this);
}
