import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Markdown_ extends StatelessWidget {
  const Markdown_({
    super.key,
    required this.markdowndata,
    this.title,
  });

  final String markdowndata;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final markdownStyle = MarkdownStyleSheet.fromTheme(
      theme.copyWith(
        textTheme: textTheme.apply(
          bodyColor: const Color(0xff111827),
          displayColor: const Color(0xff111827),
        ),
      ),
    ).copyWith(
      h1: textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xff111827),
      ),
      h2: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xff111827),
      ),
      p: textTheme.bodyMedium?.copyWith(
        height: 1.5,
        fontSize: textTheme.bodyMedium?.fontSize ?? 14,
        color: const Color(0xff1f2937),
      ),
      listBullet: textTheme.bodyMedium?.copyWith(
        color: const Color(0xff1f2937),
      ),
    );

    final content =
        markdowndata.trim().isEmpty ? '표시할 내용이 없습니다.' : markdowndata;
    final displayTitle = (title ?? '').trim();
    final showTitle =
        displayTitle.isNotEmpty && !content.trimLeft().startsWith('#');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
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
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.black87,
                        iconSize: width * 0.07,
                        tooltip: '뒤로',
                      ),
                      SizedBox(width: width * 0.03),
                      IconButton(
                        onPressed: () {},
                        icon: SvgPicture.asset(
                          'assets/images/bars-3.svg',
                          width: width * 0.074,
                        ),
                        tooltip: '메뉴',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xffe2e8f0)),
            if (showTitle)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    displayTitle,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff111827),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Markdown(
                data: content,
                selectable: true,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                styleSheet: markdownStyle,
                shrinkWrap: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
