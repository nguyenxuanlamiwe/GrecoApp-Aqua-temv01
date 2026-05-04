import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:collection/collection.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/router/router.dart';
import 'package:zen8app/widgets/widgets.dart';
import 'package:zen8app/app/pages/iot/tb_list_auto_mode/tb_auto_mode_list_vm.dart';

@RoutePage()
class TBAutoModeListPage extends StatefulWidget {
  final TBControlSystem system;
  const TBAutoModeListPage({
    Key? key,
    required this.system,
  }) : super(key: key);

  @override
  State<TBAutoModeListPage> createState() => _TBAutoModeListPageState();
}

class _TBAutoModeListPageState extends State<TBAutoModeListPage> {
  final _vm = TBAutoModeListVM();
  final _rxBag = CompositeSubscription();

  var _modes = <TBATMode>[];

  bool get _isAquaculture => widget.system.appType == "aquaculture";

  @override
  void initState() {
    super.initState();
    _bindViewModel();
  }

  @override
  void dispose() {
    super.dispose();
    _rxBag.dispose();
    _vm.dispose();
  }

  void _bindViewModel() {
    _vm.output.modes.listen((modes) {
      setState(() {
        _modes = modes;
      });
    }).addTo(_rxBag);

    _reloadData();
  }

  void _reloadData() {
    _vm.input.reload.add(widget.system.deviceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách chế độ tự động")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: _isAquaculture ? _showModeTypeDialog : () => _viewModeDetail(mode: _generateNewATMode()),
      ),
      body: LoadingWidget(
        error: _vm.errorTracker.asAppError(),
        isLoading: _vm.activityTracker.isRunningAny(),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemBuilder: (context, index) => _cellWidget(_modes[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemCount: _modes.length,
        ),
      ),
    );
  }

  Widget _cellWidget(TBATMode mode) {
    return Dismissible(
      key: ValueKey(mode),
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
          _modes.remove(mode);
          _vm.input.delete.add((mode.moId, widget.system.deviceId));
        });
      },
      child: ListTile(
        title: Text("${mode.moId} | ${mode.name}"),
        trailing: const Icon(Icons.chevron_right),
        tileColor: AppTheme.$F3F3F3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () => _viewModeDetail(mode: mode),
      ),
    );
  }

  Future<void> _viewModeDetail({
    required TBATMode mode,
  }) async {
    final shouldReload = await context.router.push<bool>(
      TBAutoModeRoute(
        mode: mode,
        system: widget.system,
      ),
    );

    if (shouldReload ?? false) {
      _reloadData();
    }
  }

  TBATMode _generateNewATMode({String? modeType}) {
    var allIds = {for (var mode in _modes) mode.moId};
    var newId = allIds.isEmpty ? 1 : allIds.max + 1;
    return TBATMode(
      moId: newId,
      name: '',
      modeType: modeType,
      steps: [],
      lotList: [],
    );
  }

  Future<void> _showModeTypeDialog() async {
    final type = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(
          "Chọn loại chế độ",
          style: AppTheme.textStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, TBModeType.timer),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Text(
                    "Chạy theo thời gian",
                    style: AppTheme.textStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, TBModeType.dissolvedOxygen),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.water_drop, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Text(
                    "Kiểm soát DO",
                    style: AppTheme.textStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (type != null) {
      _viewModeDetail(mode: _generateNewATMode(modeType: type));
    }
  }
}
