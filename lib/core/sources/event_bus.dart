import 'package:rxdart/rxdart.dart';

class EventBus {
  final mqttUpdates = PublishSubject<Map<String, Map<String, dynamic>>>();
  final mqttConnectionStatus = BehaviorSubject<bool>.seeded(false);
}
