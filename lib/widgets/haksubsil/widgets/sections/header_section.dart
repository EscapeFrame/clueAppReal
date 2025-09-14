// 상단 상태/제목/마감일/남은시간을 표시하는 헤더입니다.
import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  final String status;
  final String title;
  final String dueDateText;
  final String timeLeftText;
  final VoidCallback onClose;

  const HeaderSection({
    super.key,
    required this.status,
    required this.title,
    required this.dueDateText,
    required this.timeLeftText,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.025,
                vertical: height * 0.005,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xff86C1FF), width: 1.5),
                color: const Color(0xff86C1FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(fontSize: width * 0.03, color: Colors.black),
              ),
            ),
            IconButton(iconSize: width * 0.06, icon: const Icon(Icons.close), onPressed: onClose),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(fontSize: width * 0.045, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: height * 0.012),
        Row(children: [
          Icon(Icons.calendar_today, size: width * 0.04, color: Colors.grey),
          SizedBox(width: width * 0.015),
          Text(dueDateText, style: TextStyle(fontSize: width * 0.03)),
        ]),
        SizedBox(height: height * 0.008),
        Row(children: [
          Icon(Icons.access_time, size: width * 0.04, color: Colors.blue),
          SizedBox(width: width * 0.015),
          Text(timeLeftText, style: TextStyle(fontSize: width * 0.03, color: Colors.blue)),
        ]),
      ],
    );
  }
}
