import 'package:dio/dio.dart';
import 'package:farmlens_app/data/services/network/auth_interceptor.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://warless-aden-atavistically.ngrok-free.dev',
      connectTimeout: Duration(seconds: 15),
      receiveTimeout: Duration(seconds: 15),
    ),
  )..interceptors.add(AuthInterceptor());
}
