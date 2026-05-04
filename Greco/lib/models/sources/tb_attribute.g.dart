// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tb_attribute.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TBAttribute _$TBAttributeFromJson(Map<String, dynamic> json) => TBAttribute(
      lastUpdateTs: (json['lastUpdateTs'] as num).toInt(),
      key: json['key'] as String,
      value: json['value'],
    );

Map<String, dynamic> _$TBAttributeToJson(TBAttribute instance) =>
    <String, dynamic>{
      'lastUpdateTs': instance.lastUpdateTs,
      'key': instance.key,
      'value': instance.value,
    };
