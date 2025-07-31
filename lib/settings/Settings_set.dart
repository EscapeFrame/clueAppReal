import 'package:clue/settings/Settings_cheat.dart';
import 'package:flutter/material.dart';

class SettingsSet extends StatefulWidget {
  const SettingsSet({super.key});

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
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    Widget buildToggleItem(
      String title,
      bool value,
      ValueChanged<bool> onChanged,
    ) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 21),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: width * 0.037)),
            Transform.scale(
              scale: width * 0.00175,
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: const Color(0xff578FCA),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xffcccccc),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            "사용자관련",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: width * 0.045,
            ),
          ),
        ),
        ListTile(
          title: Text("사용자 정보 수정", style: TextStyle(fontSize: width * 0.037)),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 21),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsCheat()));
          },
          child: ListTile(
            title: Text("보관된 채팅", style: TextStyle(fontSize: width * 0.037)),
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 21),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            "알림설정",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: width * 0.045,
            ),
          ),
        ),
        buildToggleItem("사용자와의 채팅", chatWithUser, (val) {
          setState(() => chatWithUser = val);
        }),
        buildToggleItem("채점결과", gradingResult, (val) {
          setState(() => gradingResult = val);
        }),
        buildToggleItem("미제출과제", notSubmitted, (val) {
          setState(() => notSubmitted = val);
        }),
        buildToggleItem("수업 내용 업로드", classUpload, (val) {
          setState(() => classUpload = val);
        }),
        buildToggleItem("학사 일정", academicSchedule, (val) {
          setState(() => academicSchedule = val);
        }),
        buildToggleItem("학교 공지", schoolNotice, (val) {
          setState(() => schoolNotice = val);
        }),
        buildToggleItem("서비스 공지", serviceNotice, (val) {
          setState(() => serviceNotice = val);
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            "서비스관련",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: width * 0.045,
            ),
          ),
        ),
        ListTile(
          title: Text("서비스 사용방법", style: TextStyle(fontSize: width * 0.037)),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 21),
        ),
        ListTile(
          title: Text("문의사항", style: TextStyle(fontSize: width * 0.037)),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 21),
        ),
      ],
    );
  }
}
