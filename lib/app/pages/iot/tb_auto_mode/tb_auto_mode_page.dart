import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';
import 'package:zen8app/app/pages/iot/tb_auto_mode/tb_assign_boolean_step_widget.dart';
import 'package:zen8app/app/pages/iot/tb_auto_mode/tb_assign_float_step_widget.dart';
import 'package:zen8app/app/pages/iot/tb_auto_mode/tb_auto_mode_vm.dart';
import 'package:zen8app/app/pages/iot/tb_auto_mode/tb_compare_step_widget.dart';
import 'package:zen8app/app/pages/iot/tb_auto_mode/tb_timer_step_widget.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/router/router.dart';
import 'package:zen8app/widgets/widgets.dart';

@RoutePage<bool>()
class TBAutoModePage extends StatefulWidget {
  final TBATMode mode;
  final TBControlSystem system;
  const TBAutoModePage({
    Key? key,
    required this.mode,
    required this.system,
  }) : super(key: key);

  @override
  State<TBAutoModePage> createState() => _TBAutoModePageState();
}

class _TBAutoModePageState extends State<TBAutoModePage> {
  final _vm = TBAutoModeVM();
  final _rxBag = CompositeSubscription();

  late final _nameTextController =
      TextEditingController(text: _editingMode.name);

  late final _editingMode = widget.mode.copy();

  // Aquaculture lot-based state
  late final List<TBGroup> _lots = widget.system.groups
      .where((g) => g.type == TBGroupType.lot)
      .toList();
  late final TBGroup? _station = widget.system.groups
      .where((g) => g.type == TBGroupType.station)
      .firstOrNull;
  
  late final Map<int, bool> _lotSelected = {
    for (var lot in _lots)
      lot.id: _editingMode.lotList.any((l) => l.id == lot.id),
  };
  late final Map<int, TextEditingController> _minsControllers = {
    for (var lot in _lots)
      lot.id: TextEditingController(
        text: _editingMode.lotList
                .where((l) => l.id == lot.id)
                .firstOrNull
                ?.mins
                ?.toString() ??
            '',
      ),
  };
  late final Map<int, TextEditingController> _doStartControllers = {
    for (var lot in _lots)
      lot.id: TextEditingController(
        text: _editingMode.lotList
                .where((l) => l.id == lot.id)
                .firstOrNull
                ?.doStart
                ?.toString() ??
            '',
      ),
  };
  late final Map<int, TextEditingController> _doEndControllers = {
    for (var lot in _lots)
      lot.id: TextEditingController(
        text: _editingMode.lotList
                .where((l) => l.id == lot.id)
                .firstOrNull
                ?.doEnd
                ?.toString() ??
            '',
      ),
  };
  late final Map<int, String> _calcMethods = {
    for (var lot in _lots)
      lot.id: _editingMode.lotList
              .where((l) => l.id == lot.id)
              .firstOrNull
              ?.calcMethod ??
          'avg',
  };
  late final Map<int, bool> _doEndEnabled = {
    for (var lot in _lots)
      lot.id: _editingMode.lotList
              .where((l) => l.id == lot.id)
              .firstOrNull
              ?.doEndEnabled ??
          false,
  };

  // Irrigation SM mode state
  late final Map<int, TextEditingController> _smStartControllers = {
    for (var lot in _lots)
      lot.id: TextEditingController(
        text: _editingMode.lotList
                .where((l) => l.id == lot.id)
                .firstOrNull
                ?.smStart
                ?.toString() ??
            '',
      ),
  };
  late final Map<int, TextEditingController> _smEndControllers = {
    for (var lot in _lots)
      lot.id: TextEditingController(
        text: _editingMode.lotList
                .where((l) => l.id == lot.id)
                .firstOrNull
                ?.smEnd
                ?.toString() ??
            '',
      ),
  };
  late final Map<int, bool> _smEndEnabled = {
    for (var lot in _lots)
      lot.id: _editingMode.lotList
              .where((l) => l.id == lot.id)
              .firstOrNull
              ?.smEndEnabled ??
          false,
  };

  // Station mode controls
  late bool _stationEnabled = _editingMode.stationEnabled;
  late final List<int> _stationRlcIndices = _getStationRlcIndices();
  late final Map<int, bool> _stationRlcSelected = {
    for (var index in _stationRlcIndices)
      index: _editingMode.stationRlc.contains(index),
  };

  // Irrigation timer: run mode
  late String _irrigationRunMode =
      _editingMode.runMode ?? TBRunMode.alternating;

