import 'package:rxdart/rxdart.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/api/api.dart';

class TBCameraVMInput extends Disposable {
  final reload = PublishSubject<TBControlSystem>();
  @override
  void dispose() {
    reload.close();
  }
}

class TBCameraVMOutput extends Disposable {
  final rtspLinks = PublishSubject<Map<String, String>>();
  @override
  void dispose() {
    rtspLinks.close();
  }
}

class TBCameraVM extends BaseVM<TBCameraVMInput, TBCameraVMOutput> {
  TBCameraVM() : super(TBCameraVMInput(), TBCameraVMOutput());

  @override
  CompositeSubscription? connect() {
    final rxBag = CompositeSubscription();
    final tbService = DI.resolve<TBService>();

    input.reload
        .switchMap((system) {
          final cameraKeys = [for (var c in system.camera) c.cameraUrl];
          return cameraKeys.isNotEmpty
              ? tbService.getRtspLinks(system.deviceId, cameraKeys)
              : tbService.getAllRtspLinks(system.deviceId);
        })
        .trackActivity('loading', activityTracker)
        .handleErrorBy(errorTracker)
        .bindTo(output.rtspLinks)
        .addTo(rxBag);

    return rxBag;
  }
}
