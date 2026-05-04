import 'package:rxdart/rxdart.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/api/api.dart';

class TBATSystemConfigVMInput extends Disposable {
  final reload = PublishSubject<String>();
  final submit = PublishSubject<(TBATSystem, String)>();
  @override
  void dispose() {
    reload.close();
    submit.close();
  }
}

class TBATSystemConfigVMOutput extends Disposable {
  final atModes = BehaviorSubject<List<TBATMode>>();
  final submitSuccess = PublishSubject();
  @override
  void dispose() {
    atModes.close();
    submitSuccess.close();
  }
}

class TBATSystemConfigVM
    extends BaseVM<TBATSystemConfigVMInput, TBATSystemConfigVMOutput> {
  TBATSystemConfigVM()
      : super(TBATSystemConfigVMInput(), TBATSystemConfigVMOutput());

  @override
  CompositeSubscription? connect() {
    final rxBag = CompositeSubscription();
    final tbService = DI.resolve<TBService>();

    input.reload
        .switchMap((deviceId) => tbService
            .getATModes(deviceId)
            .trackActivity("atmode", activityTracker))
        .ignoreError()
        .bindTo(output.atModes)
        .addTo(rxBag);

    input.submit
        .switchMap((params) => tbService
            .updateATSys(params.$1, params.$2)
            .trackActivity("atsys", activityTracker))
        .handleErrorBy(errorTracker)
        .bindTo(output.submitSuccess)
        .addTo(rxBag);

    return rxBag;
  }
}
