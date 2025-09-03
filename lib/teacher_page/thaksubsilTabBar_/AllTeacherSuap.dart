import 'package:clue/teacher_page/tHakSubsilSuapTrue.dart';
import 'package:flutter/material.dart';

class Allteachersuap extends StatelessWidget {
  final List<Map<String, dynamic>> teacherHakSubSil;

  const Allteachersuap({super.key, required this.teacherHakSubSil});

  @override
  Widget build(BuildContext context) {
    final filteredList = teacherHakSubSil.toList();
    final width = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
      child: ListView.builder(
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          final tsuap = filteredList[index];
          return Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(
                  width * 0.045,
                  width * 0.045,
                  width * 0.055,
                  width * 0.037,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width * 0.025),
                  border: Border.all(color: Colors.grey, width: 0.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          tsuap['title'].toString(),
                          style: TextStyle(
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xff86C1FF),
                          ),

                          child: Text(
                            tsuap['status'] == 'activate' ? '활성화' : '비활성화',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: width * 0.008),
                    Row(
                      children: [
                        Text(
                          tsuap['language'].toString(),
                          style: TextStyle(
                            fontSize: width * 0.04,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(width: width * 0.01),
                        Text(
                          '|',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: width * 0.035,
                          ),
                        ),
                        SizedBox(width: width * 0.01),
                        Text(
                          tsuap['class'].toString(),
                          style: TextStyle(
                            fontSize: width * 0.04,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: width * 0.008),
                    Row(
                      children: [
                        const Icon(Icons.people, color: Colors.grey),
                        const SizedBox(width: 10),
                        Text(
                          '학생 ${tsuap['people']} 명',
                          style: TextStyle(fontSize: width * 0.04),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3,
                              vertical: 4,
                            ),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Color(0xff86C1FF),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '관리',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: width * 0.037,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: width * 0.025),
                        Expanded(
                          child: GestureDetector(
                            onTap:
                                () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              Thaksubsilsuaptrue(tsuap: tsuap),
                                    ),
                                  ),
                                },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 3,
                                vertical: 4,
                              ),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xff86C1FF),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Color(0xff86C1FF),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '학습실보기',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: width * 0.037,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: width * 0.02),
            ],
          );
        },
      ),
    );
  }
}
