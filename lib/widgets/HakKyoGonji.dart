import 'package:flutter/material.dart';

class Hakkyogonji extends StatelessWidget {
  const Hakkyogonji({super.key});

  // url도 달아야됨
  final List<Map<String, String>> noticeList = const [ 
    {'title': '2025년도 학사일정 안내', 'date': '25.10.21'}, 
    {'title': '2025년도 반배정 안내', 'date': '25.10.21'},
    {'title': '2025년도 학사일정 안내', 'date': '25.10.21'},
    {'title': '2025년도 반배정 안내', 'date': '25.10.21'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(10),
      //   color: Colors.white,
      //   boxShadow: const [
      //     BoxShadow(
      //       color: Colors.black12,
      //       blurRadius: 10,
      //       offset: Offset(0, 4),
      //     ),
      //   ],
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '학교공지',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          ),
          const SizedBox(height: 10),

          ...noticeList.map(
            (notice) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(notice['title']!, style: const TextStyle(fontSize: 13)),
                  Text(notice['date']!, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),
          SizedBox(height:10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Image.asset('assets/images/jagunbar.png'),
              SizedBox(width:7),
              Image.asset('assets/images/ginbar.png'),
              SizedBox(width:7),
              Image.asset('assets/images/jagunbar.png'),
            ],
          ),
        ],
      ),
    );
  }
}
