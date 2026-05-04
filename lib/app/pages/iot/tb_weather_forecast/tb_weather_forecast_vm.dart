import 'package:rxdart/rxdart.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/api/api.dart';

class TBWeatherForecastVMInput extends Disposable {
  final reload = PublishSubject<String>();
  @override
  void dispose() {
    reload.close();
  }
}

class TBWeatherForecastVMOutput extends Disposable {
  final response = PublishSubject<List<TBWeather>>();
  @override
  void dispose() {
    response.close();
  }
}

class TBWeatherForecastVM
    extends BaseVM<TBWeatherForecastVMInput, TBWeatherForecastVMOutput> {
  TBWeatherForecastVM()
      : super(TBWeatherForecastVMInput(), TBWeatherForecastVMOutput());

  @override
  CompositeSubscription? connect() {
    final rxBag = CompositeSubscription();
    final tbService = DI.resolve<TBService>();

    input.reload
        .switchMap((deviceId) => tbService
            .getWeatherForNext10Days(deviceId)
            .trackActivity("loading", activityTracker))
        .handleErrorBy(errorTracker)
        .bindTo(output.response)
        .addTo(rxBag);

    return rxBag;
  }
}