  /// Find rlc indices (rlc0, rlc1...) from a lot's components
  List<int> _getRlcIndices(TBGroup lot) {
    return lot.components
        .where((c) => c.variable.toLowerCase().startsWith('rlc'))
        .map((c) => int.tryParse(c.variable.substring(3)))
        .where((i) => i != null)
        .cast<int>()
        .toList()
      ..sort();
  }

  /// Find DO indices (do1, do2...) from a lot's components
  List<int> _getDoIndices(TBGroup lot) {
    return lot.components
        .where((c) =>
            c.dataType == 'float' &&
            c.variable.toLowerCase().startsWith('do'))
        .map((c) => int.tryParse(c.variable.substring(2)))
        .where((i) => i != null)
        .cast<int>()
        .toList()
      ..sort();
  }

  /// Find SM (soil moisture) indices (sm1, sm2...) from a lot's components
  List<int> _getSmIndices(TBGroup lot) {
    return lot.components
        .where((c) =>
            c.dataType == 'float' &&
            c.variable.toLowerCase().startsWith('sm'))
        .map((c) => int.tryParse(c.variable.substring(2)))
        .where((i) => i != null)
        .cast<int>()
        .toList()
      ..sort();
  }

  /// Get RLC indices from station components only
  List<int> _getStationRlcIndices() {
    if (_station == null) return [];
    return _station!.components
        .where((c) => c.variable.toLowerCase().startsWith('rlc'))
        .map((c) => int.tryParse(c.variable.substring(3)))
        .where((i) => i != null)
        .cast<int>()
        .toList()
      ..sort();
  }

  /// Get all unique RLC indices from all lots
  List<int> _getAllRlcIndices() {
    final allRlc = <int>{};
    for (var lot in _lots) {
      allRlc.addAll(_getRlcIndices(lot));
    }
    return allRlc.toList()..sort();
  }

