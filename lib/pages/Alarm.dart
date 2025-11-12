import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Alarm extends StatefulWidget {
  const Alarm({super.key});

  @override
  State<Alarm> createState() => _AlarmState();
}

class _AlarmState extends State<Alarm> {
  int _selectedCategory = 0;
  final List<String> _categories = const ['학교공지', '일정안내', '서비스공지', '기타'];

  final List<Map<String, dynamic>> _items = const [
    {'title': '2025학교공지', 'date': '2025-12-31', 'disabled': false},
    {'title': '2025학교공지', 'date': '2025-12-31', 'disabled': false},
    {'title': '2025학교공지', 'date': '2025-12-31', 'disabled': false},
    {'title': '2025학교공지', 'date': '2025-12-31', 'disabled': true},
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    'assets/images/realLogo.svg',
                    width: width * 0.25,
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.arrow_back, size: width * 0.07),
                      ),
                      SizedBox(width: width * 0.03),
                      SvgPicture.asset(
                        'assets/images/bars-3.svg',
                        width: width * 0.074,
                      ),
                      SizedBox(width: width * 0.0443),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                color: const Color(0xFFF5F5F5),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCategoryChips(context),
                      const SizedBox(height: 12),
                      ..._items.map(
                        (e) => _buildNoticeItem(
                          title: e['title'] as String,
                          date: e['date'] as String,
                          disabled: e['disabled'] as bool,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Fixed horizontal gap between chips (can be made responsive if needed)
        const double baseGap = 6.0;
        const double safeBufferPerChip =
            8.0; // generous safety buffer to prevent CJK clipping

        // Baseline metrics to scale from
        const double baseFont = 13.0; // px (logical)
        const double baseHPad =
            10.0; // chip horizontal padding (slightly increased)
        const double baseVPad =
            8.0; // chip vertical padding (slightly increased)
        const double baseRadius = 8.0; // reduced border radius baseline

        final textDirection = Directionality.of(context);
        final textScale = MediaQuery.textScaleFactorOf(context);

        // Measure single-line text width for a given font size
        double measureTextWidth(String text, double fontSize) {
          final painter = TextPainter(
            text: TextSpan(
              text: text,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
            ),
            maxLines: 1,
            textDirection: textDirection,
            textScaler: TextScaler.linear(textScale),
          )..layout();
          return painter.width;
        }

        // Finds the largest scale so that total width of all 4 chips fits.
        double low = 0.15; // allow even smaller text if needed
        double high = 1.4; // allow slight upscale when room permits
        double best = low;
        for (int iter = 0; iter < 22; iter++) {
          final mid = (low + high) / 2.0;
          final testFont = baseFont * mid;
          final testHPad = baseHPad * mid;
          double total = 0.0;
          for (final label in _categories) {
            total += measureTextWidth(label, testFont) + 2 * testHPad;
          }
          final gaps = baseGap * (_categories.length - 1);
          total += gaps;

          if (total <= constraints.maxWidth) {
            best = mid; // fits; try larger
            low = mid;
          } else {
            high = mid; // too big; shrink
          }
        }

        // Final scaled metrics (with reasonable clamps)
        double scale = best.clamp(0.15, 1.4);
        double fontSize = baseFont * scale;
        double hPad = (baseHPad * scale).clamp(2.0, 18.0);
        double vPad = (baseVPad * scale).clamp(2.0, 12.0);
        final double gaps = baseGap * (_categories.length - 1);

        // Ensure final sum fits (guard against rounding/border effects)
        List<double> widths() =>
            _categories
                .map(
                  (label) =>
                      measureTextWidth(label, fontSize) +
                      2 * hPad +
                      safeBufferPerChip,
                )
                .toList();

        double sum(List<double> list) => list.fold(0.0, (p, e) => p + e);

        var w = widths();
        double total = sum(w) + gaps;
        int safety = 0;
        while (total > constraints.maxWidth && safety < 16) {
          // Proportional shrink with slight margin for stability
          final factor = (constraints.maxWidth / total).clamp(0.80, 0.98);
          scale *= factor;
          fontSize = baseFont * scale;
          hPad = (baseHPad * scale).clamp(2.0, 18.0);
          vPad = (baseVPad * scale).clamp(2.0, 12.0);
          w = widths();
          total = sum(w) + gaps;
          safety++;
        }

        // Additional uniform shrink to keep the same ratio but make chips smaller
        const double shrinkFactor = 0.88; // keep ratio; can be tuned
        scale = (scale * shrinkFactor).clamp(0.12, 1.4);
        fontSize = baseFont * scale;
        hPad = (baseHPad * scale).clamp(2.0, 18.0);
        vPad = (baseVPad * scale).clamp(2.0, 12.0);
        w = widths();
        total = sum(w) + gaps;

        // Final ensure: if rounding/buffer made it overflow, shrink uniformly
        int safety2 = 0;
        while (total > constraints.maxWidth && safety2 < 16) {
          scale *= 0.98;
          fontSize = baseFont * scale;
          hPad = (baseHPad * scale).clamp(2.0, 18.0);
          vPad = (baseVPad * scale).clamp(2.0, 12.0);
          w = widths();
          total = sum(w) + gaps;
          safety2++;
        }

        // Ceil widths to device pixels to avoid fractional clipping
        w = w.map((v) => v.ceilToDouble()).toList();

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (int index = 0; index < _categories.length; index++) ...[
              SizedBox(
                width: w[index],
                child: ChoiceChip(
                  label: Text(
                    _categories[index],
                    maxLines: 1, // single line; width is guaranteed to fit
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                      color:
                          _selectedCategory == index
                              ? const Color(0xFF0077FF)
                              : Colors.grey[700],
                    ),
                  ),
                  selected: _selectedCategory == index,
                  onSelected: (val) {
                    setState(() => _selectedCategory = index);
                  },
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color:
                          _selectedCategory == index
                              ? const Color(0xFF0077FF)
                              : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(
                      (baseRadius * scale).clamp(4.0, 12.0),
                    ),
                  ),
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: const Color(0xFFD6EAFF),
                  showCheckmark: false,
                  labelPadding: EdgeInsets.zero,
                  padding: EdgeInsets.symmetric(
                    horizontal: hPad,
                    vertical: vPad,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              if (index != _categories.length - 1)
                const SizedBox(width: baseGap),
            ],
          ],
        );
      },
    );
  }

  Widget _buildNoticeItem({
    required String title,
    required String date,
    bool disabled = false,
  }) {
    final Color border = Color(0xffE9E9E9);
    final Color bg = disabled ? Colors.grey.shade100 : Colors.white;
    final Color titleColor = disabled ? Colors.grey.shade500 : Colors.black87;
    final Color dateColor =
        disabled ? Colors.grey.shade500 : Colors.grey.shade700;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          Text(
            date,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: dateColor,
            ),
          ),
        ],
      ),
    );
  }
}
