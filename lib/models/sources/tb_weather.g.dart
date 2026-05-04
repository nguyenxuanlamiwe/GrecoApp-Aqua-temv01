// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tb_weather.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TbWeatherForNext10Days _$TbWeatherForNext10DaysFromJson(
        Map<String, dynamic> json) =>
    TbWeatherForNext10Days(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      generationtimeMs: (json['generationtime_ms'] as num).toDouble(),
      utcOffsetSeconds: (json['utc_offset_seconds'] as num).toInt(),
      timezone: json['timezone'] as String,
      timezoneAbbreviation: json['timezone_abbreviation'] as String,
      elevation: (json['elevation'] as num).toDouble(),
      hourlyUnits:
          HourlyUnits.fromJson(json['hourly_units'] as Map<String, dynamic>),
      dailyUnits:
          DailyUnits.fromJson(json['daily_units'] as Map<String, dynamic>),
      daily: Daily.fromJson(json['daily'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TbWeatherForNext10DaysToJson(
        TbWeatherForNext10Days instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'generationtime_ms': instance.generationtimeMs,
      'utc_offset_seconds': instance.utcOffsetSeconds,
      'timezone': instance.timezone,
      'timezone_abbreviation': instance.timezoneAbbreviation,
      'elevation': instance.elevation,
      'hourly_units': instance.hourlyUnits,
      'daily_units': instance.dailyUnits,
      'daily': instance.daily,
    };

Daily _$DailyFromJson(Map<String, dynamic> json) => Daily(
      time: (json['time'] as List<dynamic>).map((e) => e as String).toList(),
      weathercode: (json['weathercode'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      temperature2mMax: (json['temperature_2m_max'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      temperature2mMin: (json['temperature_2m_min'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      rainSum: (json['rain_sum'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      precipitationProbabilityMax:
          (json['precipitation_probability_max'] as List<dynamic>)
              .map((e) => (e as num).toInt())
              .toList(),
      windspeed10MMax: (json['windspeed_10m_max'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      humidity2m: (json['humidity_2m'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$DailyToJson(Daily instance) => <String, dynamic>{
      'time': instance.time,
      'weathercode': instance.weathercode,
      'temperature_2m_max': instance.temperature2mMax,
      'temperature_2m_min': instance.temperature2mMin,
      'rain_sum': instance.rainSum,
      'precipitation_probability_max': instance.precipitationProbabilityMax,
      'windspeed_10m_max': instance.windspeed10MMax,
      'humidity_2m': instance.humidity2m,
    };

DailyUnits _$DailyUnitsFromJson(Map<String, dynamic> json) => DailyUnits(
      time: json['time'] as String? ?? '',
      weathercode: json['weathercode'] as String? ?? '',
      temperature2mMax: json['temperature_2m_max'] as String? ?? '',
      temperature2mMin: json['temperature_2m_min'] as String? ?? '',
      rainSum: json['rain_sum'] as String? ?? '',
      precipitationProbabilityMax:
          json['precipitation_probability_max'] as String? ?? '',
      windspeed10MMax: json['windspeed_10m_max'] as String? ?? '',
    );

Map<String, dynamic> _$DailyUnitsToJson(DailyUnits instance) =>
    <String, dynamic>{
      'time': instance.time,
      'weathercode': instance.weathercode,
      'temperature_2m_max': instance.temperature2mMax,
      'temperature_2m_min': instance.temperature2mMin,
      'rain_sum': instance.rainSum,
      'precipitation_probability_max': instance.precipitationProbabilityMax,
      'windspeed_10m_max': instance.windspeed10MMax,
    };

HourlyUnits _$HourlyUnitsFromJson(Map<String, dynamic> json) => HourlyUnits(
      relativehumidity2m: json['relativehumidity_2m'] as String? ?? '',
    );

Map<String, dynamic> _$HourlyUnitsToJson(HourlyUnits instance) =>
    <String, dynamic>{
      'relativehumidity_2m': instance.relativehumidity2m,
    };
