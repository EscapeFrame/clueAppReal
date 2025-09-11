import 'package:flutter/material.dart';

class DayCard extends StatelessWidget {
  

  final String day;
  final String neyong;

  const DayCard({super.key, required this.day, required this.neyong});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // 반응형 크기 계산
    final cardWidth = width * 0.65; // 화면 너비의 75%
    final cardHeight = height * 0.205; // 화면 높이의 20%
    final cardPadding = width * 0.06;
    final dayFontSize = (width * 0.04).clamp(14.0, 24.0); // 최소 14, 최대 24
    final contentFontSize = (width * 0.03).clamp(12.0, 20.0); // 최소 12, 최대 20
    final submitFontSize = (width * 0.025).clamp(10.0, 16.0); // 최소 10, 최대 16
    final borderRadius = width * 0.025;
    final shadowBlur = width * 0.025;
    final shadowOffset = width * 0.01;

    final int dayValue = int.parse(day);

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: shadowBlur,
            offset: Offset(0, shadowOffset),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: cardPadding,
        vertical: height * 0.022,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'D-$day',
            style: TextStyle(
              fontWeight: dayValue <= 20 ? FontWeight.w900 : FontWeight.w300,
              color: dayValue <= 5 ? Colors.red : Colors.black,
              fontSize: dayFontSize,
            ),
          ),
          SizedBox(height: height * 0.002),
          Text(
            neyong,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(fontSize: contentFontSize),
          ),
          Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              '제출 >',
              style: TextStyle(fontSize: submitFontSize, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
