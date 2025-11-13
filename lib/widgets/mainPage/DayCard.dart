import 'package:flutter/material.dart';

class DayCard extends StatelessWidget {
  const DayCard({
    super.key,
    required this.day,
    required this.neyong,
    this.location,
  });

  final String day;
  final String neyong;
  final String? location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final hasLocation = (location ?? '').trim().isNotEmpty;

    final double cardWidth = (width * 0.7).clamp(240.0, 360.0).toDouble();
    final double horizontalPadding =
        (width * 0.045).clamp(16.0, 22.0).toDouble();
    final double verticalPadding = (width * 0.04).clamp(14.0, 20.0).toDouble();
    final String dayLabel = day == '0' ? 'D-day' : 'D-$day';

    return Container(
      width: cardWidth,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9E9E9)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            spreadRadius: 1,
            blurRadius: 100,
            offset: const Offset(0, 4), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFA4A4)),
            ),
            child: Text(
              dayLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFF4D65),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            neyong,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F1F1F),
            ),
          ),
          if (hasLocation) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: theme.textTheme.bodyMedium?.fontSize,
                  color: const Color(0xFF8C8C8C),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location!.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF8C8C8C),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
