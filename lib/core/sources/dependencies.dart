import 'package:zen8app/core/sources/event_bus.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/api/api.dart';

void registerDependencies() {
  DI.register<EventBus>(() => EventBus());
  DI.register<LocalStore>(() => LocalStore());
  DI.register<TBService>(() => TBService());
  DI.register<MQTTService>(() => MQTTService());
}
