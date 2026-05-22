class TBATSystem {
  bool isPrMaintainEnabled;
  double? prMaintainValue;
  double? safeAtpress;
  int? moId;
  DateTime? startTime; // for aquaculture / irrigation
  bool startNow; // send "now" instead of datetime
  String? scheduleType; // irrigation only: "onetime" | "daily" | "weekly" | "monthly"

  TBATSystem({
    required this.isPrMaintainEnabled,
    required this.prMaintainValue,
    required this.safeAtpress,
    required this.moId,
    this.startTime,
    this.startNow = false,
    this.scheduleType,
  });

  TBATSystem.empty()
      : this(
          isPrMaintainEnabled: false,
          prMaintainValue: null,
          safeAtpress: null,
          moId: null,
          startTime: null,
          startNow: false,
          scheduleType: null,
        );

  TBATSystem copy() => TBATSystem(
        isPrMaintainEnabled: isPrMaintainEnabled,
        prMaintainValue: prMaintainValue,
        safeAtpress: safeAtpress,
        moId: moId,
        startTime: startTime,
        startNow: startNow,
        scheduleType: scheduleType,
      );

  factory TBATSystem.fromJson(Map<String, dynamic> json) {
    final moId = json["moId"] as int?;
    final safeAtpress = (json["safeAtpress"] as num?)?.toDouble();
    final prMaintainJson = (json["prMaintain"] as Map<String, dynamic>?) ?? {};
    final isPrMaintainEnabled = (prMaintainJson["enable"] as bool?) ?? false;
    final prMaintainValue = (prMaintainJson["value"] as num?)?.toDouble();

    DateTime? startTime;
    bool startNow = false;
    final startTimeRaw = json["startTime"];
    if (startTimeRaw == "now") {
      startNow = true;
    } else if (startTimeRaw is List) {
      startTime = DateTime(
        startTimeRaw[0] as int,
        startTimeRaw[1] as int,
        startTimeRaw[2] as int,
        startTimeRaw[3] as int,
        startTimeRaw[4] as int,
        startTimeRaw.length > 5 ? startTimeRaw[5] as int : 0,
      );
    }

    return TBATSystem(
      isPrMaintainEnabled: isPrMaintainEnabled,
      prMaintainValue: prMaintainValue,
      safeAtpress: safeAtpress,
      moId: moId,
      startTime: startTime,
      startNow: startNow,
      scheduleType: json["scheduleType"] as String?,
    );
  }

  /// For irrigation: pressure fields + startTime + scheduleType
  Map<String, dynamic> toIrrigationJson() {
    final result = <String, dynamic>{"moId": moId};
    result["prMaintain"] = {
      "enable": isPrMaintainEnabled,
      "value": prMaintainValue ?? 0,
    };
    if (safeAtpress != null) result["safeAtpress"] = safeAtpress;
    if (scheduleType != null) result["scheduleType"] = scheduleType;
    if (startNow) {
      result["startTime"] = "now";
    } else if (startTime != null) {
      result["startTime"] = [
        startTime!.year,
        startTime!.month,
        startTime!.day,
        startTime!.hour,
        startTime!.minute,
        0,
      ];
    }
    return result;
  }

  /// For aquaculture: produces {"moId": x, "startTime": "now" or [y,m,d,h,m,0]}
  Map<String, dynamic> toAquacultureJson() {
    final result = <String, dynamic>{"moId": moId};
    if (startNow) {
      result["startTime"] = "now";
    } else if (startTime != null) {
      result["startTime"] = [
        startTime!.year,
        startTime!.month,
        startTime!.day,
        startTime!.hour,
        startTime!.minute,
        0,
      ];
    }
    return result;
  }

  /// Full JSON with all fields (used by jsonEncode in the service layer)
  Map<String, dynamic> toJson() {
    var results = <String, dynamic>{};
    results["moId"] = moId;
    results["prMaintain"] = {
      "enable": isPrMaintainEnabled,
      "value": prMaintainValue ?? 0,
    };
    if (safeAtpress != null) results["safeAtpress"] = safeAtpress;
    if (scheduleType != null) results["scheduleType"] = scheduleType;
    if (startNow) {
      results["startTime"] = "now";
    } else if (startTime != null) {
      results["startTime"] = [
        startTime!.year,
        startTime!.month,
        startTime!.day,
        startTime!.hour,
        startTime!.minute,
        0,
      ];
    }
    return results;
  }
}
