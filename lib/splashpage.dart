// lib/splash_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool show = false;

  @override
  void initState() {
    super.initState();

    // 첫 프레임 그려진 뒤 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => show = true);                  // AnimatedOpacity 시작
      await Future.delayed(const Duration(milliseconds: 500)); // 로고 보이는 시간
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');      // 홈으로 교체 이동
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _SplashView();
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 네이티브 스플래시 color와 맞추기
      body: Center(
        child: _LogoFade(),          // 분리하면 재사용/테스트 쉬움
      ),
    );
  }
}

class _LogoFade extends StatefulWidget {
  const _LogoFade();

  @override
  State<_LogoFade> createState() => _LogoFadeState();
}

class _LogoFadeState extends State<_LogoFade> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    // 프레임 이후 서서히 보이게
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _opacity = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 350), // 블로그처럼 1~3초 사이 취향대로
      curve: Curves.easeOut,
      child: SvgPicture.asset(
        'assets/images/logo.svg',
        width: 160,
        height: 160,
      ),
    );
  }
}