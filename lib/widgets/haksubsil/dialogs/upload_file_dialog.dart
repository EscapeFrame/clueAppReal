// 파일 업로드 다이얼로그창
import 'package:clue/config/app_color.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/file_picker_service.dart' as picker_service;

Future<void> showUploadFileDialog(
  BuildContext context,
  void Function(PlatformFile) onFileSelected,
) async {
  final width = MediaQuery.of(context).size.width;
  final height = MediaQuery.of(context).size.height;
  PlatformFile? selectedFile;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              width: width * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '파일 제출하기',
                    style: TextStyle(
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  GestureDetector(
                    onTap: () async {
                      final file = await picker_service.pickFile();
                      if (file != null) {
                        setState(() => selectedFile = file);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          if (selectedFile != null) ...[
                            Icon(
                              Icons.insert_drive_file_outlined,
                              size: width * 0.09,
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              selectedFile!.name,
                              style: TextStyle(
                                fontSize: width * 0.03,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${(selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                              style: TextStyle(
                                fontSize: width * 0.025,
                                color: Colors.grey,
                              ),
                            ),
                          ] else ...[
                            Icon(
                              Icons.upload_file,
                              size: width * 0.09,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '화면을 클릭하여 업로드하세요',
                              style: TextStyle(fontSize: width * 0.03),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xffCCCCCC),
                              ),
                            ),
                            child: const Center(child: Text('취소')),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (selectedFile != null) {
                              onFileSelected(selectedFile!);
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color:
                                  selectedFile != null
                                      ? AppColor.blue
                                      : Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    selectedFile != null
                                        ? AppColor.blue
                                        : Colors.grey,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '확인',
                                style: TextStyle(
                                  color:
                                      selectedFile != null
                                          ? Colors.white
                                          : Colors.grey[400],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
