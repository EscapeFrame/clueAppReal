import 'package:flutter/material.dart';

Future<void> showHamburgerDialog(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'HamburgerMenu',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return Align(
        alignment: Alignment.centerRight,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: const _HamburgerPanel(),
        ),
      );
    },
  );
}

class _HamburgerPanel extends StatelessWidget {
  const _HamburgerPanel();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width * 0.78; // slide-in panel width

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (SafeArea only on top)
            SafeArea(
              top: true,
              bottom: false,
              child: SizedBox(
                height: 56,
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, size: 24),
                      color: Colors.black87,
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: '닫기',
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),

            // Scrollable content area
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                children: [
                  Text(
                    'CLUE 서비스로 이동',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MenuItem(
                    label: '설정',
                    onTap: () {
                      Navigator.of(context).pop();
                      // TODO: Navigate to settings page
                    },
                  ),
                  _MenuItem(
                    label: '문의하기',
                    onTap: () {
                      Navigator.of(context).pop();
                      // TODO: Navigate to inquiry/contact page
                    },
                  ),
                ],
              ),
            ),

            // Bottom account/info pill pinned (SafeArea only on bottom)
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                bottom: true,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(0xFFD9D9D9),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '공덕현',
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.labelLarge?.copyWith(
                              color: const Color(0xFF2563EB),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.copy_outlined,
                          size: 18,
                          color: Color(0xFF2563EB),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _MenuItem({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.black87),
        ),
      ),
    );
  }
}
