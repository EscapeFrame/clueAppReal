import 'package:clue/teacher_page/assignment/utils/date_time.dart';
import 'package:clue/teacher_page/assignment/utils/file_utils.dart';

// 현재 UI는 Map 기반으로 동작하므로, 모델 클래스로 완전 이전 전까지
// 정규화 함수를 제공해 기존 코드와 호환합니다.
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

