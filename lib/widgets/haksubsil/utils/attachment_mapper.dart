// 서버 첨부 데이터(Map 리스트)를 UI에서 쓰기 쉬운 구조로 정규화합니다.
import 'formatters.dart';

/// Normalizes attachment-like maps from server into a consistent structure.
/// Returns a list of maps with: name, sizeText, contentType, kind('FILE'|'URL'), url
List<Map<String, dynamic>> mapAttachments(List src) {
  return src
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .map((m) {
    final typeVal = (m['type'] ?? '').toString().toUpperCase();
    final valueStr = (m['value'] ?? m['url'] ?? '').toString();
    final originalName = (m['originalFileName'] ?? '').toString();
    final isLikelyUrl =
        typeVal == 'URL' || (valueStr.startsWith('http') && originalName.isEmpty);
    final kind = isLikelyUrl ? 'URL' : 'FILE';
    final sizeNum = m['size'] is int
        ? (m['size'] as int)
        : int.tryParse('${m['size'] ?? ''}') ?? 0;
    final name = (originalName.isNotEmpty ? originalName : (isLikelyUrl ? valueStr : ''))
        .toString();

    final attachmentRaw = m['assignmentAttachmentId'] ??
        m['attachmentId'] ??
        m['assignment_attachment_id'] ??
        m['id'];
    final attachmentId = attachmentRaw == null
        ? ''
        : attachmentRaw.toString();

    return <String, dynamic>{
      'name': name,
      'sizeText': (kind == 'URL' && sizeNum == 0) ? '' : formatSize(sizeNum),
      'contentType': (m['contentType'] ?? m['type'] ?? '').toString(),
      'kind': kind,
      'url': isLikelyUrl ? valueStr : '',
      'attachmentId': attachmentId,
    };
  }).toList();
}
