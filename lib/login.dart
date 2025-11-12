import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  static const _callbackScheme = 'realclue';
  static const _callbackHost = 'auth';
  static const _callbackPath = '/callback';

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
      final authUri = baseUri.resolve(
        '/oauth2/authorization/google?client_type=app',
      );
      final requestUri = authUri; // prompt 강제 제거로 재인증 루프 최소화

      debugPrint('OAuth 시작: request=$requestUri redirect=$redirectUri');

      final resultUri = await FlutterWebAuth2.authenticate(
        url: requestUri.toString(),
        callbackUrlScheme: _callbackScheme,
        options: const FlutterWebAuth2Options(preferEphemeral: false),
      );

      final returnedUri = Uri.parse(resultUri);
      debugPrint('OAuth 콜백 수신: uri=$returnedUri');
      final token =
          returnedUri.queryParameters['token'] ??
          returnedUri.queryParameters['access_token'] ??
          returnedUri.queryParameters['code'] ??
          returnedUri.fragment
              .split('&')
              .map((pair) {
                final parts = pair.split('=');
                return parts.length == 2 ? MapEntry(parts[0], parts[1]) : null;
              })
              .whereType<MapEntry<String, String>>()
              .firstWhere(
                (entry) =>
                    entry.key == 'token' ||
                    entry.key == 'access_token' ||
                    entry.key == 'code',
                orElse: () => const MapEntry('', ''),
              )
              .value;

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
        'OAuth PlatformException: code=${e.code} message=${e.message} details=${e.details}',
      );
      const cancelCodes = {
        'CANCELED',
        'CANCELLED',
        'userCancelled',
        'userCanceled',
      };
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return _LoginStyledUi(onGoogle: () => _handleGoogleLogin(context));
  }
}

class _LoginStyledUi extends StatelessWidget {
  const _LoginStyledUi({required this.onGoogle});

  final VoidCallback onGoogle;
  Future<void> _requestDevToken() async {
    try {
      final base = ApiClient.instance.dio.options.baseUrl;
      final dio = Dio(BaseOptions(baseUrl: base));

      final res = await dio.post(
        '/test',
        queryParameters: {
          'userId': '3d571e58-2cee-43cf-8f90-8d8ee3a5fa11',
          'username': 'admin2',
          'role': 'TEACHER',
        },
        options: Options(validateStatus: (_) => true),
      );

      // if (res.statusCode != 200) {
      //   debugPrint('DevToken fail: ${res.statusCode}');
      //   debugPrint('URL: ${res.requestOptions.uri}');
      //   debugPrint('Resp: ${res.data}');
      //   return;
      // }

      String? token = res.headers.value('Authorization');

      if (token == null || token.isEmpty) {
        debugPrint('⚠️ 토큰 없음. headers=${res.headers.map} body=${res.data}');
        return;
      }

      await AuthStorage.instance.saveAccessToken(token);
      final realSavedToken = await AuthStorage.instance.readAccessToken();
      debugPrint('token saved: $realSavedToken');
    } on DioException catch (e) {
      debugPrint(
        'DevToken request failed: ${e.response?.statusCode} ${e.message}',
      );
      debugPrint('URL: ${e.requestOptions.uri}');
      debugPrint('Resp: ${e.response?.data}');
    } catch (e) {
      debugPrint('DevToken error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          // 상단 연한 블루 배경
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [Color(0xFFE9F3FF), Color(0xFFF6FAFF)],
                ),
              ),
            ),
          ),
          // 하단 대각선 흰색 영역
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ClipPath(
                clipper: _DiagonalClipper(),
                child: Container(height: height * 0.58, color: Colors.white),
              ),
            ),
          ),
          // 콘텐츠
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.075),
              child: Column(
                children: [
                  SizedBox(height: height * 0.1),
                  Column(
                    children: [
                      SvgPicture.asset(
                        'assets/images/clueLogo.svg',
                        width: width * 0.42,
                      ),
                      const SizedBox(height: 10),
                      SvgPicture.asset(
                        'assets/images/LoginText.svg',
                        width: width * 0.4,
                      ),
                    ],
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _requestDevToken,
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
                  const Spacer(),
                  GestureDetector(
                    onTap: onGoogle,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          // wider, still subtle 4-direction shadow
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 14,
                            spreadRadius: 2,
                            offset: Offset(0, 3),
                          ),
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 14,
                            spreadRadius: 2,
                            offset: Offset(0, -3),
                          ),
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 14,
                            spreadRadius: 2,
                            offset: Offset(3, 0),
                          ),
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 14,
                            spreadRadius: 2,
                            offset: Offset(-3, 0),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/google.png',
                            width: 30,
                            height: 30,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            'Google 계정으로 로그인하기',
                            style: TextStyle(
                              fontSize: width * 0.042,

                              color: const Color(0xFF111111),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Opacity(
                    opacity: 0.6,
                    child: Text(
                      '로그인시 서비스 이용약관 및\n개인정보처리방침에 동의하는 것으로 간주됩니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * 0.032,
                        color: const Color(0xFF6B7280),
                        height: 1.3,
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.06),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final cut = size.height * 0.28; // 대각선 컷 깊이
    path.moveTo(0, cut);
    path.lineTo(size.width * 0.65, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
