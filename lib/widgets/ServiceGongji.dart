import 'package:flutter/material.dart';

class ServiceGongJi extends StatelessWidget {
  const ServiceGongJi({super.key});

  final List<Map<String, String>> noticeList = const [
    {'title': 'CLUE 서비스 추가 기능', 'date': '25.10.21'},
    {'title': '시스템 점검 안내', 'date': '25.10.19'},
    {'title': '앱 업데이트 공지', 'date': '25.10.15'},
    {'title': '앱 업데이트 공지', 'date': '25.10.15'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '서비스공지',
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
        ],
      ),
    );
  }
}
