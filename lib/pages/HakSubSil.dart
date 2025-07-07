import 'package:clue/widgets/BangGwaHooHakSubSilBaroGaJa.dart';
import 'package:clue/widgets/HakSubSilBaroGaJa.dart';
import 'package:clue/widgets/InmoonHakSubSilBaroGaJa.dart';
import 'package:clue/widgets/JeongGongHakSubSilBaroGaJa.dart';
import 'package:flutter/material.dart';

class Haksubsil extends StatelessWidget {
   Haksubsil({super.key});
  final List<Map<String, dynamic>> noticeList = [
  {
    'title': '자바를 자바라!',
    'language': 'JAVA',
    'class': '2-2',
    'people': '16',
    'teacher': '유근찬',
    'description': '즐거운 자바 수업을 하고 자바를 마스터하며...ㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣ',
    'subject':'jeongong',
    'progress': 1,
    'total': 6,
    'lessons': [
      { 
        'title': '1차시',
        'items': ['자바란 무엇인가?'],
      },
      {
        'title': '1차시 자료',
        'items': ['ver 교과서연결', 'ver PPT', 'ver Code'],
      },
    ]
  },
  {
    'title': '상미파이썬!',
    'language': 'python',
    'class': '2-3',
    'people': '14',
    'teacher': '곽상미',
    'description': '즐거운 파이선 수업을 하고 자바를 마스터하며...',
    'subject':'inmoon',
    'progress': 2,
    'total': 6,
    'lessons': [
      {
        'title': '1차시',
        'items': ['자바란 무엇인가?'],
      },
      {
        'title': '1차시 자료',
        'items': ['ver 교과서연결', 'ver PPT', 'ver Code'],
      },
    ]
  },
  {
    'title': '드레이븐!',
    'language': '국어',
    'class': '2-3',
    'people': '14',
    'teacher': 'ㄴㄴㅌㅌ',
    'description': '즐거운 파이선 수업을 하고 자바를 마스터하며...',
    'subject':'banggwahoo',
    'progress': 2,
    'total': 6,
    'lessons': [
      {
        'title': '1차시',
        'items': ['자바란 무엇인가?'],
      },
      {
        'title': '1차시 자료',
        'items': ['ver 교과서연결', 'ver PPT', 'ver Code'],
      },
    ]
  },
];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Column(
          children: [
            // 상단 제목 및 탭바
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: height * 0.015),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 로고 줄
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/images/logo.png', width: width * 0.2),
                      Image.asset('assets/images/jongn.png', width: width * 0.2),
                    ],
                  ),
                  SizedBox(height: height * 0.0005),
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
                          child: Text('인문과목', style: TextStyle(fontSize: width * 0.045)),
                        ),
                      )),
                      Tab(child: SizedBox(
                        height: height * 0.04,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('전공과목', style: TextStyle(fontSize: width * 0.045)),
                        ),
                      )),
                      Tab(child: SizedBox(
                        height: height * 0.04,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('방과후', style: TextStyle(fontSize: width * 0.045)),
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
                  Haksubsilbarogaja(noticeList:noticeList),
                  Inmoonhaksubsilbarogaja(noticeList:noticeList),
                  Jeonggonghaksubsilbarogaja(noticeList:noticeList),
                  Banggwahoohaksubsilbarogaja(noticeList:noticeList),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
