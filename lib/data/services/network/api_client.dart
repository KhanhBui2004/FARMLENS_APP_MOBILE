import 'package:dio/dio.dart';
import 'package:farmlens_app/data/services/network/auth_interceptor.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://warless-aden-atavistically.ngrok-free.dev',
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 60),
    ),
  )..interceptors.add(AuthInterceptor());
}
