import 'package:dio/dio.dart';
import 'package:zen8app/utils/utils.dart';

extension _AppErrorConverting on Extendable {
  AppError asAppError() {
    if (base is AppError) {
      return base as AppError;
    }
    try {
      String? description =
          (base as DioError).response?.data["detail"] as String?;
      return AppError(description: description, underlyingError: base);
    } catch (_) {
      return AppError(underlyingError: base);
    }
  }
}

extension StreamAppErrorConverting<T> on Stream<T> {
  Stream<AppError> asAppError() {
    return map((e) => e.ex.asAppError());
  }
}

enum AppErrorType { other }
