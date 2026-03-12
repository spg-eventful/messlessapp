import 'package:json_annotation/json_annotation.dart';

part 'basic_auth.g.dart';

@JsonSerializable()
class BasicAuth {
  BasicAuth(this.email, this.password);

  final String email;
  final String password;

  factory BasicAuth.fromJson(Map<String, dynamic> json) =>
      _$BasicAuthFromJson(json);

  Map<String, dynamic> toJson() => _$BasicAuthToJson(this);
}
