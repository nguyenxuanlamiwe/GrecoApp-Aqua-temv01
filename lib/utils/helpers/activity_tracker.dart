import 'package:rxdart/rxdart.dart';
import 'disposable.dart';

class ActivityTracker implements Disposable {
  BehaviorSubject<Set<String>> _activities = BehaviorSubject.seeded({});

  void start(String activity) {
    var newActivities = _activities.value;
    if (newActivities.add(activity) && !_activities.isClosed) {
      _activities.add(newActivities);
    }
  }

  void stop(String activity) {
    var newActivities = _activities.value;
    if (newActivities.remove(activity) && !_activities.isClosed) {
      _activities.add(newActivities);
    }
  }

  Stream<bool> isRunning(String activity) {
    return _activities
        .map((activities) => activities.contains(activity))
        .distinct();
  }

  Stream<bool> isRunningAnyOf(Set<String> activities) {
    return _activities
        .map((allActivities) =>
            allActivities.intersection(activities).isNotEmpty)
        .distinct();
  }

  Stream<bool> isRunningAny() {
    return _activities.map((activities) => activities.isNotEmpty).distinct();
  }

  @override
  void dispose() {
    _activities.close();
  }
}
