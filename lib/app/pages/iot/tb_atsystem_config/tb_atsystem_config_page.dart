import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zen8app/app/pages/iot/tb_atsystem_config/tb_atsystem_config_vm.dart';
import 'package:zen8app/app/pages/iot/tb_mode_list_dialog/tb_mode_list_dialog.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/widgets/widgets.dart';
import 'package:zen8app/router/router.dart';
import 'package:intl/intl.dart';

@RoutePage<bool>()
class TBATSystemConfigPage extends StatefulWidget {
  final TBATSystem? atSystem;
  final TBControlSystem controlSystem;
  const TBATSystemConfigPage({
    Key? key,
    required this.atSystem,
    required this.controlSystem,
  }) : super(key: key);

  @override
  State<TBATSystemConfigPage> createState() => _TBATSystemConfigPageState();
}

class _TBATSystemConfigPageState extends State<TBATSystemConfigPage> {
  final _vm = TBATSystemConfigVM();
  final _rxBag = CompositeSubscription();

  final _prMaintainTextController = TextEditingController();
  final _safeAtpressTextController = TextEditingController();

  var _currentATSys = TBATSystem.empty();

  var _modesMap = <int, TBATMode>{};
  var _allModes = <TBATMode>[];

  bool get _isAquaculture => widget.controlSystem.appType == "aquaculture";
  bool get _isIrrigation => widget.controlSystem.appType == "irrigation";
  var _startNow = false;
  String? _scheduleType; // irrigation only

  @override
  void initState() {
    super.initState();
    _setupInitialData();
    _bindViewModel();
  }

  @override
  void dispose() {
    super.dispose();
    _vm.dispose();
    _rxBag.dispose();
    _prMaintainTextController.dispose();
    _safeAtpressTextController.dispose();
  }

  void _setupInitialData() {
    if (widget.atSystem != null) {
      _currentATSys = widget.atSystem!.copy();
    }
    _startNow = _currentATSys.startNow;
    _scheduleType = _currentATSys.scheduleType ?? 'onetime';
    _prMaintainTextController.text =
        (_currentATSys.prMaintainValue ?? 0).toString();

    _safeAtpressTextController.text =
        (_currentATSys.safeAtpress ?? 0).toString();
  }

  void _bindViewModel() {
    _vm.output.atModes.listen(_updateModes).addTo(_rxBag);
    _vm.output.submitSuccess.listen((_) {
      context.router.pop(true);
    }).addTo(_rxBag);

    _reloadData();
  }

  void _reloadData() {
    _vm.input.reload.add(widget.controlSystem.deviceId);
  }

