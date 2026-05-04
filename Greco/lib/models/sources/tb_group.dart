import 'package:json_annotation/json_annotation.dart';
import 'tb_component.dart';

part 'tb_group.g.dart';

enum TBGroupType {
  @JsonValue("lot")
  lot,

  @JsonValue("station")
  station,
}

@JsonSerializable()
class TBGroup {
  int id;
  String name;

  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  TBGroupType? type;

  @JsonKey(name: "component", defaultValue: [])
  List<TBComponent> components;

  TBGroup(this.id, this.name, this.type, this.components);

  factory TBGroup.fromJson(Map<String, dynamic> json) =>
      _$TBGroupFromJson(json);

  Map<String, dynamic> toJson() => _$TBGroupToJson(this);
}
