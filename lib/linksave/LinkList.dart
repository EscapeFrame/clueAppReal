import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final scale = (width / 360).clamp(0.85, 1.2);
    double scaled(double base) => double.parse((base * scale).toStringAsFixed(2));

    final scopes = <String>[];
    if (restrictByGrade) scopes.add('학년');
    if (restrictByClass) scopes.add('반');

    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.04),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    createdAt ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                          fontSize: scaled(13),
                        ),
                  ),
                ),
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
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    fontSize: scaled(18),
                  ),
            ),
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
                  ...tags.map(
                    (tag) => _ScopeChip(tag, tag: true, scale: scale),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScopeChip extends StatelessWidget {
  const _ScopeChip(
    this.label, {
    this.tag = false,
    required this.scale,
  });

  final String label;
  final bool tag;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tag ? Colors.grey[400]! : const Color(0xFF0D6EFD),
        ),
        color: tag ? Colors.grey[100] : Colors.white,
      ),
      child: Text(
        tag ? '#$label' : label,
        style: TextStyle(
          fontSize: (13 * scale).clamp(11, 16),
          color: tag ? Colors.grey[700] : const Color(0xFF0D6EFD),
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
        child: Icon(
          icon,
          size: (20 * scale).clamp(16, 24),
          color:  color,
        ),
      ),
    );
  }
}
