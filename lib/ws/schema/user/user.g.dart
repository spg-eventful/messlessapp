// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  (json['id'] as num).toInt(),
  json['firstName'] as String,
  json['lastName'] as String,
  json['fullName'] as String,
  json['email'] as String,
  json['phone'] as String,
  json['role'] as String,
  (json['company'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'fullName': instance.fullName,
  'email': instance.email,
  'phone': instance.phone,
  'role': instance.role,
  'company': instance.company,
};
