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
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Column(
          children: [
            // 상단 제목 및 탭바
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 로고 줄
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/images/logo.png'),
                      Image.asset('assets/images/jongn.png'),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    '나의 학습실',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '학습실을 확인하고 관리해주세요!',
                    style: TextStyle(fontSize: 17),
                  ),
                  const SizedBox(height: 2),
                  const TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.lightBlue,
                    indicatorWeight: 3,
                    labelStyle: TextStyle(
                      fontSize: 15, 
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1, 
                    ),
                    tabs: [
                      Tab(text: '전체'),
                      Tab(text: '인문과목'),
                      Tab(text: '전공과목'),
                      Tab(text: '방과후'),
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
