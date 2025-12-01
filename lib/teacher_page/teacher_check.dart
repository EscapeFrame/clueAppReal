import 'dart:io';

import 'package:clue/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:clue/widgets/common/app_snackbar.dart';

class TeacherCheck extends StatefulWidget {
  final VoidCallback? onBack;
  final dynamic assignmentId;
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
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _notificationInitialized = false;

  Future<void> _fetchAssignmentDetail(String idStr) async {
    setState(() {
      _detailLoading = true;
      _detailError = null;
    });
    try {
      final dio = ApiClient.instance.dio;
      final res = await dio.get('/api/assignments/$idStr');
      final data = res.data;
      final Map<String, dynamic>? detailMap =
          data is Map ? Map<String, dynamic>.from(data) : null;
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
    } catch (e, st) {
      debugPrint('로그 컨텍스트: $e');
      debugPrint('$st');
      if (!mounted) return;
      const msg = '과제 정보를 불러오지 못했습니다. 다시 시도해주세요.';
      setState(() {
        _assignmentTitle = null;
        _assignmentEndDate = null;
        _detailError = msg;
        _detailLoading = false;
      });
      _showSnackBar(msg);
    }
  }

  @override
  void initState() {
    super.initState();
    _allStudents = [];
    filteredStudents = [];
    _ensureLocalNotifications();
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
    } catch (e, st) {
      debugPrint('로그 컨텍스트: $e');
      debugPrint('$st');
      if (!mounted) return;
      const msg = '학생 제출 정보를 불러오지 못했습니다. 다시 시도해주세요.';
      setState(() {
        _studentsLoading = false;
        _studentsError = msg;
      });
      _showSnackBar(msg);
    }
  }

  Future<void> _ensureLocalNotifications() async {
    if (_notificationInitialized) return;
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
    _notificationInitialized = true;
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> _showDownloadNotification(String filePath) async {
    await _ensureLocalNotifications();
    const androidDetails = AndroidNotificationDetails(
      'downloads',
      '다운로드',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    await _localNotifications.show(
      0,
      '다운로드 완료',
      '다운로드가 완료되었습니다.',
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: filePath,
    );
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
                      style: TextStyle(
                        fontSize: width * 0.055,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => widget.onBack?.call(),
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
                    borderSide: const BorderSide(color: Colors.blue),
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
                                                ? const Color(0xFF1CC078)
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
                onDownloadAttachment: _downloadAttachmentFile, // 버튼용(스낵바 있음)
                onOpenAttachment: _openAttachment,
                onOpenFileTile: (attachment) async {
                  final path = await _downloadAttachmentFile(
                    attachment,
                    showSnackbar: false,
                  );
                  if (path != null && path.isNotEmpty) {
                    await OpenFile.open(path); // 파일 뷰, 스낵바 없음
                  }
                },
                onDownloadAll: (attachments) async {
                  for (final attachment in attachments) {
                    final upperType = attachment.type.toUpperCase();
                    if (upperType == 'FILE') {
                      await _downloadAttachmentFile(attachment);
                    } else if (attachment.url.isNotEmpty) {
                      await _openAttachment(attachment.url);
                    }
                  }
                },
              ),
        );
      } else {
        _showSnackBar('제출 정보를 불러오지 못했습니다 (${res.statusCode}).');
      }
    } catch (e, st) {
      debugPrint('로그 컨텍스트: $e');
      debugPrint('$st');
      _showSnackBar('상세 제출 정보를 불러오지 못했습니다. 다시 시도해주세요.');
    }
  }

  Future<String?> _downloadAttachmentFile(
    SubmissionAttachment attachment, {
    bool showSnackbar = true,
  }) async {
    if ((attachment.id).isEmpty) {
      _showSnackBar('다운로드 ID를 찾을 수 없습니다.');
      return null;
    }
    final id = attachment.id;
    final base = ApiClient.instance.dio.options.baseUrl;
    final baseUrl =
        base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final downloadUrl = '$baseUrl/api/submissions/$id/download';
    final fileName =
        attachment.name.isNotEmpty ? attachment.name : 'attachment_$id';
    final safeName = _sanitizeFileName(fileName);
    try {
      final dir = await _resolveDownloadDirectory();
      final file = File(p.join(dir.path, safeName));
      final res = await ApiClient.instance.dio.download(
        downloadUrl,
        file.path,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (res.statusCode != 200) {
        if (!mounted) return null;
        showAppSnackBar(context, '파일을 다운로드할 수 없습니다. 다시 시도해주세요.');
        return null;
      }
      if (!mounted) return null;
      await _showDownloadNotification(file.path);
      if (showSnackbar) {
        showAppSnackBar(
          context,
          '다운로드가 완료되었습니다.',
          isError: false,
        );
      }
      return file.path;
    } catch (e, st) {
      debugPrint('다운로드 오류: $e');
      debugPrint('$st');
      if (!mounted) return null;
      showAppSnackBar(context, '파일을 다운로드하지 못했습니다. 다시 시도해주세요.');
      return null;
    }
  }

  Future<Directory> _resolveDownloadDirectory() async {
    Directory? targetDir;
    if (Platform.isAndroid) {
      // Try shared "Download" so it appears in 내파일/다운로드
      final sharedDownload = await _androidSharedDownloadsDirectory();
      if (sharedDownload != null) {
        targetDir = sharedDownload;
      }
      try {
        final dirs = await getExternalStorageDirectories(
          type: StorageDirectory.downloads,
        );
        if (dirs != null && dirs.isNotEmpty) {
          targetDir = dirs.first;
        }
      } catch (_) {
        // fallback below
      }
      targetDir ??= await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      targetDir = await getApplicationDocumentsDirectory();
    }
    targetDir ??= await getApplicationDocumentsDirectory();
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    return targetDir;
  }

  Future<Directory?> _androidSharedDownloadsDirectory() async {
    final dir = Directory('/storage/emulated/0/Download');
    if (await dir.exists()) {
      return dir;
    }
    return null;
  }

  String _sanitizeFileName(String name) {
    final invalid = RegExp(r'[\\/:*?"<>|]');
    final cleaned = name.replaceAll(invalid, '_').trim();
    return cleaned.isEmpty ? 'attachment' : cleaned;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    showAppSnackBar(context, message);
  }

  Future<void> _openAttachment(String url) async {
    var normalized = url.trim();
    if (normalized.isEmpty) {
      _showSnackBar('잘못된 링크입니다.');
      return;
    }
    final parsed = Uri.tryParse(normalized);
    if (parsed == null || !(parsed.hasScheme)) {
      normalized =
          normalized.startsWith('//')
              ? 'https:$normalized'
              : 'https://$normalized';
    }
    final uri = Uri.tryParse(normalized);
    if (uri == null) {
      _showSnackBar('잘못된 링크입니다.');
      return;
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showSnackBar('링크를 열 수 없습니다.');
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                )
                .toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
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
  final Future<String?> Function(SubmissionAttachment)? onDownloadAttachment;
  final Future<void> Function(String url)? onOpenAttachment;
  final Future<void> Function(SubmissionAttachment)? onOpenFileTile;

  final Future<void> Function(List<SubmissionAttachment> attachments)?
  onDownloadAll;

  const SubmissionDetailDialog({
    super.key,
    required this.detail,
    required this.fallbackStudent,
    this.onDownloadAttachment,
    this.onOpenAttachment,
    this.onOpenFileTile,
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
              ],
            ),
            const SizedBox(height: 8),
            if (attachments.isEmpty)
              const Text(
                '제출된 파일이 없습니다.',
                style: TextStyle(color: textSecondary),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: attachments.length > 3 ? 320 : double.infinity,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics:
                      attachments.length > 3
                          ? const BouncingScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                  itemCount: attachments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final attachment = attachments[index];
                    final isFile = attachment.type.toUpperCase() == 'FILE';
                    final label = isFile ? '다운로드' : '열기';
                    final canAction =
                        (isFile && attachment.id.isNotEmpty) ||
                        (!isFile && attachment.url.isNotEmpty);
                    return InkWell(
                      onTap:
                          canAction
                              ? () async {
                                if (isFile) {
                                  await onOpenFileTile?.call(
                                    attachment,
                                  ); // 스낵바 없이 다운로드+뷰
                                } else if (attachment.url.isNotEmpty) {
                                  await onOpenAttachment?.call(attachment.url);
                                }
                              }
                              : null,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
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
                                  canAction
                                      ? () async {
                                        if (isFile) {
                                          await onDownloadAttachment
                                              ?.call(attachment);
                                        } else if (attachment.url.isNotEmpty) {
                                          await onOpenAttachment
                                              ?.call(attachment.url);
                                        }
                                      }
                                      : null,
                              child: Text(label), // 버튼 = 다운로드/열기(파일/URL 구분)
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
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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
