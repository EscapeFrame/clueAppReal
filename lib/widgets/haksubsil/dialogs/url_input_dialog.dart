// URL 입력 다이얼로그: 사용자가 입력한 링크를 콜백으로 전달합니다.
import 'package:flutter/material.dart';

Future<void> showUrlInputDialog(
  BuildContext context,
  void Function(String) onUrlAdded,
) async {
  final controller = TextEditingController();
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('링크 업로드'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'URL을 입력하세요'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            final url = controller.text.trim();
            if (url.isNotEmpty) onUrlAdded(url);
            Navigator.pop(ctx);
          },
          child: const Text('등록'),
        ),
      ],
    ),
  );
}
