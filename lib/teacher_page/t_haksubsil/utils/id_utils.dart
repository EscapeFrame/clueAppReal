// 과제(학습실)에서 assignmentId 문자열을 안전하게 추출하는 유틸.


String assignmentIdStrFrom(Map<String, dynamic>? detail, Map<String, dynamic> assignment) {
  final cands = [
    detail?['assignmentId'],
    assignment['assignmentId'],
    assignment['id'],
    assignment['assignment_id'],
  ];
  for (final v in cands) {
    final s = v?.toString();
    if (s != null && s.isNotEmpty) return s;
  }
  return '';
}
