import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsProfileSujeong extends StatefulWidget {
  const SettingsProfileSujeong({super.key});

  @override
  State<SettingsProfileSujeong> createState() => _SettingsProfileSujeongState();
}

class _SettingsProfileSujeongState extends State<SettingsProfileSujeong> {
  String _selectedGrade = '2학년';
  String _selectedClass = '2반';
  final TextEditingController _nameController = TextEditingController(text: '공덕현');
  final TextEditingController _emailController =
      TextEditingController(text: 'example@gmail.com');
  final TextEditingController _numberController = TextEditingController(text: '1');
  final TextEditingController _introController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _numberController.dispose();
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final width = media.size.width;

    Widget buildChoiceGroup({
      required String label,
      required List<String> options,
      required String selected,
      required ValueChanged<String> onChanged,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label, requiredMark: true, width: width),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: options
                .map(
                  (option) => GestureDetector(
                    onTap: () => onChanged(option),
                    child: _ChoiceChip(
                      label: option,
                      selected: selected == option,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/clueLogo.svg',
                    height: width * 0.12,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      'assets/images/bars-3.svg',
                      height: width * 0.075,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                '사용자 정보 수정',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: width * 0.05,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE6ECF4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 48,
                              color: Color(0xFF7F8EA3),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0D6EFD),
                              side: const BorderSide(color: Color(0xFFB9D5FF)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.camera_alt_outlined, size: 18),
                            label: const Text('사진변경'),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'JPG, PNG 파일만 업로드 가능합니다',
                            style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _LabeledField(
                      label: '이름',
                      requiredMark: true,
                      child: TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration(''),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _LabeledField(
                      label: '이메일',
                      requiredMark: true,
                      child: TextFormField(
                        controller: _emailController,
                        readOnly: true,
                        decoration: _inputDecoration('').copyWith(
                          fillColor: const Color(0xFFEFF2F7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    buildChoiceGroup(
                      label: '학년',
                      options: const ['1학년', '2학년', '3학년'],
                      selected: _selectedGrade,
                      onChanged: (value) => setState(() => _selectedGrade = value),
                    ),
                    const SizedBox(height: 24),
                    buildChoiceGroup(
                      label: '반',
                      options: const ['1반', '2반', '3반', '4반'],
                      selected: _selectedClass,
                      onChanged: (value) => setState(() => _selectedClass = value),
                    ),
                    const SizedBox(height: 24),
                    _LabeledField(
                      label: '번호',
                      requiredMark: true,
                      child: TextFormField(
                        controller: _numberController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('번호를 입력해주세요.'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _LabeledField(
                      label: '자기소개',
                      child: TextFormField(
                        controller: _introController,
                        minLines: 3,
                        maxLines: 3,
                        decoration: _inputDecoration('내용을 입력해주세요.'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text('변경사항 저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0D6EFD)),
      ),
    );
  }

  Widget _buildLabel(String label, {required bool requiredMark, required double width}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: const Color(0xFF111827),
          fontWeight: FontWeight.w600,
          fontSize: width * 0.038,
        ),
        children: requiredMark
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFF0D6EFD)),
                ),
              ]
            : null,
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    this.requiredMark = false,
    required this.child,
  });

  final String label;
  final bool requiredMark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: const Color(0xFF111827),
              fontWeight: FontWeight.w600,
              fontSize: width * 0.038,
            ),
            children: requiredMark
                ? const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: Color(0xFF0D6EFD)),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF0D6EFD) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? const Color(0xFF0D6EFD) : const Color(0xFFE2E8F0),
        ),
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0x220D6EFD),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF1F2933),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
