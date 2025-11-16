// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wp_exception.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WpException _$WpExceptionFromJson(Map<String, dynamic> json) => WpException(
      status: (json['status'] as num).toInt(),
      reason: json['reason'] as String?,
      errorMsg: json['errorMsg'] as String,
      errorData: json['errorData'] as String?,
    );

Map<String, dynamic> _$WpExceptionToJson(WpException instance) =>
    <String, dynamic>{
      'status': instance.status,
      'errorMsg': instance.errorMsg,
      'reason': instance.reason,
      'errorData': instance.errorData,
    };
