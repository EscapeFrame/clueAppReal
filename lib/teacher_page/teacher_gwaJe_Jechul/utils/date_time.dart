// 날짜/시간 포맷과 시간 계산 유틸리티

String formatDate(DateTime? dt) => dt == null ? '' : dt.toIso8601String().split('T').first;

String formatDateTimeReadable(DateTime? dt) {
  if (dt == null) return '';
  String p2(int v) => v.toString().padLeft(2, '0');
  return '${dt.year}-${p2(dt.month)}-${p2(dt.day)} ${p2(dt.hour)}:${p2(dt.minute)}';
}

// API 전송용 포맷: yyyy-MM-ddTHH:mm (초 없음)
String formatApiDateTime(DateTime? dt) {
  if (dt == null) return '';
  String p2(int v) => v.toString().padLeft(2, '0');
  return '${dt.year}-${p2(dt.month)}-${p2(dt.day)}T${p2(dt.hour)}:${p2(dt.minute)}';
}

String formatTimeLeftFrom(DateTime? end) {
  if (end == null) return '-';
  final diff = end.difference(DateTime.now());
  if (diff.isNegative) return '마감';
  final d = diff.inDays, h = diff.inHours % 24, m = diff.inMinutes % 60;
  if (d > 0) return '${d}일 ${h}시간 남음';
  if (diff.inHours > 0) return '${diff.inHours}시간 ${m}분 남음';
  return '${m}분 남음';
}
