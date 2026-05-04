import 'package:rxdart/rxdart.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/models/sources/tb_control_system.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/api/api.dart';

class TBManualControlVMInput extends Disposable {
  final reload = PublishSubject<void>();
  final toggleComponent = PublishSubject<(String, bool)>();
  @override
  void dispose() {
    reload.close();
    toggleComponent.close();
  }
}

class TBManualControlVMOutput extends Disposable {
  final reloadedValues = PublishSubject<Map<String, dynamic>>();
  final updatedValues = PublishSubject<Map<String, dynamic>>();
  @override
  void dispose() {
    reloadedValues.close();
    updatedValues.close();
  }
}

class TBManualControlVM
    extends BaseVM<TBManualControlVMInput, TBManualControlVMOutput> {
  final TBControlSystem system;
  TBManualControlVM(this.system)
      : super(TBManualControlVMInput(), TBManualControlVMOutput());

  @override
  CompositeSubscription? connect() {
    final rxBag = CompositeSubscription();
    final tbService = DI.resolve<TBService>();

    input.reload
        .switchMap((_) => tbService
            .getDeviceAttributes(system.deviceId, null)
            .trackActivity("loading", activityTracker))
        .handleErrorBy(errorTracker)
        .bindTo(output.reloadedValues)
        .addTo(rxBag);

    input.toggleComponent
        .flatMap((params) => tbService
            .setValue(system.deviceId, params.$1, params.$2)
            .trackActivity("sending", activityTracker))
        .handleErrorBy(errorTracker)
        .bindTo(output.updatedValues)
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
