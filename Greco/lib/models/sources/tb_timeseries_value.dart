import 'package:json_annotation/json_annotation.dart';

part 'tb_timeseries_value.g.dart';

@JsonSerializable()
class TBTimeseriesValue {
  double ts;
  @JsonKey(defaultValue: "0")
  String value;

  TBTimeseriesValue({
    required this.ts,
    required this.value,
  });

  factory TBTimeseriesValue.fromJson(Map<String, dynamic> json) =>
      _$TBTimeseriesValueFromJson(json);
  Map<String, dynamic> toJson() => _$TBTimeseriesValueToJson(this);
}
