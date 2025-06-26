import 'package:flutter/material.dart';

class Gwajejechul extends StatelessWidget {
  final Map<String, dynamic> data;

  const Gwajejechul({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(data['title'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: data['submitted'] ? Colors.blue[100] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  data['status'],
                  style: TextStyle(
                    fontSize: 12,
                    color: data['submitted'] ? Colors.blue : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text("마감일: ${data['due']}", style: const TextStyle(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.blue),
              const SizedBox(width: 6),
              Text(data['timeLeft'], style: const TextStyle(fontSize: 13, color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 15),
          // 파일 정보
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.insert_drive_file_outlined),
                const SizedBox(width: 10),
                Text(data['file']['name']),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // 제출 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload),
              label: const Text("과제 제출하기"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB9DCFF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}