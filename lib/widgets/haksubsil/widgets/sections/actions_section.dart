// Upload / submit action buttons.
import 'package:flutter/material.dart';

class ActionsSection extends StatelessWidget {
  final bool isSubmitted;
  final Future<bool> Function() onConfirmSubmit; // returns true if confirmed
  final VoidCallback onUploadPressed;
  final Key? uploadButtonKey;

  const ActionsSection({
    super.key,
    required this.isSubmitted,
    required this.onConfirmSubmit,
    required this.onUploadPressed,
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
          child: OutlinedButton.icon(
            key: uploadButtonKey,
            onPressed: onUploadPressed,
            icon: Icon(Icons.cloud_upload_outlined, size: width * 0.045),
            label: const Text('과제 업로드'),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xff1F2937),
              side: const BorderSide(color: Color(0xffCBD5F5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(width * 0.03),
              ),
              padding: EdgeInsets.symmetric(vertical: height * 0.018),
            ),
          ),
        ),
        SizedBox(height: height * 0.005),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final ok = await onConfirmSubmit();
              if (!ok) return;
            },
            icon: Icon(Icons.upload, size: width * 0.045),
            label: Text(isSubmitted ? '과제 제출 취소하기' : '과제 제출하기'),
            style: ElevatedButton.styleFrom(
              elevation: 4,
              backgroundColor:
                  isSubmitted ? const Color(0xFFD8D8D8) : const Color(0xff3B82F6),
              foregroundColor: isSubmitted ? const Color(0xff1F2937) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(width * 0.03),
              ),
              padding: EdgeInsets.symmetric(vertical: height * 0.018),
            ),
          ),
        ),
      ],
    );
  }
}
