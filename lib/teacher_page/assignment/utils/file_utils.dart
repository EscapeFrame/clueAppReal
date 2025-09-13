import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('다운로드 완료: $fileName')),
    );
    await OpenFile.open(savePath);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('다운로드 실패: $e')),
    );
  }
}

