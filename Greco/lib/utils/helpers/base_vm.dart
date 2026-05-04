import 'package:rxdart/rxdart.dart';
import 'disposable.dart';
import 'activity_tracker.dart';

class BaseVM<Input extends Disposable, Output extends Disposable>
    implements Disposable {
  Input input;
  Output output;

  final errorTracker = PublishSubject();
  final activityTracker = ActivityTracker();

  CompositeSubscription? _subscription;

  BaseVM(this.input, this.output) {
    _subscription = connect();
  }

  CompositeSubscription? connect() {
    return null;
  }

  @override
  void dispose() {
    input.dispose();
    output.dispose();
    errorTracker.close();
    activityTracker.dispose();
    _subscription?.dispose();
  }
}
