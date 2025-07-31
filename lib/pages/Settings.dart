import 'package:clue/settings/Settings_set.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    Widget sectionHeader(String title) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: width * 0.045,
          ),
        ),
      );
    }

    Widget sectionItem(String title) {
      return ListTile(
        title: Text(title, style: TextStyle(fontSize: width * 0.037)),
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 21),
      );
    }

    Widget toggleItem(String title, bool value) {
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
                onChanged: (_) {},

                activeTrackColor: const Color(0xff578FCA),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xffcccccc),
              ),
            ),
          ],
        ),
      );
    }

    Widget divider() {
      return Container(
        height: 6,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: const Color(0xffffffff),
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.06,
                vertical: height * 0.015,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        'assets/images/clueLogo.svg',
                        width: width * 0.25,
                      ),
                      Container(
                        margin: EdgeInsets.only(right: width * 0.035),
                        child: SvgPicture.asset(
                          'assets/images/jong.svg',
                          width: width * 0.055,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.05),
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide.none,
                      borderRadius: BorderRadius.zero,
                    ),
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: FlutterLogo(size: 72.0),
                      title: Text(
                        '공덕현',
                        style: TextStyle(
                          fontSize: width * 0.043,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SizedBox(height: 4),
                          Text(
                            '부산소프트웨어마이스터고등학교',
                            style: TextStyle(fontSize: width * 0.035),
                          ),
                          Text(
                            '2학년 2반 1번',
                            style: TextStyle(fontSize: width * 0.035),
                          ),
                        ],
                      ),
                      // trailing: Icon(Icons.more_vert),
                      isThreeLine: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  SettingsSet(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
