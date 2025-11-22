import 'package:clue/teacher_page/tHakSubSilGaJa.dart';
import 'package:clue/teacher_page/teacher_check.dart';
import 'package:clue/teacher_page/teacher_gwaJe_Jechul/data/assignment_service.dart';
import 'package:clue/teacher_page/teacher_gwaJe_Jechul/sheets/create_assignment_sheet.dart';
import 'package:clue/teacher_page/teacher_gwaJe_Jechul/sheets/edit_assignment_sheet.dart';
import 'package:flutter/material.dart';

class TeacherGwajeJechul extends StatefulWidget {
  final List<Map<String, dynamic>> dataList;
  final Function(int index, bool submitted)? onSubmissionChanged;
  final String classRoomId;

  const TeacherGwajeJechul({
    super.key,
    required this.dataList,
    this.onSubmissionChanged,
    required this.classRoomId,
  });

  @override
  State<TeacherGwajeJechul> createState() => TeacherGwajeJechulState();
}

class TeacherGwajeJechulState extends State<TeacherGwajeJechul> {
  late List<Map<String, dynamic>> dataList;
  bool showTeacherCheck = false;
  bool showAssignmentDetail = false;
  Map<String, dynamic>? selectedAssignment;

  @override
  void initState() {
    super.initState();
    dataList = List<Map<String, dynamic>>.from(widget.dataList);
    _loadAssignments();
  }

  void _loadAssignments() async {
    final fetched = await AssignmentService.fetchAssignments(
      widget.classRoomId,
    );
    if (!mounted) return;
    setState(() {
      dataList = fetched;
    });
  }

