import 'package:clue/HamburgerDialog.dart';
import 'package:clue/api_client.dart';
import 'package:clue/widgets/haksubsilPage/GwaJeJeChul.dart';
import 'package:clue/widgets/haksubsilPage/HakSubSilGaJa.dart';
import 'package:clue/widgets/markdown_.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Haksubsilsuap extends StatefulWidget {
  final Map<String, dynamic> notice;

  const Haksubsilsuap({super.key, required this.notice});

  @override
  State<Haksubsilsuap> createState() => _HaksubsilsuapState();
}

class _HaksubsilsuapState extends State<Haksubsilsuap> {
  static const List<Map<String, dynamic>> _fallbackAssignments = [
    {
      'title': 'asdf',
      'content': '샘플 과제를 작성해 주세요.',
      'startDate': '2025-11-18T03:06:00Z',
      'endDate': '2025-11-29T23:59:00Z',
      'userName': '홍길동',
      'submissionId': 'fallback-asdf',
      'isSubmitted': true,
      'submittedAt': '2025-11-20T12:00:00Z',
      'submissionAttachmentResponses': [
        {
          'submissionAttachmentId': 'fallback-attach-1',
          'type': 'FILE',
          'value': 'report.pdf',
          'originalFileName': 'report.pdf',
          'contentType': 'application/pdf',
          'size': 2048,
        },
      ],
    },
    {
      'title': 'dkswoals',
      'content': '텍스트 입력 예시입니다.',
      'startDate': '2025-11-18T03:58:00Z',
      'endDate': '2025-11-29T23:59:00Z',
      'userName': '이선생',
      'submissionId': 'fallback-dkswoals',
      'isSubmitted': false,
      'submittedAt': null,
      'submissionAttachmentResponses': [],
    },
  ];
  late List<Map<String, dynamic>> assignments;
  bool showAssignmentDetail = false;
  Map<String, dynamic>? selectedAssignment;
  void closeAssignmentDetail() {
    setState(() {
      showAssignmentDetail = false;
      selectedAssignment = null;
    });
  }

