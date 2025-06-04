import 'package:clue/widgets/HakSubSilSuap.dart';
import 'package:flutter/material.dart';

class Banggwahoohaksubsilbarogaja extends StatelessWidget {
  final List<Map<String, dynamic>> noticeList;

  const Banggwahoohaksubsilbarogaja({super.key, required this.noticeList});

  @override
  Widget build(BuildContext context) {
    final filteredList = noticeList
        .where((notice) => notice['subject'] == 'banggwahoo')
        .toList();

    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: ListView.builder(
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          final notice = filteredList[index];
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Haksubsilsuap(notice: notice),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 18, 22, 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey, width: 0.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            notice['title'].toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            notice['language'].toString(),
                            style: const TextStyle(
                              fontSize: 17,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Text('|',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 15)),
                          const SizedBox(width: 3),
                          Text(
                            notice['class'].toString(),
                            style: const TextStyle(
                                fontSize: 17, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.people, color: Colors.grey),
                          const SizedBox(width: 10),
                          const Text('사람'),
                          const SizedBox(width: 2),
                          Text(
                            notice['people'].toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 2),
                          const Text('명'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Spacer(),
                          Text(
                            '과제 보기 >',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          );
        },
      ),
    );
  }
}