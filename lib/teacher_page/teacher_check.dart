import 'package:clue/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    _allStudents = [];
    filteredStudents = [];
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
                child: Builder(
                  builder: (context) {
                    if (_studentsLoading && filteredStudents.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (_studentsError != null && filteredStudents.isEmpty) {
                      return Center(
                        child: Text(
                          _studentsError!,
                          style: const TextStyle(color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: filteredStudents.length,
                      separatorBuilder:
                          (_, __) =>
                              Divider(height: 1, color: Colors.grey[200]),
                      itemBuilder: (context, idx) {
                        final student = filteredStudents[idx];
                        return GestureDetector(
                          onTap: () => _showSubmissionDetail(student),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: height * 0.015,
                            ),
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

                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    student['name'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: width * 0.04,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),

                                SizedBox(width: width * 0.04),
                                Expanded(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.centerRight,
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
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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

  Future<void> _showSubmissionDetail(Map<String, dynamic> student) async {
    final submissionId = student['submissionId']?.toString();
    if (submissionId == null || submissionId.isEmpty) {
      _showSnackBar('제출 ID가 없어 상세 정보를 열 수 없습니다.');
      return;
    }
    try {
      final dio = ApiClient.instance.dio;
      final res = await dio.get('/api/submissions/assignment/$submissionId');
      if (!mounted) return;
      if (res.statusCode == 200 && res.data is Map) {
        final detail = Map<String, dynamic>.from(res.data as Map);
        await showDialog(
          context: context,
          builder:
              (ctx) => SubmissionDetailDialog(
                detail: detail,
                fallbackStudent: student,
                onDownloadAttachment: (url) => _openAttachment(url),
                onDownloadAll: (urls) async {
                  for (final url in urls) {
                    await _openAttachment(url);
                  }
                },
              ),
        );
      } else {
        _showSnackBar('제출 정보를 불러오지 못했습니다 (${res.statusCode}).');
      }
    } on DioException catch (e) {
      _showSnackBar(e.message ?? '제출 정보를 불러오지 못했습니다.');
    } catch (e) {
      _showSnackBar('제출 정보를 불러오지 못했습니다: $e');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openAttachment(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showSnackBar('잘못된 링크입니다.');
      return;
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showSnackBar('파일을 열 수 없습니다.');
    }
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

class SubmissionDetailDialog extends StatelessWidget {
  final Map<String, dynamic> detail;
  final Map<String, dynamic> fallbackStudent;
  final Future<void> Function(String url)? onDownloadAttachment;
  final Future<void> Function(List<String> urls)? onDownloadAll;

  const SubmissionDetailDialog({
    super.key,
    required this.detail,
    required this.fallbackStudent,
    this.onDownloadAttachment,
    this.onDownloadAll,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xff0077FF);
    const successColor = Color(0xff16A34A);
    const dangerColor = Color(0xffDC2626);
    const surfaceColor = Colors.white;
    const subtleSurfaceColor = Color(0xffF8FAFC);
    const borderColor = Color(0xffE2E8F0);
    const textPrimary = Color(0xff0F172A);
    const textSecondary = Color(0xff475569);

    final submitted =
        detail['IsSubmitted'] == true || detail['isSubmitted'] == true;
    final submittedAtRaw = detail['submittedAt']?.toString();
    final submittedAt =
        submittedAtRaw != null && submittedAtRaw.isNotEmpty
            ? DateTime.tryParse(submittedAtRaw)
            : null;
    final attachments = _parseAttachments();
    final name =
        detail['userName']?.toString().isNotEmpty == true
            ? detail['userName'].toString()
            : (fallbackStudent['name']?.toString() ?? '');
    final number = fallbackStudent['number']?.toString() ?? '';

    return Dialog(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  submitted ? '제출완료' : '미제출',
                  style: TextStyle(
                    color: submitted ? successColor : dangerColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: subtleSurfaceColor,
                  child: Icon(Icons.person, color: textSecondary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$name $number',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      if (submittedAt != null) const SizedBox(height: 2),
                      if (submittedAt != null)
                        Text(
                          '제출: ${_formatDateTime(submittedAt)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '제출 파일 ${attachments.length}개',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                if (attachments.isNotEmpty)
                  TextButton(
                    onPressed:
                        onDownloadAll != null
                            ? () {
                              final urls =
                                  attachments
                                      .map((e) => e.url)
                                      .where((url) => url.isNotEmpty)
                                      .toList();
                              if (urls.isNotEmpty) {
                                onDownloadAll!(urls);
                              }
                            }
                            : null,
                    style: TextButton.styleFrom(
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    child: const Text('전체 다운로드'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (attachments.isEmpty)
              const Text(
                '제출된 파일이 없습니다.',
                style: TextStyle(color: textSecondary),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: attachments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final attachment = attachments[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: subtleSurfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                attachment.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                attachment.sizeLabel,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed:
                              (onDownloadAttachment != null &&
                                      attachment.url.isNotEmpty)
                                  ? () => onDownloadAttachment!(attachment.url)
                                  : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: const BorderSide(color: primaryColor),
                            backgroundColor: surfaceColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          child: const Text('다운로드'),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  List<SubmissionAttachment> _parseAttachments() {
    final rawList = detail['submissionAttachmentResponses'];
    if (rawList is! List) return const <SubmissionAttachment>[];
    return rawList.whereType<Map>().map((item) {
      final map = Map<String, dynamic>.from(item);
      final fileName =
          map['originalFileName']?.toString().isNotEmpty == true
              ? map['originalFileName'].toString()
              : (map['value']?.toString() ?? '첨부 파일');
      final sizeLabel = _formatFileSize(map['size']);
      return SubmissionAttachment(
        id: map['submissionAttachmentId']?.toString() ?? '',
        name: fileName,
        url: map['value']?.toString() ?? '',
        type: map['type']?.toString() ?? '',
        sizeLabel: sizeLabel,
      );
    }).toList();
  }

  String _formatFileSize(dynamic size) {
    final intVal =
        size is int
            ? size
            : size is String
            ? int.tryParse(size) ?? 0
            : int.tryParse(size?.toString() ?? '') ?? 0;
    if (intVal >= 1024 * 1024) {
      return '${(intVal / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    if (intVal >= 1024) {
      return '${(intVal / 1024).toStringAsFixed(1)}KB';
    }
    if (intVal > 0) {
      return '${intVal}B';
    }
    return '용량 정보 없음';
  }

  String _formatDateTime(DateTime date) {
    final local = date.toLocal();
    final mm = local.month.toString().padLeft(2, '0');
    final dd = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '${local.year}.$mm.$dd $hh:$min';
  }
}

class SubmissionAttachment {
  final String id;
  final String name;
  final String url;
  final String type;
  final String sizeLabel;

  const SubmissionAttachment({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.sizeLabel,
  });
}
