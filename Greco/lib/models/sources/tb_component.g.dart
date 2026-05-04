// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tb_component.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TBComponent _$TBComponentFromJson(Map<String, dynamic> json) => TBComponent(
      json['variable'] as String,
      json['nameDevice'] as String,
      json['actualOpt'] as String?,
      json['unit'] as String?,
      json['dataType'] as String?,
      (json['icon'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TBComponentToJson(TBComponent instance) =>
    <String, dynamic>{
      'variable': instance.variable,
      'nameDevice': instance.nameDevice,
      'actualOpt': instance.actualOpt,
      'unit': instance.unit,
      'dataType': instance.dataType,
      'icon': instance.icon,
    };
