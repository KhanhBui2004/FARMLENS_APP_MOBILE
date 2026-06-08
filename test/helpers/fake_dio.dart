import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class RequestRecord {
  RequestRecord({
    required this.method,
    required this.path,
    required this.data,
    required this.queryParameters,
    required this.headers,
  });

  final String method;
  final String path;
  final Object? data;
  final Map<String, dynamic>? queryParameters;
  final Map<String, dynamic>? headers;
}

Dio FakeDio(FutureOr<Response<dynamic>> Function(RequestRecord request)
    responseFactory) {
  final dio = Dio();
  dio.httpClientAdapter = _FakeHttpClientAdapter(responseFactory);
  return dio;
}

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this.responseFactory);

  final FutureOr<Response<dynamic>> Function(RequestRecord request)
      responseFactory;

  final List<RequestRecord> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final request = RequestRecord(
      method: options.method,
      path: options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      headers: options.headers,
    );
    requests.add(request);

    final response = await responseFactory(request);
    final body = response.data is String
        ? response.data as String
        : jsonEncode(response.data);

    return ResponseBody.fromString(
      body,
      response.statusCode ?? 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Response<dynamic> buildResponse(
  String path,
  dynamic data, {
  int statusCode = 200,
}) {
  return Response<dynamic>(
    data: data,
    statusCode: statusCode,
    requestOptions: RequestOptions(path: path),
  );
}
