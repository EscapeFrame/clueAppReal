import 'package:flutter/material.dart';

class AssignmentMeta extends StatelessWidget {
  final double width;
  final double height;
  final String due;
  final String timeLeft;

  const AssignmentMeta({
    super.key,
    required this.width,
    required this.height,
    required this.due,
    required this.timeLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, size: width * 0.04, color: Colors.grey),
            SizedBox(width: width * 0.015),
            Text('마감일: $due', style: TextStyle(fontSize: width * 0.03)),
          ],
        ),
        SizedBox(height: height * 0.008),
        Row(
          children: [
            Icon(Icons.access_time, size: width * 0.04, color: Colors.blue),
            SizedBox(width: width * 0.015),
            Text(timeLeft, style: TextStyle(fontSize: width * 0.03, color: Colors.blue)),
          ],
        ),
      ],
    );
  }
}
// 학습실 메타 정보 위젯.
// 마감일과 남은 시간을 행 형태로 표시합니다.
