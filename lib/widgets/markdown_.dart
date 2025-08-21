import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/svg.dart';

class Markdown_ extends StatelessWidget {
  Markdown_({super.key});
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final markdowndata = '## HelloWorld \n --- \n ## 김한결 \n | ㅎㅇ';
    return Scaffold(
      key: _scaffoldKey,

      endDrawer: SizedBox(
        
        width: width * 0.75,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color:Colors.white,

          
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.close),
                SizedBox(height:height*0.05),
              ],
            ),
          ),
        ),
      ),

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
                      GestureDetector(
                        onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                        child: SvgPicture.asset(
                          'assets/images/bars-3.svg',
                          width: width * 0.08,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.05),
                ],
              ),
            ),
            Markdown(
              data: markdowndata,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
          ],
        ),
      ),
    );
  }
}
