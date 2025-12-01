import 'package:flutter/material.dart';

class QuizEnter extends StatelessWidget {
  const QuizEnter({
    super.key,
    this.code = '2939',
    this.embed = false,
    this.onBack,
  });

  final String code;
  final bool embed;
  final VoidCallback? onBack;

  Widget _buildCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      constraints: const BoxConstraints(maxWidth: 520),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onBack != null)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black54,
                ),
                onPressed: onBack,
                splashRadius: 20,
              ),
            ),
          if (onBack != null) const SizedBox(height: 8),
          Text(
            code,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF0A84FF),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '퀴즈 참여완료',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Image.asset(
            'assets/images/owl.png',
            height: 170,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (embed) {
      return _buildCard(context);
    }
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(child: Center(child: _buildCard(context))),
    );
  }
}
