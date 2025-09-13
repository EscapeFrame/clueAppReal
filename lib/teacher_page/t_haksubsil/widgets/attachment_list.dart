import 'package:flutter/material.dart';
import 'package:clue/teacher_page/t_haksubsil/widgets/attachment_item.dart';

class AttachmentList extends StatelessWidget {
  final double width;
  final double height;
  final List<Map<String, dynamic>> attachments;
  final Set<String> deletingIds;
  final void Function(String attachmentId, String name) onDownload;
  final void Function(String attachmentId) onDelete;

  const AttachmentList({
    super.key,
    required this.width,
    required this.height,
    required this.attachments,
    required this.deletingIds,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '첨부 파일',
          style: TextStyle(fontSize: width * 0.04, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: height * 0.009),
        ...attachments.map((f) {
          final id = (f['attachmentId'] ?? '').toString();
          return AttachmentItem(
            width: width,
            file: f,
            deleting: deletingIds.contains(id),
            onDownload: () => onDownload(id, (f['name'] ?? '').toString()),
            onDelete: () => onDelete(id),
          );
        }),
      ],
    );
  }
}
// 학습실 첨부 목록 섹션 위젯.
// 첨부 제목과 리스트를 렌더링하고, 각 항목의 다운로드/삭제 이벤트를 상위에 위임합니다.
