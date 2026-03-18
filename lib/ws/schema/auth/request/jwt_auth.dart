import 'package:json_annotation/json_annotation.dart';

part 'jwt_auth.g.dart';

@JsonSerializable()
class JwtAuth {
  JwtAuth(this.jwt);

  final String jwt;

  factory JwtAuth.fromJson(Map<String, dynamic> json) =>
      _$JwtAuthFromJson(json);

  Map<String, dynamic> toJson() => _$JwtAuthToJson(this);
}
