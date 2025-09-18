// 학습실 첨부 아이템 한 줄 위젯.
// 파일/URL 타입을 구분해 아이콘/링크 스타일을 적용하고, 다운로드/삭제 콜백을 제공합니다.
// url도 id가 있어야한다!

import 'package:flutter/material.dart';

class AttachmentItem extends StatelessWidget {
  final double width;
  final Map<String, dynamic> file;
  final bool deleting;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const AttachmentItem({
    super.key,
    required this.width,
    required this.file,
    required this.deleting,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final kind = (file['kind'] ?? '').toString();
    final isUrl = kind == 'URL';
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(width * 0.025),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isUrl ? Icons.link : Icons.insert_drive_file_outlined,
            size: width * 0.05,
          ),
          SizedBox(width: width * 0.025),
          Expanded(
            child: GestureDetector(
              onTap: onDownload,
              child: Text(
                (file['name'] ?? '').toString(),
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
            (file['sizeText'] ?? '').toString(),
            style: TextStyle(fontSize: width * 0.025, color: Colors.grey),
          ),
          SizedBox(width: width * 0.02),
          GestureDetector(
            onTap: deleting ? null : onDelete,
            child: deleting
                ? SizedBox(
                    width: width * 0.045,
                    height: width * 0.045,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.close, size: width * 0.045),
          ),
        ],
      ),
    );
  }
}
