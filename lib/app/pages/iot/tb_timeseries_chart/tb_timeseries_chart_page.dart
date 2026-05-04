import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';

import 'package:zen8app/core/core.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/widgets/widgets.dart';
import 'package:zen8app/utils/utils.dart';

import 'tb_timeseries_chart_vm.dart';

class TBTimeseriesChartPage extends StatefulWidget {
  final TBControlSystem system;
  final TBComponent component;
  const TBTimeseriesChartPage({
    super.key,
    required this.system,
    required this.component,
  });

  @override
  State<TBTimeseriesChartPage> createState() => _TBTimeseriesChartPageState();
}

enum _Period {
  six,
  twelve,
  twentyFour,
  fortyEight,
  seventyTwo,
  custom;

  @override
  String toString() => switch (this) {
        _Period.custom => 'Khác',
        _ => '${durationInHour()}h',
      };

  int durationInHour() => switch (this) {
        _Period.six => 6,
        _Period.twelve => 12,
        _Period.twentyFour => 24,
        _Period.fortyEight => 48,
        _Period.seventyTwo => 72,
        _Period.custom => 0,
      };
}

enum _Interval {
  none,
  oneHour,
  sixHour,
  oneDay,
  oneMonth;

  @override
  String toString() => switch (this) {
        _Interval.none => 'Ốp',
        _Interval.oneHour => '1 giờ',
        _Interval.sixHour => '6 giờ',
        _Interval.oneDay => '1 ngày',
        _Interval.oneMonth => '1 tháng',
      };

  int? get milliseconds => switch (this) {
        _Interval.none => null,
        _Interval.oneHour => const Duration(hours: 1).inMilliseconds,
        _Interval.sixHour => const Duration(hours: 6).inMilliseconds,
        _Interval.oneDay => const Duration(days: 1).inMilliseconds,
        _Interval.oneMonth => const Duration(days: 30).inMilliseconds,
      };
}

enum _Aggregation {
  none,
  avg,
  max,
  min,
  sum,
  count;

  @override
  String toString() => switch (this) {
        _Aggregation.none => 'Thống kê',
        _Aggregation.avg => 'Trung bình',
        _Aggregation.max => 'Lớn nhất',
        _Aggregation.min => 'Nhỏ nhất',
        _Aggregation.sum => 'Tổng',
        _Aggregation.count => 'Đếm',
      };

  String get aggregationFunction => switch (this) {
        _Aggregation.none => 'NONE',
        _Aggregation.avg => 'AVG',
        _Aggregation.max => 'MAX',
        _Aggregation.min => 'MIN',
        _Aggregation.sum => 'SUM',
        _Aggregation.count => 'COUNT',
      };
}

