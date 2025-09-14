// 학습실 화면에서 사용하는 날짜/시간 유틸.
// 문자열 파싱, 마감일 포맷, 남은 시간 계산을 제공합니다.

DateTime? parseDateFlexible(String? s) {
  if (s == null || s.isEmpty) return null;
  try {
    return DateTime.parse(s.replaceAll(' ', 'T'));
  } catch (_) {
    return null;
  }
}

String formatDue(DateTime? dt) =>
    dt == null ? '-' : dt.toIso8601String().split('T').first;

String formatTimeLeft(DateTime? end) {
  if (end == null) return '-';
  final diff = end.difference(DateTime.now());
  if (diff.isNegative) return '마감됨';
  final d = diff.inDays, h = diff.inHours % 24, m = diff.inMinutes % 60;
  if (d > 0) return '$d일 $h시간 남음';
  if (diff.inHours > 0) return '${diff.inHours}시간 $m분 남음';
  return '$m분 남음';
}
