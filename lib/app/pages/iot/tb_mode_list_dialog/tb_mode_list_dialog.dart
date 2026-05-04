import 'package:flutter/material.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/router/router.dart';
import 'package:zen8app/models/models.dart';

class TBModeListDialog extends StatefulWidget {
  final List<TBATMode> modes;
  final TBATMode? currentMode;
  final ScrollController? scrollController;
  const TBModeListDialog({
    Key? key,
    required this.modes,
    this.currentMode,
    this.scrollController,
  }) : super(key: key);

  @override
  State<TBModeListDialog> createState() => _TBModeListDialogState();
}

class _TBModeListDialogState extends State<TBModeListDialog> {
  TBATMode? _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.currentMode;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        controller: widget.scrollController,
        itemCount: widget.modes.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return _modeCellWidget(widget.modes[index]);
        });
  }

  Widget _modeCellWidget(TBATMode mode) {
    bool isSelected = mode.moId == _selectedMode?.moId;
    return ListTile(
      title: Text(
        mode.name,
        style: AppTheme.textStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.$3A3A3A,
          fontWeight: FontWeight.w500,
        ),
      ),
      tileColor: isSelected ? const Color(0xFFEBF6F5) : AppTheme.$F5F5F5,
      trailing: isSelected
          ? Image.asset(
              "images/ic_check.png",
              width: 16,
              height: 16,
            )
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        if (!isSelected) {
          setState(() {
            _selectedMode = mode;
          });
          context.router.pop(mode);
        }
      },
    );
  }
}
