// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tb_crop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TBCrop _$TBCropFromJson(Map<String, dynamic> json) => TBCrop(
      name: json['name'] as String,
      cropStage:
          (json['cropStage'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$TBCropToJson(TBCrop instance) => <String, dynamic>{
      'name': instance.name,
      'cropStage': instance.cropStage,
    };
