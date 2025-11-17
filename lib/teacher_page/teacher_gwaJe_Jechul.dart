import 'package:clue/teacher_page/tHakSubSilGaJa.dart';
import 'package:clue/teacher_page/teacher_check.dart';
import 'package:clue/teacher_page/teacher_gwaJe_Jechul/data/assignment_service.dart';
import 'package:clue/teacher_page/teacher_gwaJe_Jechul/sheets/create_assignment_sheet.dart';
import 'package:clue/teacher_page/teacher_gwaJe_Jechul/sheets/edit_assignment_sheet.dart';
import 'package:flutter/material.dart';
class TeacherGwajeJechul extends StatefulWidget {
  final List<Map<String, dynamic>> dataList;
  final Function(int index, bool submitted)? onSubmissionChanged;
  final String classRoomId; // path param for API
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
  void _closeAssignmentDetail() {
    setState(() {
      showAssignmentDetail = false;
      selectedAssignment = null;
    });
  }
  void _normalizeAssignments() {
    for (final data in dataList) {
      if (data['files'] == null || data['files'] is! List) {
        data['files'] = [];
      }
      if (data['files'] is List) {
        (data['files'] as List).removeWhere((element) => element == null);
      }
    }
  }
  @override
  void initState() {
    super.initState();
    dataList = List.from(widget.dataList);
    _normalizeAssignments();
    gwaJeJeChul();
  }
  Future<void> gwaJeJeChul() async {
    final parsed = await AssignmentService.fetchAssignments(widget.classRoomId);
    if (!mounted) return;
    setState(() {
      dataList = parsed;
      _normalizeAssignments();
    });
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButton: showAssignmentDetail
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
                    _normalizeAssignments();
                  });
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('과제를 생성했어요.')),
                  );
                }
              },
              backgroundColor: const Color(0xff0077FF),
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 245, 245, 245),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: showAssignmentDetail
              ? Thaksubsilgaja(
                  key: const ValueKey('assignmentDetail'),
                  assignment: selectedAssignment!,
                  onClose: _closeAssignmentDetail,
                )
              : showTeacherCheck
                  ? TeacherCheck(
                      key: const ValueKey('teacherCheck'),
                      assignmentId: ((selectedAssignment?['assignmentId'] 제목 없음
                                  selectedAssignment?['id'] 제목 없음
                                  selectedAssignment?['assignment_id'] 제목 없음
                                  '')
                              .toString()),
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
  Widget _buildAssignmentList(BuildContext context, double width, double height) {
    return ListView(
      key: const ValueKey('assignmentList'),
      padding: EdgeInsets.symmetric(vertical: height * 0.01),
      children: dataList.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        final Color accent = const Color(0xff4F68FF);
        final String title = (data['title'] 제목 없음 '제목 없음').toString();
        final DateTime? startDate = _parseDate(data['startDate']?.toString());
        final DateTime? endDate = _parseDate(data['endDate']?.toString());
        final String? dDayLabel = _buildDDayLabel(endDate);
        final String periodText = _formatPeriod(startDate, endDate);

        return GestureDetector(
          onTap: () {
            setState(() {
              final mapped = Map<String, dynamic>.from(data);
              if (!(mapped.containsKey('file')) &&
                  mapped['files'] is List &&
                  (mapped['files'] as List).isNotEmpty) {
                mapped['file'] = (mapped['files'] as List).first;
              } else if (!mapped.containsKey('file')) {
                mapped['file'] = {'name': ''};
              }
              if (mapped['assignmentId'] == null) {
                final dynamic altId = mapped['id'] 제목 없음 mapped['assignment_id'];
                if (altId != null) {
                  final parsed = int.tryParse(altId.toString());
                  mapped['assignmentId'] = parsed 제목 없음 altId;
                }
              }
              selectedAssignment = mapped;
              showAssignmentDetail = true;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            margin: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.012,
            ),
            padding: EdgeInsets.all(width * 0.04),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Color(0xfff7f9ff),
                ],
              ),
              borderRadius: BorderRadius.circular(width * 0.045),
              border: Border.all(color: accent.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: width * 0.04,
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
                    if (dDayLabel != null) ...[
                      SizedBox(width: width * 0.02),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          dDayLabel,
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (periodText.isNotEmpty) ...[
                  SizedBox(height: height * 0.01),
                  Text(
                    periodText,
                    style: TextStyle(
                      fontSize: width * 0.034,
                      color: const Color(0xff475467),
                    ),
                  ),
                ],
                SizedBox(height: height * 0.016),
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
                    ),
                  ],
                ),
                SizedBox(height: height * 0.018),
                const Divider(height: 1, color: Color(0xffE2E8F0)),
                SizedBox(height: height * 0.012),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final updated = await showEditAssignmentSheet(
                              context: context,
                              assignment: dataList[index],
                            );
                            if (updated != null) {
                              setState(() {
                                dataList[index]['title'] = updated['title'];
                                dataList[index]['content'] = updated['content'];
                                dataList[index]['startDate'] = updated['startDate'];
                                dataList[index]['endDate'] = updated['endDate'];
                                dataList[index]['due'] = updated['due'];
                                dataList[index]['timeLeft'] = updated['timeLeft'];
                              });
                              await gwaJeJeChul();
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('내용이 업데이트됐어요.')),
                              );
                            }
                          },
                          label: Text(
                            '내용수정',
                            style: TextStyle(
                              fontSize: width * 0.035,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          icon: const Icon(Icons.brush),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffEEF2FF),
                            foregroundColor: const Color(0xff1E3A8A),
                            surfaceTintColor: Colors.transparent,
                            elevation: 0,
                            side: const BorderSide(color: Color(0xffCBD5F5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(width * 0.028),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: height * 0.018,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: width * 0.03),
                    Expanded(
                      child: SizedBox(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              final mapped = Map<String, dynamic>.from(dataList[index]);
                              if (mapped['assignmentId'] == null) {
                                final altId = mapped['id'] 제목 없음 mapped['assignment_id'];
                                if (altId != null) {
                                  final parsed = int.tryParse(altId.toString());
                                  mapped['assignmentId'] = parsed 제목 없음 altId;
                                }
                              }
                              selectedAssignment = mapped;
                              showTeacherCheck = true;
                            });
                          },
                          label: Text(
                            '확인/채점',
                            style: TextStyle(
                              fontSize: width * 0.035,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          icon: const Icon(Icons.assignment_turned_in_outlined),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffDBEAFE),
                            foregroundColor: const Color(0xff1D4ED8),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(width * 0.028),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: height * 0.018,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  String? _buildDDayLabel(DateTime? endDate) {
    if (endDate == null) return null;
    final now = DateTime.now();
    final diff = endDate.difference(now).inDays;
    if (diff > 0) return 'D-' + diff.toString();
    if (diff == 0) return 'D-DAY';
    return '종료';
  }
  String _formatPeriod(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '';
    return _formatDate(start) + ' ~ ' + _formatDate(end);
  }
  String _formatDate(DateTime? date) {
    if (date == null) return '정보 없음';
    final d = date.toLocal();
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '${d.year}.$mm.$dd $hh:$min';
  }
  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
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
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.025,
        vertical: 12,
      ),
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
                  style: TextStyle(fontSize: width * 0.03, color: const Color(0xff6B7280)),
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
