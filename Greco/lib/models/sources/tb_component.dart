import 'package:json_annotation/json_annotation.dart';

part 'tb_component.g.dart';

@JsonSerializable()
class TBComponent {
  String variable;

  String nameDevice;

  String? actualOpt;
  String? unit;
  String? dataType;
  int? icon;

  TBComponent(
    this.variable,
    this.nameDevice,
    this.actualOpt,
    this.unit,
    this.dataType,
    this.icon,
  );

  factory TBComponent.fromJson(Map<String, dynamic> json) =>
      _$TBComponentFromJson(json);

  Map<String, dynamic> toJson() => _$TBComponentToJson(this);

  bool isBooleanComponent() => dataType == 'boolean';

  @override
  String toString() => nameDevice;

  String? iconName() => switch (icon) {
        var iconId? => 'images/ic_component_$iconId.png',
        _ => null,
      };
}
