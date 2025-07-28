import 'package:clue/config/app_color.dart';
import 'package:clue/config/app_data_.dart';
import 'package:clue/widgets/haksubsilPage/haksubsilTabBar_/BangGwaHooHakSubSilBaroGaJa.dart';
import 'package:clue/widgets/haksubsilPage/haksubsilTabBar_/HakSubSilBaroGaJa.dart';
import 'package:clue/widgets/haksubsilPage/haksubsilTabBar_/InmoonHakSubSilBaroGaJa.dart';
import 'package:clue/widgets/haksubsilPage/haksubsilTabBar_/JeongGongHakSubSilBaroGaJa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Haksubsil extends StatelessWidget {
  Haksubsil({super.key});
  final List<Map<String, dynamic>> noticeList = AppData.getNoticeList();

  void showAddClassDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            width: width * 0.8,
            // height: height * 0.2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  '학습실 추가하기',
                  style: TextStyle(
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.01),
                TextField(
                  style: TextStyle(
                    fontSize: width * 0.031,
                    color: Color(0xff666666),
                  ),
                  controller: codeController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    filled: true,
                    isDense: true,
                    fillColor: Color(0xffF3F3F3),
                    hintText: "학습실 코드를 입력해주세요",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
                GestureDetector(
                  onTap: () => {
                    Navigator.pop(context),
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xffCCCCCC)),
                    ),
                    child: Center(child: Text('취소')),
                  ),
                ),
                SizedBox(
                  height:5
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColor.blue,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColor.blue),
                  ),
                  child: Center(child: Text('확인')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showAddClassDialog(context);
          },
          backgroundColor: Color(0xff86C1FF),
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
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
                    '나의 학습실',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.045,
                    ),
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
                      Tab(
                        child: SizedBox(
                          height: height * 0.04,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '전체',
                              style: TextStyle(fontSize: width * 0.045),
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        child: SizedBox(
                          height: height * 0.04,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '인문과목',
                              style: TextStyle(fontSize: width * 0.045),
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        child: SizedBox(
                          height: height * 0.04,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '전공과목',
                              style: TextStyle(fontSize: width * 0.045),
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        child: SizedBox(
                          height: height * 0.04,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '방과후',
                              style: TextStyle(fontSize: width * 0.045),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Haksubsilbarogaja(noticeList: noticeList),
                  Inmoonhaksubsilbarogaja(noticeList: noticeList),
                  Jeonggonghaksubsilbarogaja(noticeList: noticeList),
                  Banggwahoohaksubsilbarogaja(noticeList: noticeList),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
