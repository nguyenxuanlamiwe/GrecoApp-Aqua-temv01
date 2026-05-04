class TBATSystem {
  bool isPrMaintainEnabled;
  double? prMaintainValue;
  double? safeAtpress;
  int? moId;

  TBATSystem({
    required this.isPrMaintainEnabled,
    required this.prMaintainValue,
    required this.safeAtpress,
    required this.moId,
  });

  TBATSystem.empty()
      : this(
          isPrMaintainEnabled: false,
          prMaintainValue: null,
          safeAtpress: null,
          moId: null,
        );

  TBATSystem copy() => TBATSystem(
        isPrMaintainEnabled: isPrMaintainEnabled,
        prMaintainValue: prMaintainValue,
        safeAtpress: safeAtpress,
        moId: moId,
      );

  factory TBATSystem.fromJson(Map<String, dynamic> json) {
    final moId = json["moId"] as int?;
    final safeAtpress = (json["safeAtpress"] as num?)?.toDouble();
    final prMaintainJson = (json["prMaintain"] as Map<String, dynamic>?) ?? {};
    final isPrMaintainEnabled = (prMaintainJson["enable"] as bool?) ?? false;
    final prMaintainValue = (prMaintainJson["value"] as num?)?.toDouble();

    return TBATSystem(
      isPrMaintainEnabled: isPrMaintainEnabled,
      prMaintainValue: prMaintainValue,
      safeAtpress: safeAtpress,
      moId: moId,
    );
  }

  Map<String, dynamic> toJson() {
    var results = <String, dynamic>{};
    results["moId"] = moId;
    results["safeAtpress"] = safeAtpress;
    results["prMaintain"] = <String, dynamic>{
      "enable": isPrMaintainEnabled,
      "value": prMaintainValue,
    };
    return results;
  }
}
