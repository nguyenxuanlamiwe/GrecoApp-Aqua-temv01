import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zen8app/app/pages/iot/tb_auto_mode/tb_auto_mode_page.dart';
import 'package:zen8app/app/pages/iot/ui_config/ui_config_page.dart';
import 'package:zen8app/app/pages/main/home_vm.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/widgets/widgets.dart';
import 'package:zen8app/router/router.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final _vm = HomeVM(Session.currentUser!);
  final _rxBag = CompositeSubscription();

  var _farms = <TBFarm>[];
  var _farmStatuses = <String, List<TBAttribute>>{};

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
  }

  void _bindViewModel() {
    _vm.output.systems.listen(_showControlSystemPage).addTo(_rxBag);

    _vm.output.farms.listen((farms) {
      setState(() {
        _farms = farms;
      });
    }).addTo(_rxBag);

    _vm.output.farmStatus.listen((status) {
      setState(() {
        _farmStatuses[status.$1] = status.$2;
      });
    }).addTo(_rxBag);

    _vm.output.didLogout.listen((_) async {
      await Session.endAuthenticatedSession(reason: 'user log out');
    }).addTo(_rxBag);

    _vm.input.reload.add(null);
  }

  _showControlSystemPage(List<TBControlSystem> systems) async {
    await context.pushRoute(TBControlSystemRoute(systems: systems));
    _vm.input.reload.add(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingWidget(
        error: _vm.errorTracker.asAppError(),
        isLoading: _vm.activityTracker.isRunningAny(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _headerWidget(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () {
                  _vm.input.reload.add(null);
                  return Future.value();
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemBuilder: (context, index) =>
                      _farmItemWidget(_farms[index]),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemCount: _farms.length,
                ),
              ),
            ),
            _footerWidget(),
          ],
        ),
      ),
    );
  }

  Widget _headerWidget() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/img_home_banner.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Xin chào ${Session.currentUser?.name ?? ""}',
                      style: AppTheme.textStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                  Material(
                    shape: const CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    color: Colors.white,
                    child: InkWell(
                      onTap: () => _vm.input.logout.add(null),
                      child: const SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(
                            Icons.logout,
                            color: Colors.black,
                          )),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              height: 32,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _farmItemWidget(TBFarm farm) {
    var allAttrs = _farmStatuses[farm.id.id] ?? [];
    TBAttribute? warningLevel;
    var otherAttrs = <TBAttribute>[];
    for (var attr in allAttrs) {
      if (attr.key == "warningLevel") {
        warningLevel = attr;
      } else {
        otherAttrs.add(attr);
      }
    }
    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => _vm.input.selectedFarm.add(farm.id.id),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          DefaultNetworkImage(
            height: 100,
            radius: 0,
            imageUrl: farm.additionalInfo.imageUrl,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (warningLevel != null)
                  Row(
                    children: [
                      Icon(
                        Icons.cell_tower_outlined,
                        color: _warningLevelColor(warningLevel.value),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          farm.name,
                          style: AppTheme.textStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    farm.name,
                    style: AppTheme.textStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 8),
                ...otherAttrs.expand(
                  (attr) => [
                    const SizedBox(height: 4),
                    _attributeWidget(attr),
                  ],
                ),
                if (Session.currentUser?.authority == TBAuthority.tenantAdmin) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () async {
                        final saved = await context.pushRoute<bool>(UIConfigRoute(farm: farm));
                        if (saved == true) _vm.input.reload.add(null);
                      },
                      icon: const Icon(Icons.tune, size: 16),
                      label: const Text('Cấu hình giao diện',
                          style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        foregroundColor: AppTheme.primaryColor,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          )
        ]),
      ),
    );
  }

  Color _warningLevelColor(dynamic value) {
    return switch (value) {
      1 => const Color.fromARGB(255, 0, 110, 255), // Rủi ro thấp
      2 => const Color.fromARGB(255, 247, 244, 88), // Rủi ro trung bình
      3 => const Color.fromARGB(255, 244, 179, 50), //Rủi ro lớn
      4 => const Color.fromARGB(255, 255, 62, 62), // Rủi ro rất lớn
      5 => const Color.fromARGB(255, 166, 1, 255), // Rủi ro ở mức thảm hoạ
      _ => const Color(0xFF1B8D42), //bình thường
    };
  }

  Widget _attributeWidget(TBAttribute attribute) {
    var color = switch (attribute.key) {
      "statusWeather" => const Color.fromARGB(255, 232, 143, 26),
      "statusAuto" => const Color.fromARGB(255, 27, 141, 135),
      _ => const Color(0xFF1B8D42),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${DateTime.fromMillisecondsSinceEpoch(attribute.lastUpdateTs).ex.asString(DatePattern.ddMMyyyyHHmm)}: ${attribute.value}',
        style: AppTheme.textStyle(color: Colors.black, fontSize: 13),
      ),
    );
  }

  Widget _footerWidget() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
        child: ElevatedButton.icon(
          onPressed: () {
            var farmData = _farms.map((aFarm) {
              var attrs = _farmStatuses[aFarm.id.id];
              var warningLevel =
                  attrs?.where((e) => e.key == "warningLevel").firstOrNull;
              return (aFarm, _warningLevelColor(warningLevel?.value));
            }).toList();

            context.pushRoute(MapRoute(farms: farmData));
          },
          label: Text("Xem bản đồ"),
          icon: Icon(Icons.map_outlined),
        ),
      ),
    );
  }
}
