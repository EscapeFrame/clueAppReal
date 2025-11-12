import 'package:clue/main.dart'; // AppNavigator, AuthGateBridge
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'api_client.dart';
import 'auth_storage.dart';

/// refresh_token 보조 확장 (AuthStorage에 메서드 없을 때 대비)
extension _AuthStorageRefreshExt on AuthStorage {
  static const _kRefreshToken = 'refresh_token';
  Future<void> saveRefreshToken(String token) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: _kRefreshToken, value: token);
  }

  Future<String?> readRefreshToken() async {
    const storage = FlutterSecureStorage();
    return storage.read(key: _kRefreshToken);
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  static const _callbackScheme = 'realclue';
  static const _callbackHost = 'auth';
  static const _callbackPath = '/callback';

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _loggingIn = false; // 중복 클릭 방지
  bool _navigated = false; // 중복 네비 방지

  Future<void> _handleGoogleLogin(BuildContext context) async {
    if (_loggingIn) return;
    setState(() => _loggingIn = true);

    final redirectUri = Uri(
      scheme: Login._callbackScheme,
      host: Login._callbackHost,
      path: Login._callbackPath,
    );

    try {
      final base = ApiClient.instance.dio.options.baseUrl.trim();
      if (base.isEmpty) {
        _snack('BASE_URL이 비어있습니다.');
        setState(() => _loggingIn = false);
        return;
      }

      final baseUri = Uri.parse(base);
      final requestUri = baseUri.resolve(
        '/oauth2/authorization/google?client_type=app',
      );

      debugPrint('OAuth 시작: request=$requestUri redirect=$redirectUri');

      final resultUri = await FlutterWebAuth2.authenticate(
        url: requestUri.toString(),
        callbackUrlScheme: Login._callbackScheme,
        options: const FlutterWebAuth2Options(preferEphemeral: false),
      );

      final returnedUri = Uri.parse(resultUri);
      debugPrint('✅ OAuth 콜백 수신: uri=$returnedUri');

      // --- 토큰 파싱
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
                (e) =>
                    e.key == 'token' ||
                    e.key == 'access_token' ||
                    e.key == 'code',
                orElse: () => const MapEntry('', ''),
              )
              .value;

      if (token.isEmpty) {
        debugPrint('❌ OAuth callback missing token. uri=$returnedUri');
        _snack('로그인 결과에 토큰이 없습니다.');
        setState(() => _loggingIn = false);
        return;
      }

      // --- 저장
      final bearer = token.startsWith('Bearer ') ? token : 'Bearer $token';
      await AuthStorage.instance.saveAccessToken(bearer);
      final rt = returnedUri.queryParameters['refresh_token'];
      if (rt != null && rt.isNotEmpty) {
        await AuthStorage.instance.saveRefreshToken(rt);
      }
      debugPrint('✅ AccessToken/RefreshToken 저장 완료');

      // 커스텀탭 → 액티비티 복귀 안정화를 위해 아주 짧게 대기
      await Future.delayed(const Duration(milliseconds: 120));

      // AuthGate에 토큰 재확인 요청
      await AuthGateBridge.refresh();
      debugPrint('✅ AuthGateBridge.refresh() 완료');

      // --- 전역 네비게이터로 전환 (항상 같은 루트)
      if (!_navigated) {
        _navigated = true;
        AppNavigator.key.currentState?.pushNamedAndRemoveUntil(
          '/main',
          (route) => false,
        );
        debugPrint('✅ /main pushNamedAndRemoveUntil 완료');
      }
    } on MissingPluginException {
      debugPrint('❌ flutter_web_auth_2 플러그인 미등록');
      _snack('로그인 모듈이 로드되지 않았어요. 앱을 다시 시작해 주세요.');
    } on PlatformException catch (e) {
      debugPrint('❌ PlatformException: ${e.code} / ${e.message}');
      const cancel = {'CANCELED', 'CANCELLED', 'userCancelled', 'userCanceled'};
      _snack(cancel.contains(e.code) ? '로그인을 취소했어요.' : '로그인 중 오류가 발생했습니다.');
    } catch (e, st) {
      debugPrint('❌ OAuth 예외: $e');
      debugPrintStack(stackTrace: st);
      _snack('로그인 중 알 수 없는 오류가 발생했습니다.');
    } finally {
      if (mounted) setState(() => _loggingIn = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return _LoginStyledUi(
      onGoogle: _loggingIn ? null : () => _handleGoogleLogin(context),
      loggingIn: _loggingIn,
    );
  }
}

/// ───────────────── UI ─────────────────
class _LoginStyledUi extends StatelessWidget {
  const _LoginStyledUi({required this.onGoogle, required this.loggingIn});
  final VoidCallback? onGoogle;
  final bool loggingIn;

  // (선택) 개발용 토큰 버튼
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
      final token = res.headers.value('Authorization');
      if (token == null || token.isEmpty) {
        debugPrint('⚠️ 토큰 없음. headers=${res.headers.map} body=${res.data}');
        return;
      }
      await AuthStorage.instance.saveAccessToken(token);
      debugPrint('token saved');
      // 전역 네비게이터로 바로 이동해도 됨:
      AppNavigator.key.currentState?.pushNamedAndRemoveUntil(
        '/main',
        (r) => false,
      );
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
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ClipPath(
                clipper: _DiagonalClipper(),
                child: Container(height: height * 0.58, color: Colors.white),
              ),
            ),
          ),
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
                          const Text(
                            'google 계정으로 로그인하기',
                            style: TextStyle(color: Color(0xff111111)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onGoogle,
                    child: Opacity(
                      opacity: loggingIn ? 0.6 : 1,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: const [
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
                            const Text(
                              'Google 계정으로 로그인하기',
                              style: TextStyle(color: Color(0xFF111111)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Opacity(
                    opacity: 0.6,
                    child: Text(
                      '로그인시 서비스 이용약관 및\n개인정보처리방침에 동의하는 것으로 간주됩니다.',
                      textAlign: TextAlign.center,
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
    final cut = size.height * 0.28;
    path
      ..moveTo(0, cut)
      ..lineTo(size.width * 0.65, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
