//  FilePicker로 단일 파일을 선택.
import 'package:file_picker/file_picker.dart';


Future<PlatformFile?> pickFile() async {
  final result = await FilePicker.platform.pickFiles();
  if (result == null) return null;
  return result.files.first;
}
