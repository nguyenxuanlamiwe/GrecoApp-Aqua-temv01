// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tb_component.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TBComponent _$TBComponentFromJson(Map<String, dynamic> json) => TBComponent(
      variable: json['variable'] as String,
      nameDevice: json['nameDevice'] as String,
      type: json['type'] as String?,
      unit: json['unit'] as String?,
      dataType: json['dataType'] as String?,
      icon: (json['icon'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TBComponentToJson(TBComponent instance) =>
    <String, dynamic>{
      'variable': instance.variable,
      'nameDevice': instance.nameDevice,
      'type': instance.type,
      'unit': instance.unit,
      'dataType': instance.dataType,
      'icon': instance.icon,
    };
