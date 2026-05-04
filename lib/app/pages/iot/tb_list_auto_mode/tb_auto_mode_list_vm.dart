import 'package:rxdart/rxdart.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/api/api.dart';

class TBAutoModeListVMInput extends Disposable {
  final reload = PublishSubject<String>();
  final delete = PublishSubject<(int, String)>();
  @override
  void dispose() {
    reload.close();
    delete.close();
  }
}

class TBAutoModeListVMOutput extends Disposable {
  final modes = BehaviorSubject<List<TBATMode>>();
  @override
  void dispose() {
    modes.close();
  }
}

class TBAutoModeListVM
    extends BaseVM<TBAutoModeListVMInput, TBAutoModeListVMOutput> {
  TBAutoModeListVM() : super(TBAutoModeListVMInput(), TBAutoModeListVMOutput());

  @override
  CompositeSubscription? connect() {
    final rxBag = CompositeSubscription();
    final tbService = DI.resolve<TBService>();

    input.reload
        .switchMap((deviceId) => tbService
            .getATModes(deviceId)
            .trackActivity("loading", activityTracker))
        .handleErrorBy(errorTracker)
        .bindTo(output.modes)
        .addTo(rxBag);

    input.delete
        .switchMap((params) => tbService
            .deleteATMode(params.$1, params.$2)
            .trackActivity("deleting", activityTracker))
        .listen(null)
        .addTo(rxBag);

    return rxBag;
  }
}
