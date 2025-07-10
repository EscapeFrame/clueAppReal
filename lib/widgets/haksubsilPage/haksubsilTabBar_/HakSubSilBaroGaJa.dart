import 'package:clue/widgets/haksubsilPage/HakSubSilSuap.dart';
import 'package:flutter/material.dart';

class Haksubsilbarogaja extends StatelessWidget {
  final List<Map<String, dynamic>> noticeList;

  const Haksubsilbarogaja({super.key, required this.noticeList});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
      child: ListView.builder(
        itemCount: noticeList.length,
        itemBuilder: (context, index) {
          final notice = noticeList[index];
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Haksubsilsuap(notice: notice),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(width * 0.045, width * 0.045, width * 0.055, width * 0.037),
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
                            notice['title'].toString(),
                            style: TextStyle(
                              fontSize: width * 0.045,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: width * 0.02),
                          
                        ],
                      ),
                      SizedBox(height: width * 0.008),
                      Row(
                        children: [
                          Text(
                            notice['language'].toString(),
                            style: TextStyle(
                              fontSize: width * 0.04,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(width: width * 0.01),
                          Text('|', style: TextStyle(color: Colors.grey, fontSize: width * 0.035)),
                          SizedBox(width: width * 0.01),
                          Text(
                            notice['class'].toString(),
                            style: TextStyle(fontSize: width * 0.04, color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: width * 0.008),
                      Row(
                        children: [
                          const Icon(Icons.people, color: Colors.grey),
                          const SizedBox(width: 10),
                           Text('사람 ${notice['people']} 명',style: TextStyle(fontSize: width * 0.04,)),
                        ],
                      ),
                      const SizedBox(height: 20),
                       Row(
                        children: [
                          Spacer(),
                          Text(
                            '과제 보기 >',
                            style: TextStyle(color: Colors.grey, fontSize: width * 0.04,),
                          ),
                        ],
                      ),
                    ],
                  ),
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