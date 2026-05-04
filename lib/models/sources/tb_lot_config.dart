class TBLotConfig {
  int id;
  double? mins; // for timer mode
  double? doStart; // for DO mode
  double? doEnd; // for DO mode
  bool doEndEnabled; // enable/disable DO end threshold
  String? calcMethod; // "min", "avg", "max"
  List<int> rlc; // rlc indices from farmConfig components
  List<int> doIndices; // DO sensor indices from farmConfig components

  TBLotConfig({
    required this.id,
    this.mins,
    this.doStart,
    this.doEnd,
    this.doEndEnabled = false,
    this.calcMethod,
    this.rlc = const [],
    this.doIndices = const [],
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
      );

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{'id': id};
    if (mins != null) result['mins'] = mins;
    if (rlc.isNotEmpty) result['rlc'] = rlc;
    if (doStart != null) result['ds'] = doStart;
    if (doEndEnabled && doEnd != null) result['de'] = doEnd;
    if (doEndEnabled) result['dee'] = doEndEnabled;
    if (calcMethod != null) result['calc'] = calcMethod;
    if (doIndices.isNotEmpty) result['do'] = doIndices;
    return result;
  }

  bool validateTimer() => mins != null && mins! > 0 && rlc.isNotEmpty;

  bool validateDO() =>
      doStart != null && calcMethod != null && doIndices.isNotEmpty && rlc.isNotEmpty;
}
