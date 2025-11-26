import 'package:clue/api_client.dart';
import 'package:clue/HamburgerDialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class Alarm extends StatefulWidget {
  const Alarm({super.key});

  @override
  State<Alarm> createState() => _AlarmState();
}

class _AlarmState extends State<Alarm> {
  int _selectedCategory = 0;
  String? _userRole;
  final List<_NoticeCategory> _categories = const [
    _NoticeCategory(label: '학교공지', type: 'SCHOOL'),
    _NoticeCategory(label: '설정안내', type: 'SETTING'),
    _NoticeCategory(label: '개별공지', type: 'PERSONAL'),
    _NoticeCategory(label: '기타', type: 'ETC'),
  ];

  List<Map<String, dynamic>> _notices = [];
  List<Map<String, dynamic>> _filteredNotices = [];

  @override
  void initState() {
    super.initState();
    _fetchNotices();
    _fetchUserRole();
  }

  Future<void> _fetchNotices() async {
    try {
      final dio = ApiClient.instance.dio;
      final res = await dio.get('/api/notice');
      debugPrint('공지 목록: ${res.data}');
      final data = res.data;
      final List<Map<String, dynamic>> fetched = [];
      if (data is List) {
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            fetched.add(Map<String, dynamic>.from(item));
          } else if (item is Map) {
            fetched.add(
              Map<String, dynamic>.from(
                item.map((key, value) => MapEntry(key.toString(), value)),
              ),
            );
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _notices = fetched;
        _applyCategoryFilter();
      });
    } on DioException catch (e) {
      debugPrint('공지 요청 실패: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('공지 알 수 없는 오류: $e');
    }
  }

