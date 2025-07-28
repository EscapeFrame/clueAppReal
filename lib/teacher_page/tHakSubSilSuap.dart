import 'package:clue/config/teacher_data.dart';
import 'package:clue/teacher_page/thaksubsilTabBar_/ActivateTeacherSuap.dart';
import 'package:clue/teacher_page/thaksubsilTabBar_/AllTeacherSuap.dart';
import 'package:clue/teacher_page/thaksubsilTabBar_/UnActivateTeacherSuap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Thaksubsilsuap extends StatelessWidget {
   Thaksubsilsuap({super.key});
  final List<Map<String, dynamic>> teacherHakSubSil = TeacherData.getTeacherHakSubsil();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Column(
          children: [

            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: height * 0.015),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height:height*0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset('assets/images/clueLogo.svg', width:width*0.25),
                      Container(
                        margin: EdgeInsets.only(right: width*0.035),
                        child: SvgPicture.asset('assets/images/jong.svg', width:width*0.055),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.05),
                  Text(
                    '나의 학습실',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: width * 0.045),
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    '학습실을 확인하고 관리해주세요!',
                    style: TextStyle(fontSize: width * 0.038),
                  ),
                  SizedBox(height: height * 0.003),
                  TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.lightBlue,
                    indicatorWeight: 3,
                    labelStyle: TextStyle(
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                    ),
                    tabs: [
                      Tab(child: SizedBox(
                        height: height * 0.04,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('전체', style: TextStyle(fontSize: width * 0.045)),
                        ),
                      )),
                      Tab(child: SizedBox(
                        height: height * 0.04,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('활성화', style: TextStyle(fontSize: width * 0.045)),
                        ),
                      )),
                      Tab(child: SizedBox(
                        height: height * 0.04,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('비활성화', style: TextStyle(fontSize: width * 0.045)),
                        ),
                      )),
                      
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Allteachersuap(teacherHakSubSil:teacherHakSubSil),
                  Activateteachersuap(teacherHakSubSil:teacherHakSubSil),
                  Unactivateteachersuap(teacherHakSubSil:teacherHakSubSil),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}