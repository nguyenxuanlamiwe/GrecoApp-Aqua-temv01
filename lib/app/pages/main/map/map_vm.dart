import 'package:rxdart/rxdart.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/api/api.dart';

class MapVMInput extends Disposable {
  final selectedFarm = PublishSubject<String>();
  @override
  void dispose() {
    selectedFarm.close();
  }
}

class MapVMOutput extends Disposable {
  final systems = PublishSubject<List<TBControlSystem>>();
  @override
  void dispose() {
    systems.close();
  }
}

class MapVM extends BaseVM<MapVMInput, MapVMOutput> {
  MapVM() : super(MapVMInput(), MapVMOutput());

  @override
  CompositeSubscription? connect() {
    final rxBag = CompositeSubscription();
    final tbService = DI.resolve<TBService>();
    input.selectedFarm
        .switchMap((farmId) => tbService
            .getFarmConfig(farmId)
            .trackActivity('loading', activityTracker))
        .handleErrorBy(errorTracker)
        .bindTo(output.systems)
        .addTo(rxBag);
    return rxBag;
  }
}
