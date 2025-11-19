import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _picker = ImagePicker();
  final _numbers = List<String>.generate(30, (index) => '${index + 1}');

  bool _submitInProgress = false;
  File? _pickedImage;
  int? _grade;
  int? _klass;
  String? _number;

  Future<void> _pickImage() async {
    final result = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (result == null) return;
    setState(() => _pickedImage = File(result.path));
  }

  Future<void> _submitProfile() async {
    if (_submitInProgress ||
        _grade == null ||
        _klass == null ||
        _number == null)
      return;

    setState(() => _submitInProgress = true);
    try {
      debugPrint(
        'Submitting profile -> grade=$_grade, class=$_klass, number=$_number',
      );
      // TODO: send grade/class/number + profile image to backend
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('회원가입 정보가 저장되었습니다.')));
        await Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/main', (route) => false);
      }
    } finally {
      if (mounted) {
        setState(() => _submitInProgress = false);
      } else {
        _submitInProgress = false;
      }
    }
  }

  Widget _buildChoice({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF0D6EFD),
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xFF1F2933),
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? const Color(0xFF0D6EFD) : const Color(0xFFE2E8F0),
        ),
      ),
      elevation: selected ? 4 : 0,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        !_submitInProgress &&
        _grade != null &&
        _klass != null &&
        _number != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('회원정보 입력'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '정보를 입력해주세요',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '원활한 서비스 사용을 위해 현재 내용을 작성해주세요.',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      '학년*',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: List.generate(3, (index) {
                        final label = '${index + 1}학년';
                        final selected = _grade == index + 1;
                        return _buildChoice(
                          label: label,
                          selected: selected,
                          onTap: () => setState(() => _grade = index + 1),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '반*',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: List.generate(4, (index) {
                        final label = '${index + 1}반';
                        final selected = _klass == index + 1;
                        return _buildChoice(
                          label: label,
                          selected: selected,
                          onTap: () => setState(() => _klass = index + 1),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '번호*',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                      ),
                      hint: const Text('번호를 선택해주세요'),
                      items:
                          _numbers
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text('$value번'),
                                ),
                              )
                              .toList(),
                      onChanged: (value) => setState(() => _number = value),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '이미지',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: const Color(0xFFE5E7EB),
                          backgroundImage:
                              _pickedImage != null
                                  ? FileImage(_pickedImage!)
                                  : null,
                          child:
                              _pickedImage == null
                                  ? const Icon(
                                    Icons.person,
                                    size: 44,
                                    color: Colors.white54,
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 18),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: _pickImage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                side: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('사진변경'),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'JPG, PNG 파일만 업로드 가능합니다.',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: canSubmit ? _submitProfile : null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor:
                              canSubmit
                                  ? const Color(0xFF111827)
                                  : const Color(0xFFE5E7EB),
                          foregroundColor:
                              canSubmit ? Colors.white : Colors.black54,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child:
                            _submitInProgress
                                ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text(
                                  '회원가입',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
