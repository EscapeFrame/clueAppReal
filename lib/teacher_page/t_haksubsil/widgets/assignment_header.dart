// 학습실 헤더 위젯.
// 상태 칩(제출/미제출)과 닫기 버튼을 표시합니다.

import 'package:flutter/material.dart';

class AssignmentHeader extends StatelessWidget {
  final double width;
  final double height;
  final String statusText;
  final bool submitted;
  final VoidCallback onClose;

  const AssignmentHeader({
    super.key,
    required this.width,
    required this.height,
    required this.statusText,
    required this.submitted,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.025,
            vertical: height * 0.005,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xff86C1FF), width: 1.5),
            color: submitted ? Colors.white : const Color(0xff86C1FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            statusText,
            style: TextStyle(fontSize: width * 0.03, color: Colors.black),
          ),
        ),
        IconButton(
          iconSize: width * 0.06,
          icon: const Icon(Icons.close),
          onPressed: onClose,
        ),
      ],
    );
  }
}
