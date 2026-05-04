// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'package:zen8app/app/pages/iot/tb_weather_forecast/tb_weather_forecast_vm.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/widgets/widgets.dart';

enum _ItemType {
  wind,
  humidity,
  rainSum;

  String get name => switch (this) {
        _ItemType.wind => "Gió",
        _ItemType.humidity => "Độ ẩm",
        _ItemType.rainSum => "Lượng mưa",
      };

  String get iconPath => switch (this) {
        _ItemType.wind => "images/ic_wind.png",
        _ItemType.rainSum => "images/ic_rain.png",
        _ItemType.humidity => "images/ic_precipitation.png",
      };
}

class TBWeatherForecastPage extends StatefulWidget {
  final TBControlSystem system;
  const TBWeatherForecastPage({
    super.key,
    required this.system,
  });

  @override
  State<TBWeatherForecastPage> createState() => _TBWeatherForecastPageState();
}

class _TBWeatherForecastPageState extends State<TBWeatherForecastPage> {
  final _vm = TBWeatherForecastVM();
  final _rxBag = CompositeSubscription();

  List<TBWeather> _weatherItems = [];
  var _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _vm.output.response.listen((weatherForNext10Days) {
      setState(() {
        _weatherItems = weatherForNext10Days;
        var today = DateTime.now();
        _selectedIndex = 0;
        for (var i = 0; i < _weatherItems.length; i++) {
          if (_weatherItems[i].date.difference(today).inDays.abs() <=
              _weatherItems[_selectedIndex]
                  .date
                  .difference(today)
                  .inDays
                  .abs()) {
            _selectedIndex = i;
          }
        }
      });
    }).addTo(_rxBag);

    _reload();
  }

  @override
  void dispose() {
    _vm.dispose();
    _rxBag.dispose();
    super.dispose();
  }

  void _reload() {
    _vm.input.reload.add(widget.system.deviceId);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      isLoading: _vm.activityTracker.isRunningAny(),
      error: _vm.errorTracker.asAppError(),
      child: Scaffold(
        backgroundColor: AppTheme.$F5F5F5,
        body: SafeArea(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (_weatherItems.isNotEmpty)
              _weatherExpandedItemWidget(_weatherItems[_selectedIndex]),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(top: 8),
                itemCount: _weatherItems.length,
                itemBuilder: (context, index) =>
                    _weatherCollapseItem(_weatherItems[index], index),
                separatorBuilder: (context, index) => const SizedBox(height: 8),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _weatherExpandedItemWidget(TBWeather weather) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultNetworkImage(
                  imageUrl: weather.iconPath,
                  width: 126,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.date
                                  .difference(DateTime(DateTime.now().year,
                                      DateTime.now().month, DateTime.now().day))
                                  .inDays ==
                              1
                          ? "Ngày mai"
                          : "${weather.date.ex.weekdayString}, ${weather.date.ex.asString(DatePattern.ddMM)}",
                      style: AppTheme.textStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      "${weather.maxTemperature}${weather.temperatureUnit}",
                      style: AppTheme.textStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      weather.weatherDescription,
                      style: AppTheme.textStyle(
                        color: AppTheme.$A3A3A3,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  ],
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: _weatherDetailInfoItem(_ItemType.wind, weather)),
                const SizedBox(width: 8),
                Expanded(
                    child: _weatherDetailInfoItem(_ItemType.humidity, weather)),
                const SizedBox(width: 8),
                Expanded(
                    child: _weatherDetailInfoItem(_ItemType.rainSum, weather)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _weatherDetailInfoItem(_ItemType type, TBWeather weather) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: AppTheme.$F6F6F6,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Image.asset(type.iconPath,
                width: 28, height: 28, color: AppTheme.$3A3A3A),
            const SizedBox(height: 2),
            Text(
              switch (type) {
                _ItemType.wind =>
                  "${weather.windSpeed.toStringAsFixed(1)}${weather.windSpeedUnit}",
                _ItemType.rainSum =>
                  "${weather.rainSum.toStringAsFixed(1)}${weather.rainSumUnit} (${weather.precipitation}${weather.precipitationUnit})",
                _ItemType.humidity =>
                  "${weather.humidity.toStringAsFixed(1)}${weather.humidityUnit}",
              },
              style: AppTheme.textStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              type.name,
              style: AppTheme.textStyle(
                color: AppTheme.$A3A3A3,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weatherCollapseItem(TBWeather weather, int index) {
    bool isSelected = _selectedIndex == index;
    return Material(
      color: isSelected ? AppTheme.primaryColor : Colors.white,
      child: InkWell(
        onTap: () {
          if (_selectedIndex != index) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                child: Text(
                  weather.date.ex.asString(DatePattern.ddMM),
                  style: AppTheme.textStyle(
                    color: isSelected ? Colors.white : AppTheme.$666666,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              DefaultNetworkImage(
                imageUrl: weather.iconPath,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 12),
              Text(
                "${weather.minTemperature}°",
                style: AppTheme.textStyle(
                  color: isSelected ? Colors.white : AppTheme.$3A3A3A,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                width: 55,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: const LinearGradient(
                    colors: [AppTheme.$FF9900, AppTheme.$F8D416],
                    begin: Alignment(1.00, 0.00),
                    end: Alignment(-1, 0),
                  ),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
              Text(
                "${weather.maxTemperature}°",
                style: AppTheme.textStyle(
                  color: isSelected ? Colors.white : AppTheme.$3A3A3A,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  weather.weatherDescription,
                  textAlign: TextAlign.end,
                  style: AppTheme.textStyle(
                    color: isSelected ? Colors.white : AppTheme.$A3A3A3,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
