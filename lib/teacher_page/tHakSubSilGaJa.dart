// 페이지: 학습실 과제 상세/제출 화면의 메인 구현입니다.
import 'dart:io';

import 'package:clue/api_client.dart';
import 'package:clue/teacher_page/t_haksubsil/data/haksubsil_service.dart';
import 'package:clue/widgets/haksubsil/dialogs/upload_choice_menu.dart';
import 'package:clue/widgets/haksubsil/dialogs/upload_file_dialog.dart';
import 'package:clue/widgets/haksubsil/dialogs/url_input_dialog.dart';
import 'package:clue/widgets/haksubsil/state/haksubsil_controller.dart';
import 'package:clue/widgets/haksubsil/utils/attachment_mapper.dart';
import 'package:clue/widgets/haksubsil/utils/formatters.dart';
import 'package:clue/widgets/haksubsil/utils/id_resolver.dart';
import 'package:clue/widgets/haksubsil/widgets/sections/actions_section.dart';
import 'package:clue/widgets/haksubsil/widgets/sections/attachments_section.dart';
import 'package:clue/widgets/haksubsil/widgets/sections/description_section.dart';
import 'package:clue/widgets/haksubsil/widgets/sections/header_section.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

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

/// Legacy alias kept for older callers that still reference `Thaksubsilgaja`.
typedef Thaksubsilgaja = Haksubsilgaja;

class _HaksubsilgajaState extends State<Haksubsilgaja> {
  final controller = HaksubsilController();
  final GlobalKey _uploadButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    controller.loading = true;
    controller.error = null;
    setState(() {});
    try {
      final assignmentId = resolveAssignmentId(widget.assignment);
      if (assignmentId == null) {
        controller.loading = false;
        controller.error = '\uC0C1\uC138 \uC870\uD68C \uC2E4\uD328(\uACFC\uC81C ID \uC5C6\uC74C)';
        setState(() {});
        return;
      }
      final dio = ApiClient.instance.dio;
      final res = await dio.get('/api/assignments/$assignmentId');
      if (!mounted) return;
      if (res.statusCode == 200 && res.data is Map) {
        controller.detail = Map<String, dynamic>.from(res.data as Map);
      } else {
        controller.error = '\uC0C1\uC138 \uC870\uD68C \uC2E4\uD328(${res.statusCode})';
      }
    } on DioException catch (e) {
      controller.error = '\uC0C1\uC138 \uC624\uB958: ${e.message}';
    } catch (e) {
      controller.error = '\uC0C1\uC138 \uC608\uC678: $e';
    } finally {
      controller.loading = false;
      if (mounted) setState(() {});
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
                        "'$name' 첨부를 정말 삭제하시겠습니까?",
                        style: TextStyle(
                          fontSize: width * 0.036,
                          color: const Color(0xff4B5563),
                          height: 1.4,
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

  Future<void> _handleLocalAttachmentRemoval({
    required bool isFile,
    required int index,
    required String name,
  }) async {
    final confirmed = await _confirmAttachmentDeletion(name);
    if (!confirmed) return;
    if (!mounted) return;
    setState(() {
      if (isFile) {
        controller.removeFileAt(index);
      } else {
        controller.removeUrlAt(index);
      }
    });
  }

  Future<void> _handleServerAttachmentRemoval({
    required String attachmentId,
    required String name,
  }) async {
    final confirmed = await _confirmAttachmentDeletion(name);
    if (!confirmed) return;
    try {
      final dio = ApiClient.instance.dio;
      await dio.delete('/api/assignments/attachment/$attachmentId');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('첨부가 삭제되었습니다.')));
      await _loadDetail();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: ${e.message ?? '알 수 없는 오류'}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
    }
  }

