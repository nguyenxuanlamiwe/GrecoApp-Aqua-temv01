import 'package:json_annotation/json_annotation.dart';
import 'package:zen8app/models/models.dart';
import 'tb_camera.dart';
import 'tb_component.dart';
import 'tb_group.dart';

part 'tb_control_system.g.dart';

@JsonSerializable()
class TBControlSystem {
  String name;
  String accessToken;
  String deviceId;

  @JsonKey(name: "component", defaultValue: [])
  List<TBGroup> groups;

  @JsonKey(defaultValue: [])
  List<TBGroup> hyrdromets;

  @JsonKey(defaultValue: [])
  List<TBCamera> camera;

  @JsonKey(defaultValue: [])
  List<TBCrop> crop;

  @JsonKey(defaultValue: [])
  List<String> soil;

  @JsonKey(defaultValue: "")
  String appType;

  @JsonKey(defaultValue: false)
  bool weatherForcast;

  @JsonKey(defaultValue: false)
  bool hasCamera;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late final List<TBComponent> booleanComponents = (groups + hyrdromets)
      .expand((g) => g.components)
      .where((e) => e.dataType == 'boolean')
      .toList();

  @JsonKey(includeFromJson: false, includeToJson: false)
  late final List<TBComponent> floatComponents = (groups + hyrdromets)
      .expand((g) => g.components)
      .where((e) => e.dataType == 'float')
      .toList();

  TBControlSystem(
    this.name,
    this.accessToken,
    this.deviceId,
    this.groups,
    this.hyrdromets,
    this.camera,
    this.crop,
    this.soil,
    this.appType,
    this.weatherForcast,
    this.hasCamera,
  );

  factory TBControlSystem.fromJson(Map<String, dynamic> json) =>
      _$TBControlSystemFromJson(json);

  Map<String, dynamic> toJson() => _$TBControlSystemToJson(this);
}
