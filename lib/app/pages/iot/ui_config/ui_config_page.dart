import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zen8app/api/api.dart';
import 'package:zen8app/app/pages/iot/ui_config/ui_config_vm.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/widgets/widgets.dart';
import 'package:zen8app/router/router.dart';

// ── Editable data classes ────────────────────────────────────────────────────

class _EditableComponent {
  final variableCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final unitCtrl = TextEditingController();
  String componentType; // 'sensor' | 'actuator'
  int icon;
  bool isExpanded;

  static const _iconLabels = {
    1: 'Độ ẩm không khí',
    2: 'Mưa',
    3: 'Áp suất',
    4: 'Bức xạ',
    5: 'Hướng gió',
    6: 'Độ dẫn',
    7: 'Độ ẩm đất',
    8: 'Nhiệt độ',
    9: 'Tốc độ gió',
    10: 'Bơm',
    11: 'Van tưới',
    12: 'Thời gian',
    13: 'Bốc thoát hơi',
    14: 'DO (Oxy hòa tan)',
    15: 'Lưu lượng',
    16: 'SAT (Độ bão hòa)',
    17: 'pH',
    18: 'Quạt',
    19: 'Máy thổi',
  };

  static List<DropdownMenuItem<int>> get iconItems => _iconLabels.entries
      .map((e) => DropdownMenuItem(
            value: e.key,
            child: Text('${e.key} – ${e.value}',
                style: const TextStyle(fontSize: 13)),
          ))
      .toList();

  _EditableComponent({this.componentType = 'sensor', this.icon = 8, this.isExpanded = false}) {
    nameCtrl.text = 'Thiết bị mới';
  }

  factory _EditableComponent.fromComponent(TBComponent c) {
    const validTypes = {'sensor', 'actuator'};
    final type =
        validTypes.contains(c.type) ? c.type! : 'sensor';
    final iconVal = c.icon ?? 8;
    final icon = _iconLabels.containsKey(iconVal) ? iconVal : 8;
    final ec = _EditableComponent(componentType: type, icon: icon);
    ec.variableCtrl.text = c.variable;
    ec.nameCtrl.text = c.nameDevice;
    ec.unitCtrl.text = c.unit ?? '';
    return ec;
  }

  TBComponent toComponent() => TBComponent(
        variable: variableCtrl.text.trim(),
        nameDevice: nameCtrl.text.trim(),
        type: componentType,
        unit: unitCtrl.text.trim().isEmpty ? null : unitCtrl.text.trim(),
        dataType: componentType == 'actuator' ? 'boolean' : 'float',
        icon: icon,
      );

  void dispose() {
    variableCtrl.dispose();
    nameCtrl.dispose();
    unitCtrl.dispose();
  }
}

class _EditableGroup {
  int id;
  TBGroupType type;
  final nameCtrl = TextEditingController();
  final List<_EditableComponent> components;
  bool isExpanded;

  _EditableGroup(this.id, this.type, String name,
      [List<_EditableComponent>? comps, this.isExpanded = false])
      : components = comps ?? [] {
    nameCtrl.text = name;
  }

  factory _EditableGroup.fresh(int id, String appType) {
    final label = appType == 'aquaculture' ? 'Ao $id' : 'Nhóm $id';
    return _EditableGroup(id, TBGroupType.lot, label);
  }

  factory _EditableGroup.fromGroup(TBGroup g) {
    final comps = g.components.map(_EditableComponent.fromComponent).toList();
    return _EditableGroup(
        g.id, g.type ?? TBGroupType.lot, g.name, comps, false);
  }

  TBGroup toGroup() => TBGroup(
        id,
        nameCtrl.text.trim(),
        type,
        components.map((c) => c.toComponent()).toList(),
      );

  void dispose() {
    nameCtrl.dispose();
    for (var c in components) {
      c.dispose();
    }
  }
}

// ── Page ────────────────────────────────────────────────────────────────────

