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
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xffCCCCCC), width: 0.7),
            borderRadius: BorderRadius.circular(width * 0.025),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onUploadPressed,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(width * 0.025),
                ),
                padding: EdgeInsets.symmetric(vertical: height * 0.018),
              ),
              child: Text("파일 업로드", style: TextStyle(fontSize: width * 0.035)),
            ),
          ),
        ),
        SizedBox(height: height * 0.005),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onSavePressed,
            label: Text("저장", style: TextStyle(fontSize: width * 0.035)),
            icon: const Icon(Icons.save),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF86C1FF),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(width * 0.025),
              ),
              padding: EdgeInsets.symmetric(vertical: height * 0.018),
            ),
          ),
        ),
      ],
    );
  }
}
