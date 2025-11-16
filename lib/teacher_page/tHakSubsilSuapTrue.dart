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
          widget.tsuap['name'] =
              (m['classRoomName'] ?? widget.tsuap['name'] ?? '').toString();
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
        (header['classRoomName'] ?? header['title'] ?? header['name'])
            ?.toString() ??
        '';
    final description = header['description']?.toString() ?? '';
    final teacherNames = header['teacherNames'];
    String teacherName = '';
    if (teacherNames is List && teacherNames.isNotEmpty) {
      teacherName = teacherNames
          .where((name) => name != null)
          .map((name) => name.toString())
          .join(', ');
    } else if (header['teacherName'] != null) {
      teacherName = header['teacherName'].toString();
    }
    final dynamic classCodeValue =
        header['code'] ??
        header['classRoomCode'] ??
        header['classCode'] ??
        header['classRoomIdStr'] ??
        header['classRoomId'];
    final classCode = classCodeValue?.toString() ?? '';
    final List<dynamic> directoryList =
        (header['directoryList'] as List?) ?? const [];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(
                  'assets/images/realLogo.svg',
                  width: width * 0.25,
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back, size: width * 0.07),
                    ),
                    SizedBox(width: width * 0.03),
                    SvgPicture.asset(
                      'assets/images/bars-3.svg',
                      width: width * 0.074,
                    ),
                    SizedBox(width: width * 0.0443),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              width * 0.07,
              0,
              height * 0.01,
              height * 0.01,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: width * 0.065,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.003),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text(
                    description,
                    style: TextStyle(fontSize: width * 0.035),
                  ),
                ),
                SizedBox(height: height * 0.004),
                if (teacherName.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: width * 0.06,
                        color: Colors.black54,
                      ),
                      SizedBox(width: width * 0.005),
                      Text(
                        teacherName,
                        style: TextStyle(
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.w600,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '수업코드',
                      style: TextStyle(
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff0077FF),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      classCode.isEmpty ? '-' : classCode,
                      style: TextStyle(
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
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
                      labelColor: const Color(0xff0077FF),
                      unselectedLabelColor: Colors.black,
                      indicatorColor: const Color(0xff0077FF),
                      indicatorWeight: 3,
                      indicatorPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
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
                              itemCount: directoryList.length,
                              itemBuilder: (context, index) {
                                final lesson =
                                    (directoryList[index] as Map?) ?? const {};
                                final List<dynamic> documents =
                                    (lesson['documentList'] as List?) ??
                                    const [];
                                return Column(
                                  children: [
                                    SizedBox(height: height * 0.01),
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: width * 0.05,
                                        vertical: height * 0.003,
                                      ),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          width: 0.25,
                                          color: const Color(0xffCCCCCC),
                                        ),
                                        color: Colors.white,
                                      ),
                                      child: Theme(
                                        data: Theme.of(context).copyWith(
                                          dividerColor: Colors.transparent,
                                        ),
                                        child: ExpansionTile(
                                          title: Text(
                                            lesson['directoryName']
                                                    ?.toString() ??
                                                '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: width * 0.045,
                                            ),
                                          ),
                                          children:
                                              documents.map<Widget>((docItem) {
                                                final doc =
                                                    (docItem as Map?) ??
                                                    const {};
                                                return Column(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                        left: width * 0.028,
                                                        right: width * 0.028,
                                                        bottom: height * 0.012,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xffF5F5F5,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        border: Border.all(
                                                          width: 0.01,
                                                          color: const Color(
                                                            0xffCCCCCC,
                                                          ),
                                                        ),
                                                      ),
                                                      child: ListTile(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets.symmetric(
                                                              horizontal:
                                                                  width * 0.04,
                                                            ),
                                                        title: Text(
                                                          doc['title']
                                                                  ?.toString() ??
                                                              '',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                width * 0.035,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
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
                              color: const Color(0xffffffff),
                            ),
                            child: TeacherGwajeJechul(
                              dataList: assignments,
                              onSubmissionChanged: updateSubmissionStatus,
                              classRoomId:
                                  (header['classRoomId'] ??
                                          header['classRoomIdStr'])
                                      ?.toString() ??
                                  '',
                            ),
                          ),
                          Container(child: const Placeholder()),
                          Container(
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(
                                  context,
                                ).colorScheme.copyWith(
                                  primary: const Color(0xff578FCA),
                                  secondary: const Color(0xff578FCA),
                                ),
                                textSelectionTheme:
                                    const TextSelectionThemeData(
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
                                        _detail['classRoomName'] =
                                            updated['name'];
                                      }
                                      if (updated['description'] != null) {
                                        _detail['description'] =
                                            updated['description'];
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