  void _updateModes(List<TBATMode> modes) {
    setState(() {
      _allModes = modes;
      var newMap = <int, TBATMode>{};
      for (var mode in modes) {
        newMap[mode.moId] = mode;
      }
      _modesMap = newMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cấu hình tự động")),
      backgroundColor: AppTheme.$F5F5F5,
      body: LoadingWidget(
        error: _vm.errorTracker.asAppError(),
        isLoading: _vm.activityTracker.isRunningAny(),
        child: ListView(
          children: [
            if (_isAquaculture)
              _startTimeWidget()
            else if (_isIrrigation) ...[
              _prMaintainWidget(),
              const SizedBox(height: 8),
              _startTimeWidget(),
              const SizedBox(height: 8),
              _scheduleTypeWidget(),
            ] else
              _prMaintainWidget(),
            const SizedBox(height: 8),
            _autoModeSelectionWidget(),
            const SizedBox(height: 24),
            _saveButton(),
            const SizedBox(height: 16),
            _cancelButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _prMaintainWidget() {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _textFieldListTileWidget(
              title: "Áp suất tối thiểu:",
              hintText: "Áp suất",
              controller: _prMaintainTextController,
              suffixText: "(bar)",
              padding: const EdgeInsets.only(left: 0, right: 16),
              leading: Checkbox(
                value: _currentATSys.isPrMaintainEnabled,
                onChanged: (isEnabled) {
                  setState(() {
                    _currentATSys.isPrMaintainEnabled = isEnabled ?? false;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            _textFieldListTileWidget(
              title: "Áp suất tối đa:",
              hintText: "Áp suất",
              controller: _safeAtpressTextController,
              suffixText: "(bar)",
            ),
          ],
        ),
      ),
    );
  }
  Widget _startTimeWidget() {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final displayText = _startNow
        ? "Ngay bây giờ"
        : _currentATSys.startTime != null
            ? dateFormat.format(_currentATSys.startTime!)
            : "Chọn thời gian";

    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Thời gian bắt đầu chế độ tự động:",
              style: AppTheme.textStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _startNow ? null : _pickStartTime,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.$F3F3F3,
                      padding: const EdgeInsets.all(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayText,
                            style: AppTheme.textStyle(
                              fontSize: 16,
                              color: (_startNow || _currentATSys.startTime != null)
                                  ? AppTheme.$3A3A3A
                                  : AppTheme.$A3A3A3,
                            ),
                          ),
                        ),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _startNow,
                  onChanged: (value) {
                    setState(() {
                      _startNow = value ?? false;
                      if (_startNow) {
                        _currentATSys.startTime = DateTime.now();
                      }
                    });
                  },
                ),
                Text(
                  "Ngay bây giờ",
                  style: AppTheme.textStyle(fontSize: 15),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _scheduleTypeWidget() {
    const options = [
      ('onetime', 'Một lần'),
      ('daily', 'Hàng ngày'),
      ('weekly', 'Hàng tuần'),
      ('monthly', 'Hàng tháng'),
    ];
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Chu kỳ lặp lại:",
              style: AppTheme.textStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (value, label) in options)
                  ChoiceChip(
                    label: Text(label),
                    selected: _scheduleType == value,
                    onSelected: (_) => setState(() => _scheduleType = value),
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    labelStyle: AppTheme.textStyle(
                      fontSize: 14,
                      color: _scheduleType == value
                          ? AppTheme.primaryColor
                          : AppTheme.$A3A3A3,
                      fontWeight: _scheduleType == value
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStartTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _currentATSys.startTime ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_currentATSys.startTime ?? now),
    );
    if (time == null) return;

    setState(() {
      _currentATSys.startTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
        0,
      );
    });
  }
  Widget _autoModeSelectionWidget() {
    return Material(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(
              "Chế độ chăm sóc",
              textAlign: TextAlign.left,
              style: AppTheme.textStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: IconButton(
              icon: Image.asset(
                "images/ic_pen_green.png",
                width: 24,
                height: 24,
              ),
              onPressed: _showAutoModeList,
            ),
          ),
          _atModeSelectionWidget(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _atModeSelectionWidget() {
    var selectedModeName = _modesMap[_currentATSys.moId]?.name;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        clipBehavior: Clip.hardEdge,
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(
              color: AppTheme.$E1E1E1,
            )),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Chế độ áp dụng:",
                style: AppTheme.textStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _changeMode(_modesMap[_currentATSys.moId], (selectedMode) {
                    setState(() {
                      _currentATSys.moId = selectedMode.moId;
                    });
                  });
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.$F3F3F3,
                    padding: const EdgeInsets.all(16)),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedModeName ?? "Chọn chế độ",
                        style: AppTheme.textStyle(
                          fontSize: 16,
                          color: selectedModeName != null
                              ? AppTheme.$3A3A3A
                              : AppTheme.$A3A3A3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Image.asset(
                      "images/ic_arrow_down_16.png",
                      width: 16,
                      height: 16,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textFieldListTileWidget({
    required String title,
    String? hintText,
    TextEditingController? controller,
    String? suffixText,
    Widget? leading,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16),
    TextInputType keyboardType = const TextInputType.numberWithOptions(
      signed: false,
      decimal: true,
    ),
  }) {
    return ListTile(
      contentPadding: padding,
      leading: leading,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppTheme.$E1E1E1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      title: Text(
        title,
        style: AppTheme.textStyle(),
      ),
      trailing: SizedBox(
        width: 140,
        child: TextField(
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
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        ),
      ),
    );
  }

  Future<void> _showAutoModeList() async {
    await context.router
        .push(TBAutoModeListRoute(system: widget.controlSystem));
    _reloadData();
  }

  Future<void> _changeMode(
    TBATMode? currentMode,
    Function(TBATMode selectedMode) callback,
  ) async {
    final selectedMode = await showModalBottomScrollableSheet<TBATMode>(
      context: context,
      bodyBuilder: (context, scrollController) => TBModeListDialog(
        modes: _allModes,
        scrollController: scrollController,
        currentMode: currentMode,
      ),
      headerBuilder: (context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          "Chọn chế độ",
          style: AppTheme.textStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    if (selectedMode != null && selectedMode.moId != currentMode?.moId) {
      callback(selectedMode);
    }
  }

  Widget _saveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: _currentATSys.moId != null ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        child: Text(
          "Lưu",
          style: AppTheme.textStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _cancelButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        child: Text(
          "Hủy",
          style: AppTheme.textStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onPressed: _cancel,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.$E8E8E8,
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_isAquaculture) {
      _currentATSys.startNow = _startNow;
      if (!_startNow) {
        // startTime already set by _pickStartTime
      }
    } else if (_isIrrigation) {
      _currentATSys.prMaintainValue =
          double.tryParse(_prMaintainTextController.text);
      _currentATSys.safeAtpress =
          double.tryParse(_safeAtpressTextController.text);
      _currentATSys.startNow = _startNow;
      _currentATSys.scheduleType = _scheduleType;
    } else {
      _currentATSys.prMaintainValue =
          double.tryParse(_prMaintainTextController.text);
      _currentATSys.safeAtpress =
          double.tryParse(_safeAtpressTextController.text);
    }
    _vm.input.submit.add((_currentATSys, widget.controlSystem.deviceId));
  }

  void _cancel() {
    context.router.pop();
  }
}
