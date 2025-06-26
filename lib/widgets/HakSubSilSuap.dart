import 'package:clue/widgets/GwaJeJeChul.dart';
import 'package:flutter/material.dart';

class Haksubsilsuap extends StatelessWidget {
  final Map<String, dynamic> notice;

  Haksubsilsuap({super.key, required this.notice});
  final List<Map<String, dynamic>> gwaJE = [
    {
      'title': '자바에 대해서 조사하기',
      'status': '미제출',
      'due': '2025.04.15 23:59:59',
      'timeLeft': '1일 5시간 남음',
      'file': {'name': '학번-이름.pdf', 'size': '15.0 KB'},
      'submitted': false,
    },
    {
      'title': '객체지향 특징 정리',
      'status': '제출완료',
      'due': '2025.04.10 18:00:00',
      'timeLeft': '마감됨',
      'file': {'name': '2201234-홍길동.pdf', 'size': '23.4 KB'},
      'submitted': true,
    },
  ];
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
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          // 하단 탭 및 차시
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
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
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F5),
                            ),
                            child: ListView.builder(
                              itemCount: notice['lessons'].length,
                              itemBuilder: (context, index) {
                                final lesson = notice['lessons'][index];
                                return Column(
                                  children: [
                                    SizedBox(height: 5),
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 0.25,
                                          color: Color(0xffCCCCCC),
                                        ),
                                        ///////////////////////////////
                                        //줄 뭐임?
                                        //////////////////////////////////////////////////////////////////////////////////////////
                                        // borderRadius: BorderRadius.only(
                                        //   topLeft: Radius.circular(10),
                                        //   topRight: Radius.circular(10),
                                        // ),
                                        color: Colors.white,
                                      ),
                                      child: ExpansionTile(
                                        title: Text(
                                          lesson['title'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        children: [
                                          ...(lesson['items'] as List<dynamic>)
                                              .map<Widget>(
                                                (item) => Column(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          width: 0.25,
                                                          color: Color(
                                                            0xffCCCCCC,
                                                          ),
                                                        ),
                                                      ),
                                                      child: ListTile(
                                                        title: Container(
                                                          child: Text(
                                                            item.toString(),
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                              .toList(),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F5),
                            ),
                            child: Gwajejechul(data: gwaJE[0]),
                          ),

                          Center(child: Text('시험 탭')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
