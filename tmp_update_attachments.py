from pathlib import Path

path = Path(r"lib/widgets/haksubsilPage/HakSubSilGaJa.dart")
text = path.read_text(encoding="utf-8")
old = """    final detail = controller.detail;
    List<Map<String, dynamic>> serverAttachments = _assignmentAttachments;
    if (serverAttachments.isEmpty && detail != null) {
      final sources = [
        (detail['submissionAttachmentResponses'] as List?) ?? const [],
        (detail['AssignmentAttachments'] as List?) ?? const [],
        (detail['attachmentDtos'] as List?) ?? const [],
        (detail['xAssignmentResponseDtos'] as List?) ?? const [],
      ];
      for (final src in sources) {
        if (src.isNotEmpty) {
          serverAttachments = mapAttachments(src);
          break;
        }
      }
    }
    // fallback: widget���� ���޵� ����÷�� ���
    if (serverAttachments.isEmpty) {
      final fallback =
          (widget.assignment['submissionAttachmentResponses'] as List?) ??
          const [];
      if (fallback.isNotEmpty) {
        serverAttachments = mapAttachments(fallback);
      }
    }

"""
new = """    final detail = controller.detail;
    List<Map<String, dynamic>> serverAttachments = [];
    if (detail != null) {
      final submissionResponses =
          (detail['submissionAttachmentResponses'] as List?) ?? const [];
      if (submissionResponses.isNotEmpty) {
        serverAttachments.addAll(mapAttachments(submissionResponses));
      }
      if (serverAttachments.isEmpty) {
        final sources = [
          (detail['AssignmentAttachments'] as List?) ?? const [],
          (detail['attachmentDtos'] as List?) ?? const [],
          (detail['xAssignmentResponseDtos'] as List?) ?? const [],
        ];
        for (final src in sources) {
          if (src.isNotEmpty) {
            serverAttachments = mapAttachments(src);
            break;
          }
        }
      }
    }
    if (serverAttachments.isEmpty && _assignmentAttachments.isNotEmpty) {
      serverAttachments =
          List<Map<String, dynamic>>.from(_assignmentAttachments);
    }
    if (serverAttachments.isEmpty) {
      final fallback =
          (widget.assignment['submissionAttachmentResponses'] as List?) ??
          const [];
      if (fallback.isNotEmpty) {
        serverAttachments = mapAttachments(fallback);
      }
    }

"""
if old not in text:
    raise SystemExit("target block not found")
path.write_text(text.replace(old, new, 1), encoding="utf-8")
