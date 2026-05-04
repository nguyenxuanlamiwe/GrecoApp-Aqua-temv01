import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class TBAdditionalInfo {
  final String description;
  final String imageUrl;
  final double? lat;
  final double? lon;
  TBAdditionalInfo({
    required this.description,
    required this.imageUrl,
    required this.lat,
    required this.lon,
  });

  factory TBAdditionalInfo.fromJson(Map<String, dynamic> json) {
    try {
      var map = jsonDecode(json["description"]);
      return TBAdditionalInfo(
        description: map["textDescription"] ?? "",
        imageUrl: map["farmImageLink"] ?? "",
        lat: map["lat"],
        lon: map["lon"],
      );
    } catch (_) {
      return TBAdditionalInfo(
        description: "",
        imageUrl: "",
        lat: null,
        lon: null,
      );
    }
  }
}
