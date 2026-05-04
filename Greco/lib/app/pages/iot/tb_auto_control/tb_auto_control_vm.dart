import 'package:rxdart/rxdart.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/api/api.dart';

class TBAutoControlVMInput extends Disposable {
  final reload = PublishSubject<void>();
  final autoEnable = PublishSubject<bool>();
  final autoPauseEnable = PublishSubject<bool>();
  @override
  void dispose() {
    reload.close();
    autoEnable.close();
    autoPauseEnable.close();
  }
}

class TBAutoControlVMOutput extends Disposable {
  final currentATSys = BehaviorSubject<TBATSystem>();
  final atModes = BehaviorSubject<List<TBATMode>>();
  final reloadedValues = PublishSubject<Map<String, dynamic>>();
  final updatedValues = PublishSubject<Map<String, dynamic>>();

  @override
  void dispose() {
    currentATSys.close();
    atModes.close();
    reloadedValues.close();
    updatedValues.close();
  }
}

class TBAutoControlVM
    extends BaseVM<TBAutoControlVMInput, TBAutoControlVMOutput> {
  final TBControlSystem system;
  TBAutoControlVM(this.system)
      : super(TBAutoControlVMInput(), TBAutoControlVMOutput());

  @override
  CompositeSubscription? connect() {
    final rxBag = CompositeSubscription();
    final tbService = DI.resolve<TBService>();

    input.reload
        .switchMap((_) => tbService
            .getATSystem(system.deviceId)
            .trackActivity("atsys", activityTracker))
        .ignoreError()
        .bindTo(output.currentATSys)
        .addTo(rxBag);

    input.reload
        .switchMap((_) => tbService
            .getATModes(system.deviceId)
            .trackActivity("atmode", activityTracker))
        .ignoreError()
        .bindTo(output.atModes)
        .addTo(rxBag);

    //["autoEnable", "autoPauseEnable", "auActProId"]
    input.reload
        .switchMap((_) => tbService
            .getDeviceAttributes(system.deviceId, null)
            .trackActivity("reload", activityTracker))
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

    input.autoEnable
        .switchMap((enable) => tbService
            .setValue(system.deviceId, "autoEnable", enable, 60000)
            .trackActivity("auto", activityTracker))
        .handleErrorBy(errorTracker)
        .bindTo(output.updatedValues)
        .addTo(rxBag);

    input.autoPauseEnable
        .switchMap((enable) => tbService
            .setValue(system.deviceId, "autoPauseEnable", enable, 3000)
            .trackActivity("pause", activityTracker))
        .handleErrorBy(errorTracker)
        .bindTo(output.updatedValues)
        .addTo(rxBag);

    return rxBag;
  }
}