  Future<void> _openDocumentMarkdown(Map<String, dynamic> document) async {
    final rawId =
        document['documentId'] ??
        document['document_id'] ??
        document['id'] ??
        document['documentNo'];
    final docId = rawId == null ? '' : rawId.toString();
    if (docId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('문서 정보를 찾을 수 없어요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final navigator = Navigator.of(context, rootNavigator: true);
    var loaderClosed = false;
    void closeLoader() {
      if (!loaderClosed) {
        navigator.pop();
        loaderClosed = true;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final dio = ApiClient.instance.dio;
      final response = await dio.get(
        '/api/document/$docId/download',
        options: Options(responseType: ResponseType.plain),
      );
      closeLoader();
      if (!mounted) return;
      final markdownContent = (response.data?.toString() ?? '').trim();
      final rendered = markdownContent.isEmpty ? markdowndata : markdownContent;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => Markdown_(markdowndata: rendered)),
      );
    } on DioException catch (e) {
      debugPrint('document download error: $e');
      closeLoader();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('문서를 불러오는 중 오류가 발생했어요. (${e.message})'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('document download unexpected error: $e');
      closeLoader();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('문서를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> gwaJeJeChul() async {
    try {
      final assignmentsApi = ApiClient.instance.dio;

      final String? idStr =
          (widget.notice['classRoomIdStr'] ?? widget.notice['classRoomId'])
              ?.toString();

      final submissionsRes = await assignmentsApi.get(
        '/api/submissions/$idStr',
      );

      final submissionData = submissionsRes.data;

      debugPrint("과제 제출:${submissionData.toString()}");

      final list =
          submissionData is List
              ? submissionData
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList()
              : <Map<String, dynamic>>[];

      if (list.isEmpty) {
        return const <Map<String, dynamic>>[];
      }
      return list;
    } on DioException catch (e) {
      debugPrint('status : ${e.response?.statusCode}');

      debugPrint('data   : ${e.response?.data}');

      debugPrint('headers: ${e.response?.headers}');

      debugPrint('msg    : ${e.message}');

      return const <Map<String, dynamic>>[];
    } catch (e) {
      debugPrint('assignments load error: $e');

      return const <Map<String, dynamic>>[];
    }
  }

  String markdowndata = '## HelloWorld \n --- \n ## 김한결 \n | ㅎㅇh';
  @override
  void initState() {
    super.initState();

    gwaJeJeChul();

    // debugPrint(widget.notice.toString());
    // assignments 초기화 및 file → files 변환
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
    final teacherNames = widget.notice['teacherNames'];
    String teacherNameText = '';
    if (teacherNames is List && teacherNames.isNotEmpty) {
      teacherNameText = teacherNames
          .where((name) => name != null)
          .map((name) => name.toString())
          .join(', ');
    } else if (widget.notice['teacherName'] != null) {
      teacherNameText = widget.notice['teacherName'].toString();
    }

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
                    GestureDetector(
                      onTap: () => showHamburgerDialog(context),
                      child: SvgPicture.asset(
                        'assets/images/bars-3.svg',
                        width: width * 0.074,
                      ),
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
                    widget.notice['classRoomName'].toString(),
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
                    widget.notice['description'].toString(),
                    style: TextStyle(fontSize: width * 0.035),
                  ),
                ),
                SizedBox(height: height * 0.004),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: width * 0.06,
                      color: Colors.black54,
                    ),
                    SizedBox(width: width * 0.005),
                    Text(
                      teacherNameText,
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
                      widget.notice['code'].toString(),
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
                length: 3,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: Color(0xff0077FF),
                      unselectedLabelColor: Colors.black,
                      indicatorColor: Color(0xff0077FF),
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
                            '수행평가',
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
                            child: Builder(
                              builder: (context) {
                                final lessons =
                                    (widget.notice['directoryList'] as List?) ??
                                    const [];
                                if (lessons.isEmpty) {
                                  return Center(
                                    child: Text(
                                      '수업이 없습니다.',
                                      style: TextStyle(
                                        fontSize: width * 0.04,
                                        color: const Color(0xff6B7280),
                                      ),
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  itemCount: lessons.length,
                                  itemBuilder: (context, index) {
                                    final lesson =
                                        (lessons[index] as Map?) ?? const {};
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
                                                color: Colors.grey.withOpacity(
                                                  0.1,
                                                ),
                                                spreadRadius: 5,
                                                blurRadius: 7,
                                                offset: Offset(
                                                  0,
                                                  3,
                                                ), // changes position of shadow
                                              ),
                                            ],
                                            borderRadius: BorderRadius.circular(
                                              12,
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
                                                lesson['directoryName']
                                                    .toString(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: width * 0.045,
                                                ),
                                              ),
                                              children: [
                                                ...(((lesson['documentList']
                                                            as List?) ??
                                                        const []))
                                                    .map<Widget>((item) {
                                                      final doc = Map<
                                                        String,
                                                        dynamic
                                                      >.from(
                                                        (item as Map?) ??
                                                            const {},
                                                      );
                                                      return Column(
                                                        children: [
                                                          GestureDetector(
                                                            onTap:
                                                                () =>
                                                                    _openDocumentMarkdown(
                                                                      doc,
                                                                    ),
                                                            child: Container(
                                                              margin:
                                                                  EdgeInsets.only(
                                                                    left:
                                                                        width *
                                                                        0.028,
                                                                    right:
                                                                        width *
                                                                        0.028,
                                                                    bottom:
                                                                        height *
                                                                        0.012,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: Color(
                                                                  0xffF5F5F5,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                                // boxShadow: [
                                                                //   BoxShadow(
                                                                //     color: Colors
                                                                //         .black
                                                                //         .withOpacity(
                                                                //           0.05,
                                                                //         ),
                                                                //     blurRadius: 6,
                                                                //     offset: Offset(
                                                                //       0,
                                                                //       2,
                                                                //     ),
                                                                //   ),
                                                                // ],
                                                                // color: const Color.fromARGB(255, 245, 245, 245),
                                                                border: Border.all(
                                                                  width: 0.01,
                                                                  color: Color(
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
                                                                          width *
                                                                          0.04,
                                                                    ),
                                                                title: Text(
                                                                  doc['title']
                                                                          ?.toString() ??
                                                                      '',
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        width *
                                                                        0.035,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    }),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
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
                                      : FutureBuilder<
                                        List<Map<String, dynamic>>
                                      >(
                                        future: gwaJeJeChul(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState !=
                                              ConnectionState.done) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                          final list =
                                              snapshot.data ??
                                              const <Map<String, dynamic>>[];
                                          if (list.isEmpty) {
                                            return Center(
                                              child: Text(
                                                '과제가 없습니다.',
                                                style: TextStyle(
                                                  fontSize: width * 0.04,
                                                  color: const Color(
                                                    0xff6B7280,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                          return Gwajejechul(
                                            key: const ValueKey('list'),
                                            dataList: list,
                                            onSubmissionChanged:
                                                updateSubmissionStatus,
                                            onCardClick: (assignment) {
                                              setState(() {
                                                selectedAssignment = assignment;
                                                showAssignmentDetail = true;
                                              });
                                            },
                                          );
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
