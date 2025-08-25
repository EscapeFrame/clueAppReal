import 'package:clue/widgets/haksubsilPage/GwaJeJeChul.dart';
import 'package:clue/widgets/haksubsilPage/HakSubSilGaJa.dart';
import 'package:clue/widgets/markdown_.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Haksubsilsuap extends StatefulWidget {
  final Map<String, dynamic> notice;

  const Haksubsilsuap({super.key, required this.notice});

  @override
  State<Haksubsilsuap> createState() => _HaksubsilsuapState();
}

class _HaksubsilsuapState extends State<Haksubsilsuap> {
  late List<Map<String, dynamic>> assignments;
  bool showAssignmentDetail = false;
  Map<String, dynamic>? selectedAssignment;
  void closeAssignmentDetail() {
    setState(() {
      showAssignmentDetail = false;
      selectedAssignment = null;
    });
  }

  String markdowndata = '## HelloWorld \n --- \n ## 김한결 \n | ㅎㅇ';
  @override
  void initState() {
    super.initState();
    final rawAssignments = widget.notice['assignments'];
    if (rawAssignments is List) {
      assignments = List<Map<String, dynamic>>.from(
        rawAssignments.map((a) {
          // file → files 변환
          if (a['files'] == null) {
            if (a['file'] != null) {
              a['files'] = [a['file']];
            } else {
              a['files'] = [];
            }
          }
          return a;
        }),
      );
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
                SizedBox(height: height * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                      'assets/images/clueLogo.svg',
                      width: width * 0.25,
                    ),
                    Container(
                      margin: EdgeInsets.only(right: width * 0.035),
                      child: SvgPicture.asset(
                        'assets/images/jong.svg',
                        width: width * 0.055,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.05),
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
                              color: const Color.fromARGB(255, 245, 245, 245),
                              // color:Colors.white,
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
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                        border: Border.all(
                                          width: 0.25,
                                          color: Color(0xffCCCCCC),
                                        ),
                                        color: Colors.white,
                                      ),
                                      child: Theme(
                                        data: Theme.of(context).copyWith(
                                          dividerColor: Colors.transparent,
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
                                            ...(lesson['items'] as List<dynamic>).map<
                                              Widget
                                            >(
                                              (item) => Column(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder:
                                                              (
                                                                context,
                                                              ) => Markdown_(
                                                                markdowndata:
                                                                    markdowndata,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Color(
                                                          0xffF5F5F5,
                                                        ),
                                                        // color: const Color.fromARGB(255, 245, 245, 245),
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
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 245, 245, 245),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              transitionBuilder: (
                                Widget child,
                                Animation<double> animation,
                              ) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(
                                        0.1,
                                        0,
                                      ), // 오른쪽에서 슬라이드 인
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child:
                                  showAssignmentDetail
                                      ? Haksubsilgaja(
                                        key: const ValueKey('detail'),
                                        assignment: selectedAssignment!,
                                        onClose: closeAssignmentDetail,
                                      )
                                      : Gwajejechul(
                                        key: const ValueKey('list'),
                                        dataList: assignments,
                                        onSubmissionChanged:
                                            updateSubmissionStatus,
                                        onCardClick: (assignment) {
                                          setState(() {
                                            selectedAssignment = assignment;
                                            showAssignmentDetail = true;
                                          });
                                        },
                                      ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F5),
                            ),
                            child: const Placeholder(),
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
