import 'package:clue/widgets/haksubsilPage/HakSubSilGaJa.dart';
import 'package:flutter/material.dart';

class Gwajejechul extends StatefulWidget {
  final List<Map<String, dynamic>> dataList;
  final Function(int index, bool submitted)? onSubmissionChanged;
  final Function(Map<String, dynamic>)? onCardClick;
  const Gwajejechul({
    super.key,
    required this.dataList,
    this.onSubmissionChanged,
    this.onCardClick,
  });

  @override
  State<Gwajejechul> createState() => _GwajejechulState();
}

class _GwajejechulState extends State<Gwajejechul> {
  late List<Map<String, dynamic>> dataList;

  @override
  void initState() {
    super.initState();
    // 원본 데이터를 복사하여 상태 관리
    dataList = List.from(widget.dataList);
  }

  void toggleSubmissionStatus(int index) {
    setState(() {
      dataList[index]['submitted'] = !dataList[index]['submitted'];
      dataList[index]['status'] = dataList[index]['submitted'] ? '제출됨' : '미제출';

      // 부모 위젯에 변경사항 알림
      if (widget.onSubmissionChanged != null) {
        widget.onSubmissionChanged!(index, dataList[index]['submitted']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return ListView(
      padding: EdgeInsets.symmetric(vertical: height * 0.01),
      children:
          dataList.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            return GestureDetector(
              onTap: () {
                if (widget.onCardClick != null) {
                  widget.onCardClick!(data);
                }
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: height * 0.012,
                ),
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(width * 0.04),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: width * 0.02,
                      offset: Offset(0, width * 0.01),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['title'],
                          style: TextStyle(
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.025,
                            vertical: height * 0.005,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xff86C1FF),
                              width: 1.5,
                            ),
                            color:
                                data['submitted']
                                    ? Colors.white
                                    : Color(0xff86C1FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            data['status'],
                            style: TextStyle(
                              fontSize: width * 0.03,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.012),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: width * 0.04,
                          color: Colors.grey,
                        ),
                        SizedBox(width: width * 0.015),
                        Text(
                          "마감일: ${data['due']}",
                          style: TextStyle(fontSize: width * 0.03),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.008),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: width * 0.04,
                          color: Colors.blue,
                        ),
                        SizedBox(width: width * 0.015),
                        Text(
                          data['timeLeft'],
                          style: TextStyle(
                            fontSize: width * 0.03,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.018),
                    Container(
                      padding: EdgeInsets.all(width * 0.03),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(width * 0.025),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.insert_drive_file_outlined,
                            size: width * 0.05,
                          ),
                          SizedBox(width: width * 0.025),
                          Text(
                            data['file']['name'],
                            style: TextStyle(fontSize: width * 0.03),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.018),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => toggleSubmissionStatus(index),
                        icon: Icon(Icons.upload, size: width * 0.045),
                        label: Text(
                          data['submitted'] ? "제출 취소" : "과제 제출하기",
                          style: TextStyle(fontSize: width * 0.035),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              data['submitted']
                                  ? Colors.grey[300]
                                  : const Color(0xFF86C1FF),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(width * 0.025),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: height * 0.018,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
