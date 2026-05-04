import 'package:flutter/material.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/models/models.dart';
import 'package:collection/collection.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/widgets/widgets.dart';

class TBAssignFloatStepWidget extends StatefulWidget {
  final TBATStep step;
  final TBControlSystem system;
  const TBAssignFloatStepWidget(
      {super.key, required this.step, required this.system});

  @override
  State<TBAssignFloatStepWidget> createState() =>
      _TBAssignFloatStepWidgetState();
}

class _TBAssignFloatStepWidgetState extends State<TBAssignFloatStepWidget> {
  late final _titleTextController =
      TextEditingController(text: widget.step.name);

  late final _valueTextController =
      TextEditingController(text: _action.value?.toString() ?? '');

  TBAssignFloatAction get _action => widget.step.action as TBAssignFloatAction;

  late var _selectedComponent = widget.system.floatComponents
      .firstWhereOrNull((e) => e.variable == _action.variable);

  @override
  void initState() {
    super.initState();

    _titleTextController.addListener(() {
      widget.step.name = _titleTextController.text;
    });

    _valueTextController.addListener(() {
      _action.value = double.tryParse(_valueTextController.text);
    });
  }

  @override
  void dispose() {
    _titleTextController.dispose();
    _valueTextController.dispose();
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
        _assignWidget(),
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

  Widget _assignWidget() {
    return Row(
      children: [
        Expanded(child: _variableWidget()),
        const SizedBox(width: 8),
        _valueWidget(),
      ],
    );
  }

  Widget _variableWidget() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      ),
      onPressed: _selectVariable,
      child: Row(
        children: [
          Expanded(
            child: Text(
              _selectedComponent?.nameDevice ?? "Biến điều khiển",
              style: AppTheme.textStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _selectedComponent != null
                    ? AppTheme.$3A3A3A
                    : AppTheme.$A3A3A3,
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

  Widget _valueWidget() {
    return SizedBox(
      width: 70,
      child: TextField(
        controller: _valueTextController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: AppTheme.textStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: const InputDecoration(
          fillColor: Colors.white,
          hintText: '0.0',
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        ),
      ),
    );
  }

  Future<void> _selectVariable() async {
    final result = await showModalBottomScrollableSheet<Set<TBComponent>>(
      context: context,
      initialChildSize: 0.9,
      bodyBuilder: (context, scrollController) {
        return BottomSheetPickerPage<TBComponent>(
          title: 'Biến điều khiển',
          loader: PassthroughListLoader(widget.system.floatComponents),
          selectedElements: {
            if (_selectedComponent != null) _selectedComponent!
          },
          controller: scrollController,
        );
      },
    );

    if (_selectedComponent != result?.firstOrNull) {
      setState(() {
        _selectedComponent = result?.firstOrNull;
        _action.variable = _selectedComponent?.variable;
      });
    }
  }
}
