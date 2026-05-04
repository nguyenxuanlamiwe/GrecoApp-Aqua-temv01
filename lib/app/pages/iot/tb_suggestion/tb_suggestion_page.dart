import 'package:flutter/material.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/widgets/widgets.dart';

class TBSuggestionPage extends StatefulWidget {
  final TBControlSystem system;
  const TBSuggestionPage({
    super.key,
    required this.system,
  });

  @override
  State<TBSuggestionPage> createState() => _TBSuggestionPageState();
}

enum _Monitor {
  full,
  rain,
  none;

  @override
  String toString() => switch (this) {
        _Monitor.full => 'Đầy đủ',
        _Monitor.rain => 'Mưa',
        _Monitor.none => 'Không có',
      };

  double? width() => switch (this) {
        _Monitor.full => 110,
        _Monitor.rain => 90,
        _Monitor.none => null,
      };
}

class _TBSuggestionPageState extends State<TBSuggestionPage> {
  late final _areaTextController = TextEditingController();
  late final _valveCountTextController = TextEditingController();
  late final _powerTextController = TextEditingController();
  late final _humidityTextController = TextEditingController();
  late final _allCrops = [for (var e in widget.system.crop) e.name];
  late final _stagesMap = {
    for (var e in widget.system.crop) e.name: e.cropStage
  };

