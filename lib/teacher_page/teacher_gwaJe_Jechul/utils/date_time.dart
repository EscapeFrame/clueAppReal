// 날짜/시간 포맷과 남은 시간 계산.
// 화면 전반에서 일관된 표기를 위해 사용됨.


String formatDate(DateTime? dt) => dt == null ? '' : dt.toIso8601String().split('T').first;

String formatDateTimeReadable(DateTime? dt) {
  if (dt == null) return '';
  String p2(int v) => v.toString().padLeft(2, '0');
  return '${dt.year}-${p2(dt.month)}-${p2(dt.day)} ${p2(dt.hour)}:${p2(dt.minute)}';
}

// API 전송용 포맷: YYYY-MM-DD HH:MM (초/타임존 제외)
String formatApiDateTime(DateTime? dt) {
  if (dt == null) return '';
  String p2(int v) => v.toString().padLeft(2, '0');
  return '${dt.year}-${p2(dt.month)}-${p2(dt.day)} ${p2(dt.hour)}:${p2(dt.minute)}';
}

// ISO-8601 without milliseconds/timezone, e.g. 2025-09-07T14:30:00
String formatIsoLocal(DateTime? dt) {
  if (dt == null) return '';
  String p2(int v) => v.toString().padLeft(2, '0');
  return '${dt.year}-${p2(dt.month)}-${p2(dt.day)}T${p2(dt.hour)}:${p2(dt.minute)}:00';
}

String formatTimeLeftFrom(DateTime? end) {
  if (end == null) return '-';
  final diff = end.difference(DateTime.now());
  if (diff.isNegative) return '마감됨';
  final d = diff.inDays, h = diff.inHours % 24, m = diff.inMinutes % 60;
  if (d > 0) return '$d일 $h시간 남음';
  if (diff.inHours > 0) return '${diff.inHours}시간 $m분 남음';
  return '$m분 남음';
}

