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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,16,24,0
                ),
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
                            onTap: () => Navigator.pop(context),
                            child: Icon(Icons.arrow_back, size: width * 0.07),
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
            Container(
              color: const Color(0xffffffff),
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.06,
                // vertical: height * 0.015,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  SizedBox(height: height * 0.03),
                  Text(
                    '채팅보관함',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: width * 0.055,
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
