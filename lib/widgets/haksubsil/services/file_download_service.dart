// URL로 파일을 저장하고 완료 후 열어줍니다.
// *************************수정(****************************************
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

Future<void> downloadFile(
  BuildContext context,
  String url,
  String fileName,
) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/$fileName';
    await Dio().download(url, savePath);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('다운로드 완료: $fileName')));
    }
    await OpenFile.open(savePath);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('다운로드 실패: $e')));
    }
  }
}
