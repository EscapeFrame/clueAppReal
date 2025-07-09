import 'package:flutter/material.dart';

class TeacherGwajeJechul extends StatefulWidget {
  final List<Map<String, dynamic>> dataList;
  final Function(int index, bool submitted)? onSubmissionChanged;

  const TeacherGwajeJechul({
    super.key, 
    required this.dataList,
    this.onSubmissionChanged,
  });

  @override
  State<TeacherGwajeJechul> createState() => TeacherGwajeJechulState();
}

class TeacherGwajeJechulState extends State<TeacherGwajeJechul> {
  late List<Map<String, dynamic>> dataList;

  @override
  void initState() {
    super.initState();
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
      children: dataList.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.012),
          padding: EdgeInsets.all(width * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(width * 0.04),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: width * 0.02,
                offset: Offset(0, width * 0.01),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(data['title'],
                      style: TextStyle(fontSize: width * 0.045, fontWeight: FontWeight.bold)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.025, vertical: height * 0.005),
                    decoration: BoxDecoration(
                      color: data['submitted'] ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(width * 0.05),
                    ),
                    child: Text(
                      data['status'],
                      style: TextStyle(
                        fontSize: width * 0.03,
                        color: data['submitted'] ? Colors.blue : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.012),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: width * 0.04, color: Colors.grey),
                  SizedBox(width: width * 0.015),
                  Text("마감일: ${data['due']}", style: TextStyle(fontSize: width * 0.03)),
                ],
              ),
              SizedBox(height: height * 0.008),
              Row(
                children: [
                  Icon(Icons.access_time, size: width * 0.04, color: Colors.blue),
                  SizedBox(width: width * 0.015),
                  Text(data['timeLeft'], style: TextStyle(fontSize: width * 0.03, color: Colors.blue)),
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
                    Icon(Icons.insert_drive_file_outlined, size: width * 0.05),
                    SizedBox(width: width * 0.025),
                    Text(data['file']['name'], style: TextStyle(fontSize: width * 0.03)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {},
                      child: Icon(Icons.close, size: width * 0.045),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.018),
              Row(
                // mainAxisAlignment: MainAxisAlignment.,
                children: [
                  Expanded(
                    
                    child: SizedBox(

                      child: ElevatedButton.icon(
                        onPressed: () => toggleSubmissionStatus(index),

                        label: Text('내용수정', style: TextStyle(fontSize: width * 0.035)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:Colors.grey[300],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(width * 0.025),
                          ),
                          padding: EdgeInsets.symmetric(vertical: height * 0.018, ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width:width*0.03),
                  Expanded(
                    child: SizedBox(

                      child: ElevatedButton.icon(
                        onPressed: () => toggleSubmissionStatus(index),
                        
                        label: Text('확인/채점', style: TextStyle(fontSize: width * 0.035)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:  const Color(0xFFB9DCFF),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(width * 0.025),
                          ),
                          padding: EdgeInsets.symmetric(vertical: height * 0.018,),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}