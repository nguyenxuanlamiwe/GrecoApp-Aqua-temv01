import 'package:dio/dio.dart';
import 'package:zen8app/utils/utils.dart';

extension NetworkConfig on Extendable<Dio> {
  void config({required String baseUrl}) {
    base.options.baseUrl = baseUrl;
  }

  void setAuthCredential<Credential>({
    required Credential credential,
    required Authenticator<Credential> authenticator,
  }) {
    removeInterceptors();
    _addNewInterceptors(credential, authenticator);
  }

  //Private methods
  void _addNewInterceptors<Credential>(
    Credential credential,
    Authenticator<Credential> authenticator,
  ) {
    base.interceptors.add(
      AutoRetryInterceptor(
        client: base,
        credential: credential,
        authenticator: authenticator,
      ),
    );
  }

  void removeInterceptors() {
    final autoRetryInterceptors =
        base.interceptors.whereType<AutoRetryInterceptor>();
    for (var interceptor in autoRetryInterceptors) {
      interceptor.dispose();
    }
    base.interceptors.clear();
  }
}
