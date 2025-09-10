import 'package:clue/api_client.dart';
import 'package:clue/config/app_color.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class Thaksubsilgaja extends StatefulWidget {
  final Map<String, dynamic> assignment;
  final VoidCallback onClose;

  const Thaksubsilgaja({
    super.key,
    required this.assignment,
    required this.onClose,
  });

  @override
  State<Thaksubsilgaja> createState() => _ThaksubsilgajaState();
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

Future<Map<String, dynamic>?> assignmentsDetailApi(String assignmentId) async {
  try {
    final api = ApiClient.instance.dio;
    final res = await api.get('/api/assignments/$assignmentId');
    debugPrint('과제 상세 정보: ${res.data}');
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(res.data as Map);
    }
  } on DioException catch (e) {
    debugPrint('과제 상세 정보 가져오기 중 오류 발생: ${e.response?.data}');
  } catch (e) {
    debugPrint('과제 상세 정보 가져오기 중 오류 발생: $e');
  }
  return null;
}

class _ThaksubsilgajaState extends State<Thaksubsilgaja> {
  bool loading = true;
  String? error;
  Map<String, dynamic>? detail;

  DateTime? _parseDate(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      return DateTime.parse(s.replaceAll(' ', 'T'));
    } catch (_) {
      return null;
    }
  }

  String _formatDue(DateTime? dt) =>
      dt == null ? '-' : dt.toIso8601String().split('T').first;

  String _formatTimeLeft(DateTime? end) {
    if (end == null) return '-';
    final diff = end.difference(DateTime.now());
    if (diff.isNegative) return '마감됨';
    final d = diff.inDays, h = diff.inHours % 24, m = diff.inMinutes % 60;
    if (d > 0) return '$d일 $h시간 남음';
    if (diff.inHours > 0) return '${diff.inHours}시간 $m분 남음';
    return '$m분 남음';
  }

  String? _assignmentIdStr() {
    final cands = [
      detail?['assignmentId'],
      widget.assignment['assignmentId'],
      widget.assignment['id'],
      widget.assignment['assignment_id'],
    ];
    for (final v in cands) {
      final s = v?.toString();
      if (s != null && s.isNotEmpty) return s;
    }
    return null;
  }

  Future<void> _loadDetail(String idPath) async {
    setState(() {
      loading = true;
      error = null;
    });
    final data = await assignmentsDetailApi(idPath);
    if (!mounted) return;
    if (data != null) {
      setState(() {
        detail = data;
        loading = false;
      });
    } else {
      setState(() {
        error = '과제 상세 정보를 불러오지 못했습니다.';
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // 페이지 진입 시 과제 상세 조회 호출 (문자열 ID 허용)
    final idStr = _assignmentIdStr();
    if (idStr != null) {
      _loadDetail(idStr);
    } else {
      debugPrint('assignmentId가 없어 상세 조회를 건너뜀: ${widget.assignment}');
      loading = false;
    }
  }

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

  Future<void> _uploadFile(PlatformFile file) async {
    final idStr = _assignmentIdStr();
    try {
      final mf = await MultipartFile.fromFile(file.path!, filename: file.name);
      //파일 가져오기

      final form = FormData.fromMap({'files': mf});
      await ApiClient.instance.dio.post(
        '/api/assignments/$idStr/file',
        data: form,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('업로드 완료')));
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('업로드 실패: ${e.message}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('업로드 예외: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final title =
        (detail?['title'] ?? widget.assignment['title'])?.toString() ?? '';
    final content =
        (detail?['content'] ??
                widget.assignment['content'] ??
                widget.assignment['description'] ??
                '')
            .toString();
    final endDateStr =
        (detail?['endDate'] ?? widget.assignment['endDate'])?.toString();
    final end = _parseDate(endDateStr);
    final due = _formatDue(end);
    final timeLeft = _formatTimeLeft(end);

    return Scaffold(
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: height * 0.006,
                    horizontal: width * 0.045,
                  ),
                  decoration: BoxDecoration(color: Color(0xffffffff)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (error != null) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            error!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: width * 0.032,
                            ),
                          ),
                        ),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                        title,
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
                            "마감일: $due",
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
                            timeLeft,
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
                        content,
                        style: TextStyle(fontSize: width * 0.04, height: 1.6),
                      ),
                      SizedBox(height: height * 0.015),

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
                          '할당 파일',
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
                              borderRadius: BorderRadius.circular(
                                width * 0.025,
                              ),
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
                      SizedBox(height: height * 0.05),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xffCCCCCC),
                            width: 0.7,
                          ),
                          borderRadius: BorderRadius.circular(width * 0.025),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              showAddClassDialog(context, _uploadFile);
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  width * 0.025,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: height * 0.018,
                              ),
                            ),
                            child: Text(
                              "파일 업로드",
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
                            showAddClassDialog(context, _uploadFile);
                          },
                          // icon: Icon(Icons.upload, size: width * 0.045),
                          label: Text(
                            "저장",
                            style: TextStyle(fontSize: width * 0.035),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF86C1FF),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                width * 0.025,
                              ),
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
              ),
    );
  }
}
