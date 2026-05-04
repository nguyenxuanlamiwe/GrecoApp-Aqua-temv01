import 'package:dio/dio.dart';

extension RequestOptionsRetryable on RequestOptions {
  int get retryCount => extra["retry_count"] ?? 0;
  set retryCount(int value) => extra["retry_count"] = value;
}

abstract class Authenticator<Credential> {
  void applyCredential(Credential credential, RequestOptions options);

  Future<Credential> refreshCredential(Credential oldCredential, Dio client);

  bool shouldRefreshCredential(DioError error) {
    return error.response?.statusCode == 401 &&
        error.requestOptions.retryCount == 0;
  }

  bool isRequestAuthenticatedWithCredential(
      RequestOptions options, Credential credential);
}
