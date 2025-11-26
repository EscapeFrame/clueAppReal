import 'package:flutter/material.dart';

/// 앱 전역에서 사용하는 공통 스낵바 UI.
/// [isError] 가 true이면 오류 스타일(빨간 포인트), false이면 성공/안내 스타일(초록 포인트)로 표시됩니다.
void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = true,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();

  final Color accent =
      isError ? const Color(0xFFEF4444) : const Color(0xFF22C55E);
  final Color bg = const Color(0xFF111827).withOpacity(0.96);
  final IconData icon =
      isError ? Icons.error_outline_rounded : Icons.check_circle_rounded;

  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: accent.withOpacity(0.55), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon, size: 18, color: accent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}


