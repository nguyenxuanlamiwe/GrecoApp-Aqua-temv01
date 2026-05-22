import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zen8app/app/pages/iot/tb_auto_control/tb_auto_control_page.dart';
import 'package:zen8app/app/pages/iot/tb_camera/tb_camera_page.dart';
import 'package:zen8app/app/pages/iot/tb_manual_control/tb_manual_control_page.dart';
import 'package:zen8app/app/pages/iot/tb_control_system/tb_control_system_vm.dart';
import 'package:zen8app/app/pages/iot/tb_suggestion/tb_suggestion_page.dart';
import 'package:zen8app/app/pages/iot/tb_system_list/tb_system_list_dialog.dart';
import 'package:zen8app/app/pages/iot/tb_weather_forecast/tb_weather_forecast_page.dart';
import 'package:zen8app/app/pages/iot/tb_weather_station/tb_weather_station_page.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/router/router.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/widgets/widgets.dart';

@RoutePage()
class TBControlSystemPage extends StatefulWidget {
  final List<TBControlSystem> systems;
  const TBControlSystemPage({
    Key? key,
    required this.systems,
  }) : super(key: key);

  @override
  State<TBControlSystemPage> createState() => _TBControlSystemPageState();
}

enum _ControlSystemTab {
  manual,
  auto,
  hyrdromets,
  forecast,
  camera,
  suggestion;
}

class _TBControlSystemPageState extends State<TBControlSystemPage> {
  final _vm = TBControlSystemVM();
  final _rxBag = CompositeSubscription();
  final _localStore = DI.resolve<LocalStore>();

  //state variables
  late var _currentSystem = widget.systems.first;
  var _enabledFeatures = <String>{}; // set of enabled optional feature keys

  // Optional features that can be toggled per-device (forecast, camera)
  static const _featureForecast = 'forecast';
  static const _featureCamera = 'camera';

  List<_ControlSystemTab> get _displayTabs {
    final isAquaculture = _currentSystem.appType == "aquaculture";
    return [
        if (_currentSystem.groups.isNotEmpty) ...[
          _ControlSystemTab.manual,
          _ControlSystemTab.auto,
        ],
        if (!isAquaculture && _currentSystem.hyrdromets.isNotEmpty)
          _ControlSystemTab.hyrdromets,
        if (_currentSystem.weatherForcast &&
            _enabledFeatures.contains(_featureForecast))
          _ControlSystemTab.forecast,
        if ((_currentSystem.hasCamera || _currentSystem.camera.isNotEmpty) &&
            _enabledFeatures.contains(_featureCamera))
          _ControlSystemTab.camera,
        if (!isAquaculture &&
            _currentSystem.groups.isNotEmpty &&
            _currentSystem.hasSuggestion)
          _ControlSystemTab.suggestion,
      ];
  }

  bool? _isRestarting;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void dispose() {
    super.dispose();
    _rxBag.dispose();
    _vm.dispose();
  }

