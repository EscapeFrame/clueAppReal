// 유틸: 다양한 키에서 과제 ID 문자열을 추출합니다.
/// Resolves assignment id string from a possibly inconsistent map.
String? resolveAssignmentId(Map<String, dynamic> assignment) {
  final cand = [
    assignment['assignmentId'],
    assignment['id'],
    assignment['assignment_id'],
  ];
  for (final v in cand) {
    final s = v?.toString();
    if (s != null && s.isNotEmpty) return s;
  }
  return null;
}
