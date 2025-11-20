// 페이지: 학습실 과제 상세/제출 화면의 메인 구현입니다.
import 'package:clue/api_client.dart';
import 'package:clue/widgets/haksubsil/dialogs/upload_choice_menu.dart';
import 'package:clue/widgets/haksubsil/dialogs/upload_file_dialog.dart';
import 'package:clue/widgets/haksubsil/dialogs/url_input_dialog.dart';
import 'package:clue/widgets/haksubsil/state/haksubsil_controller.dart';
import 'package:clue/widgets/haksubsil/utils/attachment_mapper.dart';
import 'package:clue/widgets/haksubsil/utils/id_resolver.dart';
import 'package:clue/widgets/haksubsil/widgets/sections/actions_section.dart';
import 'package:clue/widgets/haksubsil/widgets/sections/attachments_section.dart';
import 'package:clue/widgets/haksubsil/widgets/sections/description_section.dart';
import 'package:clue/widgets/haksubsil/widgets/sections/header_section.dart';
import 'package:clue/widgets/haksubsil/widgets/sections/uploaded_files_section.dart';
import 'package:clue/widgets/haksubsil/widgets/sections/uploaded_links_section.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
      final idStr = resolveAssignmentId(widget.assignment);
      if (idStr == null) {
        controller.loading = false;
        controller.error = '상세 조회 실패(과제 ID 없음)';
        setState(() {});
        return;
      }
      final dio = ApiClient.instance.dio;
      final res = await dio.get('/api/assignments/$idStr');
      if (!mounted) return;
      if (res.statusCode == 200 && res.data is Map) {
        controller.detail = Map<String, dynamic>.from(res.data as Map);
      } else {
        controller.error = '상세 조회 실패(${res.statusCode})';
      }
    } on DioException catch (e) {
      controller.error = '상세 오류: ${e.message}';
    } catch (e) {
      controller.error = '상세 예외: $e';
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
              if (serverAttachments.isNotEmpty)
                AttachmentsSection(
                  attachments: serverAttachments,
                  onTap: (f) async {
                    if ((f['kind'] ?? '') == 'URL') {
                      final u = Uri.tryParse((f['url'] ?? '').toString());
                      if (u != null) {
                        await launchUrl(
                          u,
                          mode: LaunchMode.externalApplication,
                        );
                      }
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
              UploadedFilesSection(
                files: controller.uploadedFiles,
                onRemove: controller.removeFileAt,
              ),
              UploadedLinksSection(
                urls: controller.uploadedUrls,
                onRemove: controller.removeUrlAt,
              ),
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
                onUploadPressed: _handleUploadMenu,
                onToggleSubmit: () async {
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '제출 확인',
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
                                  '정말 과제를 제출하시겠습니까?',
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          foregroundColor: Colors.black,
                                          backgroundColor: Colors.white,
                                        ),
                                        child: const Text('취소'),
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: const Text('제출'),
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
                    setState(controller.toggleSubmitted);
                  }
                },
                uploadButtonKey: _uploadButtonKey,
              ),
              SizedBox(height: height * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
