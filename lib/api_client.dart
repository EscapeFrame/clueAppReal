import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

import 'auth_storage.dart';
import 'main.dart';

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
          if (options.extra['skipAuth'] == true) {
            handler.next(options);
            return;
          }
          final token = await AuthStorage.instance.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] =
                token; // "Bearer ..." 형태로 저장돼있다면 그대로
          }
          handler.next(options);
        },
        onError: (err, handler) async {
          final status = err.response?.statusCode ?? 0;
          final alreadyRetried =
              err.requestOptions.extra['refreshRetried'] == true;

          if (status == 401 && !alreadyRetried) {
            final refresh = await AuthStorage.instance.readRefreshToken();
            if (refresh != null && refresh.isNotEmpty) {
              try {
                final tokens = await _reissueTokens(refresh);
                if (tokens != null) {
                  final access = tokens['accessToken'] ?? '';
                  final refreshNew = tokens['refreshToken'] ?? '';
                  final bearer =
                      access.startsWith('Bearer ') ? access : 'Bearer $access';

                  await AuthStorage.instance.saveAccessToken(bearer);
                  if (refreshNew.isNotEmpty) {
                    await AuthStorage.instance.saveRefreshToken(refreshNew);
                  }

                  final req = err.requestOptions;
                  final headers = Map<String, dynamic>.from(req.headers)
                    ..remove('Authorization');
                  headers['Authorization'] = bearer;

                  final resp = await _dio.request<dynamic>(
                    req.path,
                    data: req.data,
                    queryParameters: req.queryParameters,
                    options: Options(
                      method: req.method,
                      headers: headers,
                      contentType: req.contentType,
                      responseType: req.responseType,
                      extra: {
                        ...req.extra,
                        'refreshRetried': true,
                      },
                    ),
                  );
                  handler.resolve(resp);
                  return;
                }
              } catch (_) {
                // refresh 실패 시 원본 에러 반환
              }
            }
            // refresh 재발급 실패 시 로그아웃 처리
            try {
              await _logoutAndRedirect();
            } catch (_) {
              // ignore
            }
          }
          handler.next(err);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;

  Dio get dio => _dio;

  Future<Map<String, dynamic>?> _reissueTokens(String refreshToken) async {
    try {
      final plain = Dio(
        BaseOptions(
          baseUrl: _dio.options.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      final res = await plain.post<Map<String, dynamic>>(
        '/app/reissue',
        options: Options(
          headers: {'cookie': 'refresh_token=$refreshToken'},
          extra: {'skipAuth': true},
        ),
      );
      final data = res.data;
      if (res.statusCode == 200 && data is Map<String, dynamic>) {
        return data;
      }
    } catch (_) {
      // ignore
    }
    return null;
  }

  Future<void> _logoutAndRedirect() async {
    final plain = Dio(
      BaseOptions(
        baseUrl: _dio.options.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    try {
      final refresh = await AuthStorage.instance.readRefreshToken();
      await plain.post(
        '/api/logout',
        options: Options(
          headers: refresh != null && refresh.isNotEmpty
              ? {'cookie': 'refresh_token=$refresh'}
              : {},
          extra: {'skipAuth': true},
        ),
      );
    } catch (_) {
      // ignore logout error
    }
    await AuthStorage.instance.clear();
    // UI 전환
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = AppNavigator.key.currentState;
      nav?.pushNamedAndRemoveUntil('/login', (route) => false);
    });
  }
}
