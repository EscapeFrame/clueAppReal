import 'package:clue/api_client.dart';
import 'package:clue/config/teacher_data.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class TeacherCheck extends StatefulWidget {
  final VoidCallback? onBack;
  final assignmentId;
  const TeacherCheck({super.key, this.onBack, required this.assignmentId});

  @override
  State<TeacherCheck> createState() => _TeacherCheckState();
}

class _TeacherCheckState extends State<TeacherCheck> {
  String selectedStatus = '상태';
  String selectedGrade = '학년';
  String selectedClass = '반';
  String searchText = '';
  List<Map<String, dynamic>> filteredStudents = [];
  List<Map<String, dynamic>> _allStudents = [];
  bool _studentsLoading = false;
  String? _studentsError;
  String? _assignmentTitle;
  DateTime? _assignmentEndDate;
  bool _detailLoading = false;
  String? _detailError;

  Future<void> _fetchAssignmentDetail(String idStr) async {
    setState(() {
      _detailLoading = true;
      _detailError = null;
    });
    debugPrint("idSSSSTTTTRRR:  $idStr");
    try {
      final dio = ApiClient.instance.dio;
      final res = await dio.get('/api/assignments/$idStr');
      final data = res.data;
      final Map<String, dynamic>? detailMap =
          data is Map ? Map<String, dynamic>.from(data as Map) : null;
      final String? detailTitle = detailMap?['title']?.toString();
      final String? endDateStr = detailMap?['endDate']?.toString();
      final DateTime? parsedEndDate =
          (endDateStr != null && endDateStr.isNotEmpty)
              ? DateTime.tryParse(endDateStr)
              : null;
      if (!mounted) return;
      if (res.statusCode == 200 && detailMap != null) {
        setState(() {
          _assignmentTitle = detailTitle;
          _assignmentEndDate = parsedEndDate;
          _detailError = null;
          _detailLoading = false;
        });
      } else {
        setState(() {
          _assignmentTitle = null;
          _assignmentEndDate = null;
          _detailError = '과제 정보를 불러오지 못했습니다 (${res.statusCode}).';
          _detailLoading = false;
        });
      }
      debugPrint("응답값 : ${data.toString()}");
    } on DioException catch (e) {
      debugPrint("DioError:  ${e.error}");
      debugPrint("DioError:  ${e.message}");
      if (!mounted) return;
      setState(() {
        _assignmentTitle = null;
        _assignmentEndDate = null;
        _detailError = e.message ?? '과제 정보를 불러오지 못했습니다.';
        _detailLoading = false;
      });
    } catch (e) {
      debugPrint("Errrrrrrorrrr:$e");
      if (!mounted) return;
      setState(() {
        _assignmentTitle = null;
        _assignmentEndDate = null;
        _detailError = '과제 정보를 불러오지 못했습니다: $e';
        _detailLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _allStudents = TeacherData.getStudentJechul();
    filteredStudents = List<Map<String, dynamic>>.from(_allStudents);
    final idStr = (widget.assignmentId ?? '').toString();
    if (idStr.isNotEmpty) {
      _fetchAssignmentDetail(idStr);
      _fetchSubmissions(idStr);
    }
  }

  @override
  void didUpdateWidget(covariant TeacherCheck oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentId = (widget.assignmentId ?? '').toString();
    final prevId = (oldWidget.assignmentId ?? '').toString();
    if (currentId.isNotEmpty && currentId != prevId) {
      _fetchAssignmentDetail(currentId);
      _fetchSubmissions(currentId);
    }
  }

  void _updateFilteredStudents() {
    final source = _allStudents;
    final searchLower = searchText.toLowerCase();
    filteredStudents =
        source.where((student) {
          final name = student['name']?.toString().toLowerCase() ?? '';
          final number = student['number']?.toString().toLowerCase() ?? '';
          final isSubmitted = student['submitted'] == true;
          final matchesSearch =
              name.contains(searchLower) || number.contains(searchLower);
          bool matchesStatus = true;
          if (selectedStatus == '제출완료') {
            matchesStatus = isSubmitted;
          } else if (selectedStatus == '미제출') {
            matchesStatus = !isSubmitted;
          }
          return matchesSearch && matchesStatus;
        }).toList();
  }

  Future<void> _fetchSubmissions(String idStr) async {
    setState(() {
      _studentsLoading = true;
      _studentsError = null;
    });
    try {
      final dio = ApiClient.instance.dio;
      final res = await dio.get('/api/submissions/$idStr/check');
      if (!mounted) return;
      if (res.statusCode == 200 && res.data is List) {
        debugPrint('Submission check response: ${res.data}');
        final list =
            (res.data as List)
                .map((item) {
                  if (item is Map) {
                    final map = Map<String, dynamic>.from(item);
                    final grade = map['grade'];
                    final classNo = map['classNo'];
                    final number = map['number'];
                    final numberStr =
                        number == null
                            ? ''
                            : number is int
                            ? number.toString().padLeft(2, '0')
                            : number.toString().padLeft(2, '0');
                    final formattedNumber =
                        [
                          grade != null ? grade.toString() : '',
                          classNo != null ? classNo.toString() : '',
                          numberStr,
                        ].join();
                    return {
                      'number': formattedNumber,
                      'name': map['userName']?.toString() ?? '',
                      'submitted': map['isSubmitted'] == true,
                      'submittedAt': map['submittedAt']?.toString(),
                      'grade': map['grade'],
                      'classNo': map['classNo'],
                      'submissionId': map['submissionId']?.toString(),
                    };
                  }
                  return null;
                })
                .whereType<Map<String, dynamic>>()
                .toList();
        setState(() {
          _allStudents = list;
          _updateFilteredStudents();
          _studentsLoading = false;
          _studentsError = null;
        });
      } else {
        setState(() {
          _studentsLoading = false;
          _studentsError = '제출 정보를 불러오지 못했습니다 (${res.statusCode}).';
        });
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _studentsLoading = false;
        _studentsError = e.message ?? '제출 정보를 불러오지 못했습니다.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _studentsLoading = false;
        _studentsError = '제출 정보를 불러오지 못했습니다: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _assignmentTitle ??
                          (_detailLoading
                              ? '과제 정보를 불러오는 중입니다.'
                              : _detailError ?? '과제 제목 정보 없음'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: width * 0.055,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (widget.onBack != null) {
                        widget.onBack!();
                      }
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.black,
                      size: width * 0.06,
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.01),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: width * 0.04,
                    color: Colors.grey[700],
                  ),
                  SizedBox(width: width * 0.01),
                  Text(
                    _buildDueDateLabel(),
                    style: TextStyle(
                      fontSize: width * 0.035,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.015),

              if (false)
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: width * 0.04,
                      color: Colors.grey,
                    ),
                    SizedBox(width: width * 0.01),
                    Text(
                      '마감일: 2025.04.15 23:59:59',
                      style: TextStyle(
                        fontSize: width * 0.035,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: height * 0.02),

              _buildDropdown(selectedStatus, ['상태', '제출완료', '미제출'], (val) {
                setState(() {
                  selectedStatus = val!;
                  _updateFilteredStudents();
                });
              }),
              SizedBox(height: height * 0.02),

              TextField(
                decoration: InputDecoration(
                  hintText: '찾으시는 학생을 검색해주세요.',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: width * 0.035,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: EdgeInsets.symmetric(
                    vertical: height * 0.015,
                    horizontal: width * 0.03,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    _updateFilteredStudents();
                  });
                },
              ),
              SizedBox(height: height * 0.02),

              Expanded(
                child: ListView.separated(
                  itemCount: filteredStudents.length,
                  separatorBuilder:
                      (_, __) => Divider(height: 1, color: Colors.grey[200]),
                  itemBuilder: (context, idx) {
                    final student = filteredStudents[idx];
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: height * 0.015),
                      child: Row(
                        children: [
                          SizedBox(
                            width: width * 0.15,
                            child: Text(
                              student['number'],
                              style: TextStyle(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          SizedBox(
                            width: width * 0.2,
                            child: Text(
                              student['name'],
                              style: TextStyle(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          Expanded(
                            child: Text(
                              student['submitted'] ? '제출완료' : '미제출',
                              style: TextStyle(
                                color:
                                    student['submitted']
                                        ? Color(0xFF1CC078)
                                        : Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: width * 0.04,
                              ),
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${student['name']} 학생 채점하기'),
                                ),
                              );
                            },
                            child: Text(
                              '채점하기',
                              style: TextStyle(
                                color: Color(0xFF3A7BFF),
                                fontWeight: FontWeight.w500,
                                fontSize: width * 0.04,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildDueDateLabel() {
    if (_assignmentEndDate != null) {
      final date = _assignmentEndDate!.toLocal();
      final mm = date.month.toString().padLeft(2, '0');
      final dd = date.day.toString().padLeft(2, '0');
      final hh = date.hour.toString().padLeft(2, '0');
      final min = date.minute.toString().padLeft(2, '0');
      return '마감일 ${date.year}.$mm.$dd $hh:$min';
    }
    if (_detailLoading) return '마감일 정보를 불러오는 중입니다.';
    if (_detailError != null) return '마감일 정보를 불러오지 못했습니다.';
    return '마감일 정보 없음';
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      child: DropdownButton<String>(
        value: value,
        items:
            items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                )
                .toList(),
        onChanged: onChanged,
        underline: SizedBox(),
        isDense: true,
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
        dropdownColor: Colors.white,
      ),
    );
  }
}
