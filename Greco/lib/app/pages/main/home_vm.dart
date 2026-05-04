import 'package:rxdart/rxdart.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/api/api.dart';

class HomeVMInput extends Disposable {
  final reload = PublishSubject<void>();
  final selectedFarm = PublishSubject<String>();
  final logout = PublishSubject();
  @override
  void dispose() {
    reload.close();
    selectedFarm.close();
    logout.close();
  }
}

class HomeVMOutput extends Disposable {
  final systems = PublishSubject<List<TBControlSystem>>();
  final farms = BehaviorSubject<List<TBFarm>>();
  final farmStatus = PublishSubject<(String, List<TBAttribute>)>();
  final didLogout = PublishSubject();
  @override
  void dispose() {
    systems.close();
    farms.close();
    farmStatus.close();
    didLogout.close();
  }
}

class HomeVM extends BaseVM<HomeVMInput, HomeVMOutput> {
  final TBUser user;
  HomeVM(this.user) : super(HomeVMInput(), HomeVMOutput());

  @override
  CompositeSubscription? connect() {
    final rxBag = CompositeSubscription();
    final tbService = DI.resolve<TBService>();

    input.reload
        .switchMap((_) => tbService
            .getFarms(user: user)
            .trackActivity("loading", activityTracker))
        .handleErrorBy(errorTracker)
        .bindTo(output.farms)
        .addTo(rxBag);

    output.farms
        .switchMap((farms) {
          var farmStatuses = [
            for (var aFarm in farms)
              tbService
                  .getFarmStatuses(aFarm.id.id)
                  .map((status) => (aFarm.id.id, status))
          ];
          return Rx.merge(farmStatuses);
        })
        .bindTo(output.farmStatus)
        .addTo(rxBag);

    input.selectedFarm
        .switchMap((farmId) => tbService
            .getFarmConfig(farmId)
            .trackActivity('loading', activityTracker))
        .handleErrorBy(errorTracker)
        .bindTo(output.systems)
        .addTo(rxBag);

    input.logout
        .switchMap(
            (_) => tbService.logout().trackActivity('loading', activityTracker))
        .bindTo(output.didLogout)
        .addTo(rxBag);

    return rxBag;
  }
}
