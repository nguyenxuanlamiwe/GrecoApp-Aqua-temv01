// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'tb_action.dart';
import 'tb_lot_config.dart';

class TBModeType {
  static const timer = 'timer';
  static const dissolvedOxygen = 'do';
}

class TBATMode {
  int moId;
  String name;
  String? modeType; // null for irrigation step-based, "timer" or "do" for aquaculture
  List<TBATStep> steps; // irrigation modes
  List<TBLotConfig> lotList; // aquaculture modes
  bool stationEnabled; // station control enabled
  List<int> stationRlc; // RLC actuators controlled by station

  TBATMode({
    required this.moId,
    required this.name,
    this.modeType,
    required this.steps,
    this.lotList = const [],
    this.stationEnabled = false,
    this.stationRlc = const [],
  });

  bool get isAquacultureMode => modeType != null;

  TBATMode copy() => TBATMode(
        moId: moId,
        name: name,
        modeType: modeType,
        steps: [for (var e in steps) e.copy()],
        lotList: [for (var e in lotList) e.copy()],
        stationEnabled: stationEnabled,
        stationRlc: [...stationRlc],
      );

  factory TBATMode.fromJson(Map<String, dynamic> json) {
    final modeType = json['modeType'] as String?;
    final stationJson = json['station'] as Map<String, dynamic>?;
    return TBATMode(
      moId: json['moId'] as int,
      name: json['name'] as String,
      modeType: modeType,
      steps: modeType == null
          ? [
              for (var actionJson in json['actionList'] ?? [])
                TBATStep.fromJson(actionJson)
            ]
          : [],
      lotList: modeType != null
          ? [
              for (var lot in json['lotList'] ?? [])
                TBLotConfig.fromJson(lot)
            ]
          : [],
      stationEnabled: (stationJson?['enable'] as bool?) ?? false,
      stationRlc: (stationJson?['rlc'] as List?)?.map((e) => (e as num).toInt()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'moId': moId,
      'name': name,
    };
    if (modeType != null) {
      result['modeType'] = modeType;
      result['lotList'] = [for (var lot in lotList) lot.toJson()];
      if (stationEnabled || stationRlc.isNotEmpty) {
        result['station'] = {
          'enable': stationEnabled,
          if (stationRlc.isNotEmpty) 'rlc': stationRlc,
        };
      }
    } else {
      result['actionList'] = [for (var step in steps) step.toJson()];
    }
    return result;
  }

  bool validate() {
    if (moId < 0 || name.isEmpty) return false;
    if (modeType == null) {
      return !steps.any((e) => !e.validate());
    }
    if (lotList.isEmpty) return false;
    return switch (modeType) {
      TBModeType.timer => !lotList.any((e) => !e.validateTimer()),
      TBModeType.dissolvedOxygen => !lotList.any((e) => !e.validateDO()),
      _ => false,
    };
  }
}