  Future<void> _fetchUserRole() async {
    try {
      final dio = ApiClient.instance.dio;
      final res = await dio.get('/api/user/me');
      final data = _coerceToMap(res.data);
      final role = data?['role']?.toString();
      if (!mounted) return;
      setState(() {
        _userRole = role;
      });
    } on DioException catch (e) {
      debugPrint('user role request failed: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('user role unexpected error: $e');
    }
  }

  bool get _canCreateNotice {
    final role = _userRole?.toUpperCase();
    if (role == null) return false;
    return role != 'STUDENT';
  }

  Future<void> _createNotice({
    required String type,
    required String title,
    required String content,
    required List<String> fileTitles,
    required List<_UrlDraft> urls,
    required List<String> files,
  }) async {
    try {
      final dio = ApiClient.instance.dio;
      final body = {
        'metadata': {
          'type': type,
          'title': title,
          'content': content,
          'fileInfo': fileTitles
              .map((name) => {'title': name})
              .toList(growable: false),
          'urls': urls
              .map((entry) => {'title': entry.title, 'value': entry.value})
              .toList(growable: false),
        },
        'files': files,
      };
      await dio.post('/api/notice', data: body);
      await _fetchNotices();
    } on DioException catch (e) {
      debugPrint('notice create failed: ${e.response?.data ?? e.message}');
      rethrow;
    } catch (e) {
      debugPrint('notice create unexpected error: $e');
      rethrow;
    }
  }

  Future<void> _fetchNoticeDetail(String noticeId) async {
    if (noticeId.isEmpty) {
      debugPrint('notice detail request skipped: empty noticeId');
      return;
    }
    try {
      final dio = ApiClient.instance.dio;
      final res = await dio.get('/api/notice/$noticeId');
      final detail = _coerceToMap(res.data);
      debugPrint('notice detail($noticeId): ${res.data}');
      if (detail == null) {
        debugPrint('notice detail parse failed ($noticeId)');
        return;
      }
      if (!mounted) return;
      _showNoticeDetailModal(detail);
    } on DioException catch (e) {
      debugPrint(
        'notice detail request failed($noticeId): ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      debugPrint('notice detail unexpected error($noticeId): $e');
    }
  }

  Map<String, dynamic>? _coerceToMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  void _applyCategoryFilter() {
    if (_categories.isEmpty) {
      _filteredNotices = List<Map<String, dynamic>>.from(_notices);
      return;
    }
    final int safeIndex = _selectedCategory.clamp(0, _categories.length - 1);
    final targetType = _categories[safeIndex].type.toUpperCase();
    _filteredNotices =
        _notices.where((notice) {
          final type = (notice['type'] ?? '').toString().toUpperCase();
          return type == targetType;
        }).toList();
  }

  String _formatNoticeDate(String? value) {
    if (value == null || value.isEmpty) return '-';
    try {
      final date = DateTime.parse(value).toLocal();
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      return '${date.year}-$month-$day';
    } catch (_) {
      return value;
    }
  }

  String _currentCategoryLabel() {
    if (_categories.isEmpty) return '';
    final index = _selectedCategory.clamp(0, _categories.length - 1);
    return _categories[index].label;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      floatingActionButton:
          _canCreateNotice
              ? FloatingActionButton.extended(
                onPressed: _openCreateNoticeDialog,
                backgroundColor: const Color(0xFF0077FF),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.edit_outlined),
                label: const Text(
                  '새 공지',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    'assets/images/realLogo.svg',
                    width: width * 0.25,
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.arrow_back, size: width * 0.07),
                      ),
                      SizedBox(width: width * 0.03),
                      GestureDetector(
                        onTap: () => showHamburgerDialog(context),
                        child: SvgPicture.asset(
                          'assets/images/bars-3.svg',
                          width: width * 0.074,
                        ),
                      ),
                      SizedBox(width: width * 0.0443),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                color: const Color(0xFFF5F5F5),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCategoryChips(context),
                      const SizedBox(height: 12),
                      if (_filteredNotices.isEmpty) _buildEmptyNoticeMessage(),
                      if (_filteredNotices.isNotEmpty)
                        ..._filteredNotices.map((notice) {
                          final noticeId =
                              (notice['noticeId'] ?? '').toString();
                          return _buildNoticeItem(
                            title: (notice['title'] ?? '').toString(),
                            date: _formatNoticeDate(
                              notice['createdAt']?.toString(),
                            ),
                            onTap:
                                noticeId.isEmpty || noticeId == 'null'
                                    ? null
                                    : () => _fetchNoticeDetail(noticeId),
                          );
                        }),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Fixed horizontal gap between chips (can be made responsive if needed)
        const double baseGap = 6.0;
        const double safeBufferPerChip =
            8.0; // generous safety buffer to prevent CJK clipping

        // Baseline metrics to scale from
        const double baseFont = 13.0; // px (logical)
        const double baseHPad =
            10.0; // chip horizontal padding (slightly increased)
        const double baseVPad =
            8.0; // chip vertical padding (slightly increased)
        const double baseRadius = 8.0; // reduced border radius baseline

        final textDirection = Directionality.of(context);
        final textScale = MediaQuery.textScaleFactorOf(context);

        // Measure single-line text width for a given font size
        double measureTextWidth(String text, double fontSize) {
          final painter = TextPainter(
            text: TextSpan(
              text: text,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
            ),
            maxLines: 1,
            textDirection: textDirection,
            textScaler: TextScaler.linear(textScale),
          )..layout();
          return painter.width;
        }

        // Finds the largest scale so that total width of all 4 chips fits.
        double low = 0.15; // allow even smaller text if needed
        double high = 1.4; // allow slight upscale when room permits
        double best = low;
        for (int iter = 0; iter < 22; iter++) {
          final mid = (low + high) / 2.0;
          final testFont = baseFont * mid;
          final testHPad = baseHPad * mid;
          double total = 0.0;
          for (final category in _categories) {
            total += measureTextWidth(category.label, testFont) + 2 * testHPad;
          }
          final gaps = baseGap * (_categories.length - 1);
          total += gaps;

          if (total <= constraints.maxWidth) {
            best = mid; // fits; try larger
            low = mid;
          } else {
            high = mid; // too big; shrink
          }
        }

        // Final scaled metrics (with reasonable clamps)
        double scale = best.clamp(0.15, 1.4);
        double fontSize = baseFont * scale;
        double hPad = (baseHPad * scale).clamp(2.0, 18.0);
        double vPad = (baseVPad * scale).clamp(2.0, 12.0);
        final double gaps = baseGap * (_categories.length - 1);

        // Ensure final sum fits (guard against rounding/border effects)
        List<double> widths() =>
            _categories
                .map(
                  (category) =>
                      measureTextWidth(category.label, fontSize) +
                      2 * hPad +
                      safeBufferPerChip,
                )
                .toList();

        double sum(List<double> list) => list.fold(0.0, (p, e) => p + e);

        var w = widths();
        double total = sum(w) + gaps;
        int safety = 0;
        while (total > constraints.maxWidth && safety < 16) {
          // Proportional shrink with slight margin for stability
          final factor = (constraints.maxWidth / total).clamp(0.80, 0.98);
          scale *= factor;
          fontSize = baseFont * scale;
          hPad = (baseHPad * scale).clamp(2.0, 18.0);
          vPad = (baseVPad * scale).clamp(2.0, 12.0);
          w = widths();
          total = sum(w) + gaps;
          safety++;
        }

        // Additional uniform shrink to keep the same ratio but make chips smaller
        const double shrinkFactor = 0.88; // keep ratio; can be tuned
        scale = (scale * shrinkFactor).clamp(0.12, 1.4);
        fontSize = baseFont * scale;
        hPad = (baseHPad * scale).clamp(2.0, 18.0);
        vPad = (baseVPad * scale).clamp(2.0, 12.0);
        w = widths();
        total = sum(w) + gaps;

        // Final ensure: if rounding/buffer made it overflow, shrink uniformly
        int safety2 = 0;
        while (total > constraints.maxWidth && safety2 < 16) {
          scale *= 0.98;
          fontSize = baseFont * scale;
          hPad = (baseHPad * scale).clamp(2.0, 18.0);
          vPad = (baseVPad * scale).clamp(2.0, 12.0);
          w = widths();
          total = sum(w) + gaps;
          safety2++;
        }

        // Ceil widths to device pixels to avoid fractional clipping
        w = w.map((v) => v.ceilToDouble()).toList();

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (int index = 0; index < _categories.length; index++) ...[
              SizedBox(
                width: w[index],
                child: ChoiceChip(
                  label: Text(
                    _categories[index].label,
                    maxLines: 1, // single line; width is guaranteed to fit
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                      color:
                          _selectedCategory == index
                              ? const Color(0xFF0077FF)
                              : Colors.grey[700],
                    ),
                  ),
                  selected: _selectedCategory == index,
                  onSelected: (selected) {
                    if (!selected) return;
                    setState(() {
                      _selectedCategory = index;
                      _applyCategoryFilter();
                    });
                  },
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color:
                          _selectedCategory == index
                              ? const Color(0xFF0077FF)
                              : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(
                      (baseRadius * scale).clamp(4.0, 12.0),
                    ),
                  ),
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: const Color(0xFFD6EAFF),
                  showCheckmark: false,
                  labelPadding: EdgeInsets.zero,
                  padding: EdgeInsets.symmetric(
                    horizontal: hPad,
                    vertical: vPad,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              if (index != _categories.length - 1)
                const SizedBox(width: baseGap),
            ],
          ],
        );
      },
    );
  }

  Widget _buildNoticeItem({
    required String title,
    required String date,
    bool disabled = false,
    VoidCallback? onTap,
  }) {
    final Color border = Color(0xffE9E9E9);
    final Color bg = disabled ? Colors.grey.shade100 : Colors.white;
    final Color titleColor = disabled ? Colors.grey.shade500 : Colors.black87;
    final Color dateColor =
        disabled ? Colors.grey.shade500 : Colors.grey.shade700;
    final borderRadius = BorderRadius.circular(10);

    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: borderRadius,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: borderRadius,
          border: Border.all(color: border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              date,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: dateColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyNoticeMessage() {
    final label = _currentCategoryLabel();
    final text = label.isEmpty ? '공지가 없습니다.' : '$label 공지가 없습니다.';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF94A3B8),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _showNoticeDetailModal(Map<String, dynamic> detail) {
    final attachments = _normalizeNoticeDocuments(detail['noticeDocuments']);
    final title = (detail['title'] ?? '').toString().trim();
    final content = (detail['content'] ?? '').toString().trim();
    final createdAt = _formatNoticeDate(detail['createdAt']?.toString());

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (dialogContext) {
        final size = MediaQuery.of(dialogContext).size;
        final dialogWidth = size.width.clamp(320.0, 500.0);
        final maxHeight = size.height * 0.8;
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          backgroundColor: Colors.transparent,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: dialogWidth,
                maxHeight: maxHeight,
                minWidth: dialogWidth,
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title.isEmpty ? '공지 제목' : title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                  ),
                                ),
                                if (createdAt != '-')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      createdAt,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9CA3AF),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            splashRadius: 20,
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        content.isEmpty ? '내용을 불러올 수 없어요.' : content,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF6B7280),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '첨부 파일',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (attachments.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F7FB),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Text(
                            '첨부된 파일이 없습니다.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        )
                      else
                        ...attachments.map(
                          (attachment) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildAttachmentTile(
                              dialogContext,
                              attachment,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<_NoticeAttachment> _normalizeNoticeDocuments(dynamic raw) {
    if (raw is! List) return const [];
    final List<_NoticeAttachment> attachments = [];
    for (final entry in raw) {
      if (entry is Map<String, dynamic>) {
        attachments.add(_mapToAttachment(entry));
      } else if (entry is Map) {
        attachments.add(
          _mapToAttachment(
            entry.map((key, value) => MapEntry(key.toString(), value)),
          ),
        );
      }
    }
    return attachments;
  }

  _NoticeAttachment _mapToAttachment(Map<String, dynamic> raw) {
    final name =
        (raw['fileName'] ??
                raw['originalName'] ??
                raw['name'] ??
                raw['documentName'] ??
                '파일명')
            .toString()
            .trim();
    final sizeLabel = _formatFileSizeLabel(raw['fileSize'] ?? raw['size']);
    final urlValue =
        (raw['url'] ??
                raw['fileUrl'] ??
                raw['downloadUrl'] ??
                raw['filePath'] ??
                '')
            .toString()
            .trim();
    return _NoticeAttachment(
      name: name.isEmpty ? '파일명' : name,
      sizeLabel: sizeLabel,
      url: urlValue.isEmpty ? null : urlValue,
    );
  }

  String _formatFileSizeLabel(dynamic raw) {
    if (raw == null) return '파일사이즈';
    if (raw is num) {
      double value = raw.toDouble();
      const units = ['B', 'KB', 'MB', 'GB', 'TB'];
      int unit = 0;
      while (value >= 1024 && unit < units.length - 1) {
        value /= 1024;
        unit++;
      }
      final text =
          value >= 100 ? value.round().toString() : value.toStringAsFixed(1);
      return '$text ${units[unit]}';
    }
    final fallback = raw.toString().trim();
    return fallback.isEmpty ? '파일사이즈' : fallback;
  }

  Widget _buildAttachmentTile(
    BuildContext context,
    _NoticeAttachment attachment,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    attachment.sizeLabel,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: OutlinedButton(
              onPressed:
                  attachment.url == null
                      ? null
                      : () => _openAttachmentUrl(attachment.url!),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF111827),
                side: const BorderSide(color: Color(0xFFD5D6DB)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '다운로드',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAttachmentUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      debugPrint('invalid attachment url: $url');
      return;
    }
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        debugPrint('attachment launch failed: $url');
      }
    } catch (e) {
      debugPrint('attachment open error: $e');
    }
  }

  void _openCreateNoticeDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final List<TextEditingController> fileInfoControllers = [];
    final List<TextEditingController> filePayloadControllers = [];
    final List<_UrlFieldControllers> urlControllers = [];
    String selectedType =
        _categories.isNotEmpty ? _categories.first.type : 'SCHOOL';
    bool typeOptionsExpanded = false;
    bool isSubmitting = false;

    void disposeAll() {
      titleController.dispose();
      contentController.dispose();
      for (final c in fileInfoControllers) {
        c.dispose();
      }
      for (final c in filePayloadControllers) {
        c.dispose();
      }
      for (final pair in urlControllers) {
        pair.dispose();
      }
    }

    showDialog(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (dialogContext) {
        final size = MediaQuery.of(dialogContext).size;
        final dialogWidth = size.width.clamp(320.0, 520.0);
        final maxHeight = size.height * 0.85;
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            Future<void> handleSubmit() async {
              if (isSubmitting) return;
              final trimmedTitle = titleController.text.trim();
              final trimmedContent = contentController.text.trim();
              if (trimmedTitle.isEmpty || trimmedContent.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('제목과 내용을 입력해 주세요.')),
                );
                return;
              }
              setModalState(() => isSubmitting = true);
              final fileTitles =
                  fileInfoControllers
                      .map((c) => c.text.trim())
                      .where((text) => text.isNotEmpty)
                      .toList();
              final urlDrafts =
                  urlControllers
                      .map(
                        (pair) => _UrlDraft(
                          title: pair.titleController.text.trim(),
                          value: pair.valueController.text.trim(),
                        ),
                      )
                      .where((entry) => entry.isValid)
                      .toList();
              final files =
                  filePayloadControllers
                      .map((c) => c.text.trim())
                      .where((text) => text.isNotEmpty)
                      .toList();
              try {
                await _createNotice(
                  type: selectedType,
                  title: trimmedTitle,
                  content: trimmedContent,
                  fileTitles: fileTitles,
                  urls: urlDrafts,
                  files: files,
                );
                if (mounted) {
                  Navigator.of(dialogContext).pop();
                }
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('공지 작성에 실패했습니다. 다시 시도해 주세요.')),
                );
              } finally {
                if (mounted) {
                  setModalState(() => isSubmitting = false);
                }
              }
            }

            void toggleTypeList() {
              setModalState(() {
                typeOptionsExpanded = !typeOptionsExpanded;
              });
            }

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              backgroundColor: Colors.transparent,
              child: Center(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    inputDecorationTheme: const InputDecorationTheme(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0077FF)),
                      ),
                    ),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: dialogWidth,
                      maxHeight: maxHeight,
                      minWidth: dialogWidth,
                    ),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                24,
                                24,
                                16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              '새 공지 작성',
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              '공지 정보를 입력하고 첨부 자료나 링크를 구성해 보세요.',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed:
                                            isSubmitting
                                                ? null
                                                : () {
                                                  Navigator.of(
                                                    dialogContext,
                                                  ).pop();
                                                },
                                        icon: const Icon(Icons.close_rounded),
                                        splashRadius: 20,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildPrimaryNoticeFields(
                                    selectedType: selectedType,
                                    titleController: titleController,
                                    contentController: contentController,
                                    enabled: !isSubmitting,
                                    typeExpanded: typeOptionsExpanded,
                                    onTypeTap: toggleTypeList,
                                    onTypeSelect: (value) {
                                      setModalState(() {
                                        selectedType = value;
                                        typeOptionsExpanded = false;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  _NoticeDialogSection(
                                    title: '첨부 파일명',
                                    description: '게시글에 노출할 첨부 제목을 등록하세요.',
                                    actionLabel: '필드 추가',
                                    onAction:
                                        isSubmitting
                                            ? null
                                            : () {
                                              setModalState(() {
                                                fileInfoControllers.add(
                                                  TextEditingController(),
                                                );
                                              });
                                            },
                                    child:
                                        fileInfoControllers.isEmpty
                                            ? const _EmptySectionHint(
                                              text:
                                                  '첨부 파일명이 있다면 필드를 추가해 입력하세요.',
                                            )
                                            : Column(
                                              children: List.generate(
                                                fileInfoControllers.length,
                                                (index) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 10,
                                                      ),
                                                  child: TextField(
                                                    controller:
                                                        fileInfoControllers[index],
                                                    enabled: !isSubmitting,
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          '파일명 ${index + 1}',
                                                      border:
                                                          const OutlineInputBorder(),
                                                      focusedBorder:
                                                          const OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                  color: Color(
                                                                    0xFF0077FF,
                                                                  ),
                                                                ),
                                                          ),
                                                      suffixIcon: IconButton(
                                                        onPressed:
                                                            isSubmitting
                                                                ? null
                                                                : () {
                                                                  setModalState(() {
                                                                    fileInfoControllers
                                                                        .removeAt(
                                                                          index,
                                                                        )
                                                                        .dispose();
                                                                  });
                                                                },
                                                        icon: const Icon(
                                                          Icons.close,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                  ),
                                  const SizedBox(height: 16),
                                  _NoticeDialogSection(
                                    title: '파일 데이터',
                                    description:
                                        '업로드 토큰이나 Base64 데이터 값을 입력하세요.',
                                    actionLabel: '필드 추가',
                                    onAction:
                                        isSubmitting
                                            ? null
                                            : () {
                                              setModalState(() {
                                                filePayloadControllers.add(
                                                  TextEditingController(),
                                                );
                                              });
                                            },
                                    child: Column(
                                      children:
                                          filePayloadControllers.isEmpty
                                              ? const [
                                                Text(
                                                  '파일 업로드 토큰이나 Base64 데이터를 직접 입력하세요.',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ]
                                              : List.generate(
                                                filePayloadControllers.length,
                                                (index) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 10,
                                                      ),
                                                  child: TextField(
                                                    controller:
                                                        filePayloadControllers[index],
                                                    enabled: !isSubmitting,
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          '파일 데이터 ${index + 1}',
                                                      border:
                                                          const OutlineInputBorder(),
                                                      suffixIcon: IconButton(
                                                        onPressed:
                                                            isSubmitting
                                                                ? null
                                                                : () {
                                                                  setModalState(() {
                                                                    filePayloadControllers
                                                                        .removeAt(
                                                                          index,
                                                                        )
                                                                        .dispose();
                                                                  });
                                                                },
                                                        icon: const Icon(
                                                          Icons.close,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _NoticeDialogSection(
                                    title: '링크',
                                    description: '학생들에게 공유할 외부 페이지 링크를 입력하세요.',
                                    actionLabel: '링크 추가',
                                    onAction:
                                        isSubmitting
                                            ? null
                                            : () {
                                              setModalState(() {
                                                urlControllers.add(
                                                  _UrlFieldControllers(
                                                    TextEditingController(),
                                                    TextEditingController(),
                                                  ),
                                                );
                                              });
                                            },
                                    child: Column(
                                      children:
                                          urlControllers.isEmpty
                                              ? const [
                                                Text(
                                                  '링크 제목과 URL을 입력해 추가할 수 있어요.',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ]
                                              : List.generate(urlControllers.length, (
                                                index,
                                              ) {
                                                final pair =
                                                    urlControllers[index];
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 12,
                                                      ),
                                                  child: Column(
                                                    children: [
                                                      TextField(
                                                        controller:
                                                            pair.titleController,
                                                        enabled: !isSubmitting,
                                                        decoration: InputDecoration(
                                                          labelText:
                                                              '링크 제목 ${index + 1}',
                                                          border:
                                                              const OutlineInputBorder(),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      TextField(
                                                        controller:
                                                            pair.valueController,
                                                        enabled: !isSubmitting,
                                                        decoration: InputDecoration(
                                                          labelText:
                                                              'URL ${index + 1}',
                                                          border:
                                                              const OutlineInputBorder(),
                                                          suffixIcon: IconButton(
                                                            onPressed:
                                                                isSubmitting
                                                                    ? null
                                                                    : () {
                                                                      setModalState(() {
                                                                        urlControllers
                                                                            .removeAt(
                                                                              index,
                                                                            )
                                                                            .dispose();
                                                                      });
                                                                    },
                                                            icon: const Icon(
                                                              Icons.close,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed:
                                        isSubmitting
                                            ? null
                                            : () {
                                              Navigator.of(dialogContext).pop();
                                            },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black87,
                                    ),
                                    child: const Text('취소'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        isSubmitting ? null : handleSubmit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0077FF),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child:
                                        isSubmitting
                                            ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                            : const Text(
                                              '확인',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(disposeAll);
  }

  Widget _buildPrimaryNoticeFields({
    required String selectedType,
    required TextEditingController titleController,
    required TextEditingController contentController,
    required bool enabled,
    required bool typeExpanded,
    required VoidCallback onTypeTap,
    required ValueChanged<String> onTypeSelect,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '공지 유형',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: enabled ? onTypeTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDCE1EB)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _categories
                        .firstWhere(
                          (cat) => cat.type == selectedType,
                          orElse: () => _categories.first,
                        )
                        .label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color:
                          enabled ? const Color(0xFF111827) : Colors.grey[400],
                    ),
                  ),
                  Icon(
                    typeExpanded ? Icons.expand_less : Icons.expand_more,
                    color: enabled ? const Color(0xFF111827) : Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FBFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDCE1EB)),
              ),
              child: Column(
                children:
                    _categories.map((cat) {
                      final selected = cat.type == selectedType;
                      return ListTile(
                        title: Text(
                          cat.label,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color:
                                selected
                                    ? const Color(0xFF0077FF)
                                    : const Color(0xFF1F2937),
                          ),
                        ),
                        trailing:
                            selected
                                ? const Icon(
                                  Icons.check,
                                  color: Color(0xFF0077FF),
                                )
                                : null,
                        onTap: () => onTypeSelect(cat.type),
                      );
                    }).toList(),
              ),
            ),
            crossFadeState:
                typeExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBFF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '제목',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  ),
                ),
                TextField(
                  controller: titleController,
                  enabled: enabled,
                  decoration: const InputDecoration(
                    hintText: '예) 2025년 학사일정 안내',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBFF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '내용',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  ),
                ),
                TextField(
                  controller: contentController,
                  enabled: enabled,
                  minLines: 5,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    hintText: '공지 내용을 입력해 주세요.',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
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

class _NoticeCategory {
  final String label;
  final String type;

  const _NoticeCategory({required this.label, required this.type});
}

class _NoticeAttachment {
  final String name;
  final String sizeLabel;
  final String? url;

  const _NoticeAttachment({
    required this.name,
    required this.sizeLabel,
    this.url,
  });
}

class _NoticeDialogSection extends StatelessWidget {
  final String title;
  final String actionLabel;
  final String? description;
  final VoidCallback? onAction;
  final Widget child;

  const _NoticeDialogSection({
    required this.title,
    required this.actionLabel,
    required this.onAction,
    required this.child,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0077FF),
                ),
                child: Text(actionLabel),
              ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _EmptySectionHint extends StatelessWidget {
  final String text;

  const _EmptySectionHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
      ),
    );
  }
}

class _UrlFieldControllers {
  final TextEditingController titleController;
  final TextEditingController valueController;

  _UrlFieldControllers(this.titleController, this.valueController);

  void dispose() {
    titleController.dispose();
    valueController.dispose();
  }
}

class _UrlDraft {
  final String title;
  final String value;

  _UrlDraft({required this.title, required this.value});

  bool get isValid => title.isNotEmpty && value.isNotEmpty;
}
