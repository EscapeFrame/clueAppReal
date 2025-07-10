import 'package:clue/teacher_page/teacher_gwaJe_Jechul.dart';
import 'package:clue/widgets/haksubsilPage/GwaJeJeChul.dart';
import 'package:clue/config/app_data_.dart';
import 'package:flutter/material.dart';

class Haksubsilsuap extends StatefulWidget {
  final Map<String, dynamic> notice;

  Haksubsilsuap({super.key, required this.notice});

  @override
  State<Haksubsilsuap> createState() => _HaksubsilsuapState();
}

class _HaksubsilsuapState extends State<Haksubsilsuap> {
  late List<Map<String, dynamic>> assignments;

  @override
  void initState() {
    super.initState();
    final rawAssignments = widget.notice['assignments'];
    if (rawAssignments is List) {
      assignments = List<Map<String, dynamic>>.from(rawAssignments.map((a) {
        // file → files 변환
        if (a['files'] == null) {
          if (a['file'] != null) {
            a['files'] = [a['file']];
          } else {
            a['files'] = [];
          }
        }
        return a;
      }));
    } else {
      assignments = <Map<String, dynamic>>[];
    }
  }

  void updateSubmissionStatus(int index, bool submitted) {
    setState(() {
      assignments[index]['submitted'] = submitted;
      assignments[index]['status'] = submitted ? '제출됨' : '미제출';
      widget.notice['assignments'] = assignments;
    });
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
                    Image.asset('assets/images/logo.png', width: width * 0.2),
                    Image.asset('assets/images/jongn.png', width: width * 0.2),
                  ],
                ),
                SizedBox(height: height * 0.0005),
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
                            child: Gwajejechul(
                              dataList: assignments,
                              onSubmissionChanged: updateSubmissionStatus,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F5),
                            ),
                            child: TeacherGwajeJechul(
                              dataList: assignments,
                              onSubmissionChanged: updateSubmissionStatus,
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
