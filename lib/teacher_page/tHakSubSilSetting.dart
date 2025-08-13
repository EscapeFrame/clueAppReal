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
    final String classValue = (widget.tsuap['class'] ?? '').toString();
    final List<String> classParts = classValue.split('-');

    _titleController = TextEditingController(
      text: widget.tsuap['title']?.toString() ?? '',
    );
    _languageController = TextEditingController(
      text: widget.tsuap['language']?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.tsuap['description']?.toString() ?? '',
    );
    _gradeController = TextEditingController(
      text: classParts.isNotEmpty ? classParts.first : '',
    );
    _banController = TextEditingController(
      text: classParts.length > 1 ? classParts[1] : '',
    );

    _isActivated = (widget.tsuap['status']?.toString() == 'activate');
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
            Text('학습실 이름', style: TextStyle(fontSize: width * 0.042)),
            SizedBox(height: height * 0.013),
            Container(
              height: height * 0.045,
              decoration: BoxDecoration(
                boxShadow: null,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Color(0xffCCCCCC)),
              ),
              child: TextField(
                controller: _titleController,
                textAlignVertical: TextAlignVertical.center,
                maxLines: 1,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: width * 0.03,
                    vertical: vPad,
                  ),
                ),
                style: TextStyle(fontSize: inputFontSize),
              ),
            ),
            SizedBox(height: height * 0.02),
            Text('과목', style: TextStyle(fontSize: width * 0.042)),
            SizedBox(height: height * 0.013),
            Container(
              height: height * 0.045,
              decoration: BoxDecoration(
                boxShadow: null,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Color(0xffCCCCCC)),
              ),
              child: TextField(
                controller: _languageController,
                textAlignVertical: TextAlignVertical.center,
                maxLines: 1,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: width * 0.03,
                    vertical: vPad,
                  ),
                ),
                style: TextStyle(fontSize: inputFontSize),
              ),
            ),
            SizedBox(height: height * 0.02),
            Text('설명', style: TextStyle(fontSize: width * 0.042)),
            SizedBox(height: height * 0.013),
            Container(
              height: height * 0.12,
              decoration: BoxDecoration(
                boxShadow: null,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Color(0xffCCCCCC)),
              ),
              child: TextField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 4,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: width * 0.03,
                    vertical: height * 0.01,
                  ),
                ),
                style: TextStyle(fontSize: width * 0.038),
              ),
            ),
            SizedBox(height: height * 0.02),
            Row(
              children: [
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('학년', style: TextStyle(fontSize: width * 0.042)),
                        SizedBox(height: height * 0.013),
                        Container(
                          height: height * 0.045,
                          decoration: BoxDecoration(
                            boxShadow: null,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Color(0xffCCCCCC)),
                          ),
                          child: TextField(
                            controller: _gradeController,
                            textAlignVertical: TextAlignVertical.center,
                            maxLines: 1,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: width * 0.03,
                                vertical: vPad,
                              ),
                            ),
                            style: TextStyle(fontSize: inputFontSize),
                            onChanged: (v) => _updateClassFromParts(grade: v),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: width * 0.02),
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('반', style: TextStyle(fontSize: width * 0.042)),
                        SizedBox(height: height * 0.013),
                        Container(
                          height: height * 0.045,
                          decoration: BoxDecoration(
                            boxShadow: null,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Color(0xffCCCCCC)),
                          ),
                          child: TextField(
                            controller: _banController,
                            textAlignVertical: TextAlignVertical.center,
                            maxLines: 1,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: width * 0.03,
                                vertical: vPad,
                              ),
                            ),
                            style: TextStyle(fontSize: inputFontSize),
                            onChanged: (v) => _updateClassFromParts(ban: v),
                          ),
                        ),
                      ],
                    ),
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
              children: [
                Expanded(
                  child: Text(
                    '학습실 활성화',
                    style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontSize: width * 0.048,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                Transform.scale(
                  scale: width * 0.002,
                  child: Switch(
                    activeTrackColor: const Color(0xff578FCA),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xffcccccc),
                    value: _isActivated,
                    activeColor: const Color(0xff86C1FF),
                    onChanged: (v) => setState(() => _isActivated = v),
                  ),
                ),
              ],
            ),
            Text(
              '학습실을 활성화하면 학생들이 접근할 수 있습니다',
              style: TextStyle(fontSize: width * 0.028, color: Colors.black87),
            ),
            SizedBox(height: height * 0.025),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '채팅 허용',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: width * 0.048,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                Transform.scale(
                  scale: width * 0.002,
                  child: Switch(
                    activeTrackColor: const Color(0xff578FCA),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xffcccccc),
                    value: _isChatAllowed,
                    activeColor: const Color(0xff86C1FF),
                    onChanged: (v) => setState(() => _isChatAllowed = v),
                  ),
                ),
              ],
            ),
            Text(
              '학생들이 학습실 내에서 채팅할 수 있도록 허용합니다',
              style: TextStyle(fontSize: width * 0.028, color: Colors.black87),
            ),
            SizedBox(height: height*0.07,),

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
                onPressed: () {
                  final Map<String, dynamic> updated = {
                    'title': _titleController.text,
                    'language': _languageController.text,
                    'description': _descriptionController.text,
                    'class': [
                      _gradeController.text,
                      _banController.text,
                    ].where((e) => e.isNotEmpty).join('-'),
                    'status': _isActivated ? 'activate' : 'unactivate',
                    'chatAllowed': _isChatAllowed,
                  };
                  widget.onApply(updated);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('저장되었습니다.'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 1),
                    ),
                  );
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
