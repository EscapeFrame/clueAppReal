import 'package:clue/widgets/DayCard.dart';
import 'package:clue/widgets/HakKyoGonji.dart';
import 'package:clue/widgets/HomepageCard.dart';
import 'package:clue/widgets/IlJeongGongji.dart';
import 'package:clue/widgets/mainPage/ServiceGongji.dart';
import 'package:clue/widgets/mainPage/Suap.dart';
import 'package:clue/widgets/mainPage/TimetableStyledPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:clue/config/app_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> DayCardList = AppData.getDayCardList();

  final List<Map<String, dynamic>> SuapList = AppData.getSuapList();

  final List<Widget> cards = [
    const ServiceGongJi(key: ValueKey('service')),
    const Hakkyogonji(key: ValueKey('hakgyo')),
    const Iljeonggongji(key: ValueKey('iljeong')),
  ];

  int index = 0;

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
              color: const Color(0xFFD6EAFF),
              padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: height * 0.015),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/images/logo.png', width: width * 0.2),
                      Image.asset('assets/images/jongn.png', width: width * 0.2),
                    ],
                  ),
                  SizedBox(height: height * 0.0005),
                  Text(
                    '나의 일과보기',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: width * 0.045),
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    '빠르게 나의 수업을 확인해 보세요!',
                    style: TextStyle(fontSize: width * 0.038),
                  ),
                  SizedBox(height: height * 0.025),
                  TimetableStyledPage(),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: height * 0.03),
                      Text(
                        '학습실 바로가기',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: width * 0.045,
                        ),
                      ),
                      SizedBox(height: height * 0.005),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '간편하게 수업에 함께 참여해보세요!',
                            style: TextStyle(fontSize: width * 0.038),
                          ),
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/leftArrow.png',
                                width: width * 0.08,
                                height: width * 0.08,
                                fit: BoxFit.fill,
                              ),
                              SizedBox(width: width * 0.01),
                              Image.asset(
                                'assets/images/rightArrow.png',
                                width: width * 0.08,
                                height: width * 0.08,
                                fit: BoxFit.fill,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.018),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              SuapList.map((item) {
                                return Padding(
                                  padding: EdgeInsets.only(right: width * 0.03),
                                  child: Suap(
                                    title: item['title']!,
                                    neyong: item['neyong']!,
                                    url: item['url']!,
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                      SizedBox(height: height * 0.03),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              color: const Color(0xFFD6EAFF),
              padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: height * 0.015),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.018),
                  Text(
                    '미제출 과제',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: width * 0.045),
                  ),
                  SizedBox(height: height * 0.005),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '기간 안에 과제를 제출하세요!',
                        style: TextStyle(fontSize: width * 0.038),
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/leftArrow.png',
                            width: width * 0.08,
                            height: width * 0.08,
                            fit: BoxFit.fill,
                          ),
                          SizedBox(width: width * 0.01),
                          Image.asset(
                            'assets/images/rightArrow.png',
                            width: width * 0.08,
                            height: width * 0.08,
                            fit: BoxFit.fill,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.025),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          DayCardList.map((item) {
                            return Padding(
                              padding: EdgeInsets.only(right: width * 0.03),
                              child: DayCard(
                                day: item['day']!,
                                neyong: item['neyong']!,
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  SizedBox(height: height * 0.012),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.04),
                  Text(
                    '공지/안내',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: width * 0.045),
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    '학교의 소식을 빠르게 알아보세요!',
                    style: TextStyle(fontSize: width * 0.038),
                  ),
                  SizedBox(height: height * 0.03),
                  Container(
                    height: (height) / 3 + 20,
                    margin: EdgeInsets.all(width * 0.008),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width * 0.025),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: PageView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ServiceGongJi(),
                        Hakkyogonji(),
                        Iljeonggongji(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.04),
                  Text(
                    '학교 서비스 바로가기',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: width * 0.045),
                  ),
                  SizedBox(height: height * 0.012),
                  Center(
                    child: Wrap(
                      spacing: width * 0.012,
                      runSpacing: width * 0.012,
                      alignment: WrapAlignment.start,
                      children: [
                        HomepageCard(
                          imagePath: 'assets/images/bssm.png',
                          label: '공식홈페이지',
                          url: 'https://school.busanedu.net/bssm-h/main.do',
                        ),
                        HomepageCard(
                          imagePath: 'assets/images/bsm.png',
                          label: 'bsm',
                          url: 'https://school.busanedu.net/bssm-h/main.do',
                        ),
                        HomepageCard(
                          imagePath: 'assets/images/Oring.png',
                          label: 'Oring',
                          url: 'https://school.busanedu.net/bssm-h/main.do',
                        ),
                        HomepageCard(
                          imagePath: 'assets/images/bwiki.png',
                          label: '부마위키',
                          url: 'https://school.busanedu.net/bssm-h/main.do',
                        ),
                        HomepageCard(
                          imagePath: 'assets/images/dokseoro.png',
                          label: '독서로',
                          url: 'https://school.busanedu.net/bssm-h/main.do',
                        ),
                        HomepageCard(
                          imagePath: 'assets/images/kyobo.png',
                          label: '교보전자도서관',
                          url: 'https://school.busanedu.net/bssm-h/main.do',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.04),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
