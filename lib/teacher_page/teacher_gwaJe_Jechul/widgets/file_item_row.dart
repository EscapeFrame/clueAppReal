import 'package:flutter/material.dart';

class FileItemRow extends StatelessWidget {
  final double width;
  final Map<String, dynamic> file;
  final VoidCallback onRemove;
  final VoidCallback onTapDownload;

  const FileItemRow({
    super.key,
    required this.width,
    required this.file,
    required this.onRemove,
    required this.onTapDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(width * 0.025),
      ),
      child: Row(
        children: [
          Icon(
            Icons.insert_drive_file_outlined,
            size: width * 0.05,
          ),
          SizedBox(width: width * 0.025),
          GestureDetector(
            onTap: onTapDownload,
            child: SizedBox(
              width: width * 0.5,
              child: Text(
                file['name'] ?? '',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: width * 0.03,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          SizedBox(width: width * 0.02),
          Text(
            '(${file['size'] ?? ''})',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: width * 0.025,
              color: Colors.grey,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: width * 0.045),
          ),
        ],
      ),
    );
  }
}
// 과제 카드 내 파일(첨부) 한 줄 UI 위젯.
// 파일명/용량 표시, 다운로드/삭제 동작을 콜백으로 받아 표시합니다.
