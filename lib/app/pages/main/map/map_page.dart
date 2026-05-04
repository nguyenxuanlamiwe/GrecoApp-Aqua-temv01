import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zen8app/app/pages/main/map/map_vm.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/core/sources/tb_authenticator.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/router/router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:zen8app/widgets/widgets.dart';

@RoutePage()
class MapPage extends StatefulWidget {
  final List<(TBFarm, Color)> farms;
  const MapPage({
    super.key,
    required this.farms,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _vm = MapVM();
  final _rxBag = CompositeSubscription();
  @override
  void initState() {
    super.initState();
    _bindViewModel();
  }

  @override
  void dispose() {
    _vm.dispose();
    _rxBag.dispose();
    super.dispose();
  }

  void _bindViewModel() {
    _vm.output.systems.listen(_showControlSystemPage).addTo(_rxBag);
  }

  _showControlSystemPage(List<TBControlSystem> systems) {
    context.pushRoute(TBControlSystemRoute(systems: systems));
  }

  LatLng _getInitPosition() {
    for (var farm in widget.farms) {
      if (farm.$1.additionalInfo.lat != null &&
          farm.$1.additionalInfo.lon != null) {
        return LatLng(
          farm.$1.additionalInfo.lat!,
          farm.$1.additionalInfo.lon!,
        );
      }
    }
    return const LatLng(
      11.7661123,
      107.6691988,
    ); //default is Lam Dong's location
  }

  List<Marker> _getMarkers() {
    var markers = <Marker>[];
    for (var (farm, color) in widget.farms) {
      if (farm.additionalInfo.lat != null && farm.additionalInfo.lon != null) {
        markers.add(
          Marker(
            width: 40,
            height: 40,
            point: LatLng(farm.additionalInfo.lat!, farm.additionalInfo.lon!),
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () {
                    _vm.input.selectedFarm.add(farm.id.id);
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(60, 0, 0, 0),
                          offset: Offset(0, 3),
                          blurRadius: 3,
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.cell_tower,
                      color: color,
                    ),
                  ),
                ),
                Positioned(
                  top: 48,
                  left: -30,
                  child: Container(
                    width: 100,
                    alignment: Alignment.center,
                    child: Text(
                      farm.name,
                      textAlign: TextAlign.center,
                      style: AppTheme.textStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      }
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bản đồ"),
      ),
      body: LoadingWidget(
        error: _vm.errorTracker.asAppError(),
        isLoading: _vm.activityTracker.isRunningAny(),
        child: FlutterMap(
          options:
              MapOptions(initialCenter: _getInitPosition(), initialZoom: 13),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
              userAgentPackageName: "com.zen8labs.greco",
            ),
            MarkerLayer(
              markers: _getMarkers(),
              rotate: true,
            ),
          ],
        ),
      ),
    );
  }
}
