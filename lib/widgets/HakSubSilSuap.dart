import 'package:clue/widgets/GwaJeJeChul.dart';
import 'package:flutter/material.dart';

class Haksubsilsuap extends StatefulWidget {
  final Map<String, dynamic> notice;

  Haksubsilsuap({super.key, required this.notice});

  @override
  State<Haksubsilsuap> createState() => _HaksubsilsuapState();
}

class _HaksubsilsuapState extends State<Haksubsilsuap> {
  late List<Map<String, dynamic>> gwaJE;
  @override
  void initState() {
    super.initState();
    gwaJE = [
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
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: const Color(0xFFD6EAFF),
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.06,
              vertical: height * 0.015,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/logo.png', width: width * 0.13),
                    Image.asset('assets/images/jongn.png', width: width * 0.13),
                  ],
                ),
                SizedBox(height: height * 0.018),
                Text(
                  widget.notice['title'].toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: width * 0.05,
                  ),
                ),
                SizedBox(height: height * 0.005),
                Text(
                  widget.notice['description'].toString(),
                  style: TextStyle(fontSize: width * 0.035),
                ),
                SizedBox(height: height * 0.025),
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
                      tabs: [
                        Tab(
                          child: Text(
                            '수업',
                            style: TextStyle(fontSize: width * 0.045),
                          ),
                        ),
                        Tab(
                          child: Text(
                            '과제',
                            style: TextStyle(fontSize: width * 0.045),
                          ),
                        ),
                        Tab(
                          child: Text(
                            '시험',
                            style: TextStyle(fontSize: width * 0.045),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F5),
                            ),
                            child: ListView.builder(
                              itemCount: widget.notice['lessons'].length,
                              itemBuilder: (context, index) {
                                final lesson = widget.notice['lessons'][index];
                                return Column(
                                  children: [
                                    SizedBox(height: height * 0.006),
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: width * 0.05,
                                        vertical: height * 0.003,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 0.25,
                                          color: Color(0xffCCCCCC),
                                        ),
                                        color: Colors.white,
                                      ),
                                      child: ExpansionTile(
                                        title: Text(
                                          lesson['title'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: width * 0.045,
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
                                                              fontSize:
                                                                  width * 0.035,
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
                            child: Gwajejechul(dataList: gwaJE),
                          ),
                          Center(
                            child: Text(
                              '시험 탭',
                              style: TextStyle(fontSize: width * 0.045),
                            ),
                          ),
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
