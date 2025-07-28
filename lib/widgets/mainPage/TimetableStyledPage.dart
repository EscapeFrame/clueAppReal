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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final cellWidth = width / 7;
    final cellHeight = width * 0.13;
    final cellPadding = width * 0.02;
    final fontSize = width * 0.025;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: width * 0.02, vertical: height * 0.015),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.05),
        color: Colors.white,
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide(color: Colors.grey, width: width * 0.001),
        ),
        columnWidths: {0: FixedColumnWidth(cellWidth)},
        children: [
          TableRow(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(width * 0.03)),
              color: Color(0xFF91C9F7),
            ),
            children: [
              SizedBox(
                height: cellHeight,
                child: const SizedBox(),
              ),
              ...days.map(
                (day) => SizedBox(
                  height: cellHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(width * 0.03),
                      ),
                      color: Color(0xFF91C9F7),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: cellPadding * 0.7),
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          for (int i = 0; i < periods.length; i++)
            TableRow(
              children: [
                SizedBox(
                  height: cellHeight,
                  child: Container(
                    padding: EdgeInsets.all(cellPadding),
                    child: Center(
                      child: Text(
                        periods[i],
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
                      ),
                    ),
                  ),
                ),
                ...timetable[i].map(
                  (cell) => SizedBox(
                    height: cellHeight,
                    child: Padding(
                      padding: EdgeInsets.all(cellPadding),
                      child: Center(
                        child: Text(cell, style: TextStyle(fontSize: fontSize)),
                      ),
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
