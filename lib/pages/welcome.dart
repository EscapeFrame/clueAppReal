import 'dart:async';

import 'package:flutter/material.dart';
// Removed flutter_svg import since we now use PNG

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/main');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Padding(
                padding: EdgeInsets.only(bottom: width * 0.04),
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Welcome to '),
                      TextSpan(
                        text: 'CLUE',
                        style: const TextStyle(
                          color: Color(0xFF0077FF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(text: ' service'),
                    ],
                    style: TextStyle(
                      fontSize: width * 0.06,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Image (PNG for reliable rendering)
              Image.asset(
                'assets/images/ClueSplash.png',
                width: width * 0.8,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
