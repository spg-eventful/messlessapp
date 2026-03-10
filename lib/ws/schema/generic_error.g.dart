// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generic_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenericError _$GenericErrorFromJson(Map<String, dynamic> json) =>
    GenericError(json['message'] as String, json['errorClass'] as String);

Map<String, dynamic> _$GenericErrorToJson(GenericError instance) =>
    <String, dynamic>{
      'message': instance.message,
      'errorClass': instance.errorClass,
    };
