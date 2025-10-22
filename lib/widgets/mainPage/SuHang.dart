import 'package:flutter/material.dart';

class SuHang extends StatelessWidget {
  const SuHang({
    super.key,
    required this.day,
    required this.title,
    this.location,
  });

  final String day;
  final String title;
  final String? location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final String dayLabel = day == '0' ? 'D-day' : 'D-$day';
    final String trailing = (location ?? '').trim();
    final int? dayValue = int.tryParse(day);
    final bool isUrgent = dayValue != null && dayValue <= 6;
    final Color chipBg = isUrgent ? const Color(0xffFFE3E9) : const Color(0xFF0077FF);
    final Color chipBorder = isUrgent ? const Color(0xffFF6D6D) : const Color(0xFF0077FF);
    final Color chipText = isUrgent ? const Color(0xffFF6D6D) : Colors.white;

    final double containerPadding = (width * 0.04).clamp(12.0, 18.0).toDouble();
    final double chipPadding = (width * 0.03).clamp(10.0, 14.0).toDouble();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: containerPadding,
        vertical: (containerPadding * 0.75).clamp(10.0, 14.0),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: chipPadding,
              vertical: (chipPadding * 0.5).clamp(6.0, 8.0),
            ),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: chipBorder),
            ),
            child: Text(
              dayLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: chipText,
                fontSize: width * 0.03,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: trailing.isNotEmpty ? 7 : 1,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                ),
                if (trailing.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Text(
                      trailing,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF939393),
                        fontWeight: FontWeight.w500,
                        fontSize: width * 0.035,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 4),
        ],
      ),
    );
  }
}
