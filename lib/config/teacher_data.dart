class AppData {
  static List<Map<String, dynamic>> noticeList = [
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
          'title': '1차시: 자바 소개',
          'items': ['자바란 무엇인가?', '자바의 역사', 'JDK와 JRE 차이']
        },
        {
          'title': '2차시: 변수와 자료형',
          'items': ['기본 자료형', '변수 선언과 초기화', '상수와 final']
        },
        {
          'title': '1차시 자료',
          'items': ['교과서 12~15p', '자바 소개 PPT', '예제 코드.zip']
        },
      ],
      'assignments': [
        {
          'title': '자바에 대해서 조사하기',
          'status': '미제출',
          'due': '2025.04.15 23:59:59',
          'timeLeft': '1일 5시간 남음',
          'file': {'name': '학번-이름.pdf', 'size': '15.0 KB'},
          'submitted': false,
        },
        {
          'title': '객체지향 특징 정리',
          'status': '제출됨',
          'due': '2025.04.10 18:00:00',
          'timeLeft': '마감됨',
          'file': {'name': '2201234-홍길동.pdf', 'size': '23.4 KB'},
          'submitted': true,
        },
      ],
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
          'title': '1차시: 파이썬 기초',
          'items': ['파이썬의 특징', 'print 함수', '주석 사용법']
        },
        {
          'title': '2차시: 자료형과 연산자',
          'items': ['숫자형, 문자열', '리스트와 튜플', '기본 연산자']
        },
        {
          'title': '1차시 자료',
          'items': ['파이썬 기초 PDF', '실습 코드', '과제 안내문']
        },
      ],
      'assignments': [
        {
          'title': '파이썬 기초 실습 제출',
          'status': '미제출',
          'due': '2025.04.20 23:59:59',
          'timeLeft': '3일 2시간 남음',
          'file': {'name': '학번-이름.py', 'size': '5.0 KB'},
          'submitted': false,
        },
        {
          'title': '파이썬 자료형 정리',
          'status': '제출됨',
          'due': '2025.04.18 18:00:00',
          'timeLeft': '마감됨',
          'file': {'name': '2201234-홍길동.py', 'size': '7.4 KB'},
          'submitted': true,
        },
      ],
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
          'title': '1차시: 현대시 감상',
          'items': ['현대시의 특징', '감상문 작성법', '예시 시 감상']
        },
        {
          'title': '2차시: 문법과 맞춤법',
          'items': ['띄어쓰기 규칙', '자주 틀리는 맞춤법', '문장 부호 사용']
        },
        {
          'title': '1차시 자료',
          'items': ['현대시 모음집', '감상문 양식', '문법 연습문제']
        },
      ],
      'assignments': [
        {
          'title': '현대시 감상문 제출',
          'status': '미제출',
          'due': '2025.04.22 23:59:59',
          'timeLeft': '5일 1시간 남음',
          'file': {'name': '학번-이름.hwp', 'size': '10.0 KB'},
          'submitted': false,
        },
        {
          'title': '문법 연습문제 풀이',
          'status': '제출됨',
          'due': '2025.04.17 18:00:00',
          'timeLeft': '마감됨',
          'file': {'name': '2201234-홍길동.hwp', 'size': '3.2 KB'},
          'submitted': true,
        },
      ],
    },
  ];

} 