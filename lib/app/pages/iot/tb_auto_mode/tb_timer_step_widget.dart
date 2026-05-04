import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/utils/utils.dart';

class TBTimerStepWidget extends StatefulWidget {
  final TBATStep step;

  const TBTimerStepWidget({
    super.key,
    required this.step,
  });

  @override
  State<TBTimerStepWidget> createState() => _TBTimerStepWidgetState();
}

class _TBTimerStepWidgetState extends State<TBTimerStepWidget> {
  late final _titleTextController =
      TextEditingController(text: widget.step.name);

  TBTimerAction get _action => widget.step.action as TBTimerAction;

  @override
  void initState() {
    super.initState();
    _titleTextController.addListener(() {
      widget.step.name = _titleTextController.text;
    });
  }

  @override
  void dispose() {
    _titleTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(8),
      color: AppTheme.$F5F5F5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: _contentView(),
            ),
            const SizedBox(width: 10),
            Image.asset(
              'images/ic_drag.png',
              width: 16,
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _contentView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _titleWidget(),
        const SizedBox(height: 8),
        _dateTimeWidget(),
      ],
    );
  }

  Widget _titleWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '${widget.step.id} | ',
              style: AppTheme.textStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.$A3A3A3,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _titleTextController,
              style: AppTheme.textStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                fillColor: Colors.white,
                hintText: 'Nhập tên hành động',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateTimeWidget() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      ),
      onPressed: _changeDateTime,
      child: Row(
        children: [
          Expanded(
            child: Text(
              _action.value.ex.asString(DatePattern.ddMMyyyyHHmm),
              style: AppTheme.textStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Image.asset(
            "images/ic_calendar_black.png",
            width: 16,
            height: 16,
          )
        ],
      ),
    );
  }

  Future<void> _changeDateTime() async {
    var newDate = await showDatePicker(
      context: context,
      initialDate: _action.value,
      firstDate: DateTime.now().add(const Duration(days: -365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (newDate == null) return;

    var newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_action.value),
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
      _action.value = newDateTime;
    });
  }
}
