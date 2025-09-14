// 서버에서 받은 응답을 UI에서 쓰기 쉬운 Map 형태(assignment card)에 맞게 변환
import 'package:clue/teacher_page/teacher_gwaJe_Jechul/utils/date_time.dart';
import 'package:clue/teacher_page/teacher_gwaJe_Jechul/utils/file_utils.dart';

List<Map<String, dynamic>> normalizeAssignments(List<dynamic> raw) {
  DateTime? parseDate(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      // 서버가 'YYYY-MM-DD HH:MM' 형식으로 줄 수 있어 공백을 'T'로 보정
      return DateTime.parse(s.replaceAll(' ', 'T'));
    } catch (_) {
      return null;
    }
  }

  String fmtSize(dynamic bytes) => bytes is int ? formatFileSize(bytes) : '';

  return raw.whereType<Map>().map<Map<String, dynamic>>((e) {
    final m = Map<String, dynamic>.from(e);
    // 원본 필드(케이스 혼재 대비)
    final rawStart = (m['startDate'] ?? m['start_date'])?.toString();
    final rawEnd = (m['endDate'] ?? m['end_date'])?.toString();
    final end = parseDate(rawEnd);
    final attachments = (m['AssignmentAttachments'] is List)
        ? (m['AssignmentAttachments'] as List)
        : const [];
    final files = attachments.whereType<Map>().map((a) => {
          'name': (a['originalFileName'] ?? '').toString(),
          'size': fmtSize(a['size']),
          // 'url': a['url'] // 서버가 제공 시 연결
        }).toList();

    return {
      'assignmentId': m['assignmentId'],
      'title': (m['title'] ?? '').toString(),
      // 수정 시트에서 원본을 띄우기 위해 보존
      'content': (m['content'] ?? '').toString(),
      'startDate': rawStart ?? '',
      'endDate': rawEnd ?? '',
      'status': '미제출',
      'submitted': false,
      'due': formatDate(end),
      'timeLeft': formatTimeLeftFrom(end),
      'files': files,
    };
  }).toList();
}


