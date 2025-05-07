import 'package:flutter/material.dart';

class DayCard extends StatelessWidget {
  final String day;
  final String neyong;

  const DayCard({super.key, required this.day, required this.neyong});

  @override
  Widget build(BuildContext context) {
    final int dayValue = int.parse(day);
    return Container(
      width: 230,
      height: 127,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'D-$day',
            style: TextStyle(
              fontWeight: dayValue<=20?FontWeight.w900:FontWeight.w300,
              color: dayValue <= 5 ? Colors.red : Colors.black,
              fontSize: 17,
            ),
          ),
          SizedBox(height: 2),
          Text(
            neyong,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              '제출 >',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}