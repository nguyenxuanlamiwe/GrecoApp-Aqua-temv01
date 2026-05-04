// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tb_farm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TBFarm _$TBFarmFromJson(Map<String, dynamic> json) => TBFarm(
      id: TBID.fromJson(json['id'] as Map<String, dynamic>),
      name: json['name'] as String,
      additionalInfo: TBAdditionalInfo.fromJson(
          json['additionalInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TBFarmToJson(TBFarm instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'additionalInfo': instance.additionalInfo,
    };
