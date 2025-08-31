import 'package:clue/api_client.dart';
import 'package:clue/widgets/haksubsilPage/HakSubSilSuap.dart';
import 'package:flutter/material.dart';

class Inmoonhaksubsilbarogaja extends StatelessWidget {
  final List<Map<String, dynamic>> noticeList;

  const Inmoonhaksubsilbarogaja({super.key, required this.noticeList});

  Future<Map<String, dynamic>> classRoomDetailApi(int index) async {
    final filteredList =
        noticeList.where((notice) => notice['subject'] == 'inmoon').toList();
    final api = ApiClient.instance.dio;
    final res = await api.get(
      '/api/class/${filteredList[index]['classRoomId']}/all',
    );
    final data = res.data;

    return Map<String, dynamic>.from(data);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final filteredList =
        noticeList.where((notice) => notice['subject'] == 'inmoon').toList();
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
      child: ListView.builder(
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          final notice = filteredList[index];
          return Column(
            children: [
              GestureDetector(
                onTap: () async {
                  try {
                    final detail = await classRoomDetailApi(index);
                    debugPrint(detail.toString());
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Haksubsilsuap(notice: detail),
                      ),
                    );
                  } catch (e) {
                    // 실패 시 간단히 무시하거나 스낵바 출력 가능
                    // debugPrint('classRoom load error: $e');
                  }
                },
                child: Container(
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
                            notice['classRoomId'].toString(),
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
                            notice['sort'].toString(),
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
                            notice['target'].toString(),
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
                            '사람 ${notice['studentCount']} 명',
                            style: TextStyle(fontSize: width * 0.04),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Spacer(),
                          Text(
                            '과제 보기 >',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: width * 0.04,
                            ),
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
