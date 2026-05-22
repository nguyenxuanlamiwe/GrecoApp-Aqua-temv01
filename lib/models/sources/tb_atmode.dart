// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'tb_action.dart';
import 'tb_lot_config.dart';

class TBModeType {
  static const timer = 'timer';
  static const dissolvedOxygen = 'do';
  static const soilMoisture = 'sm'; // irrigation: tưới theo độ ẩm đất
  static const fertilizer = 'fertilizer'; // irrigation: châm phân tự động (TBD)
}

class TBRunMode {
  static const alternating = 'alternating';     // luân phiên
  static const simultaneous = 'simultaneous';   // đồng thời
}

class TBATMode {
  int moId;
  String name;
  String? modeType; // null for irrigation step-based, "timer" or "do" for aquaculture
  String? runMode;  // irrigation timer only: "sequential" | "parallel"
  List<TBATStep> steps; // irrigation modes
  List<TBLotConfig> lotList; // aquaculture modes
  bool stationEnabled; // station control enabled
  List<int> stationRlc; // RLC actuators controlled by station

  TBATMode({
    required this.moId,
    required this.name,
    this.modeType,
    this.runMode,
    required this.steps,
    this.lotList = const [],
    this.stationEnabled = false,
    this.stationRlc = const [],
  });

  bool get isAquacultureMode =>
      modeType == TBModeType.timer ||
      modeType == TBModeType.dissolvedOxygen;

  bool get isIrrigationLotMode =>
      modeType == TBModeType.soilMoisture ||
      modeType == TBModeType.fertilizer;

  bool get isIrrigationTimerMode => modeType == TBModeType.timer && !isAquacultureMode;

  TBATMode copy() => TBATMode(
        moId: moId,
        name: name,
        modeType: modeType,
        runMode: runMode,
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
      runMode: json['runMode'] as String?,
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
      if (runMode != null) result['runMode'] = runMode;
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
      TBModeType.soilMoisture => !lotList.any((e) => !e.validateSM()),
      _ => false,
    };
  }
}
