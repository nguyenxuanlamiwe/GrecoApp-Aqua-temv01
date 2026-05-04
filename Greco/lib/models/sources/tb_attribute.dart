import 'package:json_annotation/json_annotation.dart';

part 'tb_attribute.g.dart';

@JsonSerializable()
class TBAttribute {
  int lastUpdateTs;
  String key;
  dynamic value;

  TBAttribute({
    required this.lastUpdateTs,
    required this.key,
    required this.value,
  });

  factory TBAttribute.fromJson(Map<String, dynamic> json) =>
      _$TBAttributeFromJson(json);
  Map<String, dynamic> toJson() => _$TBAttributeToJson(this);
}