  Future<void> _subscribe() async {
    _vm.output.restartStatus.distinct().listen((restarting) {
      setState(() {
        _isRestarting = restarting;
      });
    }).addTo(_rxBag);

    await _loadFeatures(_currentSystem.deviceId);
    await _vm.connectToMQTTBroker();
    _vm.input.selectedSystem.add(_currentSystem);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _displayTabs.length,
      child: LoadingWidget(
        error: _vm.errorTracker.asAppError(),
        isLoading: _vm.activityTracker.isRunningAny(),
        child: Scaffold(
          appBar: AppBar(
            title: _appBarTitleWidget(),
            actions: [
              _restartSystemWidget(),
            ],
          ),
          body: Column(
            children: [
              if (_displayTabs.length > 1) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    // horizontal: 16,
                    vertical: 8,
                  ),
                  child: TabBar(
                    padding: const EdgeInsets.all(3),
                    isScrollable: true,
                    tabs: [
                      for (var tab in _displayTabs)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: switch (tab) {
                            _ControlSystemTab.manual =>
                              const Text('Điều khiển'),
                            _ControlSystemTab.auto => const Text('Tự động'),
                            _ControlSystemTab.hyrdromets =>
                              Text(_currentSystem.hyrdromets.first.name),
                            _ControlSystemTab.forecast =>
                              const Text('Dự báo thời tiết'),
                            _ControlSystemTab.camera =>
                              const Text('Camera giám sát'),
                            _ControlSystemTab.suggestion =>
                              const Text('Khuyến nghị tưới'),
                          },
                        ),
                    ],
                  ),
                ),
                const Divider(),
              ],
              Expanded(
                child: TabBarView(children: [
                  for (var tab in _displayTabs)
                    switch (tab) {
                      _ControlSystemTab.manual => TBManualControlPage(
                          key: ValueKey("manual_${_currentSystem.deviceId}"),
                          system: _currentSystem),
                      _ControlSystemTab.auto => TBAutoControlPage(
                          key: ValueKey("auto_${_currentSystem.deviceId}"),
                          system: _currentSystem),
                      _ControlSystemTab.hyrdromets => TBWeatherStationPage(
                          key:
                              ValueKey("hyrdromets_${_currentSystem.deviceId}"),
                          system: _currentSystem),
                      _ControlSystemTab.forecast => TBWeatherForecastPage(
                          key: ValueKey("forecast_${_currentSystem.deviceId}"),
                          system: _currentSystem),
                      _ControlSystemTab.camera => TBCameraPage(
                          key: ValueKey("camera_${_currentSystem.deviceId}"),
                          system: _currentSystem,
                        ),
                      _ControlSystemTab.suggestion => TBSuggestionPage(
                          key:
                              ValueKey("suggestion_${_currentSystem.deviceId}"),
                          system: _currentSystem,
                        ),
                    }
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadFeatures(String deviceId) async {
    final stored = await _localStore.getValue<List<String>>(
      LocalStoreKey.systemFeatures(deviceId),
      defaultValue: null,
    );
    
    // If no stored preferences, auto-enable all available features
    if (stored == null || stored.isEmpty) {
      final autoEnabled = <String>{};
      if (_currentSystem.weatherForcast) {
        autoEnabled.add(_featureForecast);
      }
      if (_currentSystem.hasCamera || _currentSystem.camera.isNotEmpty) {
        autoEnabled.add(_featureCamera);
      }
      setState(() {
        _enabledFeatures = autoEnabled;
      });
      // Save the auto-enabled features
      if (autoEnabled.isNotEmpty) {
        await _saveFeatures();
      }
    } else {
      setState(() {
        _enabledFeatures = stored.toSet();
      });
    }
  }

  Future<void> _saveFeatures() async {
    await _localStore.setValue(
      LocalStoreKey.systemFeatures(_currentSystem.deviceId),
      _enabledFeatures.toList(),
    );
  }

  Future<void> _showFeaturesDialog() async {
    final isAquaculture = _currentSystem.appType == 'aquaculture';
    // build list of available optional features for this system
    final available = <(String, String)>[
      if (_currentSystem.weatherForcast) (_featureForecast, 'Dự báo thời tiết'),
      if (_currentSystem.hasCamera || _currentSystem.camera.isNotEmpty)
        (_featureCamera, 'Camera giám sát'),
    ];

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có tính năng tuỳ chọn')),
      );
      return;
    }

    // working copy
    final working = {..._enabledFeatures};
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          title: Text(
            'Tính năng',
            style: AppTheme.textStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (key, label) in available)
                CheckboxListTile(
                  value: working.contains(key),
                  activeColor: AppTheme.primaryColor,
                  title: Text(label, style: AppTheme.textStyle(fontSize: 15)),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (checked) {
                    setLocal(() {
                      if (checked == true) {
                        working.add(key);
                      } else {
                        working.remove(key);
                      }
                    });
                  },
                ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEDF4F0),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              child: Text('Huỷ',
                  style: AppTheme.textStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              child: Text('Xong',
                  style: AppTheme.textStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    ).then((confirmed) async {
      if (confirmed == true) {
        setState(() => _enabledFeatures = working);
        await _saveFeatures();
      }
    });
  }

  Widget? _appBarTitleWidget() {
    return widget.systems.length > 1
        ? _multipleSystemTitleWidget(_currentSystem)
        : _singleSystemTitleWidget(_currentSystem);
  }

  Widget _multipleSystemTitleWidget(TBControlSystem selectedSystem) {
    return ElevatedButton(
      onPressed: _changeSystem,
      style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.$F3F3F3,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              selectedSystem.name,
              textAlign: TextAlign.center,
              style: AppTheme.textStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Image.asset(
            "images/ic_arrow_down_16.png",
            width: 16,
            height: 16,
          ),
        ],
      ),
    );
  }

  Widget _singleSystemTitleWidget(TBControlSystem selectedSystem) {
    return SizedBox(
      width: double.maxFinite,
      child: Text(
        selectedSystem.name,
        style: AppTheme.textStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _restartSystemWidget() {
    if (_isRestarting == null) {
      return const IconButton(
        onPressed: null,
        icon: Icon(Icons.restart_alt_rounded),
      );
    }

    if (_isRestarting == true) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Icon(
          Icons.history,
          color: Colors.grey,
        ),
      );
    }

    return IconButton(
      onPressed: _confirmRestartSytem,
      icon: const Icon(Icons.restart_alt_rounded),
      color: Colors.red,
    );
  }

  void _confirmRestartSytem() {
    showDialog(
      context: context,
      builder: (context) {
        Widget yesButton = ElevatedButton(
          onPressed: () {
            _vm.input.restartSystem.add(_currentSystem.deviceId);
            context.router.pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 10,
            ),
          ),
          child: Text(
            "Đồng ý",
            style: AppTheme.textStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
        Widget noButton = ElevatedButton(
          onPressed: () {
            context.router.pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEDF4F0),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 10,
            ),
          ),
          child: Text(
            "Huỷ",
            style: AppTheme.textStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        );
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          title: Text(
            'Khởi động lại hệ thống',
            style: AppTheme.textStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            "Bạn có muốn khởi động lại hệ thống?",
            style: AppTheme.textStyle(
              fontSize: 16,
              color: AppTheme.$A3A3A3,
            ),
          ),
          actions: [
            noButton,
            yesButton,
          ],
        );
      },
    );
  }

  Future<void> _changeSystem() async {
    final selectedSystem =
        await showModalBottomScrollableSheet<TBControlSystem>(
      context: context,
      bodyBuilder: (context, scrollController) => TBSystemListDialog(
        systems: widget.systems,
        scrollController: scrollController,
        selectedSystem: _currentSystem,
      ),
      headerBuilder: (context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          "Chọn hệ thống",
          style: AppTheme.textStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    if (selectedSystem != null &&
        _currentSystem.deviceId != selectedSystem.deviceId) {
      setState(() {
        _currentSystem = selectedSystem;
        _isRestarting = null;
      });
      await _loadFeatures(selectedSystem.deviceId);
      _vm.input.selectedSystem.add(selectedSystem);
    }
  }
}
