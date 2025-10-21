import 'package:flutter/material.dart';

class LinkDeleteCheckDialog extends StatelessWidget {
  const LinkDeleteCheckDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '내용을 삭제하시겠습니까?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  splashRadius: 18,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '내용이 삭제되었습니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF0D6EFD),
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF86C1FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '닫기',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> show(
    BuildContext context, {
    String heading = '내용을 삭제하시겠습니까?',
    String message = '내용이 삭제되었습니다.',
    String closeLabel = '닫기',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => LinkDeleteCheckDialog(),
    );
  }
}
