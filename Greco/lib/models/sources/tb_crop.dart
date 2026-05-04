// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

part 'tb_crop.g.dart';

@JsonSerializable()
class TBCrop {
  String name;

  List<String> cropStage;
  TBCrop({
    required this.name,
    required this.cropStage,
  });

  factory TBCrop.fromJson(Map<String, dynamic> json) => _$TBCropFromJson(json);
  Map<String, dynamic> toJson() => _$TBCropToJson(this);
}
