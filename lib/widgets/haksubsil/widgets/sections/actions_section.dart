// 업로드 트리거와 제출/취소 버튼.
import 'package:flutter/material.dart';

class ActionsSection extends StatelessWidget {
  final bool isSubmitted;
  final VoidCallback onUploadPressed;
  final VoidCallback onToggleSubmit;
  final Key? uploadButtonKey;

  const ActionsSection({
    super.key,
    required this.isSubmitted,
    required this.onUploadPressed,
    required this.onToggleSubmit,
    this.uploadButtonKey,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            key: uploadButtonKey,
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
            child: Text('과제 업로드', style: TextStyle(fontSize: width * 0.035)),
          ),
        ),
        SizedBox(height: height * 0.005),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onToggleSubmit,
            icon: Icon(Icons.upload, size: width * 0.045),
            label: Text(
              isSubmitted ? '과제 제출 취소하기' : '과제 제출하기',
              style: TextStyle(fontSize: width * 0.035),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isSubmitted ? const Color(0xFFD8D8D8) : const Color(0xFF86C1FF),
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
