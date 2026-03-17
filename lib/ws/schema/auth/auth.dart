import 'package:json_annotation/json_annotation.dart';

import '../user/user.dart';

part 'auth.g.dart';

@JsonSerializable()
class Auth {
  Auth(this.jwt, this.user);

  final String jwt;
  final User user;

  factory Auth.fromJson(Map<String, dynamic> json) => _$AuthFromJson(json);

  Map<String, dynamic> toJson() => _$AuthToJson(this);
}
