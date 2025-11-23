import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Gwajejechul extends StatefulWidget {
  final List<Map<String, dynamic>> dataList;
  final Function(int index, bool submitted)? onSubmissionChanged;
  final Function(Map<String, dynamic>)? onCardClick;
  const Gwajejechul({
    super.key,
    required this.dataList,
    this.onSubmissionChanged,
    this.onCardClick,
  });

  @override
  State<Gwajejechul> createState() => _GwajejechulState();
}

class _GwajejechulState extends State<Gwajejechul> {
  late List<Map<String, dynamic>> _submissions;

  @override
  void initState() {
    super.initState();
    _submissions = _normalize(widget.dataList);
  }

  @override
  void didUpdateWidget(covariant Gwajejechul oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.dataList, widget.dataList)) {
      setState(() {
        _submissions = _normalize(widget.dataList);
      });
    }
  }

  List<Map<String, dynamic>> _normalize(List<Map<String, dynamic>> raw) {
    return raw.map((data) {
      final normalized = Map<String, dynamic>.from(data);
      final attachments =
          ((normalized['submissionAttachmentResponses'] as List?) ?? const [])
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
      final submittedFlag =
          normalized['isSubmitted'] == true ||
          normalized['IsSubmitted'] == true ||
          normalized['submitted'] == true;
      normalized['submitted'] = submittedFlag;
      normalized['status'] =
          normalized['status'] ?? (submittedFlag ? '제출완료' : '미제출');
      normalized['attachments'] = attachments;
      return normalized;
    }).toList();
  }

  void _toggleSubmissionStatus(int index) {
    setState(() {
      final bool next = !(_submissions[index]['submitted'] == true);
      _submissions[index]['submitted'] = next;
      _submissions[index]['status'] = next ? '제출완료' : '미제출';
    });
    widget.onSubmissionChanged?.call(
      index,
      _submissions[index]['submitted'] == true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    if (_submissions.isEmpty) {
      return Center(
        child: Text(
          '등록된 과제가 없어요.',
          style: TextStyle(
            color: const Color(0xff6B7280),
            fontSize: width * 0.04,
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(vertical: height * 0.012),
      children:
          _submissions.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            final String title = (data['title'] ?? '과제 제목 없음').toString();
            final String content = (data['content'] ?? '').toString();
            final String teacher = (data['userName'] ?? '').toString();
            final bool isSubmitted = data['submitted'] == true;
            final DateTime? startDate = _tryParseDate(data['startDate']);
            final DateTime? endDate = _tryParseDate(data['endDate']);
            final DateTime? submittedAt = _tryParseDate(data['submittedAt']);
            final attachments =
                (data['attachments'] as List?)?.cast<Map<String, dynamic>>() ??
                const [];
            final Color accent = const Color(0xff2563EB);
            final dDay = _buildDDayLabel(endDate);
            final period = _formatPeriod(startDate, endDate);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap:
                  widget.onCardClick == null
                      ? null
                      : () => widget.onCardClick!(data),
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: width * 0.05,
                  vertical: height * 0.008,
                ),
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(width * 0.04),
                  border: Border.all(color: const Color(0xffE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(12),
                      blurRadius: width * 0.025,
                      offset: Offset(0, width * 0.01),
                    ),
                  ],
                ),
                child: Column(
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
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: width * 0.048,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xff1F2937),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (dDay != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: accent.withAlpha(30),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  dDay,
                                  style: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            SizedBox(height: height * 0.006),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSubmitted
                                        ? const Color(0xffDCFCE7)
                                        : const Color(0xffFEE2E2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                isSubmitted ? '제출완료' : '미제출',
                                style: TextStyle(
                                  color:
                                      isSubmitted
                                          ? const Color(0xff15803D)
                                          : const Color(0xffB91C1C),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (period.isNotEmpty) ...[
                      Text(
                        period,
                        style: TextStyle(
                          fontSize: width * 0.034,
                          color: const Color(0xff475467),
                        ),
                      ),
                    ],
                    SizedBox(height: height * 0.01),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetaTile(
                            icon: Icons.calendar_today,
                            label: '시작일',
                            value: _formatDate(startDate),
                            color: const Color(0xff4C5674),
                            width: width,
                          ),
                        ),
                        SizedBox(width: width * 0.02),
                        Expanded(
                          child: _buildMetaTile(
                            icon: Icons.flag,
                            label: '마감일',
                            value: _formatDate(endDate),
                            color: accent,
                            width: width,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.02),
                    _buildSubmissionInfo(submittedAt, isSubmitted, width),
                    if (attachments.isNotEmpty) ...[
                      SizedBox(height: height * 0.02),
                      _buildAttachmentSection(attachments, width),
                    ],
                    // const Divider(height: 32, color: Color(0xffE2E8F0)),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: ElevatedButton.icon(
                    //         onPressed:
                    //             widget.onCardClick == null
                    //                 ? null
                    //                 : () => widget.onCardClick!(data),
                    //         icon: const Icon(
                    //           Icons.description_outlined,
                    //           color: Color(0xff1F2937),
                    //         ),
                    //         label: const Text('과제 보기'),
                    //         style: ElevatedButton.styleFrom(
                    //           backgroundColor: Colors.white,
                    //           foregroundColor: const Color(0xff1F2937),
                    //           elevation: 0,
                    //           side: const BorderSide(color: Color(0xffE2E8F0)),
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(
                    //               width * 0.028,
                    //             ),
                    //           ),
                    //           padding: EdgeInsets.symmetric(
                    //             vertical: height * 0.018,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //     SizedBox(width: width * 0.03),
                    //     Expanded(
                    //       child: ElevatedButton.icon(
                    //         onPressed: () => _toggleSubmissionStatus(index),
                    //         icon: Icon(isSubmitted ? Icons.undo : Icons.upload),
                    //         label: Text(isSubmitted ? '제출 취소' : '과제 제출하기'),
                    //         style: ElevatedButton.styleFrom(
                    //           backgroundColor:
                    //               isSubmitted
                    //                   ? const Color(0xffE5E7EB)
                    //                   : const Color(0xff2563EB),
                    //           foregroundColor:
                    //               isSubmitted
                    //                   ? const Color(0xff1F2937)
                    //                   : Colors.white,
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(
                    //               width * 0.028,
                    //             ),
                    //           ),
                    //           padding: EdgeInsets.symmetric(
                    //             vertical: height * 0.018,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    SizedBox(height: 4),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildSubmissionInfo(
    DateTime? submittedAt,
    bool submitted,
    double width,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(
            submitted ? Icons.check_circle : Icons.hourglass_bottom,
            color:
                submitted ? const Color(0xff16A34A) : const Color(0xffF97316),
          ),
          SizedBox(width: width * 0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '제출 일시',
                  style: TextStyle(
                    fontSize: width * 0.032,
                    color: const Color(0xff6B7280),
                  ),
                ),
                Text(
                  submitted ? _formatDate(submittedAt) : '제출 내역이 아직 없어요.',
                  style: TextStyle(
                    fontSize: width * 0.036,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentSection(
    List<Map<String, dynamic>> attachments,
    double width,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '첨부 파일',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: width * 0.036,
            color: const Color(0xff111827),
          ),
        ),
        SizedBox(height: width * 0.02),
        Wrap(
          spacing: width * 0.02,
          runSpacing: 8,
          children:
              attachments.map((file) {
                final String name =
                    (file['originalFileName'] ?? file['value'] ?? '첨부파일')
                        .toString();
                final String type =
                    (file['type'] ?? '').toString().toUpperCase();
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.03,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        type == 'LINK' ? Icons.link : Icons.attach_file,
                        size: width * 0.04,
                        color: const Color(0xff475569),
                      ),
                      SizedBox(width: width * 0.015),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: width * 0.032,
                          color: const Color(0xff0F172A),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  String? _buildDDayLabel(DateTime? endDate) {
    if (endDate == null) return null;
    final now = DateTime.now();
    final diff = endDate.difference(now).inDays;
    if (diff > 0) return 'D-$diff';
    if (diff == 0) return 'D-DAY';
    return '종료';
  }

  String _formatPeriod(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '';
    return '${_formatDate(start)} ~ ${_formatDate(end)}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '정보 없음';
    final local = date.toLocal();
    final mm = local.month.toString().padLeft(2, '0');
    final dd = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '${local.year}.$mm.$dd $hh:$min';
  }

  DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    if (str.isEmpty) return null;
    try {
      return DateTime.parse(str);
    } catch (_) {
      return null;
    }
  }

  Widget _buildMetaTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required double width,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.025, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: width * 0.05),
          SizedBox(width: width * 0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: width * 0.03,
                    color: const Color(0xff6B7280),
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: width * 0.035,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff111827),
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
