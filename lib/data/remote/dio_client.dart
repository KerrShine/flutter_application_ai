import 'dart:async';
import 'package:dio/dio.dart';

// 自訂例外
class TimeoutException implements Exception {
  final String message;
  const TimeoutException(this.message);
  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException([this.message = '未授權']);
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
  @override
  String toString() => message;
}

class UnknownException implements Exception {
  final String message;
  const UnknownException([this.message = '未知錯誤']);
  @override
  String toString() => message;
}

// Dio錯誤處理別名
typedef DioExceptionHandle = Exception;

class DioClient {
  late final Dio _dio;
  final String baseUrl;

  DioClient({required this.baseUrl}) {
    BaseOptions options = BaseOptions(
      // 基礎url
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 45),
      contentType: 'application/json',
      // headers: {
      //   'Content-Type': 'application/json; charset=UTF-8',
      //   'Authorization': ,
      // },
    );

    _dio = Dio(options);

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  // 通用 GET
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  // 通用 POST
  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  // 通用 PUT
  Future<Response> put(String path, {dynamic data}) async {
    return _dio.put(path, data: data);
  }

  // 通用 DELETE
  Future<Response> delete(String path) async {
    return _dio.delete(path);
  }

  // 加上 Auth header (可擴充)
  void setToken(String token) {
    _dio.options.headers["Authorization"] = "Bearer $token";
  }

  // ========= 新增：安全呼叫 =========
  Future<T> apiRequest<T>({
    required Future<Response> Function() request,
    required T Function(dynamic json) mapper,
  }) async {
    try {
      final res = await request();
      // 這裡可依後端格式再做一次 code 判斷
      return mapper(res.data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (ex, stack) {
      // LogService.logger.severe("API 未知例外", ex, stack);
      print("API 未知例外: $ex, $stack");
      throw const UnknownException();
    }
  }

  // ========= 私有：把 DioError 轉成自訂例外 =========
  DioExceptionHandle _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const TimeoutException('連線逾時，請檢查網路');
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode ?? 0;
        if (status == 401) return const UnauthorizedException();
        final msg = e.response?.statusMessage ?? '伺服器錯誤 ($status)';
        return ServerException(msg);
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return const NetworkException('無法連線到伺服器，請檢查網路');

      default:
        return const UnknownException();
    }
  }
}
