import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/core/core.dart';

class TBAuthenticator extends Authenticator<TBCredential> {
  @override
  bool shouldRefreshCredential(DioError error) {
    return error.response?.statusCode == 401 &&
        error.requestOptions.retryCount == 0;
  }

  @override
  void applyCredential(TBCredential credential, RequestOptions options) {
    options.headers["X-Authorization"] = "Bearer ${credential.token}";
  }

  @override
  bool isRequestAuthenticatedWithCredential(
      RequestOptions options, TBCredential credential) {
    final requestAuthorizationHeader = options.headers["X-Authorization"];
    final currentAuthorizationHeader = "Bearer ${credential.token}";
    return requestAuthorizationHeader == currentAuthorizationHeader;
  }

  @override
  Future<TBCredential> refreshCredential(
      TBCredential oldCredential, Dio client) {
    print("------- begin refresh token THINGSBOARD");

    return Dio(client.options).post("/api/auth/token",
        data: {"refreshToken": oldCredential.refreshToken}).then((response) {
      print("------ SUCCESS refresh token THINGSBOARD: ${response.data}");
      final credential = TBCredential.fromJson(response.data);
      DI
          .resolve<LocalStore>()
          .setValue(LocalStoreKey.tbCredential, jsonEncode(credential));
      return credential;
    }).catchError((e) {
      Session.endAuthenticatedSession(
          reason: 'Không thể làm mới phiên đăng nhập');
    });
  }
}
