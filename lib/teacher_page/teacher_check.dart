import 'package:flutter/material.dart';
import 'package:clue/config/teacher_data.dart';

class TeacherCheck extends StatefulWidget {
  final VoidCallback? onBack; 

  const TeacherCheck({super.key, this.onBack});

  @override
  State<TeacherCheck> createState() => _TeacherCheckState();
}

class _TeacherCheckState extends State<TeacherCheck> {
  String selectedStatus = '상태';
  String selectedGrade = '학년';
  String selectedClass = '반';
  String searchText = '';
  List<Map<String, dynamic>> filteredStudents = [];

  @override
  void initState() {
    super.initState();
    filteredStudents = TeacherData.getStudentJechul();
  }

  void filterStudents() {
    setState(() {
      filteredStudents =
          TeacherData.getStudentJechul().where((student) {
            final name = student['name'].toString().toLowerCase();
            final number = student['number'].toString().toLowerCase();
            final searchLower = searchText.toLowerCase();
            final isSubmitted = student['submitted'] as bool;
            
 
            final matchesSearch = name.contains(searchLower) || number.contains(searchLower);
            

            bool matchesStatus = true;
            if (selectedStatus == '제출완료') {
              matchesStatus = isSubmitted;
            } else if (selectedStatus == '미제출') {
              matchesStatus = !isSubmitted;
            }

            
            return matchesSearch && matchesStatus;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '자바에 대해서 조사하기',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: width * 0.055,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (widget.onBack != null) {
                        widget.onBack!();
                      }
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.black,
                      size: width * 0.06,
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.01),

              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: width * 0.04,
                    color: Colors.grey,
                  ),
                  SizedBox(width: width * 0.01),
                  Text(
                    '마감일: 2025.04.15 23:59:59',
                    style: TextStyle(
                      fontSize: width * 0.035,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.02),


              _buildDropdown(
                selectedStatus,
                ['상태', '제출완료', '미제출'],
                (val) {
                  setState(() {
                    selectedStatus = val!;
                  });
                  filterStudents(); 
                },
              ),
              SizedBox(height: height * 0.02),


              TextField(
                decoration: InputDecoration(
                  hintText: '찾으시는 학생을 검색해주세요.',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: width * 0.035,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: EdgeInsets.symmetric(
                    vertical: height * 0.015,
                    horizontal: width * 0.03,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                  filterStudents();
                },
              ),
              SizedBox(height: height * 0.02),


              Expanded(
                child: ListView.separated(
                  itemCount: filteredStudents.length,
                  separatorBuilder:
                      (_, __) => Divider(height: 1, color: Colors.grey[200]),
                  itemBuilder: (context, idx) {
                    final student = filteredStudents[idx];
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: height * 0.015),
                      child: Row(
                        children: [

                          SizedBox(
                            width: width * 0.15,
                            child: Text(
                              student['number'],
                              style: TextStyle(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),


                          SizedBox(
                            width: width * 0.2,
                            child: Text(
                              student['name'],
                              style: TextStyle(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),


                          Expanded(
                            child: Text(
                              student['submitted'] ? '제출완료' : '미제출',
                              style: TextStyle(
                                color:
                                    student['submitted']
                                        ? Color(0xFF1CC078)
                                        : Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: width * 0.04,
                              ),
                            ),
                          ),


                          GestureDetector(
                            onTap: () {

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${student['name']} 학생 채점하기'),
                                ),
                              );
                            },
                            child: Text(
                              '채점하기',
                              style: TextStyle(
                                color: Color(0xFF3A7BFF),
                                fontWeight: FontWeight.w500,
                                fontSize: width * 0.04,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      child: DropdownButton<String>(
        value: value,
        items:
            items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                )
                .toList(),
        onChanged: onChanged,
        underline: SizedBox(),
        isDense: true,
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
        dropdownColor: Colors.white,
      ),
    );
  }
}