@RoutePage()
class UIConfigPage extends StatefulWidget {
  final TBFarm farm;
  const UIConfigPage({Key? key, required this.farm}) : super(key: key);

  @override
  State<UIConfigPage> createState() => _UIConfigPageState();
}

class _UIConfigPageState extends State<UIConfigPage> {
  final _vm = UIConfigVM();
  final _rxBag = CompositeSubscription();

  // ── Wizard state ───────────────────────────────────────────────────────────
  int _step = 0; // 0: chọn loại, 1: thông tin, 2: nhóm thiết bị, 3: lưu
  String _appType = 'irrigation';

  // Step 1
  final _nameCtrl = TextEditingController();
  final _deviceIdCtrl = TextEditingController();
  final _accessTokenCtrl = TextEditingController();
  bool _weatherForcast = false;
  bool _hasCamera = false;
  bool _suggestionEnabled = false;

  // Step 2
  final List<_EditableGroup> _groups = [];
  int _nextGroupId = 1;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _bindVM();
    _loadExisting();
  }

  @override
  void dispose() {
    _rxBag.dispose();
    _vm.dispose();
    _nameCtrl.dispose();
    _deviceIdCtrl.dispose();
    _accessTokenCtrl.dispose();
    for (var g in _groups) {
      g.dispose();
    }
    super.dispose();
  }

  void _bindVM() {
    _vm.output.saveSuccess.listen((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu cấu hình giao diện thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      context.router.pop(true);
    }).addTo(_rxBag);
  }

  void _loadExisting() {
    final tbService = DI.resolve<TBService>();
    tbService.getFarmConfig(widget.farm.id.id).first.then((configs) {
      if (!mounted || configs.isEmpty) return;
      setState(() {
        final sys = configs.first;
        _appType =
            sys.appType.isNotEmpty ? sys.appType : 'irrigation';
        _nameCtrl.text = sys.name;
        _deviceIdCtrl.text = sys.deviceId;
        _accessTokenCtrl.text = sys.accessToken;
        _weatherForcast = sys.weatherForcast;
        _hasCamera = sys.hasCamera;
        _suggestionEnabled = sys.hasSuggestion;
        for (var g in _groups) {
          g.dispose();
        }
        _groups.clear();
        for (var g in sys.groups) {
          _groups.add(_EditableGroup.fromGroup(g));
          if (g.id >= _nextGroupId) _nextGroupId = g.id + 1;
        }
        _step = 1; // bỏ qua chọn loại nếu đã có config
      });
    }).catchError((_) {});
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        leading: BackButton(onPressed: _handleBack),
      ),
      backgroundColor: AppTheme.$F5F5F5,
      body: LoadingWidget(
        error: _vm.errorTracker.asAppError(),
        isLoading: _vm.activityTracker.isRunningAny(),
        child: Column(
          children: [
            _stepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _stepBody(),
              ),
            ),
            _bottomButtons(),
          ],
        ),
      ),
    );
  }

  String get _appBarTitle => switch (_step) {
        0 => 'Chọn loại hình',
        1 => 'Thông tin thiết bị',
        2 => 'Cấu hình nhóm thiết bị',
        _ => 'Xem trước & Lưu',
      };

  void _handleBack() {
    if (_step == 0) {
      context.router.pop();
    } else {
      setState(() => _step--);
    }
  }

  // ── Step indicator ─────────────────────────────────────────────────────────
  Widget _stepIndicator() {
    const labels = ['Loại hình', 'Thông tin', 'Nhóm thiết bị', 'Lưu'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < labels.length; i++) ...[
            _stepDot(i, labels[i]),
            if (i < labels.length - 1)
              Container(
                width: 28,
                height: 2,
                color: i < _step ? AppTheme.primaryColor : AppTheme.$E1E1E1,
              ),
          ],
        ],
      ),
    );
  }

  Widget _stepDot(int index, String label) {
    final isDone = index < _step;
    final isCurrent = index == _step;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone || isCurrent
                ? AppTheme.primaryColor
                : AppTheme.$E1E1E1,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isCurrent ? Colors.white : AppTheme.$A3A3A3,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: AppTheme.textStyle(
              fontSize: 10,
              color: isCurrent ? AppTheme.primaryColor : AppTheme.$A3A3A3,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
            )),
      ],
    );
  }

  // ── Step bodies ────────────────────────────────────────────────────────────
  Widget _stepBody() => switch (_step) {
        0 => _step0AppType(),
        1 => _step1BasicInfo(),
        2 => _step2Groups(),
        _ => _step3Preview(),
      };

  // ── Step 0: Chọn loại hình ─────────────────────────────────────────────────
  Widget _step0AppType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(
          'Chọn loại hình ứng dụng',
          style: AppTheme.textStyle(
              fontSize: 18, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Cấu hình giao diện sẽ được tối ưu theo từng loại hình',
          style: AppTheme.textStyle(
              fontSize: 13, color: AppTheme.$A3A3A3),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _appTypeCard(
          type: 'irrigation',
          icon: Icons.water_drop_outlined,
          iconColor: const Color(0xFF27AE60),
          title: 'Tưới tiêu',
          subtitle:
              'Điều khiển van, bơm tưới theo vùng. Hỗ trợ sensor đất, lịch tưới tự động.',
        ),
        const SizedBox(height: 12),
        _appTypeCard(
          type: 'aquaculture',
          icon: Icons.set_meal_outlined,
          iconColor: const Color(0xFF2980B9),
          title: 'Thủy sản',
          subtitle:
              'Quản lý ao nuôi, quạt, máy thổi. Theo dõi DO, pH, nhiệt độ nước.',
        ),
        const SizedBox(height: 12),
        _appTypeCard(
          type: 'hydromet',
          icon: Icons.cloud_outlined,
          iconColor: const Color(0xFF8E44AD),
          title: 'Quan trắc',
          subtitle:
              'Theo dõi môi trường: nhiệt độ, độ ẩm, mưa, gió, bức xạ.',
        ),
      ],
    );
  }

  Widget _appTypeCard({
    required String type,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _appType == type;
    return GestureDetector(
      onTap: () => setState(() {
        _appType = type;
        _step = 1;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTheme.textStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: AppTheme.textStyle(
                          fontSize: 12, color: AppTheme.$A3A3A3)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.$A3A3A3,
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Thông tin cơ bản ───────────────────────────────────────────────
  Widget _step1BasicInfo() {
    final typeLabel = switch (_appType) {
      'aquaculture' => 'Thủy sản',
      'hydromet' => 'Quan trắc',
      _ => 'Tưới tiêu',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionCard(
          title: 'Thông tin dự án',
          children: [
            _fieldLabel('Loại hình'),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(typeLabel,
                  style: AppTheme.textStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            _fieldLabel('Tên dự án'),
            const SizedBox(height: 4),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  hintText: 'VD: Mô hình tưới vườn tiêu'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: 'Thông tin thiết bị',
          children: [
            _fieldLabel('Device ID'),
            const SizedBox(height: 4),
            TextField(
              controller: _deviceIdCtrl,
              decoration:
                  const InputDecoration(hintText: 'UUID của thiết bị'),
            ),
            const SizedBox(height: 12),
            _fieldLabel('Access Token'),
            const SizedBox(height: 4),
            TextField(
              controller: _accessTokenCtrl,
              decoration: const InputDecoration(
                  hintText: 'Access token MQTT/HTTP'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: 'Tính năng',
          children: [
            _switchRow(
              label: 'Dự báo thời tiết',
              icon: Icons.wb_sunny_outlined,
              value: _weatherForcast,
              onChanged: (v) => setState(() => _weatherForcast = v),
            ),
            const Divider(),
            _switchRow(
              label: 'Camera giám sát',
              icon: Icons.videocam_outlined,
              value: _hasCamera,
              onChanged: (v) => setState(() => _hasCamera = v),
            ),
            if (_appType != 'aquaculture') ...[
              const Divider(),
              _switchRow(
                label: 'Khuyến nghị tưới',
                icon: Icons.eco_outlined,
                value: _suggestionEnabled,
                onChanged: (v) => setState(() => _suggestionEnabled = v),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ── Step 2: Nhóm thiết bị ─────────────────────────────────────────────────
  Widget _step2Groups() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionCard(
          title: 'Nhóm thiết bị (${_groups.length})',
          children: [
            if (_groups.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Chưa có nhóm nào. Nhấn "+ Thêm nhóm" để bắt đầu.',
                  style: AppTheme.textStyle(
                      color: AppTheme.$A3A3A3, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            for (int i = 0; i < _groups.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _groupCard(i),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _addGroup,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm nhóm'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side:
                          const BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _groupCard(int groupIdx) {
    final group = _groups[groupIdx];
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.$F5F5F5,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.$E1E1E1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Group header
          GestureDetector(
            onTap: () => setState(() => group.isExpanded = !group.isExpanded),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: group.isExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(11))
                    : BorderRadius.circular(11),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_outlined,
                      size: 18, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nhóm ${groupIdx + 1} – ${group.nameCtrl.text.isNotEmpty ? group.nameCtrl.text : "(chưa đặt tên)"}',
                      style: AppTheme.textStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor),
                    ),
                  ),
                  Icon(
                    group.isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _removeGroup(groupIdx),
                    child: const Icon(Icons.delete_outline,
                        size: 18, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
          if (group.isExpanded)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Group type
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Loại nhóm'),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<TBGroupType>(
                            value: group.type,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10)),
                            items: const [
                              DropdownMenuItem(
                                  value: TBGroupType.lot,
                                  child: Text('Lô')),
                              DropdownMenuItem(
                                  value: TBGroupType.station,
                                  child: Text('Trạm')),
                            ],
                            onChanged: (v) =>
                                setState(() => group.type = v!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Tên nhóm'),
                          const SizedBox(height: 4),
                          TextField(
                            controller: group.nameCtrl,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Components list
                Text(
                  'Thông số / Thiết bị (${group.components.length})',
                  style: AppTheme.textStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                for (int ci = 0;
                    ci < group.components.length;
                    ci++) ...[
                  _componentCard(groupIdx, ci),
                  const SizedBox(height: 8),
                ],
                OutlinedButton.icon(
                  onPressed: () => _addComponent(groupIdx),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Thêm thông số',
                      style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF27AE60),
                    side: const BorderSide(color: Color(0xFF27AE60)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _componentCard(int groupIdx, int compIdx) {
    final comp = _groups[groupIdx].components[compIdx];
    final typeLabel = comp.componentType == 'actuator' ? 'Thiết bị' : 'Cảm biến';
    final namePreview = comp.nameCtrl.text.isNotEmpty
        ? comp.nameCtrl.text
        : comp.variableCtrl.text.isNotEmpty
            ? comp.variableCtrl.text
            : '(chưa đặt tên)';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.$E1E1E1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => comp.isExpanded = !comp.isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${compIdx + 1}. $namePreview',
                    style: AppTheme.textStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: comp.componentType == 'actuator'
                          ? Colors.orange.withOpacity(0.15)
                          : const Color(0xFF27AE60).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      typeLabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: comp.componentType == 'actuator'
                            ? Colors.orange
                            : const Color(0xFF27AE60),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    comp.isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppTheme.$A3A3A3,
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _removeComponent(groupIdx, compIdx),
                    child: const Icon(Icons.close, size: 16, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
          if (comp.isExpanded) ...
          [
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('Variable', fontSize: 11),
                            const SizedBox(height: 2),
                            TextField(
                              controller: comp.variableCtrl,
                              style: const TextStyle(fontSize: 12),
                              decoration: const InputDecoration(
                                hintText: 'vd: rlc0, sm1',
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('Tên hiển thị', fontSize: 11),
                            const SizedBox(height: 2),
                            TextField(
                              controller: comp.nameCtrl,
                              style: const TextStyle(fontSize: 12),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('Loại', fontSize: 11),
                            const SizedBox(height: 2),
                            DropdownButtonFormField<String>(
                              value: comp.componentType,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'sensor',
                                    child: Text('Cảm biến',
                                        style: TextStyle(fontSize: 12))),
                                DropdownMenuItem(
                                    value: 'actuator',
                                    child: Text('Thiết bị đóng/mở',
                                        style: TextStyle(fontSize: 12))),
                              ],
                              onChanged: (v) =>
                                  setState(() => comp.componentType = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('Đơn vị', fontSize: 11),
                            const SizedBox(height: 2),
                            TextField(
                              controller: comp.unitCtrl,
                              style: const TextStyle(fontSize: 12),
                              decoration: const InputDecoration(
                                hintText: 'vd: %, mg/l',
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Biểu tượng', fontSize: 11),
                      const SizedBox(height: 2),
                      DropdownButtonFormField<int>(
                        value: comp.icon,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                        ),
                        items: _EditableComponent.iconItems,
                        onChanged: (v) => setState(() => comp.icon = v!),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Step 3: Xem trước & Lưu ────────────────────────────────────────────────
  Widget _step3Preview() {
    final system = _buildControlSystem();
    final typeLabel = switch (_appType) {
      'aquaculture' => 'Thủy sản',
      'hydromet' => 'Quan trắc',
      _ => 'Tưới tiêu',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionCard(
          title: 'Tóm tắt cấu hình',
          children: [
            _previewRow('Loại hình', typeLabel),
            _previewRow('Tên dự án',
                system.name.isEmpty ? '(chưa đặt tên)' : system.name),
            _previewRow('Device ID',
                system.deviceId.isEmpty ? '(chưa nhập)' : system.deviceId),
            _previewRow('Access Token',
                system.accessToken.isEmpty
                    ? '(chưa nhập)'
                    : '••••••••${system.accessToken.length > 6 ? system.accessToken.substring(system.accessToken.length - 4) : ''}'),
            _previewRow('Dự báo thời tiết',
                _weatherForcast ? 'Bật' : 'Tắt'),
            _previewRow(
                'Camera', _hasCamera ? 'Bật' : 'Tắt'),
            if (_appType != 'aquaculture')
              _previewRow('Khuyến nghị tưới',
                  _suggestionEnabled ? 'Bật' : 'Tắt'),
            _previewRow(
                'Số nhóm thiết bị', '${_groups.length} nhóm'),
          ],
        ),
        const SizedBox(height: 12),
        if (_groups.isNotEmpty)
          _sectionCard(
            title: 'Chi tiết nhóm thiết bị',
            children: [
              for (int i = 0; i < _groups.length; i++) ...[
                if (i > 0) const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${i + 1}. ${_groups[i].nameCtrl.text} (${_groups[i].type.name})',
                        style: AppTheme.textStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      ...(_groups[i].components.map((c) => Padding(
                            padding: const EdgeInsets.only(left: 12, top: 2),
                            child: Text(
                              '• ${c.variableCtrl.text} — ${c.nameCtrl.text} [${c.componentType}]',
                              style: AppTheme.textStyle(
                                  fontSize: 12,
                                  color: AppTheme.$A3A3A3),
                            ),
                          ))),
                      if (_groups[i].components.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 2),
                          child: Text('(Không có thông số)',
                              style: AppTheme.textStyle(
                                  fontSize: 12,
                                  color: AppTheme.$A3A3A3)),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        const SizedBox(height: 12),
        _sectionCard(
          title: 'Lưu ý',
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cấu hình sẽ được lưu và có hiệu lực ngay khi ứng dụng tải lại. '
                    'Chỉ tài khoản quản trị mới có quyền thực hiện thao tác này.',
                    style: AppTheme.textStyle(
                        fontSize: 12, color: AppTheme.$A3A3A3),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.cloud_upload_outlined),
          label: const Text('Lưu cấu hình'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  TBControlSystem _buildControlSystem() {
    // Reassign IDs sequentially (1..n) to avoid gaps from add/delete operations
    for (int i = 0; i < _groups.length; i++) {
      _groups[i].id = i + 1;
    }
    return TBControlSystem(
      _nameCtrl.text.trim(),
      _accessTokenCtrl.text.trim(),
      _deviceIdCtrl.text.trim(),
      _groups.map((g) => g.toGroup()).toList(),
      [], // hyrdromets – cấu hình riêng
      [], // camera list – cấu hình riêng
      [], // crop
      [], // soil
      _appType,
      _weatherForcast,
      _hasCamera,
      _suggestionEnabled,
    );
  }

  bool _validateStep1() {
    if (_nameCtrl.text.trim().isEmpty) {
      _showError('Vui lòng nhập tên dự án');
      return false;
    }
    if (_deviceIdCtrl.text.trim().isEmpty) {
      _showError('Vui lòng nhập Device ID');
      return false;
    }
    if (_accessTokenCtrl.text.trim().isEmpty) {
      _showError('Vui lòng nhập Access Token');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (_groups.isEmpty) {
      _showError('Cần có ít nhất 1 nhóm thiết bị');
      return false;
    }
    for (final g in _groups) {
      if (g.nameCtrl.text.trim().isEmpty) {
        _showError('Tên nhóm không được để trống');
        return false;
      }
      for (final c in g.components) {
        if (c.variableCtrl.text.trim().isEmpty) {
          _showError(
              'Variable của thiết bị trong nhóm "${g.nameCtrl.text}" không được để trống');
          return false;
        }
      }
    }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _addGroup() {
    setState(() {
      _groups.add(_EditableGroup.fresh(_nextGroupId++, _appType));
    });
  }

  void _removeGroup(int index) {
    setState(() {
      _groups[index].dispose();
      _groups.removeAt(index);
    });
  }

  void _addComponent(int groupIdx) {
    final isAqua = _appType == 'aquaculture';
    setState(() {
      _groups[groupIdx].components.add(
        _EditableComponent(
          componentType: 'sensor',
          icon: isAqua ? 14 : 7, // DO cho thủy sản, ẩm đất cho tưới
        ),
      );
    });
  }

  void _removeComponent(int groupIdx, int compIdx) {
    setState(() {
      _groups[groupIdx].components[compIdx].dispose();
      _groups[groupIdx].components.removeAt(compIdx);
    });
  }

  void _save() {
    _vm.input.save.add((
      assetId: widget.farm.id.id,
      config: [_buildControlSystem()],
    ));
  }

  Widget _sectionCard(
      {required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(title,
                style: AppTheme.textStyle(
                    fontSize: 14, fontWeight: FontWeight.w700)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 12),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label, {double fontSize = 12}) => Text(
        label,
        style: AppTheme.textStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: AppTheme.$3A3A3A),
      );

  Widget _switchRow({
    required String label,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.$A3A3A3),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: AppTheme.textStyle(fontSize: 14)),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _previewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: AppTheme.textStyle(
                    fontSize: 13, color: AppTheme.$A3A3A3)),
          ),
          Expanded(
            child: Text(value,
                style: AppTheme.textStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // ── Bottom navigation buttons ──────────────────────────────────────────────
  Widget _bottomButtons() {
    if (_step == 0) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_step > 0) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _step--),
                  child: const Text('Quay lại'),
                ),
              ),
              const SizedBox(width: 12),
            ],
            if (_step < 3)
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white),
                  child: const Text('Tiếp theo'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _nextStep() {
    if (_step == 1 && !_validateStep1()) return;
    if (_step == 2 && !_validateStep2()) return;
    setState(() => _step++);
  }
}
