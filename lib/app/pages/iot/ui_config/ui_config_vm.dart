import 'package:rxdart/rxdart.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/api/api.dart';

class UIConfigVMInput extends Disposable {
  final save =
      PublishSubject<({String assetId, List<TBControlSystem> config})>();

  @override
  void dispose() {
    save.close();
  }
}

class UIConfigVMOutput extends Disposable {
  final saveSuccess = PublishSubject<void>();

  @override
  void dispose() {
    saveSuccess.close();
  }
}

class UIConfigVM extends BaseVM<UIConfigVMInput, UIConfigVMOutput> {
  UIConfigVM() : super(UIConfigVMInput(), UIConfigVMOutput());

  @override
  CompositeSubscription? connect() {
    final rxBag = CompositeSubscription();
    final tbService = DI.resolve<TBService>();

    input.save
        .switchMap((args) => tbService
            .saveFarmConfig(args.assetId, args.config)
            .trackActivity("saving", activityTracker))
        .handleErrorBy(errorTracker)
        .bindTo(output.saveSuccess)
        .addTo(rxBag);

    return rxBag;
  }
}
