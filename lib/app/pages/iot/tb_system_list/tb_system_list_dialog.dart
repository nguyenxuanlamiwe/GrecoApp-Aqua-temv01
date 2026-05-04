import 'package:flutter/material.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/router/router.dart';
import 'package:zen8app/models/models.dart';

class TBSystemListDialog extends StatefulWidget {
  final List<TBControlSystem> systems;
  final TBControlSystem? selectedSystem;
  final ScrollController? scrollController;
  const TBSystemListDialog({
    Key? key,
    required this.systems,
    this.selectedSystem,
    this.scrollController,
  }) : super(key: key);

  @override
  State<TBSystemListDialog> createState() => _TBSystemListDialogState();
}

class _TBSystemListDialogState extends State<TBSystemListDialog> {
  TBControlSystem? _selectedSystem;

  @override
  void initState() {
    super.initState();
    _selectedSystem = widget.selectedSystem;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        controller: widget.scrollController,
        itemCount: widget.systems.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return _systemCellWidget(widget.systems[index]);
        });
  }

  Widget _systemCellWidget(TBControlSystem system) {
    bool isSelected = system.deviceId == _selectedSystem?.deviceId;
    return ListTile(
      title: Text(
        system.name,
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
            _selectedSystem = system;
          });
          context.router.pop(system);
        }
      },
    );
  }
}
