import 'package:rxdart/rxdart.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/api/api.dart';

class TBTimeseriesChartVMInput extends Disposable {
  final reload = PublishSubject<
      ({String key, int startTs, int endTs, int? interval, String agg})>();
  @override
  void dispose() {
    reload.close();
  }
}

class TBTimeseriesChartVMOutput extends Disposable {
  final values = PublishSubject<List<TBTimeseriesValue>>();
  @override
  void dispose() {
    values.close();
  }
}

class TBTimeseriesChartVM
    extends BaseVM<TBTimeseriesChartVMInput, TBTimeseriesChartVMOutput> {
  final TBControlSystem system;
  TBTimeseriesChartVM(this.system)
      : super(TBTimeseriesChartVMInput(), TBTimeseriesChartVMOutput());

  @override
  CompositeSubscription? connect() {
    final rxBag = CompositeSubscription();
    final tbService = DI.resolve<TBService>();

    input.reload
        .switchMap((param) {
          return tbService
              .getTimeseriesValues(
                deviceId: system.deviceId,
                key: param.key,
                startTs: param.startTs,
                endTs: param.endTs,
                interval: param.interval,
                agg: param.agg,
              )
              .trackActivity("loading", activityTracker);
        })
        .handleErrorBy(errorTracker)
        .bindTo(output.values)
        .addTo(rxBag);

    return rxBag;
  }
}