  String? _resolveCurrentAssignmentId() {
    final detailMap = controller.detail;
    if (detailMap != null) {
      final resolved = resolveAssignmentId(detailMap);
      if (resolved != null && resolved.isNotEmpty) return resolved;
    }
    return resolveAssignmentId(widget.assignment);
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

  Future<void> _savePendingAttachments() async {
    final assignmentId = _resolveCurrentAssignmentId();
    if (assignmentId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '\uACFC\uC81C ID\uB97C \uCC3E\uC9C0 \uBABB\uD588\uC2B5\uB2C8\uB2E4.',
          ),
        ),
      );
      return;
    }
    final dio = ApiClient.instance.dio;
    try {
      if (controller.uploadedUrls.isNotEmpty) {
        final payload =
            controller.uploadedUrls.map((url) => {'url': url}).toList();
        await dio.post('/api/assignments/$assignmentId/link', data: payload);
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
          await dio.post('/api/assignments/$assignmentId/file', data: formData);
        }
      }
      setState(() {
        controller.uploadedFiles.clear();
        controller.uploadedUrls.clear();
      });
      await _loadDetail();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('\uC800\uC7A5\uB418\uC5C8\uC2B5\uB2C8\uB2E4.'),
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '\uC800\uC7A5 \uC2E4\uD328: ${e.message ?? '알 수 없는 오류'}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('\uC800\uC7A5 \uC2E4\uD328: $e')));
    }
  }

  List<Map<String, dynamic>> _decorateServerAttachments(
    List<Map<String, dynamic>> attachments,
  ) {
    return attachments.map((item) {
      final copy = Map<String, dynamic>.from(item);
      final attachmentId = (copy['attachmentId'] ?? '').toString();
      final displayName = (copy['name'] ?? '첨부').toString();
      if (attachmentId.isNotEmpty) {
        copy['onRemove'] = () {
          _handleServerAttachmentRemoval(
            attachmentId: attachmentId,
            name: displayName,
          );
        };
      }
      return copy;
    }).toList();
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
    List<Map<String, dynamic>> serverAttachments = const [];
    if (detail != null) {
      final sources = [
        (detail['submissionAttachmentResponses'] as List?) ?? const [],
        (detail['AssignmentAttachments'] as List?) ?? const [],
        (detail['attachmentDtos'] as List?) ?? const [],
        (detail['xAssignmentResponseDtos'] as List?) ?? const [],
      ];
      for (final src in sources) {
        if (src.isNotEmpty) {
          serverAttachments = mapAttachments(src);
          break;
        }
      }
    }
    // fallback: widget에서 전달된 제출첨부 사용
    if (serverAttachments.isEmpty) {
      final fallback =
          (widget.assignment['submissionAttachmentResponses'] as List?) ??
          const [];
      if (fallback.isNotEmpty) {
        serverAttachments = mapAttachments(fallback);
      }
    }

    final serverFileAttachments = _decorateServerAttachments(
      serverAttachments
          .where(
            (item) => (item['kind'] ?? '').toString().toUpperCase() == 'FILE',
          )
          .toList(),
    );
    final serverLinkAttachments = _decorateServerAttachments(
      serverAttachments
          .where(
            (item) => (item['kind'] ?? '').toString().toUpperCase() == 'URL',
          )
          .toList(),
    );

    final localFileAttachments =
        controller.uploadedFiles
            .asMap()
            .entries
            .map(
              (entry) => {
                'name': entry.value.name,
                'sizeText': formatSize(entry.value.size),
                'contentType': entry.value.extension ?? 'FILE',
                'kind': 'FILE',
                'url': '',
                'onRemove': () {
                  _handleLocalAttachmentRemoval(
                    isFile: true,
                    index: entry.key,
                    name: entry.value.name,
                  );
                },
              },
            )
            .toList();
    final localLinkAttachments =
        controller.uploadedUrls
            .asMap()
            .entries
            .map(
              (entry) => {
                'name': entry.value,
                'sizeText': '',
                'contentType': 'URL',
                'kind': 'URL',
                'url': entry.value,
                'onRemove': () {
                  _handleLocalAttachmentRemoval(
                    isFile: false,
                    index: entry.key,
                    name: entry.value,
                  );
                },
              },
            )
            .toList();

    final fileAttachments = [...serverFileAttachments, ...localFileAttachments];
    final linkAttachments = [...serverLinkAttachments, ...localLinkAttachments];

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
              HeaderSection(
                status: (widget.assignment['status'] ?? '').toString(),
                title: title,
                dueDateText: dueDateText,
                timeLeftText: timeLeftText,
                onClose: widget.onClose,
              ),
              SizedBox(height: height * 0.03),
              if (fileAttachments.isNotEmpty)
                AttachmentsSection(
                  title: '첨부된 파일',
                  attachments: fileAttachments,
                  onTap: _handleFileAttachmentTap,
                ),
              if (linkAttachments.isNotEmpty)
                AttachmentsSection(
                  title: '첨부된 링크',
                  attachments: linkAttachments,
                  onTap: (f) async {
                    final u = Uri.tryParse((f['url'] ?? '').toString());
                    if (u != null) {
                      await launchUrl(u, mode: LaunchMode.externalApplication);
                    }
                  },
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
              Theme(
                data: Theme.of(context).copyWith(
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      textStyle: TextStyle(
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                child: ActionsSection(
                  isSubmitted: controller.submitted,
                  onUploadPressed: _handleUploadMenu,
                  submitButtonLabel: '\uC800\uC7A5\uD558\uAE30',
                  onToggleSubmit: () async {
                    if (controller.uploadedFiles.isEmpty &&
                        controller.uploadedUrls.isEmpty) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '\uC800\uC7A5\uD560 \uCCA8\uBD80\uAC00 \uC5C6\uC2B5\uB2C8\uB2E4.',
                          ),
                        ),
                      );
                      return;
                    }
                    final width = MediaQuery.of(context).size.width;
                    final confirmed = await showDialog<bool>(
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
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                20,
                                20,
                                16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '\uC800\uC7A5 \uD655\uC778',
                                        style: TextStyle(
                                          fontSize: width * 0.045,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(Icons.close),
                                        onPressed:
                                            () => Navigator.pop(ctx, false),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '\uC5C5\uB85C\uB4DC\uD55C \uD30C\uC77C\uACFC \uB9C1\uD06C\uB97C \uC800\uC7A5\uD558\uC2DC\uACA0\uC2B5\uB2C8\uAE4C?',
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
                                          onPressed:
                                              () => Navigator.pop(ctx, false),
                                          style: OutlinedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                              vertical: width * 0.028,
                                            ),
                                            side: const BorderSide(
                                              color: Color(0xffCBD5F5),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            foregroundColor: Colors.black,
                                            backgroundColor: Colors.white,
                                          ),
                                          child: const Text('\uCDE8\uC18C'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed:
                                              () => Navigator.pop(ctx, true),
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                              vertical: width * 0.028,
                                            ),
                                            backgroundColor: const Color(
                                              0xff3B82F6,
                                            ),
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text('\uC800\uC7A5'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                    );
                    if (confirmed == true) {
                      await _savePendingAttachments();
                    }
                  },
                  uploadButtonKey: _uploadButtonKey,
                ),
              ),
              SizedBox(height: height * 0.05),
            ],
          ),
        ),
      ),
      );
    }

  Future<void> _handleFileAttachmentTap(Map<String, dynamic> attachment) async {
    final kind = (attachment['kind'] ?? '').toString().toUpperCase();
    if (kind != 'FILE') return;
    final attachmentId = (attachment['attachmentId'] ?? '').toString();
    if (attachmentId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('업로드된 파일만 다운로드할 수 있어요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final fileName = (attachment['name'] ?? 'attachment').toString();
    await _downloadAssignmentAttachment(attachmentId, fileName);
  }

  Future<void> _downloadAssignmentAttachment(
    String attachmentId,
    String fileName,
  ) async {
    try {
      final bytes =
          await HaksubsilService.downloadAttachmentBytes(attachmentId);
      if (bytes == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('파일을 다운로드할 수 없어요. 다시 시도해 주세요.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      final safeName = _sanitizeFileName(
        fileName.isEmpty ? 'attachment-$attachmentId' : fileName,
      );
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$safeName');
      await file.writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('다운로드 완료: $safeName'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      await OpenFile.open(file.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('다운로드 중 오류가 발생했어요: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _sanitizeFileName(String name) {
    final sanitized = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return sanitized.isEmpty ? 'attachment' : sanitized;
  }

}
