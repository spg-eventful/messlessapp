// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Auth _$AuthFromJson(Map<String, dynamic> json) => Auth(
  json['jwt'] as String,
  User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AuthToJson(Auth instance) => <String, dynamic>{
  'jwt': instance.jwt,
  'user': instance.user,
};
