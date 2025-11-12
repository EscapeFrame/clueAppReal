// 학습실 URL 첨부 입력 다이얼로그.
// URL 문자열을 입력받아 부모 위젯으로 반환.

import 'package:flutter/material.dart';

Future<String?> showUrlInputDialog(BuildContext context) async {
  final controller = TextEditingController();
  const brand = Color(0xff578FCA);
  String? result;
  await showDialog(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return Theme(
        data: theme.copyWith(
          inputDecorationTheme: const InputDecorationTheme(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: brand),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: brand, width: 2),
            ),
          ),
          dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
        ),
        child: AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('링크 업로드'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'URL을 입력하세요'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                result = controller.text.trim();
                Navigator.pop(ctx);
              },
              child: const Text('등록', style: TextStyle(color: brand)),
            ),
          ],
        ),
      );
    },
  );
  return result;
}
