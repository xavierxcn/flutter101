import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import '../constants/app_constants.dart';

class NetworkService extends GetxService {
  late dioLib.Dio _dio;

  dioLib.Dio get dio => _dio;

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = dioLib.Dio(
      dioLib.BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      dioLib.LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => Get.log(object.toString()),
      ),
    );

    // Add error interceptor
    _dio.interceptors.add(
      dioLib.InterceptorsWrapper(
        onError: (error, handler) {
          Get.log('Network Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  // GET request
  Future<dioLib.Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dioLib.Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<dioLib.Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dioLib.Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<dioLib.Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dioLib.Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<dioLib.Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dioLib.Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
}
