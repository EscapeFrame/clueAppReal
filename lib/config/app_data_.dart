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
          'due': '2025-12-31 23:59:59',
          'timeLeft': '1일 5시간 남음',
          'file': {'name': '학번-이름.pdf', 'size': '15.0 KB'},
          'submitted': false,
          // 추가: 상세설명, 제출 결과물, 할당파일
          'description': '얘들아 제발 숙제좀 미리미리 내라 너네도 내기 싫지만 나도 검사하기 귀찮다. 그러니까 빨리하고 끝내게 미리미리 제출해라. 0.1초라도 초과하면 나는 다 감점처리한다. 알겠제? 얘들아 제발 숙제좀 미리미리 내라 너네도 내기 싫지만 나도 검사하기 귀찮다.',
          'results': [
            '과제1. 수업 내용 요점정리(필수)',
            '과제2. 간단한 코드 작성(필수)',
            '과제3. 프로그램 구현(선택)',
          ],
          'files': [
            {'name': '이건 쌤이 할당한거.pdf', 'size': '15.0 KB', 'type': 'teacher'},
            {'name': '이건 학생이 업로드한거.pdf', 'size': '15.0 KB', 'type': 'student'},
          ],
        },
        {
          'title': '객체지향 특징 정리',
          'status': '제출됨',
          'due': '2025.04.10 18:00:00',
          'timeLeft': '마감됨',
          'file': {'name': '2201234-홍길동.pdf', 'size': '23.4 KB'},
          'submitted': true,
        },
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

  /// 임시 엔드포인트 예시: /api/class
  static List<Map<String, dynamic>> classRoomList = [
    {
      'classRoomId': 1,
      'name': '자바를 자바라!',
      'sort': 'JAVA',
      'target': '1-1',
      'studentCount': 3,
      'isActivation': true,
    },
    {
      'classRoomId': 2,
      'name': '스프링 부트 캠프',
      'sort': 'SPRING',
      'target': '2-2',
      'studentCount': 3,
      'isActivation': true,
    },
  ];

  static List<Map<String, String>> iljeongNoticeList = const [
    {'title': '2025년도 학사일정 안내', 'date': '25.10.21'},
    {'title': '2025년도 반배정 안내', 'date': '25.10.21'},
  ];

  static List<Map<String, String>> hakgyoNoticeList = const [
    {'title': '2025년도 학사일정 안내', 'date': '25.10.21'},
    {'title': '2025년도 반배정 안내', 'date': '25.10.21'},
    {'title': '2025년도 학사일정 안내', 'date': '25.10.21'},
    {'title': '2025년도 반배정 안내', 'date': '25.10.21'},
  ];

  static List<Map<String, String>> serviceNoticeList = const [
    {'title': 'CLUE 서비스 추가 기능', 'date': '25.10.21'},
    {'title': '시스템 점검 안내', 'date': '25.10.19'},
    {'title': '앱 업데이트 공지', 'date': '25.10.15'},
    {'title': '앱 업데이트 공지', 'date': '25.10.15'},
  ];

  static List<Map<String, String>> dayCardList = const [
    {'day': '1', 'neyong': '5차시 국어 독서 수행평가를 해야겠죠? 30자 채우기'},
    {'day': '5', 'neyong': 'cex'},
    {'day': '21', 'neyong': 'ㄴㅇㅁ'},
    {
      'day': '10',
      'neyong': 'ㄷㄱㅈdfdfdfdfdfdfdfdffdfadkdfkjdkfjkdjfkdfadkdfkjdkfjkdjfkdㄷ',
    },
    {'day': '16', 'neyong': 'ㄴㅇㅁ'},
  ];

  static List<Map<String, dynamic>> suapList = const [
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

  static List<Map<String, dynamic>> getNoticeList() {
    return List.from(noticeList);
  }

  static List<Map<String, String>> getIljeongNoticeList() {
    return List.from(iljeongNoticeList);
  }

  static List<Map<String, String>> getHakgyoNoticeList() {
    return List.from(hakgyoNoticeList);
  }

  static List<Map<String, String>> getServiceNoticeList() {
    return List.from(serviceNoticeList);
  }

  static List<Map<String, String>> getDayCardList() {
    return List.from(dayCardList);
  }

  static List<Map<String, dynamic>> getSuapList() {
    return List.from(suapList);
  }
} 