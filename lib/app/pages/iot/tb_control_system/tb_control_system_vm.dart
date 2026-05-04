import 'package:mqtt_client/mqtt_client.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/api/api.dart';

class TBControlSystemVMInput extends Disposable {
  final selectedSystem = PublishSubject<TBControlSystem>();
  final restartSystem = PublishSubject<String>();
  @override
  void dispose() {
    selectedSystem.close();
    restartSystem.close();
  }
}

class TBControlSystemVMOutput extends Disposable {
  final restartStatus = PublishSubject<bool>();
  @override
  void dispose() {
    restartStatus.close();
  }
}

class TBControlSystemVM
    extends BaseVM<TBControlSystemVMInput, TBControlSystemVMOutput> {
  TBControlSystemVM()
      : super(TBControlSystemVMInput(), TBControlSystemVMOutput());

  final _rxBag = CompositeSubscription();
  final _mqttService = DI.resolve<MQTTService>();

  @override
  void dispose() {
    super.dispose();
    _mqttService.disconnect();
    _rxBag.dispose();
  }

  Future<void> connectToMQTTBroker() async {
    final eventBus = DI.resolveSingleton<EventBus>();
    final tbService = DI.resolve<TBService>();

    activityTracker.start("connecting");
    await _mqttService.connect();
    activityTracker.stop("connecting");

    _mqttService.updates?.bindTo(eventBus.mqttUpdates).addTo(_rxBag);
    _mqttService.connectionState
        .map((event) => event == MqttConnectionState.connected)
        .distinct()
        .bindTo(eventBus.mqttConnectionStatus)
        .addTo(_rxBag);

    input.selectedSystem
        .switchMap((system) {
          return Rx.never()
              .doOnListen(() => _mqttService.subscribe(system.accessToken))
              .doOnCancel(() => _mqttService.unsubscribe(system.accessToken));
        })
        .listen(null)
        .addTo(_rxBag);

    input.selectedSystem
        .switchMap((system) => tbService
            .getDeviceAttributes(system.deviceId, ["systemRestart"])
            .map((attrs) => (attrs["systemRestart"] as bool?) ?? false)
            .onErrorReturn(false)
            .trackActivity("loading", activityTracker))
        .bindTo(output.restartStatus)
        .addTo(_rxBag);

    input.selectedSystem
        .switchMap((system) => eventBus.mqttUpdates
            .map((updates) =>
                updates[system.accessToken]?["systemRestart"] as bool?)
            .whereNotNull())
        .bindTo(output.restartStatus)
        .addTo(_rxBag);

    input.restartSystem
        .switchMap((deviceId) => tbService
            .restartSystem(deviceId)
            .mapTo(true)
            .trackActivity("restarting", activityTracker))
        .handleErrorBy(errorTracker)
        .bindTo(output.restartStatus)
        .addTo(_rxBag);
  }
}
