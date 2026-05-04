import 'package:json_annotation/json_annotation.dart';
import 'package:zen8app/models/models.dart';

part 'tb_farm.g.dart';

@JsonSerializable()
class TBFarm {
  final TBID id;

  final String name;

  final TBAdditionalInfo additionalInfo;

  TBFarm({
    required this.id,
    required this.name,
    required this.additionalInfo,
  });

  factory TBFarm.fromJson(Map<String, dynamic> json) => _$TBFarmFromJson(json);
  Map<String, dynamic> toJson() => _$TBFarmToJson(this);
}
