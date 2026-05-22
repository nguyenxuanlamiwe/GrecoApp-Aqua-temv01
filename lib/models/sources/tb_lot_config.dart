class TBLotConfig {
  int id;
  double? mins; // for timer mode
  double? doStart; // for DO mode (aquaculture)
  double? doEnd; // for DO mode (aquaculture)
  bool doEndEnabled; // enable/disable DO end threshold
  String? calcMethod; // "min", "avg", "max"
  List<int> rlc; // rlc indices from farmConfig components
  List<int> doIndices; // DO sensor indices (aquaculture)
  // irrigation soil-moisture mode
  double? smStart; // sm threshold to START watering (tưới khi sm <= smStart)
  double? smEnd;   // sm threshold to STOP watering  (dừng khi sm >= smEnd)
  bool smEndEnabled;
  List<int> smIndices; // sm sensor indices from farmConfig components
  int? iriAutoIndex; // tIriAuto index from farmConfig components (irrigation timer)

  TBLotConfig({
    required this.id,
    this.mins,
    this.doStart,
    this.doEnd,
    this.doEndEnabled = false,
    this.calcMethod,
    this.rlc = const [],
    this.doIndices = const [],
    this.smStart,
    this.smEnd,
    this.smEndEnabled = false,
    this.smIndices = const [],
    this.iriAutoIndex,
  });

  TBLotConfig copy() => TBLotConfig(
        id: id,
        mins: mins,
        doStart: doStart,
        doEnd: doEnd,
        doEndEnabled: doEndEnabled,
        calcMethod: calcMethod,
        rlc: [...rlc],
        doIndices: [...doIndices],
        smStart: smStart,
        smEnd: smEnd,
        smEndEnabled: smEndEnabled,
        smIndices: [...smIndices],
        iriAutoIndex: iriAutoIndex,
      );

  factory TBLotConfig.fromJson(Map<String, dynamic> json) => TBLotConfig(
        id: json['id'] as int,
        mins: (json['mins'] as num?)?.toDouble(),
        doStart: (json['ds'] as num?)?.toDouble(),
        doEnd: (json['de'] as num?)?.toDouble(),
        doEndEnabled: (json['dee'] as bool?) ?? false,
        calcMethod: json['calc'] as String?,
        rlc: (json['rlc'] as List?)?.map((e) => (e as num).toInt()).toList() ?? [],
        doIndices: (json['do'] as List?)?.map((e) => (e as num).toInt()).toList() ?? [],
        smStart: (json['sms'] as num?)?.toDouble(),
        smEnd: (json['sme'] as num?)?.toDouble(),
        smEndEnabled: (json['smee'] as bool?) ?? false,
        smIndices: (json['sm'] as List?)?.map((e) => (e as num).toInt()).toList() ?? [],
        iriAutoIndex: (json['ia'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{'id': id};
    if (mins != null) result['mins'] = mins;
    if (rlc.isNotEmpty) result['rlc'] = rlc;
    // DO fields
    if (doStart != null) result['ds'] = doStart;
    if (doEndEnabled && doEnd != null) result['de'] = doEnd;
    if (doEndEnabled) result['dee'] = doEndEnabled;
    if (calcMethod != null) result['calc'] = calcMethod;
    if (doIndices.isNotEmpty) result['do'] = doIndices;
    // SM fields
    if (smStart != null) result['sms'] = smStart;
    if (smEndEnabled && smEnd != null) result['sme'] = smEnd;
    if (smEndEnabled) result['smee'] = smEndEnabled;
    if (smIndices.isNotEmpty) result['sm'] = smIndices;
    if (iriAutoIndex != null) result['ia'] = iriAutoIndex;
    return result;
  }

  bool validateTimer() => mins != null && mins! > 0;

  bool validateDO() =>
      doStart != null && calcMethod != null && doIndices.isNotEmpty && rlc.isNotEmpty;

  bool validateSM() =>
      smStart != null && calcMethod != null && smIndices.isNotEmpty;
}
