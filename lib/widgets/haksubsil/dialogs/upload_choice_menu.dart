// 업로드 선택 메뉴: 파일/URL 중 선택 팝업을 표시합니다.
import 'package:flutter/material.dart';

Future<String?> showUploadChoiceMenu(
  BuildContext context,
  RelativeRect position,
) async {
  return showMenu<String>(
    context: context,
    position: position,
    items: const [
      PopupMenuItem<String>(value: 'file', child: Text('파일 업로드')),
      PopupMenuItem<String>(value: 'url', child: Text('URL 링크 업로드')),
    ],
  );
}
