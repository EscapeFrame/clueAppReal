//학습실 채팅 허용 주석 나중에 해제하기. 잊지 말자 
import 'package:clue/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Thaksubsilsetting extends StatefulWidget {
  final Map<String, dynamic> tsuap;
  final void Function(Map<String, dynamic> updated) onApply;

  const Thaksubsilsetting({
    super.key,
    required this.tsuap,
    required this.onApply,
  });

  @override
  State<Thaksubsilsetting> createState() => _ThaksubsilsettingState();
}

class _ThaksubsilsettingState extends State<Thaksubsilsetting> {
  late final TextEditingController _titleController;
  late final TextEditingController _languageController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _gradeController;
  late final TextEditingController _banController;
  late bool _isActivated;
  late bool _isChatAllowed;

  @override
  void initState() {
    super.initState();
    debugPrint('[Thaksubsilsetting] initState with tsuap: ${widget.tsuap}');
    final String targetValue = (widget.tsuap['target'] ?? '').toString();
    final List<String> targetParts = targetValue.split('-');

    _titleController = TextEditingController(
      text: (widget.tsuap['name'] ?? widget.tsuap['title'] ?? '').toString(),
    );
    _languageController = TextEditingController(
      text: (widget.tsuap['sort'] ?? '').toString(),
    );
    _descriptionController = TextEditingController(
      text: (widget.tsuap['description'] ?? '').toString(),
    );
    _gradeController = TextEditingController(
      text: targetParts.isNotEmpty ? targetParts.first : '',
    );
    _banController = TextEditingController(
      text: targetParts.length > 1 ? targetParts[1] : '',
    );

    _isActivated = (widget.tsuap['activation'] == true) || (widget.tsuap['isActivation'] == true);
    _isChatAllowed = (widget.tsuap['chatAllowed'] == true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _languageController.dispose();
    _descriptionController.dispose();
    _gradeController.dispose();
    _banController.dispose();
    super.dispose();
  }

  void _updateClassFromParts({String? grade, String? ban}) {
    final String nextGrade = grade ?? _gradeController.text;
    final String nextBan = ban ?? _banController.text;

    final String _ = [nextGrade, nextBan].where((e) => e.isNotEmpty).join('-');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final double inputHeight = height * 0.045;
    final double inputFontSize = width * 0.038;
    final double vPad = ((inputHeight - inputFontSize) / 2);

    return SingleChildScrollView(
      child: Container(
        color: const Color(0xffffffff),
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.06,
          vertical: height * 0.015,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '기본정보',
              style: TextStyle(
                fontSize: width * 0.065,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '학습실에 기본 정보를 설정합니다',
              style: TextStyle(fontSize: width * 0.03, color: Colors.black54),
            ),
            SizedBox(height: height * 0.025),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '학습실 이름',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff578FCA)),
                ),
              ),
              style: TextStyle(fontSize: inputFontSize),
            ),
            SizedBox(height: height * 0.02),
            TextFormField(
              controller: _languageController,
              decoration: const InputDecoration(
                labelText: '분류(sort)',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff578FCA)),
                ),
              ),
              style: TextStyle(fontSize: inputFontSize),
            ),
            SizedBox(height: height * 0.02),
            TextFormField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: '설명',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff578FCA)),
                ),
              ),
              style: TextStyle(fontSize: width * 0.038),
            ),
            SizedBox(height: height * 0.02),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _gradeController,
                        decoration: const InputDecoration(
                          labelText: '학년',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff578FCA)),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        style: TextStyle(fontSize: inputFontSize),
                        onChanged: (v) => _updateClassFromParts(grade: v),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: width * 0.02),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _banController,
                        decoration: const InputDecoration(
                          labelText: '반',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff578FCA)),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        style: TextStyle(fontSize: inputFontSize),
                        onChanged: (v) => _updateClassFromParts(ban: v),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: height * 0.05),
            Text(
              '학습실 설정',
              style: TextStyle(
                fontSize: width * 0.065,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '학습실의 기능과 접근 권한을 설정합니다',
              style: TextStyle(fontSize: width * 0.03, color: Colors.black54),
            ),

            SizedBox(height: height * 0.03),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '학습실 활성화',
                        style: GoogleFonts.roboto(
                          color: Colors.black,
                          fontSize: width * 0.048,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '학습실을 활성화하면 학생들이 접근할 수 있습니다',
                        style: TextStyle(
                          fontSize: width * 0.028,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: width * 0.002,
                  child: Switch(
                    activeTrackColor: const Color(0xff578FCA),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xffcccccc),
                    value: _isActivated,

                    onChanged: (v) => setState(() => _isActivated = v),
                  ),
                ),
              ],
            ),

            SizedBox(height: height * 0.025),

            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.end,
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     SizedBox(
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text(
            //             '채팅 허용',
            //             style: TextStyle(
            //               color: Colors.black,
            //               fontSize: width * 0.048,
            //               fontWeight: FontWeight.w500,
            //             ),
            //           ),
            //           Text(
            //             '학생들이 학습실 내에서 채팅할 수 있도록 허용합니다',
            //             style: TextStyle(
            //               fontSize: width * 0.028,
            //               color: Colors.black87,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //     Transform.scale(
            //       scale: width * 0.002,
            //       child: Switch(
            //         activeTrackColor: const Color(0xff578FCA),
            //         inactiveThumbColor: Colors.white,
            //         inactiveTrackColor: const Color(0xffcccccc),
            //         value: _isChatAllowed,

            //         onChanged: (v) => setState(() => _isChatAllowed = v),
            //       ),
            //     ),
            //   ],
            // ),
            SizedBox(height: height * 0.015),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '학습실 삭제하기',
                        style: TextStyle(
                          fontSize: width * 0.048,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '학습실을 삭제하면 모든 데이터가 영구적으로 삭제됩니다',
                        style: TextStyle(
                          fontSize: width * 0.028,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffE0E0E0),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.04,
                      vertical: height * 0.012,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('삭제하기'),
                ),
              ],
            ),
            SizedBox(height: height * 0.04),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff86C1FF),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04,
                    vertical: height * 0.016,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  final name = _titleController.text.trim();
                  final sort = _languageController.text.trim();
                  final description = _descriptionController.text.trim();
                  final target = [
                    _gradeController.text.trim(),
                    _banController.text.trim(),
                  ].where((e) => e.isNotEmpty).join('-');

                  final body = {
                    'name': name,
                    'description': description,
                    'sort': sort,
                    'target': target,
                    'isActivation': _isActivated,
                  };

                  try {
                    final api = ApiClient.instance.dio;
                    final id = (widget.tsuap['classRoomId'] ?? '').toString();
                    if (id.isEmpty) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('학습실 ID를 찾을 수 없습니다.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    final res = await api.patch('/api/class/$id', data: body);
                    if (res.statusCode == 200 || res.statusCode == 204) {
                      widget.onApply({
                        'name': name,
                        'description': description,
                        'sort': sort,
                        'target': target,
                        'activation': _isActivated,
                      });
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('저장되었습니다.'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    } else {
                      if (!mounted) return;
                      debugPrint('[Thaksubsilsetting] Save failed: ${res.statusCode} ${res.data}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('저장 실패: ${res.statusCode}'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } on DioException catch (e) {
                    if (!mounted) return;
                    final code = e.response?.statusCode;
                    final msg = e.response?.data?.toString() ?? e.message ?? 'unknown error';
                    debugPrint('[Thaksubsilsetting] DioException: $code $msg');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('오류: $code $msg'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('오류: $e'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Text(
                  '변경사항 저장',
                  style: TextStyle(fontSize: width * 0.04),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
