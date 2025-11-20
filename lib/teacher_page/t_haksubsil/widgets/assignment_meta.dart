import 'package:flutter/material.dart';

/// Displays due date and remaining time (with optional D-day chip).
class AssignmentMeta extends StatelessWidget {
  final double width;
  final double height;
  final String due;
  final String timeLeft;
  final String? dDay;

  const AssignmentMeta({
    super.key,
    required this.width,
    required this.height,
    required this.due,
    required this.timeLeft,
    this.dDay,
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
            Icon(
              Icons.access_time,
              size: width * 0.04,
              color: const Color(0xff3B82F6),
            ),
            SizedBox(width: width * 0.015),
            Text(
              timeLeft,
              style: TextStyle(
                fontSize: width * 0.03,
                color: const Color(0xff3B82F6),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (dDay != null && dDay!.isNotEmpty) ...[
              SizedBox(width: width * 0.015),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.018,
                  vertical: height * 0.004,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffE8F0FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  dDay!,
                  style: TextStyle(
                    fontSize: width * 0.028,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff2251C5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
