import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/router/router.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/app/pages/iot/tb_auto_control/tb_auto_control_vm.dart';
import 'package:zen8app/widgets/widgets.dart';
import 'package:group_list_view/group_list_view.dart';

class TBAutoControlPage extends StatefulWidget {
  final TBControlSystem system;
  const TBAutoControlPage({
    Key? key,
    required this.system,
  }) : super(key: key);

  @override
  State<TBAutoControlPage> createState() => _TBAutoControlPageState();
}

class _TBAutoControlPageState extends State<TBAutoControlPage> {
  late final _vm = TBAutoControlVM(widget.system);
  final _rxBag = CompositeSubscription();

  TBATSystem? _currentATSys;
  var _modesMap = <int, TBATMode>{};
  late final _componentsMap = {
    for (var c
        in widget.system.booleanComponents + widget.system.floatComponents)
      c.variable: c
  };
  late final _lotsMap = {
    for (var g in widget.system.groups.where((g) => g.type == TBGroupType.lot))
      g.id: g
  };

  bool get _isAquaculture => widget.system.appType == "aquaculture";

  var _currentValues = <String, dynamic>{};
  var _autoLots = <int, Map<String, dynamic>>{}; // id -> {st}

  @override
  void initState() {
    super.initState();
    _bindViewModel();
  }

  @override
  void dispose() {
    super.dispose();
    _vm.dispose();
    _rxBag.dispose();
  }

  void _bindViewModel() {
    _vm.output.currentATSys.listen((sys) {
      setState(() {
        _currentATSys = sys;
      });
    }).addTo(_rxBag);

    _vm.output.atModes.listen(
      (modes) {
        setState(() {
          _modesMap = {for (var e in modes) e.moId: e};
        });
      },
    ).addTo(_rxBag);

    _vm.output.reloadedValues.listen((values) {
      setState(() {
        _currentValues = values;
        _syncAutoLots(values);
      });
    }).addTo(_rxBag);

    _vm.output.updatedValues.listen((updatedValues) {
      setState(() {
        var entries = updatedValues.entries;
        _currentValues.addAll({
          for (var e in entries)
            e.key: {
              "value": e.value,
              "lastUpdateTs": DateTime.now().millisecondsSinceEpoch,
            }
        });
        _syncAutoLots(updatedValues);
      });
    }).addTo(_rxBag);

    _reloadData();
  }

  void _reloadData() {
    _vm.input.reload.add(null);
  }

  void _syncAutoLots(Map<String, dynamic> values) {
    if (values.containsKey("autoLots")) {
      _parseAutoLotsData(values["autoLots"]);
      return;
    }

    final autoEnable = values["autoEnable"];
    final autoEnableValue =
        autoEnable is Map<String, dynamic> ? autoEnable["value"] : autoEnable;
    if (autoEnableValue == false) {
      _autoLots = {};
    }
  }