  /// Find first tIriAuto index (tIriAuto0, tIriAuto1...) from a lot's components
  int? _getIriAutoIndex(TBGroup lot) {
    final indices = lot.components
        .where((c) =>
            c.dataType == 'float' &&
            c.variable.toLowerCase().startsWith('tiriauto'))
        .map((c) => int.tryParse(c.variable.substring(8)))
        .where((i) => i != null)
        .cast<int>()
        .toList()
      ..sort();
    return indices.isNotEmpty ? indices.first : null;
  }

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
    _nameTextController.dispose();
    for (var c in _minsControllers.values) {
      c.dispose();
    }
    for (var c in _doStartControllers.values) {
      c.dispose();
    }
    for (var c in _doEndControllers.values) {
      c.dispose();
    }
    for (var c in _smStartControllers.values) {
      c.dispose();
    }
    for (var c in _smEndControllers.values) {
      c.dispose();
    }
  }

  void _bindViewModel() {
    _nameTextController.addListener(() {
      _editingMode.name = _nameTextController.text;
    });

    _vm.output.updateSuccess.listen((_) {
      context.router.pop(true);
    }).addTo(_rxBag);
  }

  bool get _isIrrigation => widget.system.appType == 'irrigation';

  @override
  Widget build(BuildContext context) {
    if (_isIrrigation) {
      return _buildIrrigationLotMode();
    }
    if (_editingMode.isAquacultureMode) {
      return _buildAquacultureMode();
    }
    return _buildStepMode();
  }

  // ==================== AQUACULTURE MODE ====================

  Widget _buildAquacultureMode() {
    final title = _editingMode.modeType == TBModeType.timer
        ? "Chế độ theo thời gian"
        : "Chế độ kiểm soát DO";

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            onPressed: _submitAquaculture,
            child: Text(
              'Lưu lại',
              style: AppTheme.textStyle(
                color: AppTheme.primaryColor,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: LoadingWidget(
        error: _vm.errorTracker.asAppError(),
        isLoading: _vm.activityTracker.isRunningAny(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            _idWidget(),
            const SizedBox(height: 16),
            if (_station != null) ...[
              _stationControlWidget(),
              const SizedBox(height: 16),
            ],
            Text(
              "Danh sách Lot",
              style: AppTheme.textStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            for (var lot in _lots) ...[
              if (_editingMode.modeType == TBModeType.timer)
                _timerLotWidget(lot)
              else
                _doLotWidget(lot),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _timerLotWidget(TBGroup lot) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.$E1E1E1),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _lotSelected[lot.id] ?? false,
            onChanged: (value) {
              setState(() {
                _lotSelected[lot.id] = value ?? false;
              });
            },
          ),
          Expanded(
            child: Text(
              lot.name,
              style: AppTheme.textStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: _inputField(
              controller: _minsControllers[lot.id]!,
              hintText: "Phút",
              suffixText: "phút",
            ),
          ),
        ],
      ),
    );
  }

  Widget _doLotWidget(TBGroup lot) {
    final doVars = _getDoIndices(lot);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.$E1E1E1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Checkbox(
                value: _lotSelected[lot.id] ?? false,
                onChanged: (value) {
                  setState(() {
                    _lotSelected[lot.id] = value ?? false;
                  });
                },
              ),
              Expanded(
                child: Text(
                  lot.name,
                  style: AppTheme.textStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (_lotSelected[lot.id] == true) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                "Biến DO: ${doVars.map((i) => 'do$i').join(', ')}",
                style: AppTheme.textStyle(
                  fontSize: 12,
                  color: AppTheme.$A3A3A3,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                "Ngưỡng DO bắt đầu:",
                style: AppTheme.textStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _inputField(
                controller: _doStartControllers[lot.id]!,
                hintText: "DO bắt đầu",
                suffixText: "mg/l",
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _doEndEnabled[lot.id] ?? false,
                  onChanged: (value) {
                    setState(() {
                      _doEndEnabled[lot.id] = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    "Ngưỡng DO kết thúc:",
                    style: AppTheme.textStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            if (_doEndEnabled[lot.id] == true)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _inputField(
                  controller: _doEndControllers[lot.id]!,
                  hintText: "DO kết thúc",
                  suffixText: "mg/l",
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 12),
                Text(
                  "Tính toán: ",
                  style: AppTheme.textStyle(fontSize: 14),
                ),
                const SizedBox(width: 8),
                _calcMethodChip(lot.id, "min", "Min"),
                const SizedBox(width: 4),
                _calcMethodChip(lot.id, "avg", "TB"),
                const SizedBox(width: 4),
                _calcMethodChip(lot.id, "max", "Max"),
              ],
            ),

          ],
        ],
      ),
    );
  }

  Widget _stationControlWidget() {
    if (_station == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.$E1E1E1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Checkbox(
                value: _stationEnabled,
                onChanged: (value) {
                  setState(() {
                    _stationEnabled = value ?? false;
                  });
                },
              ),
              Expanded(
                child: Text(
                  "Trạm: ${_station!.name}",
                  style: AppTheme.textStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (_stationEnabled && _stationRlcIndices.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                "Chọn RLC Actuators từ trạm:",
                style: AppTheme.textStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (var index in _stationRlcIndices)
                    FilterChip(
                      label: Text(
                        _station!.components
                            .where((c) => c.variable == 'rlc$index')
                            .firstOrNull
                            ?.nameDevice ?? 'rlc$index',
                      ),
                      selected: _stationRlcSelected[index] ?? false,
                      onSelected: (selected) {
                        setState(() {
                          _stationRlcSelected[index] = selected;
                        });
                      },
                      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                      labelStyle: AppTheme.textStyle(
                        fontSize: 13,
                        color: (_stationRlcSelected[index] ?? false)
                            ? AppTheme.primaryColor
                            : AppTheme.$A3A3A3,
                        fontWeight: (_stationRlcSelected[index] ?? false)
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _calcMethodChip(int lotId, String value, String label) {
    final isSelected = _calcMethods[lotId] == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _calcMethods[lotId] = value;
          });
        }
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      labelStyle: AppTheme.textStyle(
        fontSize: 13,
        color: isSelected ? AppTheme.primaryColor : AppTheme.$A3A3A3,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  void _submitAquaculture() {
    _editingMode.lotList.clear();
    for (var lot in _lots) {
      if (_lotSelected[lot.id] != true) continue;
      final rlcIndices = _getRlcIndices(lot);
      if (_editingMode.modeType == TBModeType.timer) {
        final mins = double.tryParse(_minsControllers[lot.id]!.text);
        _editingMode.lotList.add(TBLotConfig(
          id: lot.id,
          mins: mins,
          rlc: rlcIndices,
        ));
      } else {
        final doEndOn = _doEndEnabled[lot.id] ?? false;
        _editingMode.lotList.add(TBLotConfig(
          id: lot.id,
          doStart: double.tryParse(_doStartControllers[lot.id]!.text),
          doEnd: doEndOn
              ? double.tryParse(_doEndControllers[lot.id]!.text)
              : null,
          doEndEnabled: doEndOn,
          calcMethod: _calcMethods[lot.id],
          rlc: rlcIndices,
          doIndices: _getDoIndices(lot),
        ));
      }
    }
    _editingMode.stationEnabled = _stationEnabled;
    _editingMode.stationRlc.clear();
    for (var index in _stationRlcIndices) {
      if (_stationRlcSelected[index] ?? false) {
        _editingMode.stationRlc.add(index);
      }
    }
    
    if (_editingMode.validate()) {
      _vm.input.update.add((_editingMode, widget.system.deviceId));
    } else {
      _showError("Vui lòng nhập đầy đủ và chính xác thông tin");
    }
  }

  Widget _inputField({
    required TextEditingController controller,
    String? hintText,
    String? suffixText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        hintText: hintText,
        fillColor: AppTheme.$F3F3F3,
        filled: true,
        isDense: true,
        suffixText: suffixText,
        suffixStyle: AppTheme.textStyle(color: AppTheme.$A3A3A3, fontSize: 13),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  // ==================== IRRIGATION LOT MODE ====================

  Widget _buildIrrigationLotMode() {
    final title = switch (_editingMode.modeType) {
      TBModeType.timer => "Tưới theo thời gian",
      TBModeType.soilMoisture => "Kiểm soát độ ẩm đất",
      TBModeType.fertilizer => "Châm phân tự động",
      _ => "Chế độ tưới",
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            onPressed: _submitIrrigation,
            child: Text(
              'Lưu lại',
              style: AppTheme.textStyle(
                color: AppTheme.primaryColor,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: LoadingWidget(
        error: _vm.errorTracker.asAppError(),
        isLoading: _vm.activityTracker.isRunningAny(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            _idWidget(),
            const SizedBox(height: 16),
            if (_editingMode.modeType == TBModeType.timer) ...[
              _irrigationRunModeWidget(),
              const SizedBox(height: 16),
            ],
            if (_station != null) ...[
              _stationControlWidget(),
              const SizedBox(height: 16),
            ],
            Text(
              "Danh sách Lô",
              style: AppTheme.textStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            for (var lot in _lots) ...[
              if (_editingMode.modeType == TBModeType.timer)
                _timerLotWidget(lot)
              else if (_editingMode.modeType == TBModeType.soilMoisture)
                _smLotWidget(lot)
              else
                _timerLotWidget(lot), // fertilizer: dùng timer tạm, chi tiết sau
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _irrigationRunModeWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.$E1E1E1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Cách chạy các lô:",
            style: AppTheme.textStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(
                      () => _irrigationRunMode = TBRunMode.alternating),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _irrigationRunMode == TBRunMode.alternating
                          ? AppTheme.primaryColor.withOpacity(0.12)
                          : AppTheme.$F3F3F3,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _irrigationRunMode == TBRunMode.alternating
                            ? AppTheme.primaryColor
                            : AppTheme.$E1E1E1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.linear_scale,
                          size: 18,
                          color: _irrigationRunMode == TBRunMode.alternating
                              ? AppTheme.primaryColor
                              : AppTheme.$A3A3A3,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Luân phiên",
                          style: AppTheme.textStyle(
                            fontSize: 14,
                            fontWeight:
                                _irrigationRunMode == TBRunMode.alternating
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                            color: _irrigationRunMode == TBRunMode.alternating
                                ? AppTheme.primaryColor
                                : AppTheme.$A3A3A3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(
                      () => _irrigationRunMode = TBRunMode.simultaneous),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _irrigationRunMode == TBRunMode.simultaneous
                          ? AppTheme.primaryColor.withOpacity(0.12)
                          : AppTheme.$F3F3F3,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _irrigationRunMode == TBRunMode.simultaneous
                            ? AppTheme.primaryColor
                            : AppTheme.$E1E1E1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.call_split,
                          size: 18,
                          color: _irrigationRunMode == TBRunMode.simultaneous
                              ? AppTheme.primaryColor
                              : AppTheme.$A3A3A3,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Đồng thời",
                          style: AppTheme.textStyle(
                            fontSize: 14,
                            fontWeight:
                                _irrigationRunMode == TBRunMode.simultaneous
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                            color: _irrigationRunMode == TBRunMode.simultaneous
                                ? AppTheme.primaryColor
                                : AppTheme.$A3A3A3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smLotWidget(TBGroup lot) {
    final smVars = _getSmIndices(lot);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.$E1E1E1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Checkbox(
                value: _lotSelected[lot.id] ?? false,
                onChanged: (value) {
                  setState(() {
                    _lotSelected[lot.id] = value ?? false;
                  });
                },
              ),
              Expanded(
                child: Text(
                  lot.name,
                  style: AppTheme.textStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (_lotSelected[lot.id] == true) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                "Sensor ẩm: ${smVars.map((i) => 'sm$i').join(', ')}",
                style: AppTheme.textStyle(fontSize: 12, color: AppTheme.$A3A3A3),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                "Độ ẩm bắt đầu tưới (%):",
                style: AppTheme.textStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _inputField(
                controller: _smStartControllers[lot.id]!,
                hintText: "Ngưỡng bắt đầu",
                suffixText: "%",
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _smEndEnabled[lot.id] ?? false,
                  onChanged: (value) {
                    setState(() {
                      _smEndEnabled[lot.id] = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    "Ngưỡng dừng tưới (%):",
                    style: AppTheme.textStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            if (_smEndEnabled[lot.id] == true)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _inputField(
                  controller: _smEndControllers[lot.id]!,
                  hintText: "Ngưỡng dừng",
                  suffixText: "%",
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 12),
                Text("Tính toán: ", style: AppTheme.textStyle(fontSize: 14)),
                const SizedBox(width: 8),
                _calcMethodChip(lot.id, "min", "Min"),
                const SizedBox(width: 4),
                _calcMethodChip(lot.id, "avg", "TB"),
                const SizedBox(width: 4),
                _calcMethodChip(lot.id, "max", "Max"),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _submitIrrigation() {
    _editingMode.lotList.clear();
    for (var lot in _lots) {
      if (_lotSelected[lot.id] != true) continue;
      final rlcIndices = _getRlcIndices(lot);
      if (_editingMode.modeType == TBModeType.timer) {
        final mins = double.tryParse(_minsControllers[lot.id]!.text);
        _editingMode.lotList.add(TBLotConfig(
          id: lot.id,
          mins: mins,
          rlc: rlcIndices,
          iriAutoIndex: _getIriAutoIndex(lot),
        ));
      } else if (_editingMode.modeType == TBModeType.soilMoisture) {
        final smEndOn = _smEndEnabled[lot.id] ?? false;
        _editingMode.lotList.add(TBLotConfig(
          id: lot.id,
          smStart: double.tryParse(_smStartControllers[lot.id]!.text),
          smEnd: smEndOn
              ? double.tryParse(_smEndControllers[lot.id]!.text)
              : null,
          smEndEnabled: smEndOn,
          calcMethod: _calcMethods[lot.id],
          rlc: rlcIndices,
          smIndices: _getSmIndices(lot),
        ));
      } else {
        // fertilizer: chi tiết tính sau, tạm lưu timer
        final mins = double.tryParse(_minsControllers[lot.id]!.text);
        _editingMode.lotList.add(TBLotConfig(
          id: lot.id,
          mins: mins,
          rlc: rlcIndices,
        ));
      }
    }
    _editingMode.runMode = (_editingMode.modeType == TBModeType.timer)
        ? _irrigationRunMode
        : null;
    _editingMode.stationEnabled = _stationEnabled;
    _editingMode.stationRlc.clear();
    for (var index in _stationRlcIndices) {
      if (_stationRlcSelected[index] ?? false) {
        _editingMode.stationRlc.add(index);
      }
    }

    if (_editingMode.validate()) {
      _vm.input.update.add((_editingMode, widget.system.deviceId));
    } else {
      _showError("Vui lòng nhập đầy đủ và chính xác thông tin");
    }
  }

  // ==================== STEP MODE (IRRIGATION) ====================

  Widget _buildStepMode() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chế độ tự động"),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
            ),
            onPressed: _submit,
            child: Text(
              'Lưu lại',
              style: AppTheme.textStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      floatingActionButton: _floatingActionButton(),
      body: LoadingWidget(
        error: _vm.errorTracker.asAppError(),
        isLoading: _vm.activityTracker.isRunningAny(),
        child: ReorderableListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, Widget? child) {
                final double animValue =
                    Curves.easeOut.transform(animation.value);
                final double elevation = lerpDouble(0, 6, animValue)!;
                final double scale = lerpDouble(1, 1.02, animValue)!;
                return Transform.scale(
                  scale: scale,
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    shadowColor: Colors.black.withOpacity(0.5),
                    elevation: elevation,
                    child: child,
                  ),
                );
              },
              child: child,
            );
          },
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              var step = _editingMode.steps.removeAt(oldIndex);
              _editingMode.steps.insert(newIndex, step);
            });
          },
          header: _idWidget(),
          itemCount: _editingMode.steps.length,
          itemBuilder: (context, index) =>
              _stepWidget(_editingMode.steps[index]),
        ),
      ),
    );
  }

  Widget _floatingActionButton() {
    return PopupMenuButton<String>(
      itemBuilder: (context) {
        return [
          PopupMenuItem<String>(
            value: TBActionType.assignBoolean,
            child: Text(
              'Bật/Tắt',
              style: AppTheme.textStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const PopupMenuDivider(height: 1),
          PopupMenuItem<String>(
            value: TBActionType.assignFloat,
            child: Text(
              'Đặt giá trị',
              style: AppTheme.textStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const PopupMenuDivider(height: 1),
          PopupMenuItem<String>(
            value: TBActionType.compare,
            child: Text(
              'Đặt điều kiện',
              style: AppTheme.textStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const PopupMenuDivider(height: 1),
          PopupMenuItem<String>(
            value: TBActionType.timer,
            child: Text(
              'Đặt thời gian',
              style: AppTheme.textStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ];
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Colors.white,
      padding: EdgeInsets.zero,
      offset: const Offset(-60, 0),
      onSelected: _addStep,
      onOpened: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SizedBox(
        width: 56,
        height: 56,
        child: Material(
          shape: const CircleBorder(),
          shadowColor: const Color(0xFF18AF79).withOpacity(0.48),
          color: AppTheme.primaryColor,
          elevation: 6,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _idWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: AppTheme.$F3F3F3,
            ),
            child: Text(
              _editingMode.moId.toString(),
              style: AppTheme.textStyle(
                color: AppTheme.$A3A3A3,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _textFieldWidget(
              controller: _nameTextController,
              hintText: "Tên chế độ",
              keyboardType: TextInputType.name,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepWidget(TBATStep step) {
    return Dismissible(
      key: ValueKey(step),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppTheme.errorColor,
        ),
        alignment: Alignment.centerRight,
        child: const Padding(
          padding: EdgeInsets.only(right: 16),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          _editingMode.steps.remove(step);
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: switch (step.action) {
          TBAssignBooleanAction() => TBAssignBooleanStepWidget(
              step: step,
              system: widget.system,
            ),
          TBAssignFloatAction() => TBAssignFloatStepWidget(
              step: step,
              system: widget.system,
            ),
          TBCompareAction() => TBCompareStepWidget(
              step: step,
              system: widget.system,
            ),
          TBTimerAction() => TBTimerStepWidget(
              step: step,
            ),
        },
      ),
    );
  }

  void _addStep(String type) {
    var id = _generateUniqueStepId();
    switch (type) {
      case TBActionType.assignBoolean:
        _editingMode.steps.add(TBATStep(
          id: id,
          action: TBAssignBooleanAction(),
        ));
      case TBActionType.assignFloat:
        _editingMode.steps.add(TBATStep(
          id: id,
          action: TBAssignFloatAction(),
        ));
      case TBActionType.compare:
        _editingMode.steps.add(TBATStep(
          id: id,
          action: TBCompareAction(),
        ));
      case TBActionType.timer:
        _editingMode.steps.add(TBATStep(
          id: id,
          action: TBTimerAction(value: DateTime.now()),
        ));
      default:
        break;
    }
    setState(() {});
  }

  int _generateUniqueStepId() {
    var allIds = {for (var s in _editingMode.steps) s.id};
    return allIds.isEmpty ? 1 : allIds.max + 1;
  }

  void _submit() {
    if (_editingMode.validate()) {
      _vm.input.update.add((_editingMode, widget.system.deviceId));
    } else {
      _showError("Vui lòng nhập đầy đủ và chính xác thông tin");
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        Widget closeButton = TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Đóng"),
        );
        return AlertDialog(
          title: const Text("Có lỗi xảy ra"),
          content: Text(message),
          actions: [
            closeButton,
          ],
        );
      },
    );
  }

  Widget _textFieldWidget({
    String? hintText,
    TextEditingController? controller,
    String? suffixText,
    TextInputType keyboardType = TextInputType.number,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        fillColor: AppTheme.$F3F3F3,
        filled: true,
        isDense: true,
        suffixText: suffixText,
        suffixStyle: AppTheme.textStyle(color: AppTheme.$A3A3A3),
        border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
