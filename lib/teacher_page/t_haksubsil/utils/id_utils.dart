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
// 과제(학습실)에서 assignmentId 문자열을 안전하게 추출하는 유틸.
// detail/assignment 객체의 다양한 키를 순서대로 확인해 ID를 반환합니다.