  /// Parses raw autoLots value (List or {value: List}) into _autoLots.
  void _parseAutoLotsData(dynamic raw) {
    List? list;
    if (raw is Map && raw["value"] is List) {
      list = raw["value"] as List;
    } else if (raw is List) {
      list = raw;
    }
    if (list != null) {
      _autoLots = {
        for (var item in list)
          if (item is Map)
            if (_asInt(item["id"]) != null)
              _asInt(item["id"])!: Map<String, dynamic>.from(item as Map)
      };
    }
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  bool get _isAnyLotRunning =>
      _autoLots.values.any((lot) => lot["st"] == "on");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.$F5F5F5,
      body: SafeArea(
        child: LoadingWidget(
            error: _vm.errorTracker.asAppError(),
            isLoading: _vm.activityTracker.isRunningAny(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _listWidget(),
                ),
                if (_currentATSys != null) _controlWidget(),
              ],
            )),
      ),
    );
  }

  Widget _listWidget() {
    var atMode = _modesMap[_currentATSys?.moId];
    if (_isAquaculture && atMode != null && atMode.isAquacultureMode) {
      return _aquacultureListWidget(atMode);
    }
    var steps = atMode?.steps ?? [];
    var isAutoEnable = _getBooleanComponentValue("autoEnable");
    var auActProId = _currentValues["auActProId"]?["value"] as int?;
    return GroupListView(
      itemBuilder: (context, indexPath) =>
          _stepWidget(steps[indexPath.index], auActProId, isAutoEnable),
      sectionsCount: 1,
      groupHeaderBuilder: (context, section) => _groupHeaderWidget(),
      countOfItemInSection: (section) => steps.length,
      separatorBuilder: (context, index) => const Divider(),
    );
  }

  Widget _groupHeaderWidget() {
    var atMode = _modesMap[_currentATSys?.moId];
    var isAutoRunning = _getBooleanComponentValue("autoEnable");
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Cấu hình tự động",
                    style: AppTheme.textStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: isAutoRunning ? Colors.grey : AppTheme.primaryColor,
                  ),
                  splashRadius: 24,
                  onPressed: isAutoRunning ? null : _configATSystem,
                ),
              ],
            ),
          ),
          if (_isAquaculture) ...[
            if (_currentATSys?.startTime != null)
              _doubleTextWidget(
                'Thời gian bắt đầu:',
                _currentATSys!.startTime!.ex
                    .asString(DatePattern.ddMMyyyyHHmm),
              ),
          ] else ...[
            if ((_currentATSys?.isPrMaintainEnabled ?? false) &&
                (_currentATSys?.prMaintainValue != null))
              _doubleTextWidget('Áp suất tối thiểu:',
                  "${_currentATSys?.prMaintainValue ?? 0}(bar)"),
            const Divider(),
            if (_currentATSys?.safeAtpress != null)
              _doubleTextWidget(
                  'Áp suất tối đa:',
                  "${_currentATSys?.safeAtpress ?? 0}(bar)"),
          ],
          if (atMode != null)
            _doubleTextWidget('Chế độ chăm sóc:', atMode.name),
          Container(color: const Color(0xFFF5F5F5), height: 8),
          if (atMode != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Theo dõi tự động",
                style: AppTheme.textStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
            const Divider(),
          ],
        ],
      ),
    );
  }

  Widget _doubleTextWidget(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTheme.textStyle(fontSize: 15),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            textAlign: TextAlign.right,
            style: AppTheme.textStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepWidget(TBATStep step, int? auActProId, bool isAutoEnable) {
    var isRunning = step.id == auActProId && isAutoEnable;

    return ListTile(
      tileColor: isRunning ? const Color(0xFFEDF4F0) : Colors.white,
      minVerticalPadding: 0,
      horizontalTitleGap: 8,
      minLeadingWidth: 16,
      dense: true,
      leading: isRunning
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primaryColor,
              ),
            )
          : null,
      title: Text(
        step.name,
        style: AppTheme.textStyle(
          fontSize: 14,
          color: isRunning ? AppTheme.primaryColor : const Color(0xFF666666),
        ),
      ),
      subtitle: switch (step.action) {
        TBAssignBooleanAction(variable: var variable) => Text(
            _getUpdatedTime(variable),
            style: AppTheme.textStyle(
              fontSize: 12,
              color: isRunning ? AppTheme.primaryColor : AppTheme.$A3A3A3,
            ),
          ),
        _ => null,
      },
      trailing: Text(
        _stepDescription(step),
        textAlign: TextAlign.right,
        style: AppTheme.textStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: isRunning ? AppTheme.primaryColor : AppTheme.$3A3A3A,
        ),
      ),
    );
  }

  Widget _controlWidget() {
    var isAutoEnable = _getBooleanComponentValue("autoEnable");
    var isAutoPauseEnable = _getBooleanComponentValue("autoPauseEnable");

    return Material(
      color: AppTheme.$F5F5F5,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  final newValue = !isAutoEnable;
                  // Optimistic update: change UI immediately
                  setState(() {
                    _currentValues["autoEnable"] = {"value": newValue};
                  });
                  // Send one-way RPC in background
                  _vm.input.autoEnable.add(newValue);
                },
                icon: Icon(
                  isAutoEnable ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  isAutoEnable ? "Huỷ" : "Chạy",
                  style: AppTheme.textStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isAutoEnable
                    ? () {
                        final newValue = !isAutoPauseEnable;
                        // Optimistic update: change UI immediately
                        setState(() {
                          _currentValues["autoPauseEnable"] = {"value": newValue};
                        });
                        // Send one-way RPC in background
                        _vm.input.autoPauseEnable.add(newValue);
                      }
                    : null,
                icon: Icon(
                  isAutoPauseEnable
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  isAutoPauseEnable ? "Tiếp tục" : "Tạm dừng",
                  style: AppTheme.textStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== AQUACULTURE MONITORING ====================

  Widget _aquacultureListWidget(TBATMode atMode) {
    return ListView(
      children: [
        _groupHeaderWidget(),
        for (var lotConfig in atMode.lotList) ...[
          if (atMode.modeType == TBModeType.timer)
            _timerLotMonitorWidget(lotConfig)
          else
            _doLotMonitorWidget(lotConfig),
          const Divider(height: 1),
        ],
      ],
    );
  }

  Widget _timerLotMonitorWidget(TBLotConfig lotConfig) {
    final lot = _lotsMap[lotConfig.id];
    final lotName = lot?.name ?? "Lot ${lotConfig.id}";
    final autoLot = _autoLots[lotConfig.id];
    final autoEnable = _getBooleanComponentValue("autoEnable");
    final isRunning = autoEnable && autoLot != null && autoLot["st"] == "on";
    final ran = (autoLot?["ran"] as num?)?.toDouble();
    final total = (autoLot?["total"] as num?)?.toDouble() ?? lotConfig.mins?.toDouble();

    String timeText;
    if (ran != null && total != null) {
      timeText = "${ran.toStringAsFixed(1)} / ${total.toStringAsFixed(1)} phút";
    } else if (ran != null) {
      timeText = "${ran.toStringAsFixed(1)} phút";
    } else {
      timeText = "${lotConfig.mins ?? 0} phút";
    }

    return ListTile(
      tileColor: isRunning ? const Color(0xFFEDF4F0) : Colors.white,
      minLeadingWidth: 16,
      leading: isRunning
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primaryColor,
              ),
            )
          : null,
      title: Text(
        lotName,
        style: AppTheme.textStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isRunning ? AppTheme.primaryColor : null,
        ),
      ),
      trailing: Text(
        timeText,
        style: AppTheme.textStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _doLotMonitorWidget(TBLotConfig lotConfig) {
    final lot = _lotsMap[lotConfig.id];
    final lotName = lot?.name ?? "Lot ${lotConfig.id}";
    final autoLot = _autoLots[lotConfig.id];
    final autoEnable = _getBooleanComponentValue("autoEnable");
    final isRunning = autoEnable && autoLot != null && autoLot["st"] == "on";

    // Use min/avg/max from server autoLots data
    final serverMin = (autoLot?["min"] as num?)?.toDouble();
    final serverAvg = (autoLot?["avg"] as num?)?.toDouble();
    final serverMax = (autoLot?["max"] as num?)?.toDouble();

    String statsText;
    if (serverMin != null && serverAvg != null && serverMax != null) {
      statsText =
          "${serverMin.toStringAsFixed(1)} | ${serverAvg.toStringAsFixed(1)} | ${serverMax.toStringAsFixed(1)}";
    } else {
      statsText = "-- | -- | --";
    }

    return ListTile(
      tileColor: isRunning ? const Color(0xFFEDF4F0) : Colors.white,
      minLeadingWidth: 16,
      leading: isRunning
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primaryColor,
              ),
            )
          : null,
      title: Text(
        lotName,
        style: AppTheme.textStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isRunning ? AppTheme.primaryColor : null,
        ),
      ),
      subtitle: Text(
        "DO bắt: ${lotConfig.doStart ?? '--'} → kết: ${lotConfig.doEnd ?? '--'} (${lotConfig.calcMethod ?? '--'})",
        style: AppTheme.textStyle(
          fontSize: 12,
          color: isRunning ? AppTheme.primaryColor : AppTheme.$A3A3A3,
        ),
      ),
      trailing: Text(
        "min|TB|max\n$statsText",
        textAlign: TextAlign.right,
        style: AppTheme.textStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  // ==================== STEP MODE (IRRIGATION) ====================

  String _stepDescription(TBATStep step) {
    switch (step.action) {
      case TBAssignBooleanAction(variable: var variable, value: var value):
        // var component = _componentsMap[variable];
        var currentValue = _getBooleanComponentValue(variable) ? 'BẬT' : 'TẮT';
        var targetValue = value ? 'BẬT' : 'TẮT';
        return '[$currentValue] / $targetValue';
      // return '${component?.nameDevice ?? ''} đã $value';
      case TBAssignFloatAction(value: var value, variable: var variable):
        var component = _componentsMap[variable];
        var currentValue = _getStringComponentValue(variable);
        return '[$currentValue] = $value (${component?.unit ?? ''})';
      // return '${component?.nameDevice ?? ''} = $value';
      case TBCompareAction(
          value: var value,
          operator: var operator,
          variable: var variable
        ):
        var component = _componentsMap[variable];
        var currentValue = _getStringComponentValue(variable);
        return '[$currentValue] $operator $value (${component?.unit ?? ''})';
      // return '${component?.nameDevice ?? ''} $operator $value';
      case TBTimerAction(value: var value):
        return value.ex.asString(DatePattern.ddMMyyyyHHmm);
    }
  }

  Future<void> _configATSystem() async {
    final shouldReload = await context.router.push<bool>(TBATSystemConfigRoute(
        atSystem: _currentATSys, controlSystem: widget.system));
    if (shouldReload ?? false) {
      _reloadData();
    }
  }

  String _getStringComponentValue(String? variable) {
    Map<String, dynamic> map = _currentValues[variable] ?? {};
    final value = map["value"];
    if (value == null) {
      return "--";
    }
    return value.toString();
  }

  bool _getBooleanComponentValue(String? variable) {
    Map<String, dynamic> map = _currentValues[variable] ?? {};
    final value = map["value"];
    if (value is bool) {
      return value;
    }
    return false;
  }

  String _getUpdatedTime(String? variable) {
    Map<String, dynamic> map = _currentValues[variable] ?? {};
    final timestamp = map["lastUpdateTs"] as int?;
    if (timestamp == null) {
      return "--";
    }

    return DateTime.fromMillisecondsSinceEpoch(timestamp)
        .ex
        .asString("yyyy-MM-dd HH:mm:ss");
  }
}
