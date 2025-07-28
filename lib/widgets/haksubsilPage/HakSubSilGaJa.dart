import 'package:flutter/material.dart';
import 'package:clue/config/app_color.dart';

class Haksubsilgaja extends StatefulWidget {
  final Map<String, dynamic> assignment;
  final VoidCallback onClose;

  const Haksubsilgaja({
    super.key,
    required this.assignment,
    required this.onClose,
  });

  @override
  State<Haksubsilgaja> createState() => _HaksubsilgajaState();
}

void showAddClassDialog(BuildContext context) {
  final TextEditingController codeController = TextEditingController();
  final width = MediaQuery.of(context).size.width;
  final height = MediaQuery.of(context).size.height;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          width: width * 0.8,
          // height: height * 0.2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                '학습실 추가하기',
                style: TextStyle(
                  fontSize: width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * 0.01),
              TextField(
                style: TextStyle(
                  fontSize: width * 0.031,
                  color: Color(0xff666666),
                ),
                controller: codeController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  filled: true,
                  isDense: true,
                  fillColor: Color(0xffF3F3F3),
                  hintText: "학습실 코드를 입력해주세요",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
              GestureDetector(
                onTap: () => {Navigator.pop(context)},
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xffCCCCCC)),
                  ),
                  child: Center(child: Text('취소')),
                ),
              ),
              SizedBox(height: 5),
              Container(
                padding: EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.blue,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColor.blue),
                ),
                child: Center(child: Text('확인')),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _HaksubsilgajaState extends State<Haksubsilgaja> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: height * 0.006,
            horizontal: width * 0.045,
          ),
          decoration: BoxDecoration(color: Color(0xffffffff)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.025,
                      vertical: height * 0.005,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xff86C1FF), width: 1.5),
                      color:
                          widget.assignment['submitted']
                              ? Colors.white
                              : Color(0xff86C1FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.assignment['status'],
                      style: TextStyle(
                        fontSize: width * 0.03,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    iconSize: width * 0.06,
                    icon: Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                widget.assignment['title'],
                style: TextStyle(
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
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
                    "마감일: ${widget.assignment['due']}",
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
                    widget.assignment['timeLeft'],
                    style: TextStyle(
                      fontSize: width * 0.03,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.015),
              Text(
                '상세설명',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.045,
                ),
              ),
              SizedBox(height: height * 0.01),
              Text(
                '${widget.assignment['description']}',
                style: TextStyle(fontSize: width * 0.04, height: 1.6),
              ),
              SizedBox(height: height * 0.015),
              Text(
                '제출 결과물',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.045,
                ),
              ),
              SizedBox(height: height * 0.007),
              ListView.builder(
                shrinkWrap: true, // Column 안에서 사용 시 필요
                physics:
                    NeverScrollableScrollPhysics(), // SingleChildScrollView와 충돌 방지
                itemCount: widget.assignment['results'].length,
                itemBuilder:
                    (context, index) => Text(
                      '${widget.assignment['results'][index]}',
                      style: TextStyle(fontSize: width * 0.04),
                    ),
              ),
              SizedBox(height: height * 0.015),
              Text(
                '할당파일',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.045,
                ),
              ),
              SizedBox(height: height * 0.009),

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
                    Text(
                      widget.assignment['file']['name'],
                      style: TextStyle(fontSize: width * 0.03),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              SizedBox(height: height * 0.01),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color:Color(0xffCCCCCC), width: 1),
                  borderRadius: BorderRadius.circular(width * 0.025),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showAddClassDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width * 0.025),
                      ),
                      padding: EdgeInsets.symmetric(vertical: height * 0.018),
                    ),
                    child: Text(
                      "과제 업로드",
                      style: TextStyle(fontSize: width * 0.035),
                    ),
                  ),
                ),
              ),
              SizedBox(height: height*0.005,),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // toggleSubmissionStatus(index);
                  },
                  icon: Icon(Icons.upload, size: width * 0.045),
                  label: Text(
                    "과제 제출하기",
                    style: TextStyle(fontSize: width * 0.035),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF86C1FF),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * 0.025),
                    ),
                    padding: EdgeInsets.symmetric(vertical: height * 0.018),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
