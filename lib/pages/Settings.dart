import 'package:clue/settings/Settings_set.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'Alarm.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  static const _backgroundColor = Color(0xffF5F5F5);
  static const _cardShadow = [
    BoxShadow(color: Color(0x11000000), blurRadius: 18, offset: Offset(0, 6)),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final width = media.size.width;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: SvgPicture.asset(
                        'assets/images/realLogo.svg',
              
                        width: width * 0.25,
                      ),
                    ),
              
                    Container(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const Alarm()),
                              );
                            },
                            child: SvgPicture.asset(
                              'assets/images/jong.svg',
                              width: width * 0.055,
                            ),
                          ),
                          SizedBox(width: width * 0.03),
                          GestureDetector(
                            // onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                            child: SvgPicture.asset(
                              'assets/images/bars-3.svg',
                              width: width * 0.074,
                            ),
                          ),
                          SizedBox(width: width * 0.0443),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: _cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE6ECF4),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xFF7F8EA3),
                                  size: 36,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '공덕현',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: width * 0.048,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '부산소프트웨어마이스터고등학교',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF5C6672),
                                      fontSize: width * 0.035,
                                    ),
                                  ),
                                  Text(
                                    '2학년 2반 1번',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF5C6672),
                                      fontSize: width * 0.035,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SettingsSet(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D6EFD),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {},
            child: const Text('변경사항 저장'),
          ),
        ),
      ),
    );
  }
}