  void _closeAssignmentDetail() {
    setState(() {
      showAssignmentDetail = false;
      selectedAssignment = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      floatingActionButton:
          showAssignmentDetail || showTeacherCheck
              ? null
              : FloatingActionButton(
                onPressed: () async {
                  final created = await showCreateAssignmentSheet(
                    context: context,
                    classRoomId: widget.classRoomId,
                  );
                  if (created != null) {
                    setState(() {
                      dataList.insert(0, created);
                    });
                    if (!mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('과제가 생성됐어요.')));
                  }
                },
                backgroundColor: const Color(0xff0077FF),
                child: const Icon(Icons.add, color: Colors.white),
              ),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xffF5F5F5)),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child:
              showAssignmentDetail
                  ? Haksubsilgaja(
                    key: const ValueKey('assignment-detail'),
                    assignment: selectedAssignment!,
                    onClose: _closeAssignmentDetail,
                  )
                  : showTeacherCheck
                  ? TeacherCheck(
                    key: const ValueKey('teacher-check'),
                    assignmentId:
                        (selectedAssignment?['assignmentId'] ??
                                selectedAssignment?['id'] ??
                                selectedAssignment?['assignment_id'] ??
                                '')
                            .toString(),
                    onBack: () {
                      setState(() {
                        showTeacherCheck = false;
                      });
                    },
                  )
                  : _buildAssignmentList(context, width, height),
        ),
      ),
    );
  }

  Widget _buildAssignmentList(
    BuildContext context,
    double width,
    double height,
  ) {
    return ListView(
      key: const ValueKey('assignment-list'),
      padding: EdgeInsets.symmetric(vertical: height * 0.01),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.04,
            vertical: height * 0.01,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.03,
              vertical: height * 0.015,
            ),
            decoration: BoxDecoration(
              color: const Color(0xffEEF4FF),
              borderRadius: BorderRadius.circular(width * 0.03),
              border: Border.all(color: const Color(0xffC1D7FF)),
            ),
            child: Row(
              children: [
                Container(
                  width: width * 0.07,
                  height: width * 0.07,
                  decoration: const BoxDecoration(
                    color: Color(0xffD1E4FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xff4F7BFF),
                    size: 20,
                  ),
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  child: Text(
                    '카드를 클릭하시면 과제에 대한 세부 내용을 확인하실 수 있습니다.',
                    style: TextStyle(
                      fontSize: width * 0.0335,
                      color: const Color(0xff1B4ED4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ...dataList.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final Color accent = const Color(0xff3B82F6);
          final String title = (data['title'] ?? '제목 없음').toString();
          final DateTime? startDate = _tryParseDate(data['startDate']);
          final DateTime? endDate = _tryParseDate(data['endDate']);
          final String? dDay = _buildDDayLabel(endDate);
          final String periodText = _formatPeriod(startDate, endDate);

          return GestureDetector(
            onTap: () {
              setState(() {
                final mapped = Map<String, dynamic>.from(data);
                selectedAssignment = mapped;
                showAssignmentDetail = true;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              margin: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.012,
              ),
              padding: EdgeInsets.all(width * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(width * 0.045),
                border: Border.all(color: const Color(0xffE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: width * 0.025,
                    offset: Offset(0, width * 0.01),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: width * 0.048,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xff1F2937),
                          ),
                        ),
                      ),
                      if (dDay != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            dDay,
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (periodText.isNotEmpty) ...[
                    SizedBox(height: height * 0.008),
                    Text(
                      periodText,
                      style: TextStyle(
                        fontSize: width * 0.034,
                        color: const Color(0xff475467),
                      ),
                    ),
                  ],
                  SizedBox(height: height * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetaTile(
                          icon: Icons.calendar_today,
                          label: '시작일',
                          value: _formatDate(startDate),
                          color: const Color(0xff4C5674),
                          width: width,
                        ),
                      ),
                      SizedBox(width: width * 0.02),
                      Expanded(
                        child: _buildMetaTile(
                          icon: Icons.flag,
                          label: '마감일',
                          value: _formatDate(endDate),
                          color: accent,
                          width: width,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.02),
                  const Divider(height: 1, color: Color(0xffE2E8F0)),
                  SizedBox(height: height * 0.012),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final updated = await showEditAssignmentSheet(
                              context: context,
                              assignment: dataList[index],
                            );
                            if (updated != null) {
                              setState(() {
                                dataList[index] = updated;
                              });
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('내용이 업데이트됐어요.')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xff1F2937),
                            elevation: 0,
                            side: const BorderSide(color: Color(0xffE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                width * 0.028,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: height * 0.018,
                            ),
                          ),
                          icon: const Icon(
                            Icons.brush,
                            color: Color(0xff1F2937),
                          ),
                          label: const Text('내용수정'),
                        ),
                      ),
                      SizedBox(width: width * 0.03),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              selectedAssignment = Map<String, dynamic>.from(
                                dataList[index],
                              );
                              showTeacherCheck = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffD1ECFF),
                            foregroundColor: const Color(0xff0D5DBA),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                width * 0.028,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: height * 0.018,
                            ),
                          ),
                          icon: const Icon(Icons.assignment_turned_in_outlined),
                          label: const Text('확인/채점'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  String? _buildDDayLabel(DateTime? endDate) {
    if (endDate == null) return null;
    final now = DateTime.now();
    final diff = endDate.difference(now).inDays;
    if (diff > 0) return 'D-$diff';
    if (diff == 0) return 'D-DAY';
    return '종료';
  }

  String _formatPeriod(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '';
    return '${_formatDate(start)} ~ ${_formatDate(end)}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '정보 없음';
    final local = date.toLocal();
    final mm = local.month.toString().padLeft(2, '0');
    final dd = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '${local.year}.$mm.$dd $hh:$min';
  }

  DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    if (str.isEmpty) return null;
    try {
      return DateTime.parse(str);
    } catch (_) {
      return null;
    }
  }

  Widget _buildMetaTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required double width,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.025, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: width * 0.05),
          SizedBox(width: width * 0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: width * 0.03,
                    color: const Color(0xff6B7280),
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: width * 0.035,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
