import 'package:flutter/material.dart';

class LinkDeleteFailDialog extends StatelessWidget {
  const LinkDeleteFailDialog({super.key});

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
                  onPressed: () => Navigator.pop(context, false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '죄송합니다.\n해당 내용 삭제를 실패하였습니다.\n다시 시도해주세요.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFFF5A5A),
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0D6EFD),
                      side: const BorderSide(color: Color(0xFF86C1FF)),
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15, 
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF86C1FF),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      '재시도',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LinkDeleteFailDialog(),
    );
  }
}
