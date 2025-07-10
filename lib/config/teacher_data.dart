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

  static List<Map<String, dynamic>> getAssignmentList() {
    return List.from(assignmentList);
  }

  static List<Map<String, dynamic>> teacherHakSubSil = [
    {
      'title': '자바를 자바라!',
      'subject': 'JAVA',
      'class': '2-2',
      'students': 16,
      'status': 'activate',
      'description': '학생 16 명',
    },
    {
      'title': '자바를 자바라!',
      'subject': 'JAVA',
      'class': '2학년 임베디드SW과 SW 트랙',
      'students': 15,
      'status': 'unactivate',
      'description': '학생 15 명',
    },
    {
      'title': 'DB',
      'subject': 'DB',
      'class': '1-4',
      'students': 18,
      'status': 'unactivate',
      'description': '학생 18 명',
    },
  ];
  static List<Map<String, dynamic>> getTeacherHakSubsil() {
    return List.from(teacherHakSubSil);
  }
}
