// 파일 사이즈 포맷과 다운로드/열기 유틸.
// 시트/페이지에서 공통으로 사용하여 중복을 줄입니다.
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:clue/widgets/common/app_snackbar.dart';

String formatFileSize(int bytes) {
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  } else {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
}

Future<void> downloadAndOpenFile(
  BuildContext context,
  String url,
  String fileName,
) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/$fileName';
    await Dio().download(url, savePath);
    showAppSnackBar(
      context,
      '다운로드 완료: $fileName',
      isError: false,
    );
    await OpenFile.open(savePath);
  } catch (e, st) {
    debugPrint('로그 컨텍스트: $e');
    debugPrint('$st');
    if (context.mounted) {
      showAppSnackBar(context, '제출 파일을 불러오지 못했습니다. 다시 시도해주세요.');
    }
  }
}

