// 학습실 본문(내용) 표시 위젯.
// 과제 설명 텍스트를 간단히 렌더링합니다.

import 'package:flutter/material.dart';

class AssignmentContent extends StatelessWidget {
  final double width;
  final String content;

  const AssignmentContent({
    super.key,
    required this.width,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: TextStyle(fontSize: width * 0.035),
    );
  }
}
