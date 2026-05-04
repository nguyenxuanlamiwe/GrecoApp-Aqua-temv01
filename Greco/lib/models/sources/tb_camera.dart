// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

part 'tb_camera.g.dart';

@JsonSerializable()
class TBCamera {
  String nameDevice;
  String cameraUrl;

  TBCamera({
    required this.nameDevice,
    required this.cameraUrl,
  });

  factory TBCamera.fromJson(Map<String, dynamic> json) =>
      _$TBCameraFromJson(json);
  Map<String, dynamic> toJson() => _$TBCameraToJson(this);
}
