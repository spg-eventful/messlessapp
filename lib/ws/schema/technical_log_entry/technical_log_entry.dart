import 'package:json_annotation/json_annotation.dart';

part 'technical_log_entry.g.dart';

@JsonSerializable()
class TechnicalLogEntry {
  TechnicalLogEntry(
    this.id,
    this.isCheckIn,
    this.attachedTo,
    this.equipmentLabel,
    this.byUser,
    this.userFullName,
    this.latitude,
    this.longitude,
    this.createdAt,
  );

  final int id;
  final bool isCheckIn;
  final int attachedTo;
  final String equipmentLabel;
  final int byUser;
  final String userFullName;
  final double latitude;
  final double longitude;
  final String createdAt;

  factory TechnicalLogEntry.fromJson(Map<String, dynamic> json) =>
      _$TechnicalLogEntryFromJson(json);

  Map<String, dynamic> toJson() => _$TechnicalLogEntryToJson(this);
}
