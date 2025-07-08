import 'package:flutter/material.dart';

class TimetableStyledPage extends StatelessWidget {
  TimetableStyledPage({super.key});

  final List<String> days = ['MON', 'TUE', 'WED', 'THU', 'FRI'];
  final List<String> periods = [
    '1교시',
    '2교시',
    '3교시',
    '4교시',
    '5교시',
    '6교시',
    '7교시',
  ];

  final List<List<String>> timetable = [
    ['-', '-', '-', '-', '운영체제(2-3)'],
    ['-', '-', '-', '-', '운영체제(2-3)'],
    ['-', '-', '운영체제(2-4)', 'THU', '-'],
    ['-', '-', '운영체제(2-4)', '-', '-'],
    ['-', '-', '-', '-', '-'],
    ['DB(2-1)', 'JAVA(2-2)', '-', 'THU', '-'],
    ['DB(2-1)', 'JAVA(2-2)', '-', 'THU', '-'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: const BorderSide(color: Colors.grey, width: 0.05),
        ),
        columnWidths: const {0: FixedColumnWidth(60)},
        children: [

          TableRow(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12)),
              color: Color(0xFF91C9F7),
            ),
            children: [
              const SizedBox(),
              ...days.map(
                (day) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                    ),
                    color: Color(0xFF91C9F7),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // 시간표 데이터
          for (int i = 0; i < periods.length; i++)
            TableRow(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),

                  child: Text(
                    periods[i],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...timetable[i].map(
                  (cell) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: Center(
                      child: Text(cell, style: TextStyle(fontSize: 10)),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
