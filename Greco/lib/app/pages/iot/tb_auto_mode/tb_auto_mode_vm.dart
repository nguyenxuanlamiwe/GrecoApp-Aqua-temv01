import 'package:rxdart/rxdart.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/api/api.dart';

class TBAutoModeVMInput extends Disposable {
  final update = PublishSubject<(TBATMode, String)>();
  @override
  void dispose() {
    update.close();
  }
}

class TBAutoModeVMOutput extends Disposable {
  final updateSuccess = PublishSubject();
  @override
  void dispose() {
    updateSuccess.close();
  }
}

class TBAutoModeVM extends BaseVM<TBAutoModeVMInput, TBAutoModeVMOutput> {
  TBAutoModeVM() : super(TBAutoModeVMInput(), TBAutoModeVMOutput());

  @override
  CompositeSubscription? connect() {
    final rxBag = CompositeSubscription();
    final tbService = DI.resolve<TBService>();

    input.update
        .switchMap((params) => tbService
            .updateATMode(params.$1, params.$2)
            .trackActivity("loading", activityTracker))
        .handleErrorBy(errorTracker)
        .bindTo(output.updateSuccess)
        .addTo(rxBag);
    return rxBag;
  }
}
