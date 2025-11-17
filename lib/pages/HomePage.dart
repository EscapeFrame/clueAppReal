import 'package:clue/HamburgerDialog.dart';
import 'package:clue/config/app_data_.dart';
import 'package:clue/services/assignment_notification_service.dart';
import 'package:clue/widgets/mainPage/DayCard.dart';
import 'package:clue/widgets/mainPage/Gonji_/HakKyoGonji.dart';
import 'package:clue/widgets/mainPage/Gonji_/IlJeongGongji.dart';
import 'package:clue/widgets/mainPage/Gonji_/ServiceGongji.dart';
import 'package:clue/widgets/mainPage/HomepageCard.dart';
import 'package:clue/widgets/mainPage/SuHang.dart';
import 'package:clue/widgets/mainPage/Timetable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'Alarm.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> DayCardList = AppData.getDayCardList();

  final List<Map<String, dynamic>> SuapList = AppData.getSuapList();

  // 서버에서 불러온 미제출 과제 목록
  List<Map<String, dynamic>> _noJeChulList = [];

  final List<Widget> cards = [
    const ServiceGongJi(key: ValueKey('service')),
    const Hakkyogonji(key: ValueKey('hakgyo')),
    const Iljeonggongji(key: ValueKey('iljeong')),
  ];

  int index = 0;

  DateTime? _parseDate(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      return DateTime.parse(s.replaceAll(' ', 'T'));
    } catch (_) {
      return null;
    }
  }

  int _calcDaysDiff(String sEnd) {
    final end = _parseDate(sEnd);
    if (end == null) return 0;
    final diff = end.difference(DateTime.now());
    if (diff.isNegative) return -1;
    final hours = diff.inHours;
    return hours % 24 == 0 ? hours ~/ 24 : hours ~/ 24 + 1;
  }

  //알람보내야할거
  Future<void> noJeChulGwaJe() async {
    try {
      await AssignmentNotificationService.ensureBackgroundTaskRegistered();
    } catch (e) {
      debugPrint('Assignment reminder setup failed (ignored): $e');
    }

    List<Map<String, dynamic>>? list;
    try {
      list = await AssignmentNotificationService.syncAssignments(
        requestPermission: true,
      );
    } catch (e) {
      debugPrint('Assignment sync failed: $e');
    }

    if (list == null) {
      debugPrint('미제출 과제 API result: null');
      return;
    }

    final now = DateTime.now();
    final filtered =
        list.where((item) {
          final start = _parseDate((item['startDate'] ?? '').toString());
          final end = _parseDate((item['endDate'] ?? '').toString());
          final startOk = start == null || !start.isAfter(now);
          final endOk = end == null || end.isAfter(now);
          return startOk && endOk;
        }).toList();

    filtered.sort((a, b) {
      final da = _calcDaysDiff((a['endDate'] ?? '').toString());
      final db = _calcDaysDiff((b['endDate'] ?? '').toString());
      return da.compareTo(db);
    });

    if (!mounted) return;
    setState(() {
      _noJeChulList = filtered;
    });
    debugPrint('gwajejechul데이터: ' + list.toString());
  }

  @override
  void initState() {
    super.initState();
    noJeChulGwaJe();
  }

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
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const Alarm()),
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/images/jong.svg',
                            width: width * 0.055,
                          ),
                        ),
                        SizedBox(width: width * 0.03),
                        GestureDetector(
                          onTap: () => showHamburgerDialog(context),
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

            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(color: const Color(0xffF5F5F5)),
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.04 + 4),
                    child: Column(
                      children: [
                        const HomeTimetableSection(),
                        SizedBox(height: width * 0.04 + 4),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.06,
                            vertical: height * 0.015,
                          ),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.09),
                                blurRadius: 12,
                                spreadRadius: 1,
                                offset: Offset.zero,
                              ),
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: height * 0.018),
                              Text(
                                '미제출 과제',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: width * 0.042,
                                ),
                              ),
                              SizedBox(height: height * 0.005),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '기간 안에 과제를 제출하세요!',
                                    style: TextStyle(
                                      fontSize: width * 0.035,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: height * 0.025),
                              if (_noJeChulList.isEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: height * 0.02,
                                  ),
                                  child: Text(
                                    '과제가 없습니다.',
                                    style: TextStyle(
                                      fontSize: width * 0.04,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                )
                              else
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children:
                                        _noJeChulList.map((m) {
                                          final String title =
                                              (m['title'] ?? '').toString();
                                          final String sEnd =
                                              (m['endDate'] ?? '').toString();
                                          final int dayDiff = _calcDaysDiff(
                                            sEnd,
                                          );
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              right: width * 0.03,
                                            ),
                                            child: GestureDetector(
                                              onTap: () {},
                                              child: DayCard(
                                                day:
                                                    (dayDiff < 0 ? 0 : dayDiff)
                                                        .toString(),
                                                location: '',
                                                neyong: title,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                              SizedBox(height: height * 0.012),
                            ],
                          ),
                        ),

                        SizedBox(height: width * 0.04 + 4),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.06,
                            vertical: height * 0.015,
                          ),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.09),
                                blurRadius: 12,
                                spreadRadius: 1,
                                offset: Offset.zero,
                              ),
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: height * 0.018),
                              Text(
                                '수행평가 안내',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: width * 0.042,
                                ),
                              ),
                              SizedBox(height: height * 0.005),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '간편하게 수행평가를 확인하세요!',
                                    style: TextStyle(
                                      fontSize: width * 0.035,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: height * 0.025),
                              SuHang(
                                day: '1',
                                title: '과제이름 지라지ㅏㄹasdfasdf',
                                location: '수학실asdfasdf',
                              ),
                              SuHang(
                                day: '12',
                                title: '과제이름 지라지ㅏㄹasdfasdf',
                                location: '수학실asdfasdf',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: width * 0.04 + 4),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.09),
                                blurRadius: 12,
                                spreadRadius: 1,
                                offset: Offset.zero,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(12),
                          ),

                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.06,
                          ),
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
                                      url:
                                          'https://school.busanedu.net/bssm-h/main.do',
                                    ),
                                    HomepageCard(
                                      imagePath: 'assets/images/bsm.png',
                                      label: 'bsm',
                                      url:
                                          'https://school.busanedu.net/bssm-h/main.do',
                                    ),
                                    HomepageCard(
                                      imagePath: 'assets/images/Oring.png',
                                      label: 'Oring',
                                      url:
                                          'https://school.busanedu.net/bssm-h/main.do',
                                    ),
                                    HomepageCard(
                                      imagePath: 'assets/images/bwiki.png',
                                      label: '부마위키',
                                      url:
                                          'https://school.busanedu.net/bssm-h/main.do',
                                    ),
                                    HomepageCard(
                                      imagePath: 'assets/images/dokseoro.png',
                                      label: '독서로',
                                      url:
                                          'https://school.busanedu.net/bssm-h/main.do',
                                    ),
                                    HomepageCard(
                                      imagePath: 'assets/images/kyobo.png',
                                      label: '교보전자도서관',
                                      url:
                                          'https://school.busanedu.net/bssm-h/main.do',
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
