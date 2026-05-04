import 'package:rxdart/rxdart.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/models/sources/tb_control_system.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/api/api.dart';

class TBWeatherStationVMInput extends Disposable {
  final reload = PublishSubject<void>();
  @override
  void dispose() {
    reload.close();
  }
}

class TBWeatherStationVMOutput extends Disposable {
  final reloadedValues = PublishSubject<Map<String, dynamic>>();
  final updatedValues = PublishSubject<Map<String, dynamic>>();
  @override
  void dispose() {
    reloadedValues.close();
    updatedValues.close();
  }
}

class TBWeatherStationVM
    extends BaseVM<TBWeatherStationVMInput, TBWeatherStationVMOutput> {
  TBWeatherStationVM(this.system)
      : super(TBWeatherStationVMInput(), TBWeatherStationVMOutput());

  TBControlSystem system;

  @override
  CompositeSubscription? connect() {
    final rxBag = CompositeSubscription();
    final tbService = DI.resolve<TBService>();

    input.reload
        .switchMap((_) => tbService
            .getSensorValues(system.deviceId, null)
            .trackActivity("loading", activityTracker))
        .handleErrorBy(errorTracker)
        .bindTo(output.reloadedValues)
        .addTo(rxBag);

    DI
        .resolveSingleton<EventBus>()
        .mqttUpdates
        .map((updates) => updates[system.accessToken])
        .whereNotNull()
        .bindTo(output.updatedValues)
        .addTo(rxBag);

    return rxBag;
  }
}
