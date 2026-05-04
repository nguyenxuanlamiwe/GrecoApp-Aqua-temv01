// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

part 'tb_weather.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TbWeatherForNext10Days {
  final double latitude;
  final double longitude;
  final double generationtimeMs;
  final int utcOffsetSeconds;
  final String timezone;
  final String timezoneAbbreviation;
  final double elevation;
  final HourlyUnits hourlyUnits;
  final DailyUnits dailyUnits;
  final Daily daily;

  TbWeatherForNext10Days({
    required this.latitude,
    required this.longitude,
    required this.generationtimeMs,
    required this.utcOffsetSeconds,
    required this.timezone,
    required this.timezoneAbbreviation,
    required this.elevation,
    required this.hourlyUnits,
    required this.dailyUnits,
    required this.daily,
  });

  factory TbWeatherForNext10Days.fromJson(Map<String, dynamic> json) =>
      _$TbWeatherForNext10DaysFromJson(json);
  Map<String, dynamic> toJson() => _$TbWeatherForNext10DaysToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Daily {
  final List<String> time;
  final List<int> weathercode;
  @JsonKey(name: "temperature_2m_max")
  final List<double> temperature2mMax;
  @JsonKey(name: "temperature_2m_min")
  final List<double> temperature2mMin;
  final List<double> rainSum;
  final List<int> precipitationProbabilityMax;
  @JsonKey(name: "windspeed_10m_max")
  final List<double> windspeed10MMax;
  @JsonKey(name: "humidity_2m")
  final List<double> humidity2m;

  Daily({
    required this.time,
    required this.weathercode,
    required this.temperature2mMax,
    required this.temperature2mMin,
    required this.rainSum,
    required this.precipitationProbabilityMax,
    required this.windspeed10MMax,
    required this.humidity2m,
  });

  factory Daily.fromJson(Map<String, dynamic> json) => _$DailyFromJson(json);
  Map<String, dynamic> toJson() => _$DailyToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class DailyUnits {
  @JsonKey(defaultValue: "")
  final String time;
  @JsonKey(defaultValue: "")
  final String weathercode;
  @JsonKey(name: "temperature_2m_max", defaultValue: "")
  final String temperature2mMax;
  @JsonKey(name: "temperature_2m_min", defaultValue: "")
  final String temperature2mMin;
  @JsonKey(defaultValue: "")
  final String rainSum;
  @JsonKey(defaultValue: "")
  final String precipitationProbabilityMax;
  @JsonKey(name: "windspeed_10m_max", defaultValue: "")
  final String windspeed10MMax;

  DailyUnits({
    required this.time,
    required this.weathercode,
    required this.temperature2mMax,
    required this.temperature2mMin,
    required this.rainSum,
    required this.precipitationProbabilityMax,
    required this.windspeed10MMax,
  });
  factory DailyUnits.fromJson(Map<String, dynamic> json) =>
      _$DailyUnitsFromJson(json);
  Map<String, dynamic> toJson() => _$DailyUnitsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class HourlyUnits {
  @JsonKey(name: "relativehumidity_2m", defaultValue: "")
  final String relativehumidity2m;

  HourlyUnits({
    required this.relativehumidity2m,
  });
  factory HourlyUnits.fromJson(Map<String, dynamic> json) =>
      _$HourlyUnitsFromJson(json);
  Map<String, dynamic> toJson() => _$HourlyUnitsToJson(this);
}

class TBWeather {
  final DateTime date;
  final String temperatureUnit;
  final String windSpeedUnit;
  final String rainSumUnit;
  final String precipitationUnit;
  final String humidityUnit;
  final double minTemperature;
  final double maxTemperature;
  final double rainSum;
  final double windSpeed;
  final int precipitation;
  final double humidity;
  final String iconPath;
  final String weatherDescription;
  TBWeather({
    required this.date,
    required this.temperatureUnit,
    required this.windSpeedUnit,
    required this.rainSum,
    required this.precipitationUnit,
    required this.humidityUnit,
    required this.minTemperature,
    required this.maxTemperature,
    required this.rainSumUnit,
    required this.windSpeed,
    required this.precipitation,
    required this.humidity,
    required this.iconPath,
    required this.weatherDescription,
  });
}
