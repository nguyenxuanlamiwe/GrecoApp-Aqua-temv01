import 'package:json_annotation/json_annotation.dart';

part 'tb_id.g.dart';

@JsonSerializable()
class TBID {
  final String entityType;
  final String id;

  TBID({
    required this.entityType,
    required this.id,
  });

  factory TBID.fromJson(Map<String, dynamic> json) => _$TBIDFromJson(json);
  Map<String, dynamic> toJson() => _$TBIDToJson(this);
}
