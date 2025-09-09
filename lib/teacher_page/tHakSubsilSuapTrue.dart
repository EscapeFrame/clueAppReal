import 'package:clue/api_client.dart';
import 'package:clue/teacher_page/tHakSubSilSetting.dart';
import 'package:clue/teacher_page/teacher_gwaJe_Jechul.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Thaksubsilsuaptrue extends StatefulWidget {
  final Map<String, dynamic> tsuap;

  const Thaksubsilsuaptrue({super.key, required this.tsuap});

  @override
  State<Thaksubsilsuaptrue> createState() => _HaksubsilsuapState();
}

class _HaksubsilsuapState extends State<Thaksubsilsuaptrue> {
  late List<Map<String, dynamic>> assignments;
  Map<String, dynamic> _detail = {};

  Future<void> _loadDetail() async {
    try {
      final api = ApiClient.instance.dio;
      final id =
          (widget.tsuap['classRoomId'] ?? widget.tsuap['classRoomIdStr'])
              ?.toString();
      
      final res = await api.get('/api/class/$id/all');
      final data = res.data;
      debugPrint('teacher detail: $data');
      if (!mounted) return;
      if (data is Map) {
        final m = Map<String, dynamic>.from(data);
        setState(() {
          _detail = m;
          // Fetch된 상세 데이터를 화면의 기본 데이터로 반영
          widget.tsuap['name'] = (m['classRoomName'] ?? widget.tsuap['name'] ?? '').toString();
          if (m['description'] != null) {
            widget.tsuap['description'] = m['description'].toString();
          }
          if (m['sort'] != null) {
            widget.tsuap['sort'] = m['sort'].toString();
          }
          if (m['target'] != null) {
            widget.tsuap['target'] = m['target'].toString();
          }
          final raw = m['assignments'];
          if (raw is List) {
            assignments = List<Map<String, dynamic>>.from(
              raw.whereType<Map>().map((a) {
                final map = Map<String, dynamic>.from(a);
                if (map['files'] == null) {
                  if (map['file'] != null) {
                    map['files'] = [map['file']];
                  } else {
                    map['files'] = [];
                  }
                }
                return map;
              }),
            );
          }
        });
      }
    } catch (e) {
      debugPrint('classRoom load error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    final rawAssignments = widget.tsuap['assignments'];
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
    _loadDetail();
  }

  void updateSubmissionStatus(int index, bool submitted) {
    setState(() {
      assignments[index]['submitted'] = submitted;
      assignments[index]['status'] = submitted ? '제출됨' : '미제출';
      widget.tsuap['assignments'] = assignments;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final header = _detail.isNotEmpty ? _detail : widget.tsuap;
    final title =
        (header['classRoomName'] ?? header['title'])?.toString() ?? '';
    final description = header['description']?.toString() ?? '';
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
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: width * 0.05,
                  ),
                ),
                SizedBox(height: height * 0.005),
                Text(description, style: TextStyle(fontSize: width * 0.035)),
                SizedBox(height: height * 0.025),
              ],
            ),
          ),

          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: DefaultTabController(
                length: 4,
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
                            '사용자',
                            style: TextStyle(fontSize: width * 0.045),
                          ),
                        ),
                        Tab(
                          child: Text(
                            '설정',
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
                              itemCount:
                                  ((widget.tsuap['directoryList'] as List?) ??
                                          const [])
                                      .length,
                              itemBuilder: (context, index) {
                                final lesson =
                                    ((widget.tsuap['directoryList'] as List?) ??
                                            const [])[index]
                                        as Map? ??
                                    const {};
                                return Column(
                                  children: [
                                    // SizedBox(height: height * 0.006),
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
                                            lesson['directoryName'].toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: width * 0.045,
                                            ),
                                          ),
                                          children: [
                                            ...(((lesson['documentList']
                                                        as List?) ??
                                                    const []))
                                                .map<Widget>(
                                                  (item) => Column(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          // Navigator.push(
                                                          //   context,
                                                          //   MaterialPageRoute(
                                                          //     builder:
                                                          //         (
                                                          //           context,
                                                          //         ) =>
                                                          //         Markdown_(
                                                          //           markdowndata:
                                                          //               markdowndata,
                                                          //         ),
                                                          //   ),
                                                          // );
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
                                                                      width *
                                                                      0.035,
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
                              color: const Color(0xFFF1F3F5),
                            ),
                            child: TeacherGwajeJechul(
                              dataList: assignments,
                              onSubmissionChanged: updateSubmissionStatus,
                              classRoomId: (header['classRoomId'] ?? header['classRoomIdStr'])
                                  ?.toString() ??
                                  '',
                            ),
                          ),
                          Container(child: const Placeholder()),
                          Container(
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(context).colorScheme.copyWith(
                                  primary: const Color(0xff578FCA),
                                  secondary: const Color(0xff578FCA),
                                ),
                                textSelectionTheme: const TextSelectionThemeData(
                                  cursorColor: Color(0xff578FCA),
                                  selectionColor: Color(0x33578FCA),
                                  selectionHandleColor: Color(0xff578FCA),
                                ),
                              ),
                              child: Thaksubsilsetting(
                                tsuap: widget.tsuap,
                                onApply: (updated) {
                                  // 서버 데이터로 재동기화를 위해 상세 재호출 (A방법)
                                  _loadDetail();
                                  // 즉시 화면 반영: 현재 상세 헤더(_detail)가 있으면 동기 업데이트
                                  setState(() {
                                    widget.tsuap.addAll(updated);
                                    if (_detail.isNotEmpty) {
                                      if (updated['name'] != null) {
                                        _detail['classRoomName'] = updated['name'];
                                      }
                                      if (updated['description'] != null) {
                                        _detail['description'] = updated['description'];
                                      }
                                      if (updated['sort'] != null) {
                                        _detail['sort'] = updated['sort'];
                                      }
                                      if (updated['target'] != null) {
                                        _detail['target'] = updated['target'];
                                      }
                                    }
                                  });
                                },
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
          ),
        ],
      ),
    );
  }
}
