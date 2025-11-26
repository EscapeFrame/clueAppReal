import 'package:clue/api_client.dart';
import 'package:clue/widgets/common/app_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Thaksubsilsetting extends StatefulWidget {
  final Map<String, dynamic> tsuap;
  final void Function(Map<String, dynamic> updated) onApply;
  final Future<void> Function()? onDeleteClass;

  const Thaksubsilsetting({
    super.key,
    required this.tsuap,
    required this.onApply,
    this.onDeleteClass,
  });

  @override
  State<Thaksubsilsetting> createState() => _ThaksubsilsettingState();
}

class _ThaksubsilsettingState extends State<Thaksubsilsetting> {
  static const List<String> _sortOptions = ['인문과목', '전공과목', '방과후'];
  late final TextEditingController _titleController;
  late final TextEditingController _languageController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _gradeController;
  late final TextEditingController _banController;
  String? _selectedSort;
  late bool _isActivated;
  late bool isChatAllowed;

  @override
  void initState() {
    super.initState();
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
    final sortText = _languageController.text.trim();
    _selectedSort = _sortOptions.contains(sortText) ? sortText : null;

    _isActivated =
        (widget.tsuap['activation'] == true) ||
        (widget.tsuap['isActivation'] == true);
    isChatAllowed = (widget.tsuap['chatAllowed'] == true);
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
    [nextGrade, nextBan].where((e) => e.isNotEmpty).join('-');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final double inputFontSize = width * 0.038;
    final accent = const Color(0xff0077FF);
    final borderColor = const Color(0xffE1E8F0);

    InputDecoration buildInputDecoration(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: accent, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

    Widget buildLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xff4C5674),
        ),
      ),
    );

    Widget buildSection({
      required String title,
      String? subtitle,
      required List<Widget> children,
    }) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xffE5EBF3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff0F172A).withOpacity(0.03),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xff1F2A44),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: Color(0xff6D768E)),
              ),
            ],
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      );
    }

    Widget buildToggleTile({
      required IconData icon,
      required String title,
      required String description,
      required bool value,
      required ValueChanged<bool> onChanged,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xffE5EBF3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xffE5F0FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff1B2741),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff6D768E),
                    ),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.9,
              alignment: Alignment.centerRight,
              child: Switch(
                value: value,
                activeColor: Colors.white,
                activeTrackColor: accent,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Container(
        color: const Color(0xfff5f5f5),
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.06,
          vertical: height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '수업 설정',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xff14213D),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '수업 정보를 정리하고 접근 권한을 관리해 보세요.',
              style: TextStyle(fontSize: 13, color: Color(0xff6D768E)),
            ),
            const SizedBox(height: 16),
            Container(height: 1, color: const Color(0xffE5EBF3)),
            buildSection(
              title: '기본 정보',
              subtitle: '수업 이름, 분류, 설명을 입력합니다.',
              children: [
                buildLabel('수업 이름'),
                TextField(
                  controller: _titleController,
                  decoration: buildInputDecoration('예) 2학년 자바 수업'),
                  style: TextStyle(fontSize: inputFontSize),
                ),
                const SizedBox(height: 16),
                buildLabel('분류 (sort)'),
                DropdownButtonFormField<String>(
                  value: _selectedSort,
                  decoration: buildInputDecoration('클릭해서 분류를 선택하세요'),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(14),
                  dropdownColor: Colors.white,
                  menuMaxHeight: height * 0.45,
                  style: TextStyle(
                    fontSize: inputFontSize,
                    color: const Color(0xff1F2A44),
                  ),
                  items:
                      _sortOptions
                          .map(
                            (option) => DropdownMenuItem<String>(
                              value: option,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: accent.withOpacity(0.55),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: inputFontSize,
                                      color: const Color(0xff1F2A44),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedSort = value;
                      _languageController.text = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                buildLabel('설명'),
                TextField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 4,
                  decoration: buildInputDecoration('수업 소개를 입력해 주세요.'),
                  style: TextStyle(fontSize: width * 0.038),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildLabel('대상 학년'),
                          TextField(
                            controller: _gradeController,
                            keyboardType: TextInputType.text,
                            decoration: buildInputDecoration('예) 2학년'),
                            style: TextStyle(fontSize: inputFontSize),
                            onChanged: (v) => _updateClassFromParts(grade: v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildLabel('대상 반'),
                          TextField(
                            controller: _banController,
                            keyboardType: TextInputType.text,
                            decoration: buildInputDecoration('예) A반'),
                            style: TextStyle(fontSize: inputFontSize),
                            onChanged: (v) => _updateClassFromParts(ban: v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            buildSection(
              title: '권한 및 기능',
              subtitle: '학생 접근과 커뮤니케이션 옵션을 관리합니다.',
              children: [
                buildToggleTile(
                  icon: Icons.play_circle_fill,
                  title: '수업 활성화',
                  description: '학생들이 수업에 참여할 수 있도록 허용합니다.',
                  value: _isActivated,
                  onChanged: (v) => setState(() => _isActivated = v),
                ),
                const SizedBox(height: 16),
                buildToggleTile(
                  icon: Icons.chat_bubble_outline,
                  title: '채팅 허용',
                  description: '수업 내 채팅 기능 사용 여부를 설정합니다.',
                  value: isChatAllowed,
                  onChanged: (v) => setState(() => isChatAllowed = v),
                ),
              ],
            ),
            buildSection(
              title: '위험 구역',
              subtitle: '수업 삭제 시 모든 구성원이 접근할 수 없습니다.',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '수업 삭제',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffB3261E),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '삭제하면 모든 기록이 복구되지 않습니다.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff8C1D18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed:
                          widget.onDeleteClass == null
                              ? null
                              : () {
                                widget.onDeleteClass!.call();
                              },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xffB3261E)),
                        foregroundColor: const Color(0xffB3261E),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('삭제하기'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04,
                    vertical: height * 0.018,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
                      showAppSnackBar(context, '수업 ID를 찾을 수 없어요.');
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
                      showAppSnackBar(
                        context,
                        '변경사항이 저장되었습니다.',
                        isError: false,
                      );
                    } else {
                      if (!mounted) return;
                      showAppSnackBar(
                        context,
                        '저장 실패: ${res.statusCode}',
                      );
                    }
                  } on DioException catch (e) {
                    if (!mounted) return;
                    final code = e.response?.statusCode;
                    final msg =
                        e.response?.data?.toString() ??
                        e.message ??
                        'unknown error';
                    showAppSnackBar(context, '오류: $code $msg');
                  } catch (e) {
                    if (!mounted) return;
                    showAppSnackBar(context, '오류: $e');
                  }
                },
                child: const Text(
                  '변경사항 저장',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
