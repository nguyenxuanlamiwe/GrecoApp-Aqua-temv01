import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:zen8app/api/api.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/models/models.dart';

class LoginVMInput extends Disposable {
  final reload = PublishSubject();
  final login = PublishSubject<(String, String, bool)>();
  @override
  void dispose() {
    reload.close();
    login.close();
  }
}

class LoginVMOutput extends Disposable {
  final response = PublishSubject<(TBCredential, TBUser)>();
  final prevLoginInfo = PublishSubject<(String, String, bool)>();
  @override
  void dispose() {
    response.close();
    prevLoginInfo.close();
  }
}

class LoginVM extends BaseVM<LoginVMInput, LoginVMOutput> {
  LoginVM() : super(LoginVMInput(), LoginVMOutput());

  @override
  CompositeSubscription? connect() {
    final rxBag = CompositeSubscription();
    final tbService = DI.resolve<TBService>();
    final store = DI.resolve<LocalStore>();

    input.login
        .doOnData((param) {
          var (username, password, willSave) = param;
          store.setValue(LocalStoreKey.saveLoginInfo, willSave);
          if (willSave) {
            store.setValue(LocalStoreKey.prevUsername, username);
            store.setValue(LocalStoreKey.prevPassword, password);
          } else {
            store.removeMany({
              LocalStoreKey.prevUsername,
              LocalStoreKey.prevPassword,
            });
          }
        })
        .switchMap((param) {
          var (username, password, _) = param;
          if (!username.contains("@")) {
            username += '@grcvn.com';
          }
          return tbService
              .login(username, password)
              .trackActivity("loading", activityTracker);
        })
        .handleErrorBy(errorTracker)
        .bindTo(output.response)
        .addTo(rxBag);

    input.reload
        .asyncMap((_) async {
          var username =
              await store.getValue<String>(LocalStoreKey.prevUsername) ?? "";
          var password =
              await store.getValue<String>(LocalStoreKey.prevPassword) ?? "";
          var willSave =
              await store.getValue<bool>(LocalStoreKey.saveLoginInfo) ?? true;
          return (username, password, willSave);
        })
        .bindTo(output.prevLoginInfo)
        .addTo(rxBag);
    return rxBag;
  }
}
