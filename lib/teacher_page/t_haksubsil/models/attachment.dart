import 'package:clue/teacher_page/t_haksubsil/utils/date_time.dart';

String _fmtSize(int bytes) {
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / 1024).toStringAsFixed(1)} KB';
}

List<Map<String, dynamic>> _mapAttList(List src) => src
    .whereType<Map>()
    .map((e) => Map<String, dynamic>.from(e))
    .map((m) {
      final typeVal = (m['type'] ?? '').toString().toUpperCase();
      final valueStr = (m['value'] ?? m['url'] ?? '').toString();
      final originalName = (m['originalFileName'] ?? '').toString();
      final isLikelyUrl =
          typeVal == 'URL' || (valueStr.startsWith('http') && originalName.isEmpty);

      final kind = isLikelyUrl ? 'URL' : 'FILE';
      final sizeNum = m['size'] is int ? (m['size'] as int) : int.tryParse('${m['size'] ?? ''}') ?? 0;
      final name = (originalName.isNotEmpty ? originalName : (isLikelyUrl ? valueStr : '')).toString();

      return <String, dynamic>{
        'name': name,
        'sizeText': (kind == 'URL' && sizeNum == 0) ? '' : _fmtSize(sizeNum),
        'contentType': (m['contentType'] ?? m['type'] ?? '').toString(),
        'attachmentId': (m['attachmentId'] ?? m['id'] ?? (kind == 'FILE' ? valueStr : '')).toString(),
        'kind': kind, // 'FILE' | 'URL'
        'url': isLikelyUrl ? valueStr : '',
      };
    })
    .toList();

List<Map<String, dynamic>> normalizeAttachments(Map<String, dynamic>? detail) {
  final a = (detail?['AssignmentAttachments'] as List?) ?? const [];
  if (a.isNotEmpty) return _mapAttList(a);
  final b = (detail?['xAssignmentResponseDtos'] as List?) ?? const [];
  return _mapAttList(b);
}
// 첨부 응답 리스트를 UI에서 쓰기 좋은 형태로 정규화하는 모델 헬퍼.
// FILE/URL 구분, 파일명/용량표시, attachmentId 매핑을 수행합니다.
