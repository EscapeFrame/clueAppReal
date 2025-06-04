import 'package:flutter/material.dart';

class Haksubsilsuap extends StatelessWidget {
  final Map<String, dynamic> notice;

  const Haksubsilsuap({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: const Color(0xFFD6EAFF),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/logo.png'),
                    Image.asset('assets/images/jongn.png'),
                  ],
                ),
                const SizedBox(height: 15),
                 Text(
                  notice['title'].toString(),
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                ),
                const SizedBox(height: 4),
                 Text(
                  notice['description'].toString(),
                  style: TextStyle(fontSize: 17),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          // 하단 탭 및 차시
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.lightBlue,
                    indicatorWeight: 3,
                    tabs: [Tab(text: '수업'), Tab(text: '과제'), Tab(text: '시험')],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        ListView.builder(
                          itemCount: notice['lessons'].length,
                          itemBuilder: (context, index) {
                            final lesson = notice['lessons'][index];
                            return ExpansionTile(
                              title: Text(lesson['title']),
                              children: [
                                ...(lesson['items'] as List<dynamic>)
                                    .map<Widget>(
                                      (item) => ListTile(
                                        title: Text(item.toString()),
                                      ),
                                    )
                                    .toList(),
                              ],
                            );
                          },
                        ),

                        Center(child: Text('과제 탭')),
                        Center(child: Text('시험 탭')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
