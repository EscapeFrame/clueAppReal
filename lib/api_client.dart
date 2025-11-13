import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'auth_storage.dart';

class ApiClient {
  static const bool useAltBase = false; // true면 BASE_URL_ALT 사용

  ApiClient._internal() {
    final selectedBase =
        ((useAltBase ? dotenv.env['BASE_URL_ALT'] : dotenv.env['BASE_URL']) ??
                '')
            .trim();

    _dio = Dio(
      BaseOptions(
        baseUrl: selectedBase,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // JWT 자동 첨부
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AuthStorage.instance.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] =
                token; // "Bearer ..." 형태로 저장돼있다면 그대로
          }
          handler.next(options);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;

  Dio get dio => _dio;
}
