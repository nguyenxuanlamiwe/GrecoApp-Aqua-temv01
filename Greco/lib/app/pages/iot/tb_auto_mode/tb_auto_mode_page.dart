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
  }

  void _bindViewModel() {
    _nameTextController.addListener(() {
      _editingMode.name = _nameTextController.text;
    });

    _vm.output.updateSuccess.listen((_) {
      context.router.pop(true);
    }).addTo(_rxBag);
  }

  @override
  Widget build(BuildContext context) {
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
