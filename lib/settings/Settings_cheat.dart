import 'package:clue/config/app_cheat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SettingsCheat extends StatelessWidget {
  const SettingsCheat({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
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
                  Text(
                    '채팅보관함',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: width * 0.045,
                    ),
                  ),

                  SizedBox(height: height * 0.02),
                  ...AppCheat.cheatData.map(
                    (item) => Padding(
                      padding: EdgeInsets.symmetric(vertical: height * 0.008),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['name'],
                            style: TextStyle(fontSize: width * 0.04),
                          ),
                          GestureDetector(
                            onTap: () {
                              //채팅 보러가기 함수 넣기
                            },
                            child: Row(
                              children: [
                                Text(
                                  '보러가기',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: width * 0.035,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.blue,
                                  size: width * 0.045,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
