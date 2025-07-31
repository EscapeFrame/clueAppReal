class TeacherData {
  static List<Map<String, dynamic>> assignmentList = [
    {
      'title': '자바에 대해서 조사하기',
      'status': '미제출',
      'due': '2025.04.15 23:59:59',
      'timeLeft': '1일 5시간 남음',
      'submitted': false,
      'files': [
        {'name': '2201001-김철수.pdf', 'size': '15.0 KB'},
        {'name': '2201002-이영희.pdf', 'size': '18.2 KB'},
      ],
    },
    {
      'title': '객체지향 특징 정리',
      'status': '제출됨',
      'due': '2025.04.10 18:00:00',
      'timeLeft': '마감됨',
      'submitted': true,
      'files': [
        {'name': '2201001-김철수.pdf', 'size': '23.4 KB'},
        {'name': '2201002-이영희.pdf', 'size': '19.8 KB'},
      ],
    },
    {
      'title': '파이썬 기초 실습 제출',
      'status': '미제출',
      'due': '2025.04.20 23:59:59',
      'timeLeft': '3일 2시간 남음',
      'submitted': false,
      'files': [],
    },
    {
      'title': '현대시 감상문 제출',
      'status': '제출됨',
      'due': '2025.04.22 23:59:59',
      'timeLeft': '5일 1시간 남음',
      'submitted': true,
      'files': [
        {'name': '2203001-한소희.hwp', 'size': '10.0 KB'},
      ],
    },
  ];


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

  static List<Map<String, dynamic>> getAssignmentList() {
    return List.from(classRoomList);
  }

  static List<Map<String, dynamic>> teacherHakSubSil = [
  {
    'title': '자바를 자바라!',
    'language': 'JAVA',
    'class': '2-2',
    'people': '16',
    'teacher': '유근찬',
    'description': '즐거운 자바 수업을 하고 자바를 마스터하며 더 나아가 프레임워크까지 다루어 봐요!',
    'subject': '전공',
    'status':'activate',
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
    'title': 'DB',
    'language': 'DB',
    'class': '1-4',
    'people': '18',
    'teacher': '김민수',
    'status':'unactivate',
    'description': '데이터베이스의 기초부터 실전 쿼리까지 배우며 실습합니다.',
    'subject': '전공',
    'progress': 3,
    'total': 8,
    'lessons': [
      {
        'title': '1차시: DB 개요',
        'items': ['DB란 무엇인가?', 'DBMS의 종류', 'RDB 기본 개념']
      },
      {
        'title': '2차시: SQL 기초',
        'items': ['SELECT 문', 'WHERE 조건', 'JOIN 기본']
      },
    ],
    'assignments': [
      {
        'title': 'ER 다이어그램 그리기',
        'status': '미제출',
        'due': '2025.04.20 23:59:59',
        'timeLeft': '3일 2시간 남음',
        'file': {'name': '', 'size': ''},
        'submitted': false,
      },
    ],
  },
  {
    'title': '파이썬 기초',
    'language': 'PYTHON',
    'class': '1-1',
    'people': '20',
    'teacher': '박지은',
    'description': '파이썬 기초 문법부터 데이터 분석 입문까지 차근차근 배워봅니다.',
    'subject': '전공',
    'progress': 5,
    'status':'unactivate',
    'total': 10,
    'lessons': [
      {
        'title': '1차시: 파이썬 소개',
        'items': ['파이썬 특징', '설치 방법', '첫 번째 코드']
      },
      {
        'title': '2차시: 변수와 자료형',
        'items': ['숫자형', '문자열', '리스트, 튜플']
      },
    ],
    'assignments': [
      {
        'title': '리스트와 딕셔너리 예제 제출',
        'status': '제출됨',
        'due': '2025.04.18 23:59:59',
        'timeLeft': '마감됨',
        'file': {'name': '2301123-김철수.py', 'size': '5.1 KB'},
        'submitted': true,
      },
    ],
  },
];
  static List<Map<String, dynamic>> getTeacherHakSubsil() {
    return List.from(teacherHakSubSil);
  }

  // 학생 제출 데이터 추가
  static List<Map<String, dynamic>> student_jechul = [
    {
      'number': '2202',
      'name': '공덕현',
      'submitted': true,
      'submittedAt': '2025.04.14 15:30:22',
      'file': '2202_공덕현_자바조사.pdf',
      'fileSize': '2.3 MB',
    },
    {
      'number': '2203',
      'name': '김민재',
      'submitted': false,
      'submittedAt': null,
      'file': null,
      'fileSize': null,
    },
    {
      'number': '2204',
      'name': '이도',
      'submitted': true,
      'submittedAt': '2025.04.14 18:45:10',
      'file': '2204_이도_자바조사.pdf',
      'fileSize': '1.8 MB',
    },
    {
      'number': '2205',
      'name': '박서연',
      'submitted': false,
      'submittedAt': null,
      'file': null,
      'fileSize': null,
    },
    {
      'number': '2206',
      'name': '정현우',
      'submitted': false,
      'submittedAt': null,
      'file': null,
      'fileSize': null,
    },
    {
      'number': '2207',
      'name': '최지은',
      'submitted': true,
      'submittedAt': '2025.04.14 20:12:35',
      'file': '2207_최지은_자바조사.pdf',
      'fileSize': '3.1 MB',
    },
    {
      'number': '2208',
      'name': '강동현',
      'submitted': true,
      'submittedAt': '2025.04.14 22:05:18',
      'file': '2208_강동현_자바조사.pdf',
      'fileSize': '2.7 MB',
    },
  ];

  static List<Map<String, dynamic>> getStudentJechul() {
    return List.from(student_jechul);
  }
}
