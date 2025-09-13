import 'package:clue/teacher_page/tHakSubSilGaJa.dart';
import 'package:clue/teacher_page/teacher_check.dart';
import 'package:clue/teacher_page/teacher_gwaJe_Jechul/data/assignment_service.dart';
import 'package:clue/teacher_page/teacher_gwaJe_Jechul/sheets/create_assignment_sheet.dart';
import 'package:clue/teacher_page/teacher_gwaJe_Jechul/sheets/edit_assignment_sheet.dart';
import 'package:clue/teacher_page/teacher_gwaJe_Jechul/utils/file_utils.dart';
import 'package:clue/teacher_page/teacher_gwaJe_Jechul/widgets/file_item_row.dart';
import 'package:file_picker/file_picker.dart';
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
  List<bool> isEditMode = [];
  bool showTeacherCheck = false;
  bool showAssignmentDetail = false;
  Map<String, dynamic>? selectedAssignment;

  void _closeAssignmentDetail() {
    setState(() {
      showAssignmentDetail = false;
      selectedAssignment = null;
    });
  }

  @override
  void initState() {
    super.initState();
    gwaJeJeChul();
    dataList = List.from(widget.dataList);
    isEditMode = List.generate(dataList.length, (index) => false);
    for (var data in dataList) {
      if (data['files'] == null || data['files'] is! List) {
        data['files'] = [];
      }
      data['files'].removeWhere((f) => f == null);
    }
  }

  Future<void> gwaJeJeChul() async {
    final parsed = await AssignmentService.fetchAssignments(widget.classRoomId);
    if (!mounted) return;
    setState(() {
      dataList = parsed;
      isEditMode = List.generate(dataList.length, (index) => false);
    });
  }

  Future<void> pickFile(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        dataList[index]['files'].add({
          'name': file.name,
          'size': formatFileSize(file.size),
        });
      });
    }
  }

  void removeFile(int dataIndex, int fileIndex) {
    setState(() {
      dataList[dataIndex]['files'].removeAt(fileIndex);
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
                    isEditMode = List.generate(dataList.length, (index) => false);
                  });
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('과제를 생성했어요.')),
                  );
                }
              },
              backgroundColor: const Color(0xff86C1FF),
              child: const Icon(Icons.add),
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
                      assignmentId: ((selectedAssignment?['assignmentId'] ??
                                  selectedAssignment?['id'] ??
                                  selectedAssignment?['assignment_id'] ??
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
        return GestureDetector(
          onTap: () {
            setState(() {
              final mapped = Map<String, dynamic>.from(data);
              if (!(mapped.containsKey('file')) && mapped['files'] is List && (mapped['files'] as List).isNotEmpty) {
                mapped['file'] = (mapped['files'] as List).first;
              } else if (!mapped.containsKey('file')) {
                mapped['file'] = {'name': ''};
              }
              if (mapped['assignmentId'] == null) {
                final dynamic altId = mapped['id'] ?? mapped['assignment_id'];
                if (altId != null) {
                  final parsed = int.tryParse(altId.toString());
                  mapped['assignmentId'] = parsed ?? altId;
                }
              }
              selectedAssignment = mapped;
              showAssignmentDetail = true;
            });
          },
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.012,
            ),
            padding: EdgeInsets.all(width * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(width * 0.04),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: width * 0.02,
                  offset: Offset(0, width * 0.01),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data['title'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: width * 0.02),
                  ],
                ),
                SizedBox(height: height * 0.012),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: width * 0.04,
                      color: Colors.grey,
                    ),
                    SizedBox(width: width * 0.015),
                    Text(
                      "마감일:  ${data['due']}",
                      style: TextStyle(fontSize: width * 0.03),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.008),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: width * 0.04,
                      color: Colors.blue,
                    ),
                    SizedBox(width: width * 0.015),
                    Text(
                      data['timeLeft'],
                      style: TextStyle(
                        fontSize: width * 0.03,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.018),

                ...List.generate(data['files'].length, (fileIdx) {
                  final file = data['files'][fileIdx];
                  return FileItemRow(
                    width: width,
                    file: file,
                    onTapDownload: () {
                      if (file['url'] != null && file['url'].toString().isNotEmpty) {
                        downloadAndOpenFile(context, file['url'], file['name']);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('다운로드 URL이 없습니다.')),
                        );
                      }
                    },
                    onRemove: () => removeFile(index, fileIdx),
                  );
                }),

                if (isEditMode[index]) ...[
                  SizedBox(height: height * 0.012),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => pickFile(index),
                      icon: const Icon(Icons.attach_file),
                      label: Text(
                        '파일 추가',
                        style: TextStyle(fontSize: width * 0.032),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[100],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(width * 0.025),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: height * 0.012,
                          horizontal: width * 0.04,
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: height * 0.018),
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
                                const SnackBar(content: Text('과제를 수정했어요.')),
                              );
                            }
                          },
                          label: Text(
                            '내용수정',
                            style: TextStyle(fontSize: width * 0.035),
                          ),
                          icon: const Icon(Icons.edit),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(width * 0.025),
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
                                final altId = mapped['id'] ?? mapped['assignment_id'];
                                if (altId != null) {
                                  final parsed = int.tryParse(altId.toString());
                                  mapped['assignmentId'] = parsed ?? altId;
                                }
                              }
                              selectedAssignment = mapped;
                              showTeacherCheck = true;
                            });
                          },
                          label: Text(
                            '확인/채점',
                            style: TextStyle(fontSize: width * 0.035),
                          ),
                          icon: const Icon(Icons.check),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB9DCFF),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(width * 0.025),
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
}
// 교사용 과제 목록/생성/수정 화면의 메인 페이지.
// 서비스(AssignmentService), 시트(create/edit), 위젯(FileItemRow) 등을 조합해 UI와 상태를 관리합니다.
