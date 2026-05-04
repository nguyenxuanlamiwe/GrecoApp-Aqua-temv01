// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tb_timeseries_value.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TBTimeseriesValue _$TBTimeseriesValueFromJson(Map<String, dynamic> json) =>
    TBTimeseriesValue(
      ts: (json['ts'] as num).toDouble(),
      value: json['value'] as String? ?? '0',
    );

Map<String, dynamic> _$TBTimeseriesValueToJson(TBTimeseriesValue instance) =>
    <String, dynamic>{
      'ts': instance.ts,
      'value': instance.value,
    };