class _TBTimeseriesChartPageState extends State<TBTimeseriesChartPage>
    with SingleTickerProviderStateMixin {
  final _periods = [
    _Period.twelve,
    _Period.twentyFour,
    _Period.fortyEight,
    _Period.seventyTwo,
    _Period.custom,
  ];

  var _currentPeriod = _Period.seventyTwo;
  var _currentInterval = _Interval.none;
  var _currentAgg = _Aggregation.none;

  var _spots = <FlSpot>[];
  var _mainValues = (
    min: 0.0,
    avg: 0.0,
    max: 0.0,
    sum: 0.0,
  );

  var _startTime = DateTime.now();
  var _endTime = DateTime.now();

  late final _timePeriodTabController = TabController(
    initialIndex: _periods.indexOf(_currentPeriod),
    length: _periods.length,
    vsync: this,
  );

  late final _vm = TBTimeseriesChartVM(widget.system);
  final _rxBag = CompositeSubscription();

  @override
  void initState() {
    super.initState();
    _updateTimeWindow();
    _bindViewModel();
  }

  @override
  void dispose() {
    _timePeriodTabController.dispose();
    _rxBag.dispose();
    _vm.dispose();
    super.dispose();
  }

  _updateTimeWindow() {
    if (_currentPeriod != _Period.custom) {
      _endTime = DateTime.now();
      _startTime =
          _endTime.add(Duration(hours: -_currentPeriod.durationInHour()));
    }
  }

  _bindViewModel() {
    _vm.output.values.listen((values) {
      setState(() {
        _spots = [for (var e in values) FlSpot(e.ts, double.parse(e.value))];

        if (_spots.isNotEmpty) {
          var summary = _spots.fold(
            (min: double.infinity, max: double.negativeInfinity, sum: 0.0),
            (p, e) => (
              min: min(p.min, e.y),
              max: max(p.max, e.y),
              sum: p.sum + e.y,
            ),
          );
          _mainValues = (
            min: summary.min,
            avg: summary.sum / _spots.length,
            max: summary.max,
            sum: summary.sum,
          );
        } else {
          _mainValues = (
            min: 0,
            avg: 0,
            max: 0,
            sum: 0,
          );
        }
      });
    }).addTo(_rxBag);

    _loadData();
  }

  _exportToCSV() async {
    var system = widget.system.name;
    var device = widget.component.nameDevice;
    var unit = widget.component.unit ?? "";

    var data = <List<String>>[
      [system],
      [
        '$device từ ${_startTime.ex.asString(DatePattern.ddMMyyyyHHmm)} đến ${_endTime.ex.asString(DatePattern.ddMMyyyyHHmm)}'
      ],
      ['Thời gian', 'Giá trị ($unit)'],
      for (var p in _spots)
        [
          DateTime.fromMillisecondsSinceEpoch(p.x.toInt()).toIso8601String(),
          p.y.toString(),
        ],
    ];

    var csvData = Uint8List.fromList(
        utf8.encode(const ListToCsvConverter().convert(data)));

    var xFile = XFile.fromData(
      csvData,
      mimeType: 'csv',
      name: '${system}_${device}_${DateTime.now().toIso8601String()}',
    );

    await Share.shareXFiles(
      [xFile],
      subject: '$system - $device',
    );
  }

  _changeTab(int index) {
    var newPeriod = _periods[index];
    if (_currentPeriod == newPeriod) {
      return;
    }

    setState(() {
      _currentPeriod = newPeriod;
      _currentInterval = _Interval.none;
      _currentAgg = _Aggregation.none;
      _updateTimeWindow();
    });

    _loadData();
  }

  _loadData() {
    _vm.input.reload.add((
      key: widget.component.variable,
      startTs: _startTime.millisecondsSinceEpoch,
      endTs: _endTime.millisecondsSinceEpoch,
      interval: _currentInterval.milliseconds,
      agg: _currentAgg.aggregationFunction,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _titleWidget(),
            const SizedBox(height: 8),
            _timePeriodWidget(),
            const SizedBox(height: 8),
            if (_currentPeriod == _Period.custom) ...[
              _timeWindowWidget(),
              const SizedBox(height: 8),
              _samplesConfigWidget(),
              const SizedBox(height: 8),
            ],
            SizedBox(
              height: 280,
              child: _chartWidget(),
            ),
            const SizedBox(height: 16),
            _statsWidget(),
          ],
        ),
      ),
    );
  }

  Widget _titleWidget() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Biểu đồ ${widget.component.nameDevice}",
            style: AppTheme.textStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _exportToCSV,
          icon: const Icon(Icons.share),
          label: Text(
            "Chia sẻ",
          ),
        ),
      ],
    );
  }

  Widget _timePeriodWidget() {
    return Material(
      borderRadius: BorderRadius.circular(100),
      color: const Color(0xFFF5F5F5),
      clipBehavior: Clip.hardEdge,
      child: TabBar(
        controller: _timePeriodTabController,
        indicatorSize: TabBarIndicatorSize.tab,
        padding: const EdgeInsets.all(3),
        onTap: _changeTab,
        tabs: [for (var p in _periods) Text(p.toString())],
      ),
    );
  }

  Widget _timeWindowWidget() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              var date = await showDatePicker(
                context: context,
                initialDate: _startTime,
                firstDate: DateTime(1970),
                lastDate: DateTime.now(),
              );
              if (date == null) return;

              var time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );

              if (time != null) {
                setState(() {
                  _startTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                });

                _loadData();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.$F3F3F3,
            ),
            child: Text(
              _startTime.ex.asString(DatePattern.ddMM_HHmm),
              style: AppTheme.textStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Text(
          ' - ',
          style: AppTheme.textStyle(),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              var date = await showDatePicker(
                context: context,
                initialDate: _endTime,
                firstDate: DateTime(1970),
                lastDate: DateTime.now(),
              );
              if (date == null) return;

              var time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );

              if (time != null) {
                setState(() {
                  _endTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                });

                _loadData();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.$F3F3F3,
            ),
            child: Text(
              _endTime.ex.asString(DatePattern.ddMM_HHmm),
              style: AppTheme.textStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _samplesConfigWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: _dropDownButton(
            icon: const Icon(
              Icons.history_toggle_off,
              size: 20,
            ),
            currentValue: _currentInterval,
            defaultValue: _Interval.none,
            allValues: _Interval.values,
            onChanged: (value) {
              setState(() {
                _currentInterval = value;
                _loadData();
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _dropDownButton(
            icon: const Icon(
              Icons.functions,
              size: 20,
            ),
            currentValue: _currentAgg,
            defaultValue: _Aggregation.none,
            allValues: _Aggregation.values,
            onChanged: (value) {
              setState(() {
                _currentAgg = value;
                _loadData();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _dropDownButton<T>({
    required Widget icon,
    required T currentValue,
    required T defaultValue,
    required List<T> allValues,
    required Function(T value) onChanged,
  }) {
    var items = [
      for (var e in allValues)
        DropdownMenuItem<T>(
          value: e,
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: e == currentValue ? const Color(0xFFF5F5F5) : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              e.toString(),
              style: AppTheme.textStyle(
                  fontSize: 14,
                  color:
                      e != defaultValue ? AppTheme.$3A3A3A : AppTheme.$A3A3A3),
            ),
          ),
        ),
    ];

    return Material(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(8),
      child: DropdownButton(
        value: currentValue,
        items: items,
        underline: const SizedBox.shrink(),
        isExpanded: true,
        borderRadius: BorderRadius.circular(8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        isDense: true,
        selectedItemBuilder: (context) {
          return [
            for (var e in allValues)
              Row(
                children: [
                  icon,
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(
                    e.toString(),
                    style: AppTheme.textStyle(
                        fontSize: 14,
                        color: e != defaultValue
                            ? AppTheme.$3A3A3A
                            : AppTheme.$A3A3A3),
                  ))
                ],
              )
          ];
        },
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }

  Widget _chartWidget() {
    if (_spots.length <= 10000) {
      var durationInHour = _endTime.difference(_startTime).inHours;

      var minX = _startTime.millisecondsSinceEpoch.toDouble();
      var maxX = _endTime.millisecondsSinceEpoch.toDouble();
      var xInterval = Duration(hours: max(durationInHour ~/ 4, 1))
          .inMilliseconds
          .toDouble();

      var minY = _mainValues.min;
      var maxY = minY + max(_mainValues.max - minY, 0.03);
      var yInterval = (maxY - minY) / 3;

      return LoadingWidget(
        error: _vm.errorTracker.asAppError(),
        isLoading: _vm.activityTracker.isRunningAny(),
        child: _lineChart(
          spots: _spots,
          unit: widget.component.unit ?? "",
          xInterval: xInterval,
          yInterval: yInterval,
          yTitleWidth: 45,
          minY: minY,
          maxY: maxY,
          minX: minX,
          maxX: maxX,
          yTitleBuilder: (value) => value.toStringAsFixed(2),
        ),
      );
    } else {
      return Center(
        child: Text(
          'Không thể hiện thị biểu đồ',
          style: AppTheme.textStyle(color: AppTheme.$A3A3A3),
        ),
      );
    }
  }

  Widget _statsWidget() {
    var unit = widget.component.unit ?? "";
    return Row(
      children: [
        Expanded(
          child: _singleMainValueWidget(
            title: 'Nhỏ nhất',
            color: const Color(0xFFFF9900),
            value: _mainValues.min,
            unit: unit,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _singleMainValueWidget(
            title: 'Trung bình',
            color: const Color(0xFF4AABF1),
            value: _mainValues.avg,
            unit: unit,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _singleMainValueWidget(
            title: 'Lớn nhất',
            color: const Color(0xFF1B8D42),
            value: _mainValues.max,
            unit: unit,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _singleMainValueWidget(
            title: 'Tổng',
            color: const Color.fromARGB(255, 150, 23, 95),
            value: _mainValues.sum,
            unit: unit,
          ),
        ),
      ],
    );
  }

  Widget _singleMainValueWidget({
    required String title,
    required Color color,
    required double value,
    required String unit,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: AppTheme.textStyle(
                fontSize: 12,
                color: AppTheme.$A3A3A3,
              ),
            ),
          ],
        ),
        Text(
          '${value.toStringAsFixed(2)} $unit',
          style: AppTheme.textStyle(fontSize: 12, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _lineChart({
    required List<FlSpot> spots,
    required String unit,
    double? xInterval,
    double? yInterval,
    double? minY,
    double? maxY,
    double? minX,
    double? maxX,
    String Function(double value)? yTitleBuilder,
    double yTitleWidth = 24,
  }) {
    final points = LineChartBarData(
      spots: spots,
      color: AppTheme.primaryColor,
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.25),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      dotData: const FlDotData(show: false),
    );

    final data = LineChartData(
      lineBarsData: [points],
      minY: minY,
      maxY: maxY,
      minX: minX,
      maxX: maxX,
      baselineX: maxX,
      baselineY: minY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => const FlLine(
          color: Color(0xFFCCCCCC),
          strokeWidth: 0.5,
          dashArray: [4, 4],
        ),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            interval: xInterval,
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (ts, meta) {
              var time = DateTime.fromMillisecondsSinceEpoch(ts.toInt());
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${time.ex.asString(DatePattern.HHmm)}\n${time.ex.asString(DatePattern.ddMM)}',
                  textAlign: TextAlign.center,
                  style: AppTheme.textStyle(
                    color: const Color(0xFF777777),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            interval: yInterval,
            reservedSize: yTitleWidth,
            showTitles: true,
            getTitlesWidget: (value, meta) {
              String title;
              if (yTitleBuilder != null) {
                title = yTitleBuilder(value);
              } else {
                title = value.toString();
              }

              return Text(
                title,
                textAlign: TextAlign.right,
                style: AppTheme.textStyle(
                  color: const Color(0xFF777777),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ),
      ),
      lineTouchData: const LineTouchData(enabled: false),
    );

    // return SizedBox(
    //   height: 200,
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.stretch,
    //     children: [
    //       Text(
    //         unit,
    //         style: AppTheme.textStyle(
    //           fontSize: 15,
    //           fontWeight: FontWeight.w500,
    //         ),
    //         textAlign: TextAlign.right,
    //       ),
    //       const SizedBox(height: 16),
    //       Expanded(child: LineChart(data)),
    //     ],
    //   ),
    // );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          unit,
          style: AppTheme.textStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 16),
        Expanded(child: LineChart(data)),
      ],
    );
  }
}
