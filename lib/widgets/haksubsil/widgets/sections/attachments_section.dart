// 서버에서 내려온 첨부파일/링크 목록을 보여줍니다.
import 'package:flutter/material.dart';

class AttachmentsSection extends StatelessWidget {
  final List<Map<String, dynamic>> attachments;
  final void Function(Map<String, dynamic> item)? onTap;
  final void Function(Map<String, dynamic> item)? onDownload;
  final String title;
  final double verticalPaddingFactor;

  const AttachmentsSection({
    super.key,
    required this.attachments,
    this.onTap,
    this.onDownload,
    this.title = '첨부파일',
    this.verticalPaddingFactor = 0.024,
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
              vertical: width * verticalPaddingFactor,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
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
                      if ((f['kind'] ?? '') != 'URL' &&
                          (f['sizeText'] ?? '').toString().isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: width * 0.006),
                          child: Text(
                            (f['sizeText'] ?? '').toString(),
                            style: TextStyle(
                              fontSize: width * 0.026,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if ((f['kind'] ?? '').toString().toUpperCase() != 'URL' &&
                    onDownload != null)
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.02),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.02,
                          vertical: width * 0.015,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => onDownload!(f),
                      child: Text(
                        '받기',
                        style: TextStyle(
                          fontSize: width * 0.03,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
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
