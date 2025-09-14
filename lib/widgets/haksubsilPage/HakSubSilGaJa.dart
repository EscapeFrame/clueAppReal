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

  const Haksubsilgaja({super.key, required this.assignment, required this.onClose});

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
    final RenderBox? button = _uploadButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    RelativeRect position;
    if (button != null) {
      final Offset offset = button.localToGlobal(Offset.zero);
      position = RelativeRect.fromRect(
        Rect.fromLTWH(offset.dx, offset.dy, button.size.width, button.size.height),
        Offset.zero & overlay.size,
      );
    } else {
      position = const RelativeRect.fromLTRB(100, 100, 0, 0);
    }

    final choice = await showUploadChoiceMenu(context, position.shift(const Offset(0, -8)));
    if (choice == 'file') {
      await showUploadFileDialog(context, (file) => controller.addFile(file));
      setState(() {});
    } else if (choice == 'url') {
      await showUrlInputDialog(context, (url) => controller.addUrl(url));
      setState(() {});
    }
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
      final a = (detail['AssignmentAttachments'] as List?) ?? const [];
      final b = (detail['xAssignmentResponseDtos'] as List?) ?? const [];
      serverAttachments = a.isNotEmpty ? mapAttachments(a) : mapAttachments(b);
    }

    final title = (detail?['title'] ?? widget.assignment['title'] ?? '').toString();
    final dueDateText = "마감일: ${(detail?['endDate'] ?? widget.assignment['due'] ?? '').toString().split('T').first}";
    final timeLeftText = (widget.assignment['timeLeft'] ?? '').toString();

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: height * 0.006, horizontal: width * 0.045),
          decoration: const BoxDecoration(color: Color(0xffffffff)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                      await launchUrl(u, mode: LaunchMode.externalApplication);
                    }
                  }
                },
              ),
            if ((widget.assignment['results'] as List?)?.isNotEmpty == true) ...[
              Text('제출 결과물', style: TextStyle(fontWeight: FontWeight.bold, fontSize: width * 0.045)),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: (widget.assignment['results'] as List).length,
                itemBuilder: (context, index) => Text('${widget.assignment['results'][index]}', style: TextStyle(fontSize: width * 0.04)),
              ),
            ],
            UploadedFilesSection(files: controller.uploadedFiles, onRemove: controller.removeFileAt),
            UploadedLinksSection(urls: controller.uploadedUrls, onRemove: controller.removeUrlAt),
            SizedBox(height: height * 0.03),
            DescriptionSection(description: (detail?['content'] ?? widget.assignment['description'] ?? '').toString()),
            SizedBox(height: height * 0.05),
            ActionsSection(
              isSubmitted: controller.submitted,
              onUploadPressed: _handleUploadMenu,
              onToggleSubmit: () => setState(controller.toggleSubmitted),
              uploadButtonKey: _uploadButtonKey,
            ),
            SizedBox(height: height * 0.05),
          ]),
        ),
      ),
    );
  }
}