  String? _currentCrop;
  double? _currentArea;
  String? _currentGrowStage;
  String? _currentSoil;
  int? _currentValveCount;
  int? _currentPower;
  var _currentMonitor = _Monitor.full;
  var _forecastEnabled = true;
  DateTime? _preIrriTime;
  double? _preIrriSoilMoist;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _areaTextController.dispose();
    _valveCountTextController.dispose();
    _powerTextController.dispose();
    _humidityTextController.dispose();
  }

  _selectCrop() async {
    var newCrop = await _showBottomSheetPicker(
      title: 'Loại cây trồng',
      currentValue: _currentCrop,
      allValues: _allCrops,
    );

    if (newCrop != null && newCrop != _currentCrop) {
      setState(() {
        _currentCrop = newCrop;
      });
    }
  }

  _selectGrowStage() async {
    var newStage = await _showBottomSheetPicker(
      title: 'Thời kỳ sinh trưởng',
      currentValue: _currentGrowStage,
      allValues: _stagesMap[_currentCrop] ?? [],
    );

    if (newStage != null && newStage != _currentGrowStage) {
      setState(() {
        _currentGrowStage = newStage;
      });
    }
  }

  _selectSoil() async {
    var newSoil = await _showBottomSheetPicker(
      title: 'Loại đất trồng',
      currentValue: _currentSoil,
      allValues: widget.system.soil,
    );

    if (newSoil != null && newSoil != _currentSoil) {
      setState(() {
        _currentSoil = newSoil;
      });
    }
  }

  _selectIrriTime() async {
    var newDate = await showDatePicker(
      context: context,
      initialDate: _preIrriTime ?? DateTime.now(),
      firstDate: DateTime.now().add(const Duration(days: -365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (newDate == null) return;

    var newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_preIrriTime ?? DateTime.now()),
    );

    if (newTime == null) return;

    var newDateTime = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      newTime.hour,
      newTime.minute,
      0,
    );

    setState(() {
      _preIrriTime = newDateTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.$F5F5F5,
      body: ListView(
        children: [
          _inputSectionWidget(),
          const SizedBox(height: 8),
          _suggestionWidget(),
          const SizedBox(height: 32),
          _applyButton(),
        ],
      ),
    );
  }

  Widget _inputSectionWidget() {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _groupWidget(
              title: 'Loại cây trồng',
              contentWidget: _dropdownButton(
                title: _currentCrop,
                hintText: 'Chọn cây trồng',
                callback: _selectCrop,
              ),
            ),
            const SizedBox(height: 16),
            _groupWidget(
              title: 'Diện tích vườn',
              contentWidget: _textFieldWidget(
                controller: _areaTextController,
                hintText: 'Nhập diện tích',
                suffixText: 'ha',
              ),
            ),
            const SizedBox(height: 16),
            _groupWidget(
              title: 'Thời kỳ sinh trưởng',
              contentWidget: _dropdownButton(
                title: _currentGrowStage,
                hintText: 'Chọn thời kỳ',
                callback: _currentCrop != null ? _selectGrowStage : null,
              ),
            ),
            const SizedBox(height: 16),
            _groupWidget(
              title: 'Loại đất trồng',
              contentWidget: _dropdownButton(
                title: _currentSoil,
                hintText: 'Chọn loại đất',
                callback: _selectSoil,
              ),
            ),
            const SizedBox(height: 16),
            _groupWidget(
              title: 'Hệ thống tưới',
              contentWidget: _textFieldWidget(
                controller: _valveCountTextController,
                hintText: 'Số lượng vòi',
                suffixText: 'vòi',
              ),
            ),
            const SizedBox(height: 16),
            _groupWidget(
              title: 'Công suất',
              contentWidget: _textFieldWidget(
                controller: _powerTextController,
                hintText: 'Công suất',
                suffixText: 'l/phút',
              ),
            ),
            const SizedBox(height: 16),
            _groupWidget(
              title: 'Khí tượng',
              contentWidget: _meteoWidget(),
            ),
            _groupWidget(
              title: 'Thời điểm tưới lần trước',
              contentWidget: _dropdownButton(
                title: _preIrriTime?.ex.asString(DatePattern.ddMMyyyyHHmm),
                hintText: 'Chọn thời gian',
                callback: _selectIrriTime,
              ),
            ),
            const SizedBox(height: 16),
            _groupWidget(
              title: 'Độ ẩm tưới lần trước',
              contentWidget: _textFieldWidget(
                controller: _humidityTextController,
                hintText: 'Nhập độ ẩm',
                suffixText: '%',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestionWidget() {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _suggestionHeaderWidget(),
            const SizedBox(height: 16),
            _groupWidget(
              title: 'Thời gian tưới',
              contentWidget: _resultFieldWidget(
                contentText: '2500',
                suffixText: 'phút',
              ),
            ),
            const SizedBox(height: 16),
            _groupWidget(
              title: 'Lượng nước',
              contentWidget: _resultFieldWidget(
                contentText: '4000',
                suffixText: 'lít',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _groupWidget({required String title, required Widget contentWidget}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: AppTheme.textStyle(
            fontSize: 14,
            color: const Color(0xFF797979),
          ),
        ),
        const SizedBox(height: 4),
        contentWidget,
      ],
    );
  }

  Widget _dropdownButton(
      {String? title, required String hintText, VoidCallback? callback}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.$F5F5F5,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      onPressed: callback,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title ?? hintText,
              style: AppTheme.textStyle(
                fontSize: 16,
                color: title != null ? AppTheme.$3A3A3A : AppTheme.$A3A3A3,
              ),
            ),
          ),
          Image.asset(
            "images/ic_arrow_down_16.png",
            width: 16,
            height: 16,
          )
        ],
      ),
    );
  }

  Widget _textFieldWidget({
    required TextEditingController controller,
    String? hintText,
    String? suffixText,
    TextInputType keyboardType =
        const TextInputType.numberWithOptions(decimal: true),
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTheme.textStyle(
        fontSize: 16,
      ),
      decoration: InputDecoration(
        fillColor: AppTheme.$F5F5F5,
        hintText: hintText,
        suffixText: suffixText,
        suffixStyle: AppTheme.textStyle(
          fontSize: 14,
          color: AppTheme.$A3A3A3,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _resultFieldWidget({
    required String contentText,
    required String suffixText,
  }) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: AppTheme.$F5F5F5),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              contentText,
              style: AppTheme.textStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            suffixText,
            style: AppTheme.textStyle(
              fontSize: 14,
              color: AppTheme.$A3A3A3,
            ),
          )
        ],
      ),
    );
  }

  Widget _meteoWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var e in _Monitor.values)
              _radioWidget(
                title: e.toString(),
                value: e,
                groupValue: _currentMonitor,
                width: e.width(),
                onChanged: (newValue) {
                  if (newValue != null && _currentMonitor != newValue) {
                    setState(() {
                      _currentMonitor = newValue;
                    });
                  }
                },
              ),
          ],
        ),
        Row(
          children: [
            for (var value in [true, false])
              _radioWidget(
                title: value ? 'Dự báo' : 'không dự báo',
                value: value,
                groupValue: _forecastEnabled,
                width: value ? _Monitor.full.width() : null,
                onChanged: (newValue) {
                  if (newValue != null && _forecastEnabled != newValue) {
                    setState(() {
                      _forecastEnabled = newValue;
                    });
                  }
                },
              ),
          ],
        )
      ],
    );
  }

  Widget _radioWidget<T>(
      {required String title,
      required T value,
      required T groupValue,
      required double? width,
      Function(T?)? onChanged}) {
    var listTile = RadioListTile(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: AppTheme.textStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
    return width != null
        ? SizedBox(
            width: width,
            child: listTile,
          )
        : Expanded(child: listTile);
  }

  Widget _suggestionHeaderWidget() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Khuyến nghị tưới',
            style: AppTheme.textStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(
            Icons.show_chart_rounded,
            color: AppTheme.primaryColor,
          ),
          style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          label: Text(
            'Xem biểu đồ',
            style: AppTheme.textStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Future<T?> _showBottomSheetPicker<T>({
    required String title,
    required List<T> allValues,
    T? currentValue,
  }) async {
    final result = await showModalBottomScrollableSheet<Set<T>>(
      context: context,
      bodyBuilder: (context, scrollController) {
        return BottomSheetPickerPage<T>(
          title: title,
          loader: PassthroughListLoader(allValues),
          selectedElements: {if (currentValue != null) currentValue},
          controller: scrollController,
        );
      },
    );
    return result?.firstOrNull;
  }

  Widget _applyButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        child: Text(
          'Áp dụng',
          style: AppTheme.textStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
