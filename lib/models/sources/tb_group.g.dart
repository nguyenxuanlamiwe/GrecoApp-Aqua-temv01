// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tb_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TBGroup _$TBGroupFromJson(Map<String, dynamic> json) => TBGroup(
      (json['id'] as num).toInt(),
      json['name'] as String,
      $enumDecodeNullable(_$TBGroupTypeEnumMap, json['type'],
          unknownValue: JsonKey.nullForUndefinedEnumValue),
      (json['component'] as List<dynamic>?)
              ?.map((e) => TBComponent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$TBGroupToJson(TBGroup instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$TBGroupTypeEnumMap[instance.type],
      'component': instance.components,
    };

const _$TBGroupTypeEnumMap = {
  TBGroupType.lot: 'lot',
  TBGroupType.station: 'station',
};
