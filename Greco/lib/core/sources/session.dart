import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:media_kit/media_kit.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:zen8app/core/sources/network.dart';
import 'package:dio/dio.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/core/core.dart';
import 'tb_authenticator.dart';

class Session {
  static Env _currentEnv = Env.dev;
  static Env get currentEnv => _currentEnv;

  static Config _currentConfig = Config.dev;
  static Config get currentConfig => _currentConfig;

  static TBUser? _currentUser;
  static TBUser? get currentUser => _currentUser;
  static bool get isLoggedIn => _currentUser != null;

  static final _logoutEvents = PublishSubject<String?>();
  static Stream<String?> get logoutEvent => _logoutEvents.stream;

  static final tbClient = Dio();
  static final tbPublicClient = Dio();

  Session._();

  static Future<void> initialize(Env env) async {
    var store = DI.resolve<LocalStore>();
    Intl.systemLocale = "vi";
    try {
      MediaKit.ensureInitialized();
    } catch (e) {
      print('-------- media kit error: $e');
    }

    await initializeDateFormatting('vi');

    //setup env, configurations
    _currentEnv = env;
    _currentConfig = Config.env(env);

    //config network
    _configAPIClients(_currentConfig);

    //load previous credentials
    var tbUser = await store.getValue(
      LocalStoreKey.loggedInUser,
      transform: (value) => TBUser.fromJson(jsonDecode(value)),
    );

    final tbCredential = await store.getValue(
      LocalStoreKey.tbCredential,
      transform: (value) => TBCredential.fromJson(jsonDecode(value)),
    );

    if (tbUser != null && tbCredential != null) {
      _currentUser = tbUser;
      tbClient.ex.setAuthCredential(
        credential: tbCredential,
        authenticator: TBAuthenticator(),
      );

      _registerFCMToken(tbUser);
    }
  }

  static Future<void> startAuthenticatedSession(
    TBCredential credential,
    TBUser user,
  ) async {
    _currentUser = user;
    var store = DI.resolve<LocalStore>();
    await store.setValue(
      LocalStoreKey.tbCredential,
      jsonEncode(credential),
    );

    await store.setValue(
      LocalStoreKey.loggedInUser,
      jsonEncode(user),
    );

    tbClient.ex.setAuthCredential(
      credential: credential,
      authenticator: TBAuthenticator(),
    );

    _registerFCMToken(user);
  }

  static Future<void> endAuthenticatedSession({String? reason}) async {
    await DI.resolve<LocalStore>().removeMany([
      LocalStoreKey.tbCredential,
      LocalStoreKey.loggedInUser,
    ]);

    if (_currentUser != null) {
      _unregisterFCMToken(_currentUser!);
    }

    _currentUser = null;
    tbClient.ex.removeInterceptors();
    _logoutEvents.add(reason);
  }

  static _configAPIClients(Config config) {
    tbClient.ex.config(baseUrl: config.tbBaseUrl);
    tbPublicClient.ex.config(baseUrl: config.tbBaseUrl);
  }

  static Future<void> _registerFCMToken(TBUser user) async {
    try {
      var settings = await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        await FirebaseMessaging.instance.subscribeToTopic(user.id.id);
      }
    } catch (err) {
      print("register fcm_token error: $err");
    }
  }

  static Future<void> _unregisterFCMToken(TBUser user) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(user.id.id);
  }
}
