import 'package:clue/api_client.dart';
import 'package:clue/config/app_color.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

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

Future<void> downloadFile(
  BuildContext context,
  String url,
  String fileName,
) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/$fileName';
    await Dio().download(url, savePath);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('다운로드 완료: $fileName')));
    await OpenFile.open(savePath); // 다운로드 후 자동으로 파일 열기
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('다운로드 실패: $e')));
  }
}

Future<PlatformFile?> pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    // 선택된 파일 정보
    PlatformFile file = result.files.first;

    print('파일명: ${file.name}');
    print('크기: ${file.size} bytes');
    print('경로: ${file.path}');

    return file;
  } else {
    print('사용자가 파일 선택을 취소함');
    return null;
  }
}

void showAddClassDialog(
  BuildContext context,
  Function(PlatformFile) onFileSelected,
) {
  final width = MediaQuery.of(context).size.width;
  final height = MediaQuery.of(context).size.height;
  PlatformFile? selectedFile;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              width: width * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '파일 제출하기',
                    style: TextStyle(
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: height * 0.01),

                  GestureDetector(
                    onTap: () async {
                      PlatformFile? file = await pickFile();
                      if (file != null) {
                        setState(() {
                          selectedFile = file;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          if (selectedFile != null) ...[
                            Icon(
                              Icons.insert_drive_file_outlined,
                              size: width * 0.09,
                              color: Colors.blue,
                            ),
                            SizedBox(height: 8),
                            Text(
                              selectedFile!.name,
                              style: TextStyle(
                                fontSize: width * 0.03,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${(selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                              style: TextStyle(
                                fontSize: width * 0.025,
                                color: Colors.grey,
                              ),
                            ),
                          ] else ...[
                            Icon(
                              Icons.upload_file,
                              size: width * 0.09,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              '화면을 클릭하여 업로드하세요',
                              style: TextStyle(fontSize: width * 0.03),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Color(0xffCCCCCC)),
                            ),
                            child: Center(child: Text('취소')),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (selectedFile != null) {
                              onFileSelected(selectedFile!);
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color:
                                  selectedFile != null
                                      ? AppColor.blue
                                      : Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    selectedFile != null
                                        ? AppColor.blue
                                        : Colors.grey,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '확인',
                                style: TextStyle(
                                  color:
                                      selectedFile != null
                                          ? Colors.white
                                          : Colors.grey[400],
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
          );
        },
      );
    },
  );
}

class _HaksubsilgajaState extends State<Haksubsilgaja> {
  bool loading = true;
  String? error;
  Map<String, dynamic>? detail;
  List<PlatformFile> uploadedFiles = [];

  // assignment의 files에서 파일을 삭제하는 함수 추가
  void removeFile(int fileIndex) {
    setState(() {
      widget.assignment['files'].removeAt(fileIndex);
    });
  }

  // 업로드된 파일을 추가하는 함수
  void addUploadedFile(PlatformFile file) {
    setState(() {
      uploadedFiles.add(file);
    });
  }

  // 업로드된 파일을 삭제하는 함수
  void removeUploadedFile(int index) {
    setState(() {
      uploadedFiles.removeAt(index);
    });
  }

  String? _assignmentIdStr() {
    final cand = [
      widget.assignment['assignmentId'],
      widget.assignment['id'],
      widget.assignment['assignment_id'],
    ];
    for (final v in cand) {
      final s = v?.toString();
      if (s != null && s.isNotEmpty) return s;
    }
    return null;
  }

  String _fmtSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }

  Future<void> _loadDetail(String id) async {
    try {
      final dio = ApiClient.instance.dio;
      final res = await dio.get('/api/assignments/$id');
      if (!mounted) return;
      if (res.statusCode == 200 && res.data is Map) {
        setState(() {
          detail = Map<String, dynamic>.from(res.data as Map);
          loading = false;
        });
      } else {
        setState(() {
          error = '상세 조회 실패(${res.statusCode})';
          loading = false;
        });
      }
      debugPrint('과제 상세: ${res.data}');
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        error = '상세 오류: ${e.message}';
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = '상세 예외: $e';
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final idStr = _assignmentIdStr();
    if (idStr != null) {
      _loadDetail(idStr);
    } else {
      loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
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
                (detail?['title'] ?? widget.assignment['title'] ?? '')
                    .toString(),
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
                    "마감일: ${(detail?['endDate'] ?? widget.assignment['due'] ?? '').toString().split('T').first}",
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
              SizedBox(height: height * 0.03),

              SizedBox(height: height * 0.015),

              // 첨부파일 (AssignmentAttachments)
              if ((detail?['AssignmentAttachments'] as List?)?.isNotEmpty ==
                  true) ...[
                Text(
                  '첨부파일',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.045,
                  ),
                ),
                SizedBox(height: height * 0.009),
                ...List<Map<String, dynamic>>.from(
                  (detail?['AssignmentAttachments'] as List).map(
                    (e) => Map<String, dynamic>.from(e as Map),
                  ),
                ).map((att) {
                  final name = (att['originalFileName'] ?? '').toString();
                  final size =
                      att['size'] is int
                          ? att['size'] as int
                          : int.tryParse('${att['size'] ?? 0}') ?? 0;
                  return Container(
                    margin: EdgeInsets.only(bottom: 6),
                    padding: EdgeInsets.all(width * 0.03),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(width * 0.025),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file_outlined),
                        SizedBox(width: width * 0.025),
                        Expanded(
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: width * 0.03),
                          ),
                        ),
                        SizedBox(width: width * 0.02),
                        Text(
                          '(${_fmtSize(size)})',
                          style: TextStyle(
                            fontSize: width * 0.025,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: height * 0.015),
              ]
              // 첨부파일 (xAssignmentResponseDtos) – AssignmentAttachments가 비어있을 때 대체 표시
              else if ((detail?['xAssignmentResponseDtos'] as List?)
                      ?.isNotEmpty ==
                  true) ...[
                Text(
                  '할당된 파일',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.045,
                  ),
                ),
                SizedBox(height: height * 0.009),
                ...List<Map<String, dynamic>>.from(
                  (detail?['xAssignmentResponseDtos'] as List).map(
                    (e) => Map<String, dynamic>.from(e as Map),
                  ),
                ).map((att) {
                  final name = (att['originalFileName'] ?? '').toString();
                  final size =
                      att['size'] is int
                          ? att['size'] as int
                          : int.tryParse('${att['size'] ?? 0}') ?? 0;
                  return Container(
                    margin: EdgeInsets.only(bottom: 6),
                    padding: EdgeInsets.all(width * 0.03),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(width * 0.025),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file_outlined),
                        SizedBox(width: width * 0.025),
                        Expanded(
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: width * 0.03),
                          ),
                        ),
                        SizedBox(width: width * 0.02),
                        Text(
                          '(${_fmtSize(size)})',
                          style: TextStyle(
                            fontSize: width * 0.025,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: height * 0.015),
              ],

              SizedBox(height: height * 0.007),
              widget.assignment['results'] != null
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '제출 결과물',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.045,
                        ),
                      ),
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
                    ],
                  )
                  : SizedBox(width: width * 0.00001),

             

              SizedBox(height: height * 0.015),
              // 업로드된 파일들 표시
              if (uploadedFiles.isNotEmpty) ...[
                SizedBox(height: height * 0.015),
                Text(
                  '업로드된 파일',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.045,
                  ),
                ),
                SizedBox(height: height * 0.009),
                ...List.generate(uploadedFiles.length, (index) {
                  final file = uploadedFiles[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 6),
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
                        Expanded(
                          child: Text(
                            file.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: width * 0.03),
                          ),
                        ),
                        SizedBox(width: width * 0.02),
                        Text(
                          '(${(file.size / 1024).toStringAsFixed(1)} KB)',
                          style: TextStyle(
                            fontSize: width * 0.025,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(width: width * 0.02),
                        GestureDetector(
                          onTap: () => removeUploadedFile(index),
                          child: Icon(Icons.close, size: width * 0.045),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              SizedBox(height: height * 0.03),
              Text(
                '상세설명',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.045,
                ),
              ),
              SizedBox(height: height * 0.01),
              Text(
                (detail?['content'] ?? widget.assignment['description'] ?? '')
                    .toString(),
                style: TextStyle(fontSize: width * 0.04, height: 1.6),
              ),
              SizedBox(height: height * 0.05),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xffCCCCCC), width: 0.7),
                  borderRadius: BorderRadius.circular(width * 0.025),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showAddClassDialog(context, addUploadedFile);
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
              SizedBox(height: height * 0.005),
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
              SizedBox(height: height * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
