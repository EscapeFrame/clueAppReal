import 'package:clue/api_client.dart';
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
                onPressed: () {},
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
                      SvgPicture.asset(
                        'assets/images/bars-3.svg',
                        width: width * 0.074,
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
