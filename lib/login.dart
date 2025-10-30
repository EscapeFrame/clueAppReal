import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import 'api_client.dart';
import 'auth_storage.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  static const _callbackScheme = 'realclue';
  static const _callbackHost = 'login';
  static const _callbackPath = '';

  Future<void> _handleGoogleLogin(BuildContext context) async {
    final redirectUri = Uri(
      scheme: _callbackScheme,
      host: _callbackHost,
      path: _callbackPath,
    );

    try {
      final base = ApiClient.instance.dio.options.baseUrl.trim();
      if (base.isEmpty) {
        _showSnackBar(context, 'BASE_URL이 비어있습니다.');
        return;
      }

      final baseUri = Uri.parse(base);
      final authUri = baseUri.resolve('/oauth2/authorization/google?client_type=app');
      final requestUri = authUri.replace(
        queryParameters: {
          ...authUri.queryParameters,
          'prompt': 'login',
        },
      );

      debugPrint('OAuth 시작: request=$requestUri redirect=$redirectUri');

      final resultUri = await FlutterWebAuth2.authenticate(
        url: requestUri.toString(),
        callbackUrlScheme: _callbackScheme,
        options: const FlutterWebAuth2Options(
          preferEphemeral: true,
        ),
      );

      final returnedUri = Uri.parse(resultUri);
      debugPrint('OAuth 콜백 수신: uri=$returnedUri');
      final token = returnedUri.queryParameters['token'] ??
          returnedUri.queryParameters['access_token'] ??
          returnedUri.queryParameters['code'] ??
          returnedUri.fragment.split('&').map((pair) {
            final parts = pair.split('=');
            return parts.length == 2 ? MapEntry(parts[0], parts[1]) : null;
          }).whereType<MapEntry<String, String>>().firstWhere(
                (entry) =>
                    entry.key == 'token' ||
                    entry.key == 'access_token' ||
                    entry.key == 'code',
                orElse: () => const MapEntry('', ''),
              ).value;

      if (token.isEmpty) {
        debugPrint('OAuth callback missing token. uri=$returnedUri');
        _showSnackBar(context, '로그인 결과에 토큰이 없습니다.');
        return;
      }

      await AuthStorage.instance.saveAccessToken(token);
      _showSnackBar(context, '로그인에 성공했어요.');
    } on MissingPluginException {
      debugPrint('OAuth 플러그인 없음: flutter_web_auth_2가 Native에 등록되지 않았습니다.');
      _showSnackBar(context, '로그인 모듈이 로드되지 않았어요. 앱을 다시 시작해 주세요.');
    } on PlatformException catch (e) {
      debugPrint(
          'OAuth PlatformException: code=${e.code} message=${e.message} details=${e.details}');
      const cancelCodes = {'CANCELED', 'CANCELLED', 'userCancelled', 'userCanceled'};
      if (cancelCodes.contains(e.code)) {
        _showSnackBar(context, '로그인을 취소했어요.');
      } else {
        _showSnackBar(context, '로그인 중 오류가 발생했습니다.');
      }
    } catch (e, stackTrace) {
      debugPrint('OAuth 예기치 못한 오류: $e');
      debugPrintStack(stackTrace: stackTrace);
      _showSnackBar(context, '로그인 중 알 수 없는 오류가 발생했습니다.');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: width * 0.045),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/clueLogo.svg',
                width: width * 0.4,
              ),
              SizedBox(height: height * 0.056),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _handleGoogleLogin(context),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.05,
                    vertical: height * 0.028,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffF3F3F3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/800px-Google_%22G%22_logo.svg.png',
                        width: width * 0.07,
                      ),
                      SizedBox(width: width * 0.045),
                      Text(
                        'google 계정으로 로그인하기',
                        style: TextStyle(
                          fontSize: width * 0.04,
                          color: const Color(0xff111111),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * 0.15),
            ],
          ),
        ),
      ),
    );
  }
}