import 'package:rxdart/rxdart.dart';
import 'package:zen8app/utils/utils.dart';

class BottomSheetPickerVMInput extends Disposable {
  final reload = PublishSubject();
  @override
  void dispose() {
    reload.close();
  }
}

class BottomSheetPickerVMOutput<E> extends Disposable {
  final elements = BehaviorSubject<List<E>>();

  @override
  void dispose() {
    elements.close();
  }
}

class BottomSheetPickerVM<E>
    extends BaseVM<BottomSheetPickerVMInput, BottomSheetPickerVMOutput<E>> {
  final ListLoader<E> _loader;
  BottomSheetPickerVM(ListLoader<E> loader)
      : _loader = loader,
        super(BottomSheetPickerVMInput(), BottomSheetPickerVMOutput<E>());

  @override
  CompositeSubscription? connect() {
    final subscription = CompositeSubscription();
    input.reload
        .switchMap(
            (_) => _loader.load().trackActivity('loading', activityTracker))
        .handleErrorBy(errorTracker)
        .bindTo(output.elements)
        .addTo(subscription);

    return subscription;
  }
}
