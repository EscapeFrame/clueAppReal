// 사용자가 업로드한 로컬 파일 목록을 표시합니다.
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UploadedFilesSection extends StatelessWidget {
  final List<PlatformFile> files;
  final void Function(int index) onRemove;

  const UploadedFilesSection({super.key, required this.files, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    if (files.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: height * 0.015),
        Text('업로드된 파일', style: TextStyle(fontWeight: FontWeight.bold, fontSize: width * 0.045)),
        SizedBox(height: height * 0.009),
        ...List.generate(files.length, (index) {
          final file = files[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: EdgeInsets.all(width * 0.03),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(width * 0.025),
            ),
            child: Row(children: [
              Icon(Icons.insert_drive_file_outlined, size: width * 0.05),
              SizedBox(width: width * 0.025),
              Expanded(
                child: Text(
                  file.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: width * 0.03),
                ),
              ),
              SizedBox(width: width * 0.02),
              Text('(${(file.size / 1024).toStringAsFixed(1)} KB)',
                  style: TextStyle(fontSize: width * 0.025, color: Colors.grey)),
              SizedBox(width: width * 0.02),
              GestureDetector(onTap: () => onRemove(index), child: Icon(Icons.close, size: width * 0.045)),
            ]),
          );
        }),
      ],
    );
  }
}
