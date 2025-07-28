import 'package:clue/widgets/mainPage/DayCard.dart';
import 'package:clue/widgets/mainPage/Gonji_/HakKyoGonji.dart';
import 'package:clue/widgets/mainPage/HomepageCard.dart';
import 'package:clue/widgets/mainPage/Gonji_/IlJeongGongji.dart';
import 'package:clue/widgets/mainPage/Gonji_/ServiceGongji.dart';
import 'package:clue/widgets/mainPage/Suap.dart';
import 'package:clue/widgets/mainPage/TimetableStyledPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:clue/config/app_data_.dart';

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
                    '나의 일과보기',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: width * 0.045,
                    ),
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
                          // Row(
                          //   children: [
                          //     Image.asset(
                          //       'assets/images/leftArrow.png',
                          //       width: width * 0.08,
                          //       height: width * 0.08,
                          //       fit: BoxFit.fill,
                          //     ),
                          //     SizedBox(width: width * 0.01),
                          //     Image.asset(
                          //       'assets/images/rightArrow.png',
                          //       width: width * 0.08,
                          //       height: width * 0.08,
                          //       fit: BoxFit.fill,
                          //     ),
                          //   ],
                          // ),
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
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.06,
                vertical: height * 0.015,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.018),
                  Text(
                    '미제출 과제',
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
                        '기간 안에 과제를 제출하세요!',
                        style: TextStyle(fontSize: width * 0.038),
                      ),
                      // Row(
                      //   children: [
                      //     Image.asset(
                      //       'assets/images/leftArrow.png',
                      //       width: width * 0.08,
                      //       height: width * 0.08,
                      //       fit: BoxFit.fill,
                      //     ),
                      //     SizedBox(width: width * 0.01),
                      //     Image.asset(
                      //       'assets/images/rightArrow.png',
                      //       width: width * 0.08,
                      //       height: width * 0.08,
                      //       fit: BoxFit.fill,
                      //     ),
                      //   ],
                      // ),
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
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: width * 0.045,
                    ),
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
            // ... 기존 코드 ...
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.04),
                  Text(
                    '학교 서비스 바로가기',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: width * 0.045,
                    ),
                  ),
                  SizedBox(height: height * 0.012),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 600;
                      final crossAxisCount = isWide ? 3 : 2;
                      final maxCardWidth =
                          isWide ? 180.0 : 220.0; // 최대 카드 크기 제한
                      final cardAspectRatio = 1.1; // 카드의 가로:세로 비율

                      final homepageCards = [
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
                      ];

                      return Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth:
                                crossAxisCount * maxCardWidth +
                                (crossAxisCount - 1) * 12,
                          ),
                          child: GridView.count(
                            crossAxisCount: crossAxisCount,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            mainAxisSpacing: width * 0.012,
                            crossAxisSpacing: width * 0.012,
                            childAspectRatio: cardAspectRatio,
                            children:
                                homepageCards
                                    .map(
                                      (card) => ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: maxCardWidth,
                                          minWidth: 100,
                                          minHeight: 100,
                                        ),
                                        child: card,
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      );
                    },
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
