import 'package:clue/widgets/DayCard.dart';
import 'package:clue/widgets/HakKyoGonji.dart';
import 'package:clue/widgets/HomepageCard.dart';
import 'package:clue/widgets/IlJeongGongji.dart';
import 'package:clue/widgets/ServiceGongji.dart';
import 'package:clue/widgets/Suap.dart';
import 'package:clue/widgets/TimetableStyledPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _nextCard() {
    setState(() {
      index = (index + 1) % cards.length;
    });
  }

  final List<Map<String, String>> DayCardList = const [
    {'day': '1', 'neyong': '5차시 국어 독서 수행평가를 해야겠죠? 30자 채우기'},
    {'day': '5', 'neyong': 'cex'},
    {'day': '21', 'neyong': 'ㄴㅇㅁ'},
    {
      'day': '10',
      'neyong': 'ㄷㄱㅈdfdfdfdfdfdfdfdffdfadkdfkjdkfjkdjfkdfadkdfkjdkfjkdjfkdㄷ',
    },
    {'day': '16', 'neyong': 'ㄴㅇㅁ'},
  ];

  final List<Map<String, dynamic>> SuapList = const [
    {
      'title': '자바',
      'neyong': '자바를자바라',
      'url':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRZE9FVgGXR74Nb0UYG5owg_sgqEzS2rIcZ7Q&s',
    },
    {
      'title': '파이썬',
      'neyong': '파이썬',
      'url':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRZE9FVgGXR74Nb0UYG5owg_sgqEzS2rIcZ7Q&s',
    },
    {
      'title': '파이썬',
      'neyong': '파이썬',
      'url':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRZE9FVgGXR74Nb0UYG5owg_sgqEzS2rIcZ7Q&s',
    },
  ];

  final List<Widget> cards = [
    const ServiceGongJi(key: ValueKey('service')),
    const Hakkyogonji(key: ValueKey('hakgyo')),
    const Iljeonggongji(key: ValueKey('iljeong')),
  ];

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: const Color(0xFFD6EAFF),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/images/logo.png'),
                      Image.asset('assets/images/jongn.png'),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    '나의 일과보기',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '빠르게 나의 수업을 확인해 보세요!',
                    style: TextStyle(fontSize: 17),
                  ),
                  SizedBox(height: 20),
                  TimetableStyledPage(),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 25),
                      const Text(
                        '학습실 바로가기',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '간편하게 수업에 함께 참여해보세요!',
                            style: TextStyle(fontSize: 17),
                          ),
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/leftArrow.png',
                                width: 30,
                                height: 30,
                                fit: BoxFit.fill,
                              ),
                              SizedBox(width: 3),
                              Image.asset(
                                'assets/images/rightArrow.png',
                                width: 30,
                                height: 30,
                                fit: BoxFit.fill,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 15),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              SuapList.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: Suap(
                                    title: item['title']!,
                                    neyong: item['neyong']!,
                                    url: item['url']!,
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                      SizedBox(height: 25),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              color: const Color(0xFFD6EAFF),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  const Text(
                    '미제출 과제',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '기간 안에 과제를 제출하세요!',
                        style: TextStyle(fontSize: 17),
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/leftArrow.png',
                            width: 30,
                            height: 30,
                            fit: BoxFit.fill,
                          ),
                          SizedBox(width: 3),
                          Image.asset(
                            'assets/images/rightArrow.png',
                            width: 30,
                            height: 30,
                            fit: BoxFit.fill,
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          DayCardList.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: DayCard(
                                day: item['day']!,
                                neyong: item['neyong']!,
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),

            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  const Text(
                    '공지/안내',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                  const SizedBox(height: 4),

                  const Text(
                    '학교의 소식을 빠르게 알아보세요!',
                    style: TextStyle(fontSize: 17),
                  ),

                  SizedBox(height: 25),

                  // AnimatedSwitcher(
                  //   duration: const Duration(milliseconds: 300),
                  //   transitionBuilder: (
                  //     Widget child,
                  //     Animation<double> animation,
                  //   ) {
                  //     final offsetAnimation = Tween<Offset>(
                  //       begin: const Offset(1.0, 0.0), // 오른쪽에서 시작
                  //       end: Offset.zero,
                  //     ).animate(animation);

                  //     return SlideTransition(
                  //       position: offsetAnimation,
                  //       child: child,
                  //     );
                  //   },
                  //   child: cards[index],
                  // ),
                  Container(
                    height: (MediaQuery.of(context).size.height) / 3 + 20,
                    margin: EdgeInsets.all(3),
                    decoration: BoxDecoration(

                      borderRadius: BorderRadius.circular(10),
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

                  // SizedBox(height: 30),
                ],
              ),
            ),

            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  const Text(
                    '학교 서비스 바로가기',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
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
                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/homen.svg',
              colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              'assets/images/homen.svg',
              colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            ),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/bookn.svg',
              colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              'assets/images/bookn.svg',
              colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            ),
            label: '책',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/bookn.svg',
              colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              'assets/images/bookn.svg',
              colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            ),
            label: '책',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/Union.svg',
              colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              'assets/images/bookn.svg',
              colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            ),
            label: '책',
          ),
        ],
      ),
    );
  }
}
