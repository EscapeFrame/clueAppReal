import 'package:clue/settings/Settings_ProfileSujeong.dart';
import 'package:clue/settings/Settings_cheat.dart';
import 'package:flutter/material.dart';
import 'package:clue/auth_storage.dart';

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
              await AuthStorage.instance.clear();
              if (!mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('로그아웃 되었습니다.')));
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
