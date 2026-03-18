// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BasicAuth _$BasicAuthFromJson(Map<String, dynamic> json) =>
    BasicAuth(json['email'] as String, json['password'] as String);

Map<String, dynamic> _$BasicAuthToJson(BasicAuth instance) => <String, dynamic>{
  'email': instance.email,
  'password': instance.password,
};
