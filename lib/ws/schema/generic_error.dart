import 'package:json_annotation/json_annotation.dart';

part 'generic_error.g.dart';

/// Represents the default error schema for failed backend requests
@JsonSerializable()
class GenericError {
  GenericError(this.message, this.errorClass);

  final String message;
  final String errorClass;

  factory GenericError.fromJson(Map<String, dynamic> json) =>
      _$GenericErrorFromJson(json);

  Map<String, dynamic> toJson() => _$GenericErrorToJson(this);
}
