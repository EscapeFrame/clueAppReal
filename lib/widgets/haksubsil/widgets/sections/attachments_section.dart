// 서버에서 내려온 첨부파일/링크 목록을 보여줍니다.
import 'package:flutter/material.dart';

class AttachmentsSection extends StatelessWidget {
  final List<Map<String, dynamic>> attachments;
  final void Function(Map<String, dynamic> item)? onTap;
  final String title;

  const AttachmentsSection({
    super.key,
    required this.attachments,
    this.onTap,
    this.title = '첨부파일',
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    if (attachments.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: width * 0.045,
          ),
        ),
        SizedBox(height: height * 0.009),
        ...attachments.map((f) {
          final VoidCallback? removeCallback = f['onRemove'] as VoidCallback?;
          return Container(
            margin: EdgeInsets.only(bottom: height * 0.007),
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.035,
              vertical: width * 0.03,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(width * 0.025),
            ),
            child: Row(
              children: [
                Icon(
                  (f['kind'] == 'URL')
                      ? Icons.link
                      : Icons.insert_drive_file_outlined,
                  size: width * 0.038,
                ),
                SizedBox(width: width * 0.02),
                Expanded(
                  child: GestureDetector(
                    onTap: onTap == null ? null : () => onTap!(f),
                    child: Text(
                      (f['name'] ?? '').toString(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: width * 0.03,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: width * 0.015),
                if ((f['kind'] ?? '') != 'URL' &&
                    (f['sizeText'] ?? '').toString().isNotEmpty)
                  Text(
                    '(${f['sizeText']})',
                    style: TextStyle(
                      fontSize: width * 0.025,
                      color: Colors.grey,
                    ),
                  ),
                if (removeCallback != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: width * 0.04,
                    onPressed: removeCallback,
                  )
                else
                  SizedBox(width: width * 0.04),
              ],
            ),
          );
        }),
        SizedBox(height: height * 0.015),
      ],
    );
  }
}
