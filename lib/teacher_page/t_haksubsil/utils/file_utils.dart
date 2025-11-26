// 학습실 파일 유틸.
// 파일 선택(pickFile), 사이즈 포맷, 다운로드 후 열기(downloadAndOpen) 기능을 제공합니다.

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:clue/widgets/common/app_snackbar.dart';

String formatFileSize(int bytes) {
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / 1024).toStringAsFixed(1)} KB';
}

Future<PlatformFile?> pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result != null) {
    return result.files.first;
  }
  return null;
}

Future<void> downloadAndOpen(
  BuildContext context,
  List<int> bytes,
  String fileName,
) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/$fileName';
    final file = File(savePath);
    await file.writeAsBytes(bytes);
    if (context.mounted) {
      showAppSnackBar(
        context,
        '다운로드 완료: $fileName',
        isError: false,
      );
    }
    await OpenFile.open(savePath);
  } catch (e, st) {
    debugPrint('로그 컨텍스트: $e');
    debugPrint('$st');
    if (context.mounted) {
      showAppSnackBar(context, '파일을 다운로드하지 못했습니다. 다시 시도해주세요.');
    }
  }
}
