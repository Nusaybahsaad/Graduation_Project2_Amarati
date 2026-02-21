import 'package:dio/dio.dart';

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});

  factory ServerException.fromDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return ServerException(
        message: 'انتهت مهلة الاتصال بالخادم. يرجى المحاولة مرة أخرى.',
      );
    }

    if (error.response != null) {
      final res = error.response!;
      if (res.data is Map && res.data['detail'] != null) {
        final detail = res.data['detail'];
        return ServerException(
          message: detail is String ? detail : detail.toString(),
          statusCode: res.statusCode,
        );
      }
      return ServerException(
        message: 'حدث خطأ غير متوقع. (Code: ${res.statusCode})',
        statusCode: res.statusCode,
      );
    }

    return ServerException(
      message: 'تعذر الاتصال بالخادم. تحقق من اتصالك بالإنترنت.',
    );
  }

  @override
  String toString() => message;
}
