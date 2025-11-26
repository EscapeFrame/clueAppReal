import 'package:clue/settings/Settings_ProfileSujeong.dart';
import 'package:clue/settings/Settings_cheat.dart';
import 'package:flutter/material.dart';
import 'package:clue/auth_storage.dart';
import 'package:clue/widgets/common/app_snackbar.dart';

class SettingsSet extends StatefulWidget {
  const SettingsSet({super.key, this.onProfileUpdated});

  final VoidCallback? onProfileUpdated;

  @override
  State<SettingsSet> createState() => _SettingsSetState();
}

class _SettingsSetState extends State<SettingsSet> {
  bool chatWithUser = false;
  bool gradingResult = true;
  bool notSubmitted = true;
  bool classUpload = false;
  bool academicSchedule = true;
  bool schoolNotice = false;
  bool serviceNotice = false;

  static const _cardShadow = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 8)),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final tileStyle = TextStyle(
      fontSize: width * 0.037,
      color: const Color(0xFF343C4A),
    );

    Widget buildSection(String title, List<Widget> items) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: _cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: width * 0.04,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE9EDF5)),
            ..._withDividers(items),
          ],
        ),
      );
    }

    Widget buildNavigationTile(String title, {VoidCallback? onTap}) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              Expanded(child: Text(title, style: tileStyle)),
              const Icon(Icons.chevron_right, color: Color(0xFFA0A9B8)),
            ],
          ),
        ),
      );
    }

    Widget buildToggle(String title, bool value, ValueChanged<bool> onChanged) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(child: Text(title, style: tileStyle)),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF0D6EFD),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFE1E5EC),
              trackOutlineColor: WidgetStateProperty.resolveWith(
                (states) => Colors.transparent,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSection('사용자관련', [
          buildNavigationTile(
            '사용자 정보 수정',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsProfileSujeong(),
                ),
              );
              if (!mounted) return;
              widget.onProfileUpdated?.call();
            },
          ),
          buildNavigationTile(
            '보관된 채팅',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsCheat(),
                  ),
                ),
          ),
        ]),
        buildSection('알림설정', [
          buildToggle('사용자와의 채팅', chatWithUser, (val) {
            setState(() => chatWithUser = val);
          }),
          buildToggle('채점결과', gradingResult, (val) {
            setState(() => gradingResult = val);
          }),
          buildToggle('미제출과제', notSubmitted, (val) {
            setState(() => notSubmitted = val);
          }),
          buildToggle('수업 내용 업로드', classUpload, (val) {
            setState(() => classUpload = val);
          }),
          buildToggle('학사 일정', academicSchedule, (val) {
            setState(() => academicSchedule = val);
          }),
          buildToggle('학교 공지', schoolNotice, (val) {
            setState(() => schoolNotice = val);
          }),
          buildToggle('서비스 공지', serviceNotice, (val) {
            setState(() => serviceNotice = val);
          }),
        ]),
        buildSection('서비스관련', [
          buildNavigationTile('서비스 사용방법'),
          buildNavigationTile('문의사항'),
          buildNavigationTile(
            '로그아웃',
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      titlePadding:
                          const EdgeInsets.fromLTRB(24, 20, 24, 8),
                      contentPadding:
                          const EdgeInsets.fromLTRB(24, 0, 24, 12),
                      actionsPadding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      title: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9F2FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: Color(0xFF0D6EFD),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '로그아웃',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      content: const Text(
                        '로그아웃하시겠습니까?\n저장된 토큰이 삭제되고 로그인 화면으로 이동합니다.',
                        style: TextStyle(
                          height: 1.4,
                          color: Color(0xFF374151),
                        ),
                      ),
                      actionsAlignment: MainAxisAlignment.spaceBetween,
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF6B7280),
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('취소'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0D6EFD),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('로그아웃'),
                        ),
                      ],
                    ),
                  ) ??
                  false;

              if (!shouldLogout) return;

              await AuthStorage.instance.clear();
              if (!mounted) return;
              showAppSnackBar(
                context,
                '로그아웃 되었습니다.',
                isError: false,
              );
              // Clear navigation stack and go to login
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              });
            },
          ),
        ]),
      ],
    );
  }

  List<Widget> _withDividers(List<Widget> items) {
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i != items.length - 1) {
        result.add(
          const Divider(height: 1, thickness: 1, color: Color(0xFFE9EDF5)),
        );
      }
    }
    return result;
  }
}
