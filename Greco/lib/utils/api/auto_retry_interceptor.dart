import 'package:dio/dio.dart';
import 'authenticator.dart';
import 'multipart_file_reusable.dart';

class _RetryOperation {
  DioError error;
  ErrorInterceptorHandler handler;
  _RetryOperation(this.error, this.handler);
}

class AutoRetryInterceptor<Credential> extends Interceptor {
  final Dio _client;
  final Authenticator<Credential> _authenticator;
  Credential _credential;

  bool _isDisposed = false;
  bool _isRefreshing = false;
  List<_RetryOperation> _pendingOperations = [];

  AutoRetryInterceptor({
    required Dio client,
    required Credential credential,
    required Authenticator<Credential> authenticator,
  })  : _client = client,
        _credential = credential,
        _authenticator = authenticator;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_isDisposed) {
      _authenticator.applyCredential(_credential, options);
      handler.next(options);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        "✓✓✓✓✓✓✓✓✓✓API SUCCESS✓✓✓✓✓✓✓✓✓✓✓\n✓ [URL]: ${response.requestOptions.uri}\n✓ [HEADER]: ${response.requestOptions.headers}\n✓ [Payload]${response.requestOptions.data}\n✓ [Status code]: ${response.statusCode}\n✓ [Response]\n${response.data}\n✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓");
    if (!_isDisposed) {
      handler.next(response);
    }
  }

  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      _isRefreshing = false;
      _pendingOperations = [];
    }
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    print(
        "!!!!!!!!!!!!!!!API ERROR!!!!!!!!!!!!!!!!\n✓ [URL]: ${err.requestOptions.uri}\n✓ [HEADER]: ${err.requestOptions.headers}\n✓ [Payload]${err.requestOptions.data}\n✓ [Status code]: ${err.response?.statusCode}\n✓ [Response]\n${err.response?.data}\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    if (_isDisposed) {
      return;
    }

    if (!_authenticator.shouldRefreshCredential(err)) {
      return handler.next(err);
    }

    if (!_authenticator.isRequestAuthenticatedWithCredential(
        err.requestOptions, _credential)) {
      if (_isRefreshing) {
        return _pendingOperations.add(_RetryOperation(err, handler));
      } else {
        return _retry(_RetryOperation(err, handler));
      }
    }

    _pendingOperations.add(_RetryOperation(err, handler));

    if (_isRefreshing) {
      return;
    }

    _isRefreshing = true;

    _authenticator
        .refreshCredential(_credential, _client)
        .then((newCredential) {
      if (!_isDisposed) {
        _credential = newCredential;
        _isRefreshing = false;
        _retryAllPendingOperations();
      }
    }).catchError((_) {
      dispose();
    });
  }

  void _retry(_RetryOperation operation) {
    if (operation.error.type == DioErrorType.cancel) {
      return operation.handler.next(operation.error);
    }

    var requestOptions = operation.error.requestOptions;

    if (!_isRequestValidToRetry(requestOptions)) {
      return operation.handler.next(
        DioError(
          requestOptions: requestOptions,
          error:
              "[AutoRetryInterceptor] FormData files must all be MultipartFileReusable instances",
        ),
      );
    }

    requestOptions.retryCount++;

    _client.fetch(requestOptions).then((response) {
      if (!_isDisposed) {
        operation.handler.resolve(response);
      }
    }).catchError((e) {
      if (!_isDisposed) {
        if (e is DioError) {
          operation.handler.next(e);
        } else {
          operation.handler
              .next(DioError(requestOptions: requestOptions, error: e));
        }
      }
    });
  }

  bool _isRequestValidToRetry(RequestOptions options) {
    if (options.data is! FormData) {
      return true;
    }
    return !(options.data as FormData)
        .files
        .any((e) => e is! MultipartFileReusable);
  }

  void _retryAllPendingOperations() {
    print("--------- retry all operations");
    var retryOperations = _pendingOperations;
    _pendingOperations = [];
    for (var operation in retryOperations) {
      _retry(operation);
    }
  }
}
