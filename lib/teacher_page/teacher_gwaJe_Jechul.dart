import 'package:clue/teacher_page/teacher_check.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

String formatFileSize(int bytes) {
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  } else {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
}

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
  List<bool> isEditMode = [];
  bool showTeacherCheck = false; 


  @override
  void initState() {
    super.initState();

    dataList = List.from(widget.dataList);
    if (dataList.isEmpty) {
      dataList = [
        {
          'title': '과제1',
          'status': '제출',
          'submitted': true,
          'due': '2024-06-10',
          'timeLeft': '2일 남음',
          'files': [
            {
              'name': 'sample.pdf',
              'size': '150 KB',
              'url': 'https://file-examples.com/wp-content/uploads/2017/10/file-sample_150kB.pdf',
            }
          ]
        }
      ];
    }
    isEditMode = List.generate(dataList.length, (index) => false);

    for (var data in dataList) {
      if (data['files'] == null || data['files'] is! List) {
        data['files'] = [];
      }
      data['files'].removeWhere((f) => f == null);
    }
  }


  Future<void> downloadFile(BuildContext context, String url, String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/$fileName';
      await Dio().download(url, savePath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('다운로드 완료: $fileName')),
      );
      await OpenFile.open(savePath); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('다운로드 실패: $e')),
      );
    }
  }

  void toggleSubmissionStatus(int index) {
    setState(() {

    });
  }

  Future<void> pickFile(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        dataList[index]['files'].add({
          'name': file.name,
          'size': formatFileSize(file.size),
        });
      });
    }
  }

  void removeFile(int dataIndex, int fileIndex) {
    setState(() {
      dataList[dataIndex]['files'].removeAt(fileIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 245, 245, 245),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (
          Widget child,
          Animation<double> animation,
        ) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0), // 오른쪽에서 슬라이드 인
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: showTeacherCheck
            ? TeacherCheck(
                key: const ValueKey('teacherCheck'),
                onBack: () {
                  setState(() {
                    showTeacherCheck = false;
                  });
                },
              )
            : _buildAssignmentList(context, width, height),
      ),
    );
  }

  Widget _buildAssignmentList(BuildContext context, double width, double height) {
    return ListView(
      key: const ValueKey('assignmentList'),
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
                  Text("마감일:  ${data['due']}", style: TextStyle(fontSize: width * 0.03)),
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

              ...List.generate(data['files'].length, (fileIdx) {
                final file = data['files'][fileIdx];
                return Container(
                  margin: EdgeInsets.only(bottom: 6),
                  padding: EdgeInsets.all(width * 0.03),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(width * 0.025),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.insert_drive_file_outlined, size: width * 0.05),
                      SizedBox(width: width * 0.025),

                      GestureDetector(
                        onTap: () {
                          if (file['url'] != null && file['url'].toString().isNotEmpty) {
                            downloadFile(context, file['url'], file['name']);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('다운로드 URL이 없습니다.')),
                            );
                          }
                        },
                        child: SizedBox(
                          width: width * 0.5,
                          child: Text(
                            file['name'],
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: width * 0.03,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: width * 0.02),
                      Text('(${file['size']})', overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: width * 0.025, color: Colors.grey)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => removeFile(index, fileIdx),
                        child: Icon(Icons.close, size: width * 0.045),
                      ),
                    ],
                  ),
                );
              }),
              if (isEditMode[index]) ...[
                SizedBox(height: height * 0.012),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => pickFile(index),
                    icon: Icon(Icons.attach_file),
                    label: Text('파일 추가', style: TextStyle(fontSize: width * 0.032)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[100],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width * 0.025),
                      ),
                      padding: EdgeInsets.symmetric(vertical: height * 0.012, horizontal: width * 0.04),
                    ),
                  ),
                ),
              ],
              SizedBox(height: height * 0.018),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            isEditMode[index] = !isEditMode[index];
                          });
                        },
                        label: Text(!isEditMode[index]?'내용수정':'완료', style: TextStyle(fontSize: width * 0.035)),
                        icon: Icon(Icons.edit),
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
                        onPressed: () {
                          setState(() {
                            showTeacherCheck = true;
                          });
                        },
                        label: Text('확인/채점', style: TextStyle(fontSize: width * 0.035)),
                        icon: Icon(Icons.check),
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
