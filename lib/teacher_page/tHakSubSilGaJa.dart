import 'package:clue/teacher_page/t_haksubsil/data/haksubsil_service.dart';
import 'package:clue/teacher_page/t_haksubsil/sheets/upload_file_sheet.dart';
import 'package:clue/teacher_page/t_haksubsil/sheets/url_input_dialog.dart';
import 'package:clue/teacher_page/t_haksubsil/utils/date_time.dart';
import 'package:clue/teacher_page/t_haksubsil/utils/file_utils.dart';
import 'package:clue/teacher_page/t_haksubsil/utils/id_utils.dart';
import 'package:clue/teacher_page/t_haksubsil/widgets/assignment_actions.dart';
import 'package:clue/teacher_page/t_haksubsil/widgets/assignment_meta.dart';
import 'package:clue/teacher_page/t_haksubsil/widgets/attachment_list.dart';
import 'package:clue/widgets/haksubsil/widgets/sections/uploaded_files_section.dart';
import 'package:clue/widgets/haksubsil/widgets/sections/uploaded_links_section.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Thaksubsilgaja extends StatefulWidget {
  final Map<String, dynamic> assignment;
  final VoidCallback onClose;

  const Thaksubsilgaja({
    super.key,
    required this.assignment,
    required this.onClose,
  });

  @override
  State<Thaksubsilgaja> createState() => _ThaksubsilgajaState();
}

// Moved: download/pick/show dialog/service helpers are split into utils/sheets/data.

class _ThaksubsilgajaState extends State<Thaksubsilgaja> {
  bool loading = true;
  String? error;
  Map<String, dynamic>? detail;
  final Set<String> _deletingAttachmentIds = <String>{};

  // formatting helpers moved to utils/date_time.dart

  String? _assignmentIdStr() {
    final s = assignmentIdStrFrom(detail, widget.assignment);
    return s.isEmpty ? null : s;
  }

  String? _submissionIdStr() {
    final candidates = [
      detail?['submissionId'],
      widget.assignment['submissionId'],
      widget.assignment['id'],
      widget.assignment['submission_id'],
    ];
    for (final v in candidates) {
      final s = v?.toString();
      if (s != null && s.isNotEmpty) return s;
    }
    return null;
  }

