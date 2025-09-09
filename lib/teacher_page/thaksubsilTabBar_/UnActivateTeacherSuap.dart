import 'package:clue/teacher_page/tHakSubsilSuapTrue.dart';
import 'package:flutter/material.dart';

class Unactivateteachersuap extends StatelessWidget {
  final List<Map<String, dynamic>> teacherHakSubSil;
  final Future<void> Function()? onRefresh;

  const Unactivateteachersuap({
    super.key,
    required this.teacherHakSubSil,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final filteredList =
        teacherHakSubSil
            .where((tsuap) => tsuap['activation']==false)
            .toList();
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
                        Expanded(
                          child: Text(
                            tsuap['name'].toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: width * 0.045,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: width * 0.02),
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
                            tsuap['activation'] ? '활성화' : '비활성화',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: width * 0.008),
                    Row(
                      children: [
                        Text(
                          tsuap['sort'].toString(),
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
                          tsuap['target'].toString(),
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
                        Text('학생 ${tsuap['studentCount']} 명', style: TextStyle(fontSize: width * 0.04)),
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
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Thaksubsilsuaptrue(tsuap: tsuap),
                                ),
                              );
                              if (onRefresh != null) {
                                await onRefresh!();
                              }
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
