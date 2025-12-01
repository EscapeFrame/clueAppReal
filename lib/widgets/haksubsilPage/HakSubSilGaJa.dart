// 페이지: 학습실 과제 상세/제출 화면의 메인 구현입니다.
import 'dart:io';

import 'package:clue/api_client.dart';
import 'package:clue/teacher_page/t_haksubsil/data/haksubsil_service.dart';
import 'package:clue/widgets/common/app_snackbar.dart';
import 'package:clue/widgets/haksubsil/dialogs/upload_choice_menu.dart';
import 'package:clue/widgets/haksubsil/dialogs/upload_file_dialog.dart';
import 'package:clue/widgets/haksubsil/dialogs/url_input_dialog.dart';
import 'package:clue/widgets/haksubsil/state/haksubsil_controller.dart';
import 'package:clue/widgets/haksubsil/utils/attachment_mapper.dart';
import 'package:clue/widgets/haksubsil/utils/id_resolver.dart';
import 'package:clue/widgets/haksubsil/utils/formatters.dart';
import 'package:clue/widgets/haksubsil/widgets/sections/actions_section.dart';
import 'package:clue/widgets/haksubsil/widgets/sections/attachments_section.dart';
import 'package:clue/widgets/haksubsil/widgets/sections/description_section.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as p;

class Haksubsilgaja extends StatefulWidget {
  final Map<String, dynamic> assignment;
  final VoidCallback onClose;

  const Haksubsilgaja({
    super.key,
    required this.assignment,
    required this.onClose,
  });

  @override
  State<Haksubsilgaja> createState() => _HaksubsilgajaState();
}

class _HaksubsilgajaState extends State<Haksubsilgaja> {
  final controller = HaksubsilController();
  final GlobalKey _uploadButtonKey = GlobalKey();
  List<Map<String, dynamic>> _assignmentAttachments = const [];
  final Set<String> _removedSubmissionAttachmentIds = <String>{};

