import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/widgets/widgets.dart';
import 'package:zen8app/app/pages/iot/tb_manual_control/tb_manual_control_vm.dart';
import 'package:zen8app/app/pages/iot/tb_timeseries_chart/tb_timeseries_chart_page.dart';

class TBManualControlPage extends StatefulWidget {
  final TBControlSystem system;
  const TBManualControlPage({
    Key? key,
    required this.system,
  }) : super(key: key);

  @override
  State<TBManualControlPage> createState() => _TBManualControlPageState();
}

class _TBManualControlPageState extends State<TBManualControlPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late final _vm = TBManualControlVM(widget.system);
  final _rxBag = CompositeSubscription();
  var _currentValues = <String, dynamic>{};
  late final _collapsedGroups = <int>{
    for (var g in widget.system.groups) g.id,
  };

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
    _vm.output.reloadedValues.listen((values) {
      setState(() {
        _currentValues = values;
        // final now = DateTime.now();
        // _updatedTimes = values.map((key, value) => MapEntry(key, now));
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
      });
    }).addTo(_rxBag);

    _reload();
  }

  void _reload() {
    _vm.input.reload.add(null);
  }

  bool get _isAutoRunning {
    final val = _currentValues["autoEnable"]?["value"];
    return val == true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: AppTheme.$F5F5F5,
      body: LoadingWidget(
        error: _vm.errorTracker.asAppError(),
        isLoading: _vm.activityTracker.isRunningAny(),
        child: Column(
          children: [
            if (_isAutoRunning)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: const Color(0xFFEDF4F0),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Hệ thống đang chạy tự động",
                      style: AppTheme.textStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) =>
                    _groupContainer(widget.system.groups[index]),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 8),
                itemCount: widget.system.groups.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _groupContainer(TBGroup group) {
    final isCollapsed = _collapsedGroups.contains(group.id);
    return Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _groupHeader(group, isCollapsed),
            if (!isCollapsed) ...[
              const Divider(height: 1),
              ...group.components.map((e) => _componentWidget(e)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _groupHeader(TBGroup group, bool isCollapsed) {
    return InkWell(
      onTap: () {
        setState(() {
          if (isCollapsed) {
            _collapsedGroups.remove(group.id);
          } else {
            _collapsedGroups.add(group.id);
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                group.name,
                style: AppTheme.textStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
            ),
            Icon(
              isCollapsed
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_up,
              color: AppTheme.$A3A3A3,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _componentWidget(TBComponent component) {
    bool isBoolean = component.isBooleanComponent();
    Widget trailingWidget;

    if (isBoolean) {
      trailingWidget = Switch.adaptive(
        value: _getControllableComponentValue(component),
        onChanged: (value) {
          _vm.input.toggleComponent.add((component.variable, value));
        },
      );
    } else {
      var resultStr = _getSensorComponentValue(component);
      if (component.unit != null) {
        resultStr += " ${component.unit}";
      }

      trailingWidget = Text(
        resultStr,
        style: AppTheme.textStyle(),
      );
    }

    var iconName = component.iconName();

    return ListTile(
      horizontalTitleGap: 8,
      minLeadingWidth: 18,
      leading: iconName != null
          ? Image.asset(
              iconName,
              width: 18,
              height: 18,
            )
          : null,
      title: Text(
        component.nameDevice,
        style: AppTheme.textStyle(),
      ),
      subtitle: Text(
        _getUpdatedTime(component),
        style: AppTheme.textStyle(color: AppTheme.$A3A3A3, fontSize: 11),
      ),
      trailing: trailingWidget,
      contentPadding: EdgeInsets.zero,
      onTap: isBoolean
          ? null
          : () {
              _showTimeseriesValues(component);
            },
    );
  }

  String _getSensorComponentValue(TBComponent component) {
    Map<String, dynamic> map = _currentValues[component.variable] ?? {};
    final value = map["value"];
    if (value == null) {
      return "--";
    }
    return value.toString();
  }

  bool _getControllableComponentValue(TBComponent component) {
    Map<String, dynamic> map = _currentValues[component.variable] ?? {};
    final value = map["value"];
    if (value is bool) {
      return value;
    }
    return false;
  }

  String _getUpdatedTime(TBComponent component) {
    Map<String, dynamic> map = _currentValues[component.variable] ?? {};
    final timestamp = map["lastUpdateTs"] as int?;
    if (timestamp == null) {
      return "--";
    }

    return DateTime.fromMillisecondsSinceEpoch(timestamp)
        .ex
        .asString("yyyy-MM-dd HH:mm:ss");
  }

  void _showTimeseriesValues(TBComponent component) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) => TBTimeseriesChartPage(
        component: component,
        system: widget.system,
      ),
    );
  }
}
