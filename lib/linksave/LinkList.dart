import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:clue/widgets/common/app_snackbar.dart';

import 'LinkDelete.dart';

class LinkList extends StatelessWidget {
  const LinkList({
    super.key,
    required this.title,
    required this.url,
    this.description,
    this.tags = const [],
    this.restrictByGrade = false,
    this.restrictByClass = false,
    this.createdAt,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  final String title;
  final String url;
  final String? description;
  final List<String> tags;
  final bool restrictByGrade;
  final bool restrictByClass;
  final String? createdAt;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final scale = (width / 360).clamp(0.85, 1.2);
    double scaled(double base) => double.parse((base * scale).toStringAsFixed(2));

    final scopes = <String>[];
    if (restrictByGrade) scopes.add('학년');
    if (restrictByClass) scopes.add('반');
    final dateText = (createdAt ?? '').trim();
    final normalizedUrl = url.trim();

    Future<void> _openLink() async {
      if (normalizedUrl.isEmpty) return;
      final uri = Uri.tryParse(normalizedUrl);
      final isHttp = uri != null && (uri.isScheme('http') || uri.isScheme('https'));
      if (!isHttp) {
        showAppSnackBar(context, '올바른 링크가 아닙니다.');
        return;
      }
      final launched = await launchUrlString(
        normalizedUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        showAppSnackBar(context, '링크를 열지 못했습니다.');
      }
    }

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: _openLink,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.09),
              blurRadius: 12,
              spreadRadius: 1,
              offset: Offset.zero,
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                fontSize: scaled(18),
                              ),
                        ),
                        if (dateText.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            dateText,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: scaled(13),
                                ),
                          ),
                        ],
                      ],
                      ),
                    ),
                    if (showActions) ...[
                      _ActionIcon(
                        icon: Icons.edit_outlined,
                        color: const Color(0xff0077FF),
                        scale: scale,
                        onTap: onEdit,
                      ),
                      const SizedBox(width: 6),
                      _ActionIcon(
                        icon: Icons.delete_outline,
                        color: const Color(0xffFF6D6D),
                        scale: scale,
                        onTap: () async {
                          await LinkDeleteDialog.show(
                            context,
                            itemTitle: title,
                            itemDescription: description,
                            onConfirmed: onDelete,
                          );
                        },
                      ),
                    ],
                  ],
                ),
              const SizedBox(height: 10),
              if ((description ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  description!.trim(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontSize: scaled(13),
                      ),
                ),
              ],
              if (scopes.isNotEmpty || tags.isNotEmpty) ...[
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    ...scopes.map((scope) => _ScopeChip(scope, scale: scale)),
                    ...tags.map((tag) => _ScopeChip(tag, tag: true, scale: scale)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ScopeChip extends StatelessWidget {
  const _ScopeChip(this.label, {this.tag = false, required this.scale});

  final String label;
  final bool tag;
  final double scale;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF86C1FF);
    const chipBg = Color(0xFFEBF6FF);
    const textColor = Color(0xFF0077FF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        color: chipBg,
      ),
      child: Text(
        tag ? '#$label' : label,
        style: TextStyle(
          fontSize: (13 * scale).clamp(11, 16),
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.scale,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: (20 * scale).clamp(16, 24), color: color),
      ),
    );
  }
}
