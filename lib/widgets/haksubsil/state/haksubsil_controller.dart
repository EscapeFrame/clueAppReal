// 업로드 파일/링크와 제출 상태를 관리합니다.
// ***********필요없을듯***************8
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class HaksubsilController extends ChangeNotifier {
  bool submitted = false;
  bool loading = false;
  String? error;
  Map<String, dynamic>? detail;

  final List<PlatformFile> uploadedFiles = [];
  final List<String> uploadedUrls = [];

  void toggleSubmitted() {
    submitted = !submitted;
    notifyListeners();
  }

  void addFile(PlatformFile f) {
    uploadedFiles.add(f);
    notifyListeners();
  }

  void removeFileAt(int index) {
    uploadedFiles.removeAt(index);
    notifyListeners();
  }

  void addUrl(String url) {
    uploadedUrls.add(url);
    notifyListeners();
  }

  void removeUrlAt(int index) {
    uploadedUrls.removeAt(index);
    notifyListeners();
  }
}
