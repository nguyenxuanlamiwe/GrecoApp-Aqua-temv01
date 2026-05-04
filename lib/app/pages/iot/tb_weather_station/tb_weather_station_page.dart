import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zen8app/app/pages/iot/tb_weather_station/tb_weather_station_vm.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/router/router.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/widgets/widgets.dart';

import 'package:zen8app/app/pages/iot/tb_timeseries_chart/tb_timeseries_chart_page.dart';

class TBWeatherStationPage extends StatefulWidget {
  final TBControlSystem system;
  const TBWeatherStationPage({
    Key? key,
    required this.system,
  }) : super(key: key);

  @override
  State<TBWeatherStationPage> createState() => _TBWeatherStationPageState();
}

class _TBWeatherStationPageState extends State<TBWeatherStationPage> {
  late final _vm = TBWeatherStationVM(widget.system);
  final _rxBag = CompositeSubscription();
  var _currentValues = <String, dynamic>{};
  // var _updatedTimes = <String, DateTime>{};

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
        print(_currentValues);
      });
    }).addTo(_rxBag);

    _vm.output.updatedValues.listen((values) {
      setState(() {
        var entries = values.entries;
        _currentValues.addAll({
          for (var e in entries)
            e.key: {
              "value": e.value,
              "ts": DateTime.now().millisecondsSinceEpoch,
            }
        });
        // final now = DateTime.now();
        // _updatedTimes.addAll(values.map((key, value) => MapEntry(key, now)));
      });
    }).addTo(_rxBag);

    _vm.input.reload.add(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingWidget(
        child: ListView.separated(
          itemBuilder: (context, index) =>
              _groupWidget(widget.system.hyrdromets[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemCount: widget.system.hyrdromets.length,
        ),
      ),
    );
  }

  Widget _groupWidget(TBGroup group) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // _groupHeader(group),
            // const Divider(height: 1),
            ...group.components.map((e) => _componentWidget(e)),
          ],
        ),
      ),
    );
  }

  Widget _groupHeader(TBGroup group) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        group.name,
        style: AppTheme.textStyle(
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
      ),
    );
  }

  Widget _componentWidget(TBComponent component) {
    var resultStr = _getComponentValue(component);
    if (component.unit != null) {
      resultStr += " ${component.unit}";
    }

    var iconName = component.iconName();

    return ListTile(
      minLeadingWidth: 18,
      horizontalTitleGap: 8,
      leading: iconName != null
          ? Image.asset(
              iconName,
              width: 18,
              height: 18,
            )
          : null,
      onTap: () => _showTimeseriesValues(component),
      title: Text(
        component.nameDevice,
        style: AppTheme.textStyle(),
      ),
      subtitle: Text(
        _getUpdatedTime(component),
        style: AppTheme.textStyle(color: AppTheme.$A3A3A3, fontSize: 11),
      ),
      trailing: Text(
        resultStr,
        style: AppTheme.textStyle(),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  String _getComponentValue(TBComponent component) {
    Map<String, dynamic> map = _currentValues[component.variable] ?? {};
    final value = map["value"];
    if (value == null) {
      return "--";
    }
    return value.toString();
  }

  String _getUpdatedTime(TBComponent component) {
    Map<String, dynamic> map = _currentValues[component.variable] ?? {};
    final timestamp = map["ts"] as int?;
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
