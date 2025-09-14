// 서버에서 내려온 첨부파일/링크 목록을 보여줍니다.
import 'package:flutter/material.dart';

class AttachmentsSection extends StatelessWidget {
  final List<Map<String, dynamic>> attachments;
  final void Function(Map<String, dynamic> item)? onTap;

  const AttachmentsSection({super.key, required this.attachments, this.onTap});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    if (attachments.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('첨부파일', style: TextStyle(fontWeight: FontWeight.bold, fontSize: width * 0.045)),
        SizedBox(height: height * 0.009),
        ...attachments.map((f) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: EdgeInsets.all(width * 0.03),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(width * 0.025),
              ),
              child: Row(children: [
                Icon((f['kind'] == 'URL') ? Icons.link : Icons.insert_drive_file_outlined),
                SizedBox(width: width * 0.025),
                Expanded(
                  child: GestureDetector(
                    onTap: onTap == null ? null : () => onTap!(f),
                    child: Text(
                      (f['name'] ?? '').toString(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: width * 0.03, color: Colors.blue, decoration: TextDecoration.underline),
                    ),
                  ),
                ),
                SizedBox(width: width * 0.02),
                if ((f['kind'] ?? '') != 'URL' && (f['sizeText'] ?? '').toString().isNotEmpty)
                  Text('(${f['sizeText']})', style: TextStyle(fontSize: width * 0.025, color: Colors.grey)),
              ]),
            )),
        SizedBox(height: height * 0.015),
      ],
    );
  }
}
