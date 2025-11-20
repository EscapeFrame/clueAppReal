// 학습실 하단 액션 영역 위젯.
// 업로드 메뉴 버튼과 저장 버튼을 묶어 제공합니다.

import 'package:flutter/material.dart';

class AssignmentActions extends StatelessWidget {
  final double width;
  final double height;
  final VoidCallback onUploadPressed;
  final VoidCallback onSavePressed;

  const AssignmentActions({
    super.key,
    required this.width,
    required this.height,
    required this.onUploadPressed,
    required this.onSavePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onUploadPressed,
            icon: const Icon(Icons.cloud_upload_outlined),
            label: Text(
              "파일 업로드",
              style: TextStyle(
                fontSize: width * 0.035,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: height * 0.018),
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xff2563EB),
              side: const BorderSide(color: Color(0xffC7D8FF)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(width * 0.03),
              ),
            ),
          ),
        ),
        SizedBox(width: width * 0.03),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onSavePressed,
            icon: const Icon(Icons.check_circle_outline),
            label: Text(
              "저장",
              style: TextStyle(
                fontSize: width * 0.035,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 4,
              padding: EdgeInsets.symmetric(vertical: height * 0.018),
              backgroundColor: const Color(0xff3B82F6),
              foregroundColor: Colors.white,
              shadowColor: const Color(0xff3B82F6).withOpacity(0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(width * 0.03),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
