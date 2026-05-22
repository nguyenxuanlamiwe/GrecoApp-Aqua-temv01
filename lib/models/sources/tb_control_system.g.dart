// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tb_control_system.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TBControlSystem _$TBControlSystemFromJson(Map<String, dynamic> json) =>
    TBControlSystem(
      json['name'] as String,
      json['accessToken'] as String,
      json['deviceId'] as String,
      (json['component'] as List<dynamic>?)
              ?.map((e) => TBGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      (json['hyrdromets'] as List<dynamic>?)
              ?.map((e) => TBGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      (json['camera'] as List<dynamic>?)
              ?.map((e) => TBCamera.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      (json['crop'] as List<dynamic>?)
              ?.map((e) => TBCrop.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      (json['soil'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      json['appType'] as String? ?? '',
      json['weatherForcast'] as bool? ?? false,
      json['hasCamera'] as bool? ?? false,
      json['hasSuggestion'] as bool? ?? false,
    );

Map<String, dynamic> _$TBControlSystemToJson(TBControlSystem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'accessToken': instance.accessToken,
      'deviceId': instance.deviceId,
      'component': instance.groups,
      'hyrdromets': instance.hyrdromets,
      'camera': instance.camera,
      'crop': instance.crop,
      'soil': instance.soil,
      'appType': instance.appType,
      'weatherForcast': instance.weatherForcast,
      'hasCamera': instance.hasCamera,
      'hasSuggestion': instance.hasSuggestion,
    };
