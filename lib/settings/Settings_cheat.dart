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
                  

                ],
              ),
            ),
          ],
        ),
      ),
    );;
  }
}