  String _fmtSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }

  String _formatDaysHours(DateTime? end) {
    if (end == null) return '남은 시간 정보 없음';
    final diff = end.difference(DateTime.now());
    if (diff.isNegative) return '마감됨';
    final days = diff.inDays;
    final hours = diff.inHours - days * 24;
    final minutes = diff.inMinutes - diff.inHours * 60;
    if (days > 0) return '$days일 ${hours}시간 남음';
    if (diff.inHours > 0) return '${diff.inHours}시간 ${minutes}분 남음';
    return '${minutes}분 남음';
  }

  String? _buildDDayLabel(DateTime? endDate) {
    if (endDate == null) return null;
    final now = DateTime.now();
    final diff = endDate.difference(now).inDays;
    if (diff > 0) return 'D-$diff';
    if (diff == 0) return 'D-DAY';
    return '종료';
  }

  Future<void> _loadDetail(String submissionId) async {
    setState(() {
      loading = true;
      error = null;
    });
    final data = await HaksubsilService.fetchSubmissionDetail(submissionId);
    if (!mounted) return;
    if (data != null) {
      setState(() {
        detail = data;
        loading = false;
      });
    } else {
      setState(() {
        error = '제출 세부 정보를 불러오지 못했습니다.';
        loading = false;
      });
    }
  }

  Future<void> _reloadDetail() async {
    final id = _submissionIdStr();
    if (id != null) {
      await _loadDetail(id);
    }
  }

  @override
  void initState() {
    super.initState();
    final submissionId = _submissionIdStr();
    if (submissionId != null) {
      _loadDetail(submissionId);
    } else {
      debugPrint('submissionId가 없어 세부 조회를 건너뜀: ${widget.assignment}');
      loading = false;
    }
    // _showFile();
  }

  List<PlatformFile> uploadedFiles = [];
  final List<String> uploadedUrls = [];

  // assignment의 files에서 파일을 삭제하는 함수 추가
  void removeFile(int fileIndex) {
    setState(() {
      widget.assignment['files'].removeAt(fileIndex);
    });
  }

  // 업로드된 파일을 추가하는 함수
  void addUploadedFile(PlatformFile file) {
    setState(() {
      uploadedFiles.add(file);
    });
  }

  // 업로드된 파일을 삭제하는 함수
  void removeUploadedFile(int index) {
    setState(() {
      uploadedFiles.removeAt(index);
    });
  }

  void addUploadedUrl(String url) {
    setState(() {
      uploadedUrls.add(url);
    });
  }

  void removeUploadedUrl(int index) {
    setState(() {
      uploadedUrls.removeAt(index);
    });
  }

  Future<void> _deleteAttachment(String attachmentId) async {
    final ok = await HaksubsilService.deleteAttachment(attachmentId);
    debugPrint('assignmentId: $attachmentId');
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('첨부 삭제 완료')));
      await _reloadDetail();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('삭제 실패')));
    }
    if (mounted) {
      setState(() {
        _deletingAttachmentIds.remove(attachmentId);
      });
    }
  }
  //통신 안됨
  // Future<void> _showFile() async {
  //   try {
  //     final api = ApiClient.instance.dio;
  //     final idStr = _assignmentIdStr();
  //     final res = await api.get('/api/assignments/$idStr/attachment');
  //     debugPrint('파일 정보: ${res.data}');
  //   } on DioException catch (e) {
  //     debugPrint('파일 정보 가져오기 중 오류 발생: ${e.response?.data}');
  //     debugPrint('e.statusCode : ${e.response?.statusCode}');
  //   } catch (e) {
  //     debugPrint('파일 정보 가져오기 중 오류 발생: $e');
  //   }
  // }

  Future<void> uploadFile(PlatformFile file) async {
    final idStr = _assignmentIdStr();
    if (idStr == null) return;
    final ok = await HaksubsilService.uploadFileAttachment(idStr, file);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('업로드 완료')));
      await _reloadDetail();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('업로드 실패')));
    }
  }

  Future<void> _uploadUrlAttachment(String assignmentId, String url) async {
    final idStr =
        assignmentId.isNotEmpty ? assignmentId : (_assignmentIdStr() ?? '');
    final ok = await HaksubsilService.uploadUrlAttachment(idStr, url);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('링크가 등록되었습니다.')));
      await _reloadDetail();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('링크 등록 실패')));
    }
  }

  Future<void> _showUploadChoiceMenu() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final width = MediaQuery.of(ctx).size.width;
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
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                      constraints: BoxConstraints(),
                      color: const Color(0xff94A3B8),
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
                    textStyle: TextStyle(
                      fontSize: width * 0.038,
                      fontWeight: FontWeight.w600,
                    ),
                    foregroundColor: const Color(0xff1E3A8A),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (choice == 'file') {
      final file = await showUploadFileSheet(context);
      if (file != null) {
        await uploadFile(file);
        addUploadedFile(file);
      }
    } else if (choice == 'url') {
      final url = await showUrlInputDialog(context);
      if (url != null && url.isNotEmpty) {
        final id = _assignmentIdStr() ?? '';
        await _uploadUrlAttachment(id, url);
        addUploadedUrl(url);
      }
    }
  }

  Future<void> _downloadAttachment(
    String attachmentId,
    String fallbackName,
  ) async {
    final bytes = await HaksubsilService.downloadAttachmentBytes(attachmentId);
    if (!mounted) return;
    if (bytes != null) {
      await downloadAndOpen(context, bytes, fallbackName);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('다운로드 실패')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final title =
        (detail?['title'] ?? widget.assignment['title'])?.toString() ?? '';
    final content =
        (detail?['content'] ??
                widget.assignment['content'] ??
                widget.assignment['description'] ??
                '')
            .toString();
    final endDateStr =
        (detail?['endDate'] ?? widget.assignment['endDate'])?.toString();
    final end = parseDateFlexible(endDateStr);
    final due = formatDue(end);
    final timeLeft = _formatDaysHours(end);

    // 첨부 소스: AssignmentAttachments 우선, 없으면 xAssignmentResponseDtos 사용
    List<Map<String, dynamic>> mapAttList(List src) =>
        src.whereType<Map>().map((e) {
          final m = Map<String, dynamic>.from(e);
          final typeVal =
              (m['type'] ?? m['kind'] ?? '').toString().toUpperCase();
          final valueStr = (m['value'] ?? m['url'] ?? '').toString();
          final originalName =
              (m['originalFileName'] ?? m['name'] ?? '').toString();
          final isLikelyUrl =
              typeVal == 'URL' ||
              (valueStr.startsWith('http') && originalName.isEmpty);
          final kind =
              isLikelyUrl ? 'URL' : (typeVal.isNotEmpty ? typeVal : 'FILE');
          final sizeNum =
              m['size'] is int
                  ? (m['size'] as int)
                  : int.tryParse('${m['size'] ?? ''}') ?? 0;
          final name =
              originalName.isNotEmpty
                  ? originalName
                  : (isLikelyUrl ? valueStr : '');
          final attachmentId =
              (m['attachmentId'] ??
                      m['submissionAttachmentId'] ??
                      m['id'] ??
                      (kind == 'FILE' ? valueStr : ''))
                  .toString();

          return <String, dynamic>{
            'name': name,
            'sizeText':
                (kind == 'URL' && sizeNum == 0) ? '' : _fmtSize(sizeNum),
            'contentType': (m['contentType'] ?? m['type'] ?? '').toString(),
            'attachmentId': attachmentId,
            'kind': kind,
            'url': isLikelyUrl ? valueStr : '',
          };
        }).toList();
    final List<Map<String, dynamic>> serverAttachments =
        (() {
          final sources = [
            (detail?['submissionAttachmentResponses'] as List?) ?? const [],
            (detail?['AssignmentAttachments'] as List?) ?? const [],
            (detail?['attachmentDtos'] as List?) ?? const [],
            (detail?['xAssignmentResponseDtos'] as List?) ?? const [],
          ];
          for (final source in sources) {
            if (source.isNotEmpty) {
              return mapAttList(source);
            }
          }
          return const <Map<String, dynamic>>[];
        })();
    return Scaffold(
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: height * 0.006,
                    horizontal: width * 0.045,
                  ),
                  decoration: BoxDecoration(color: Color(0xffffffff)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (error != null) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            error!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: width * 0.032,
                            ),
                          ),
                        ),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: width * 0.052,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            iconSize: width * 0.06,
                            icon: const Icon(Icons.close),
                            onPressed: widget.onClose,
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.012),
                      AssignmentMeta(
                        width: width,
                        height: height,
                        due: due,
                        timeLeft: timeLeft,
                        dDay: _buildDDayLabel(end),
                      ),
                      SizedBox(height: height * 0.015),
                      // 서버 첨부 파일 표시
                      if (serverAttachments.isNotEmpty) ...[
                        AttachmentList(
                          width: width,
                          height: height,
                          attachments: serverAttachments,
                          deletingIds: _deletingAttachmentIds,
                          onDownload: (id, name) async {
                            final f = serverAttachments.firstWhere(
                              (e) => (e['attachmentId'] ?? '').toString() == id,
                              orElse: () => const {},
                            );
                            if ((f['kind'] ?? '') == 'URL') {
                              final u = Uri.tryParse(
                                (f['url'] ?? '').toString(),
                              );
                              if (u != null) {
                                await launchUrl(
                                  u,
                                  mode: LaunchMode.externalApplication,
                                );
                                return;
                              }
                            }
                            await _downloadAttachment(id, name);
                          },
                          onDelete: (id) async {
                            setState(() => _deletingAttachmentIds.add(id));
                            await _deleteAttachment(id);
                          },
                        ),
                        SizedBox(height: height * 0.015),
                      ],

                      UploadedFilesSection(
                        files: uploadedFiles,
                        onRemove: removeUploadedFile,
                      ),
                      UploadedLinksSection(
                        urls: uploadedUrls,
                        onRemove: removeUploadedUrl,
                      ),
                      SizedBox(height: height * 0.015),

                      Text(
                        '상세설명',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.045,
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      Text(
                        content,
                        style: TextStyle(fontSize: width * 0.04, height: 1.6),
                      ),

                      widget.assignment['results'] != null
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '제출 결과물',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: width * 0.045,
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true, // Column 안에서 사용 시 필요
                                physics:
                                    NeverScrollableScrollPhysics(), // SingleChildScrollView와 충돌 방지
                                itemCount: widget.assignment['results'].length,
                                itemBuilder:
                                    (context, index) => Text(
                                      '${widget.assignment['results'][index]}',
                                      style: TextStyle(fontSize: width * 0.04),
                                    ),
                              ),
                            ],
                          )
                          : SizedBox(width: width * 0.00001),
                      SizedBox(height: height * 0.015),

                      SizedBox(height: height * 0.05),
                      AssignmentActions(
                        width: width,
                        height: height,
                        onUploadPressed: _showUploadChoiceMenu,
                        onSavePressed: widget.onClose,
                      ),
                      SizedBox(height: height * 0.02),
                    ],
                  ),
                ),
              ),
    );
  }
}

// 학습실(과제 상세) 화면.
// 과제 상세 조회, 첨부(파일/URL) 표시/다운로드/삭제, 업로드/링크 등록 등 상호작용을 제공합니다.