  Widget _buildDetailHeader({
    required BuildContext context,
    required String title,
    required String dueDateText,
    required String timeLeftText,
    required VoidCallback onClose,
    required String submissionStateLabel,
    required Color submissionStateColor,
  }) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.022,
                vertical: width * 0.007,
              ),
              decoration: BoxDecoration(
                color: submissionStateColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(width * 0.03),
              ),
              child: Text(
                submissionStateLabel,
                style: TextStyle(
                  fontSize: width * 0.03,
                  fontWeight: FontWeight.w600,
                  color: submissionStateColor,
                ),
              ),
            ),
            IconButton(
              iconSize: width * 0.06,
              icon: const Icon(Icons.close),
              onPressed: onClose,
            ),
          ],
        ),
        SizedBox(height: height * 0.001),
        Text(
          title,
          style: TextStyle(
            fontSize: width * 0.055,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            Icon(Icons.calendar_today, size: width * 0.04, color: Colors.grey),
            SizedBox(width: width * 0.015),
            Text(dueDateText, style: TextStyle(fontSize: width * 0.03)),
          ],
        ),
        SizedBox(height: height * 0.008),
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: width * 0.04,
              color: const Color(0xff3B82F6),
            ),
            SizedBox(width: width * 0.015),
            Text(
              timeLeftText,
              style: TextStyle(
                fontSize: width * 0.03,
                color: const Color(0xff3B82F6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String? _resolveSubmissionId(Map<String, dynamic>? data) {
    if (data == null) return null;
    final candidates = [
      data['submissionId'],
      data['SubmissionId'],
      data['submission_id'],
    ];
    for (final v in candidates) {
      final s = v?.toString();
      if (s != null && s.isNotEmpty) return s;
    }
    return null;
  }

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true') return true;
      if (lower == 'false') return false;
      final asNum = double.tryParse(lower);
      if (asNum != null) return asNum != 0;
    }
    return false;
  }

  String? _resolveCurrentSubmissionId() {
    final detailMap = controller.detail;
    if (detailMap != null) {
      final resolved = _resolveSubmissionId(detailMap);
      if (resolved != null && resolved.isNotEmpty) {
        return resolved;
      }
    }
    return _resolveSubmissionId(widget.assignment);
  }

  Future<void> _openAttachmentLink(Map<String, dynamic> attachment) async {
    final url = Uri.tryParse((attachment['url'] ?? '').toString());
    if (url != null) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _handleAssignmentAttachmentTap(
    Map<String, dynamic> attachment, {
    bool openAfterDownload = true,
  }) async {
    final kind = (attachment['kind'] ?? '').toString().toUpperCase();
    if (kind == 'URL') {
      await _openAttachmentLink(attachment);
      return;
    }
    final attachmentId = (attachment['attachmentId'] ?? '').toString();
    if (attachmentId.isEmpty) {
      if (!mounted) return;
      showAppSnackBar(context, '다운로드할 첨부 정보를 찾을 수 없습니다.');
      return;
    }
    final fileName = (attachment['name'] ?? 'attachment').toString();
    await _downloadAssignmentAttachment(
      attachmentId,
      fileName,
      openAfterDownload: openAfterDownload,
    );
  }

  Future<void> _handleAttachmentTap(Map<String, dynamic> attachment) async {
    await _handleAssignmentAttachmentTap(attachment, openAfterDownload: true);
  }

  Future<void> _downloadAssignmentAttachment(
    String attachmentId,
    String fileName, {
    bool openAfterDownload = true,
  }) async {
    try {
      final bytes = await HaksubsilService.downloadAttachmentBytes(
        attachmentId,
      );
      if (bytes == null) {
        if (!mounted) return;
        showAppSnackBar(context, '파일 다운로드에 실패했습니다. 다시 시도해주세요.');
        return;
      }
      final safeName = _sanitizeFileName(
        fileName.isEmpty ? 'attachment-$attachmentId' : fileName,
      );
      Directory dir = await getApplicationDocumentsDirectory();
      if (Platform.isAndroid) {
        // Try to save to public Downloads for easier access; fallback to app docs.
        final downloads = Directory('/storage/emulated/0/Download');
        if (await downloads.exists()) {
          dir = downloads;
        } else {
          final ext = await getExternalStorageDirectory();
          if (ext != null) dir = ext;
        }
      }
      final file = File(p.join(dir.path, safeName));
      await file.writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      if (openAfterDownload) {
        await OpenFile.open(file.path);
      } else {
        showAppSnackBar(context, '다운로드 완료: ${file.path}', isError: false);
      }
    } catch (e, st) {
      debugPrint('로그 컨텍스트: $e');
      debugPrint('$st');
      if (!mounted) return;
      showAppSnackBar(context, '파일을 다운로드하지 못했습니다. 다시 시도해주세요.');
    }
  }

  String _sanitizeFileName(String name) {
    final sanitized = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return sanitized.isEmpty ? 'attachment' : sanitized;
  }

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    controller.loading = true;
    controller.error = null;
    List<Map<String, dynamic>> assignmentAttachments = const [];
    setState(() {});
    try {
      final submissionId = _resolveSubmissionId(widget.assignment);
      Map<String, dynamic>? submissionDetail;
      final dio = ApiClient.instance.dio;
      if (submissionId == null) {
        controller.error = '제출 ID를 찾지 못했습니다.';
      }
      if (submissionId != null) {
        final res = await dio.get('/api/submissions/assignment/$submissionId');
        if (!mounted) return;
        if (res.statusCode == 200 && res.data is Map) {
          final detailMap = Map<String, dynamic>.from(res.data as Map);
          submissionDetail = detailMap;
          controller.detail = detailMap;
        } else {
          controller.error = '상세 조회 실패(${res.statusCode})';
        }
      }
      String? assignmentId;
      if (submissionDetail != null) {
        assignmentId = resolveAssignmentId(submissionDetail!);
      }
      assignmentId ??= resolveAssignmentId(widget.assignment);
      if (assignmentId != null) {
        final assignmentRes = await dio.get('/api/assignments/$assignmentId');
        if (!mounted) return;
        if (assignmentRes.statusCode == 200 && assignmentRes.data is Map) {
          final dtoList =
              ((assignmentRes.data as Map)['attachmentDtos'] as List?) ??
              const [];
          if (dtoList.isNotEmpty) {
            assignmentAttachments = mapAttachments(dtoList);
          }
        }
      }
    } catch (e, st) {
      final msg = '과제 정보를 불러오지 못했습니다. 다시 시도해주세요.';
      controller.error = msg;
      debugPrint('로그 컨텍스트: $e');
      debugPrint('$st');
      if (mounted) {
        showAppSnackBar(context, msg);
      }
    } finally {
      controller.loading = false;
      if (mounted) {
        setState(() {
          _assignmentAttachments = assignmentAttachments;
        });
      }
    }
  }

  Future<void> _handleUploadMenu() async {
    final width = MediaQuery.of(context).size.width;
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '첨부 방식 선택',
                        style: TextStyle(
                          fontSize: width * 0.042,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      iconSize: width * 0.056,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(ctx, 'file'),
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text('파일 업로드'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xff3B82F6),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: width * 0.04),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: TextStyle(
                      fontSize: width * 0.038,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(ctx, 'url'),
                  icon: const Icon(Icons.link_outlined),
                  label: const Text('URL 링크 업로드'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: width * 0.04),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Color(0xff94A3B8)),
                    foregroundColor: const Color(0xff1E3A8A),
                    textStyle: TextStyle(
                      fontSize: width * 0.038,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (choice == 'file') {
      await showUploadFileDialog(context, (file) => controller.addFile(file));
      setState(() {});
    } else if (choice == 'url') {
      await showUrlInputDialog(context, (url) => controller.addUrl(url));
      setState(() {});
    }
  }

  Future<bool> _confirmAttachmentDeletion(String name) async {
    final width = MediaQuery.of(context).size.width;
    return await showDialog<bool>(
          context: context,
          builder:
              (ctx) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                insetPadding: EdgeInsets.symmetric(
                  horizontal: width * 0.08,
                  vertical: width * 0.04,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '첨부 삭제',
                            style: TextStyle(
                              fontSize: width * 0.045,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx, false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "'$name' 첨부를 삭제하시겠습니까?",
                        style: TextStyle(
                          fontSize: width * 0.038,
                          color: const Color(0xff4B5563),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: width * 0.028,
                                ),
                                side: const BorderSide(
                                  color: Color(0xffCBD5F5),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('취소'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: width * 0.028,
                                ),
                                backgroundColor: const Color(0xffEF4444),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('삭제'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        ) ??
        false;
  }

  Future<bool> _showActionConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final width = MediaQuery.of(context).size.width;
    return await showDialog<bool>(
          context: context,
          builder:
              (ctx) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                insetPadding: EdgeInsets.symmetric(
                  horizontal: width * 0.08,
                  vertical: width * 0.04,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: width * 0.045,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx, false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: width * 0.038,
                          color: const Color(0xff4B5563),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: width * 0.028,
                                ),
                                side: const BorderSide(
                                  color: Color(0xffCBD5F5),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('취소'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: width * 0.028,
                                ),
                                backgroundColor: const Color(0xff3B82F6),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(confirmLabel),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        ) ??
        false;
  }

  Future<void> _handleServerSubmissionAttachmentRemoval({
    required String attachmentId,
    required String name,
  }) async {
    final confirmed = await _confirmAttachmentDeletion(name);
    if (!confirmed) return;
    try {
      final dio = ApiClient.instance.dio;
      await dio.delete('/api/submissions/$attachmentId');
      setState(() {
        _removedSubmissionAttachmentIds.add(attachmentId);
      });
      if (!mounted) return;
      showAppSnackBar(context, '첨부가 삭제되었습니다.', isError: false);
      await _loadDetail();
    } catch (e, st) {
      debugPrint('로그 컨텍스트: $e');
      debugPrint('$st');
      if (!mounted) return;
      showAppSnackBar(context, '첨부파일 삭제에 실패했습니다. 다시 시도해주세요.');
    }
  }

  List<Map<String, dynamic>> _decorateSubmissionAttachments(
    List<Map<String, dynamic>> attachments, {
    required bool allowRemoval,
  }) {
    return attachments.map((item) {
      final copy = Map<String, dynamic>.from(item);
      final attachmentId = (copy['attachmentId'] ?? '').toString();
      final displayName = (copy['name'] ?? '첨부파일').toString();
      if (allowRemoval && attachmentId.isNotEmpty) {
        copy['onRemove'] = () {
          _handleServerSubmissionAttachmentRemoval(
            attachmentId: attachmentId,
            name: displayName,
          );
        };
      }
      return copy;
    }).toList();
  }

  Future<void> _submitPendingAttachments() async {
    final submissionId = _resolveCurrentSubmissionId();
    if (submissionId == null) {
      if (!mounted) return;
      showAppSnackBar(context, '제출 ID를 찾지 못했습니다.');
      return;
    }
    final dio = ApiClient.instance.dio;
    final submitPayload = {
      'submissionId': submissionId,
      'IsSubmitted': true,
      'submittedAt': DateTime.now().toUtc().toIso8601String(),
    };
    try {
      if (controller.uploadedUrls.isNotEmpty) {
        final payload =
            controller.uploadedUrls.map((url) => {'url': url}).toList();
        await dio.post('/api/submissions/$submissionId/link', data: payload);
      }
      if (controller.uploadedFiles.isNotEmpty) {
        final formData = FormData();
        for (final file in controller.uploadedFiles) {
          final multipart = await _platformFileToMultipart(file);
          if (multipart != null) {
            formData.files.add(MapEntry('files', multipart));
          }
        }
        if (formData.files.isNotEmpty) {
          await dio.post('/api/submissions/$submissionId/file', data: formData);
        }
      }
      await dio.patch(
        '/api/submissions/$submissionId/submit',
        data: submitPayload,
      );
      setState(() {
        controller.uploadedFiles.clear();
        controller.uploadedUrls.clear();
        controller.submitted = true;
      });
      controller.notifyListeners();
      await _loadDetail();
      if (!mounted) return;
      showAppSnackBar(context, '제출되었습니다.', isError: false);
    } catch (e, st) {
      debugPrint('로그 컨텍스트: $e');
      debugPrint('$st');
      if (!mounted) return;
      showAppSnackBar(context, '과제 제출에 실패했습니다. 다시 시도해주세요.');
    }
  }

  Future<void> _cancelSubmission() async {
    final submissionId = _resolveCurrentSubmissionId();
    if (submissionId == null) {
      if (!mounted) return;
      showAppSnackBar(context, '제출 ID를 찾지 못했습니다.');
      return;
    }
    final dio = ApiClient.instance.dio;
    final payload = {
      'submissionId': submissionId,
      'IsSubmitted': false,
      'submittedAt': DateTime.now().toUtc().toIso8601String(),
    };
    try {
      await dio.patch('/api/submissions/$submissionId/cancel', data: payload);
      setState(() {
        controller.submitted = false;
      });
      controller.notifyListeners();
      await _loadDetail();
      if (!mounted) return;
      showAppSnackBar(context, '제출이 취소되었습니다.', isError: false);
    } catch (e, st) {
      debugPrint('로그 컨텍스트: $e');
      debugPrint('$st');
      if (!mounted) return;
      showAppSnackBar(context, '제출 취소에 실패했습니다. 다시 시도해주세요.');
    }
  }

  Future<void> _handleToggleSubmit() async {
    if (controller.submitted) {
      final confirmed = await _showActionConfirmDialog(
        title: '제출 취소',
        message: '제출을 취소하시겠습니까?',
        confirmLabel: '제출 취소',
      );
      if (confirmed) {
        await _cancelSubmission();
      }
      return;
    }
    final hasPendingUploads =
        controller.uploadedFiles.isNotEmpty ||
        controller.uploadedUrls.isNotEmpty;
    final dialogTitle = hasPendingUploads ? '제출 확인' : '안내';
    final dialogMessage =
        hasPendingUploads ? '과제 제출을 완료하시겠습니까?' : '업로드한 파일이 없습니다.\n제출하시겠습니까?';
    final confirmed = await _showActionConfirmDialog(
      title: dialogTitle,
      message: dialogMessage,
      confirmLabel: '제출',
    );
    if (confirmed) {
      await _submitPendingAttachments();
    }
  }

  Future<MultipartFile?> _platformFileToMultipart(PlatformFile file) async {
    try {
      if (file.path != null) {
        return await MultipartFile.fromFile(file.path!, filename: file.name);
      }
      if (file.bytes != null) {
        return MultipartFile.fromBytes(file.bytes!, filename: file.name);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw.replaceAll(' ', 'T')).toLocal();
    } catch (_) {
      return null;
    }
  }

  String _formatTimeLeft(DateTime? end) {
    if (end == null) return '남은 시간 정보 없음';
    final diff = end.difference(DateTime.now());
    if (diff.isNegative) return '마감됨';
    final days = diff.inDays;
    final hours = diff.inHours - days * 24;
    final minutes = diff.inMinutes - diff.inHours * 60;
    if (days > 0) return 'D-$days · ${days}일 ${hours}시간 남음';
    if (diff.inHours > 0) return '${diff.inHours}시간 ${minutes}분 남음';
    return '${minutes}분 남음';
  }

  String _formatDue(DateTime? end) {
    if (end == null) return '마감일 정보 없음';
    final y = end.year.toString().padLeft(4, '0');
    final m = end.month.toString().padLeft(2, '0');
    final d = end.day.toString().padLeft(2, '0');
    return '마감일: $y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    if (controller.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final detail = controller.detail;
    List<Map<String, dynamic>> assignmentAttachments = [];
    List<Map<String, dynamic>> submissionAttachments = [];
    if (detail != null) {
      final submissionResponses =
          (detail['submissionAttachmentResponses'] as List?) ?? const [];
      if (submissionResponses.isNotEmpty) {
        submissionAttachments = mapAttachments(submissionResponses);
      }
      final sources = [
        (detail['AssignmentAttachments'] as List?) ?? const [],
        (detail['attachmentDtos'] as List?) ?? const [],
        (detail['xAssignmentResponseDtos'] as List?) ?? const [],
      ];
      for (final src in sources) {
        if (src.isNotEmpty) {
          assignmentAttachments = mapAttachments(src);
          break;
        }
      }
    }
    // fallback: widget에서 전달된 제출첨부 사용
    if (assignmentAttachments.isEmpty && _assignmentAttachments.isNotEmpty) {
      assignmentAttachments = List<Map<String, dynamic>>.from(
        _assignmentAttachments,
      );
    }
    if (assignmentAttachments.isEmpty) {
      final assignmentFallback =
          (widget.assignment['attachmentDtos'] as List?) ??
          (widget.assignment['AssignmentAttachments'] as List?) ??
          const [];
      if (assignmentFallback.isNotEmpty) {
        assignmentAttachments = mapAttachments(assignmentFallback);
      }
    }
    if (submissionAttachments.isEmpty) {
      final submissionFallback =
          (widget.assignment['submissionAttachmentResponses'] as List?) ??
          const [];
      if (submissionFallback.isNotEmpty) {
        submissionAttachments = mapAttachments(submissionFallback);
      }
    }
    bool submissionState = controller.submitted;
    final dynamic submissionRaw =
        detail?['IsSubmitted'] ??
        detail?['isSubmitted'] ??
        widget.assignment['IsSubmitted'] ??
        widget.assignment['isSubmitted'];
    if (submissionRaw != null) {
      submissionState = _parseBool(submissionRaw);
    }
    if (controller.submitted != submissionState) {
      controller.submitted = submissionState;
    }
    final bool canEditAttachments = !controller.submitted;

    final submissionFileAttachments =
        submissionAttachments
            .where(
              (item) => (item['kind'] ?? '').toString().toUpperCase() == 'FILE',
            )
            .toList();
    final submissionLinkAttachments =
        submissionAttachments
            .where(
              (item) => (item['kind'] ?? '').toString().toUpperCase() == 'URL',
            )
            .toList();
    final filteredSubmissionFileAttachments = submissionFileAttachments.where(
      (item) =>
          !_removedSubmissionAttachmentIds.contains(
            (item['attachmentId'] ?? '').toString(),
          ),
    );
    final filteredSubmissionLinkAttachments = submissionLinkAttachments.where(
      (item) =>
          !_removedSubmissionAttachmentIds.contains(
            (item['attachmentId'] ?? '').toString(),
          ),
    );
    final decoratedSubmissionFileAttachments = _decorateSubmissionAttachments(
      filteredSubmissionFileAttachments.toList(),
      allowRemoval: canEditAttachments,
    );
    final decoratedSubmissionLinkAttachments = _decorateSubmissionAttachments(
      filteredSubmissionLinkAttachments.toList(),
      allowRemoval: canEditAttachments,
    );
    final localFileAttachments =
        controller.uploadedFiles.asMap().entries.map((entry) {
          final file = entry.value;
          return <String, dynamic>{
            'name': file.name,
            'sizeText': formatSize(file.size),
            'contentType': file.extension ?? 'FILE',
            'kind': 'FILE',
            'url': '',
            'attachmentId': '',
            'localPath': file.path ?? '',
            'localBytes': file.bytes,
            'onRemove':
                canEditAttachments
                    ? () async {
                      final confirmed = await _confirmAttachmentDeletion(
                        file.name,
                      );
                      if (!confirmed) return;
                      if (!mounted) return;
                      setState(() {
                        controller.removeFileAt(entry.key);
                      });
                    }
                    : null,
          };
        }).toList();
    final localLinkAttachments =
        controller.uploadedUrls.asMap().entries.map((entry) {
          final url = entry.value;
          return <String, dynamic>{
            'name': url,
            'sizeText': '',
            'contentType': 'URL',
            'kind': 'URL',
            'url': url,
            'onRemove':
                canEditAttachments
                    ? () async {
                      final confirmed = await _confirmAttachmentDeletion(url);
                      if (!confirmed) return;
                      if (!mounted) return;
                      setState(() {
                        controller.removeUrlAt(entry.key);
                      });
                    }
                    : null,
          };
        }).toList();
    final uploadedFileAttachments = [
      ...decoratedSubmissionFileAttachments,
      ...localFileAttachments,
    ];
    final uploadedLinkAttachments = [
      ...decoratedSubmissionLinkAttachments,
      ...localLinkAttachments,
    ];

    final title =
        (detail?['title'] ?? widget.assignment['title'] ?? '').toString();
    final endDateStr =
        (detail?['endDate'] ??
                widget.assignment['endDate'] ??
                widget.assignment['due'])
            ?.toString();
    final endDate = _parseDate(endDateStr);
    final dueDateText = _formatDue(endDate);
    final timeLeftText = _formatTimeLeft(endDate);
    final submissionBadgeLabel = submissionState ? '제출됨' : '미제출';
    final submissionBadgeColor =
        submissionState ? const Color(0xff16A34A) : const Color(0xffDC2626);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: height * 0.006,
            horizontal: width * 0.045,
          ),
          decoration: const BoxDecoration(color: Color(0xffffffff)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailHeader(
                context: context,
                title: title,
                dueDateText: dueDateText,
                timeLeftText: timeLeftText,
                onClose: widget.onClose,
                submissionStateLabel: submissionBadgeLabel,
                submissionStateColor: submissionBadgeColor,
              ),
              SizedBox(height: height * 0.03),
              if (assignmentAttachments.isNotEmpty)
                AttachmentsSection(
                  title: '첨부파일',
                  attachments: assignmentAttachments,
                  onTap: _handleAttachmentTap,
                  onDownload:
                      (item) => _handleAssignmentAttachmentTap(
                        item,
                        openAfterDownload: false,
                      ),
                ),
              if (uploadedFileAttachments.isNotEmpty)
                AttachmentsSection(
                  title: '업로드한 파일',
                  attachments: uploadedFileAttachments,
                ),
              if (uploadedLinkAttachments.isNotEmpty)
                AttachmentsSection(
                  title: '업로드한 링크',
                  attachments: uploadedLinkAttachments,
                  onTap: (item) => _openAttachmentLink(item),
                ),
              if ((widget.assignment['results'] as List?)?.isNotEmpty ==
                  true) ...[
                Text(
                  '제출 결과물',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.045,
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: (widget.assignment['results'] as List).length,
                  itemBuilder:
                      (context, index) => Text(
                        '${widget.assignment['results'][index]}',
                        style: TextStyle(fontSize: width * 0.04),
                      ),
                ),
              ],
              SizedBox(height: height * 0.03),
              DescriptionSection(
                description:
                    (detail?['content'] ??
                            widget.assignment['description'] ??
                            '')
                        .toString(),
              ),
              SizedBox(height: height * 0.05),
              ActionsSection(
                isSubmitted: controller.submitted,
                onUploadPressed:
                    canEditAttachments ? () => _handleUploadMenu() : null,
                onToggleSubmit: _handleToggleSubmit,
                uploadButtonKey: _uploadButtonKey,
                submitButtonLabel: '과제 제출하기',
                submittedButtonLabel: '제출 취소하기',
              ),
              SizedBox(height: height * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
