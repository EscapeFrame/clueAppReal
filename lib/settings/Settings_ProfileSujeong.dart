import 'package:clue/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsProfileSujeong extends StatefulWidget {
  const SettingsProfileSujeong({super.key});

  @override
  State<SettingsProfileSujeong> createState() => _SettingsProfileSujeongState();
}

class _SettingsProfileSujeongState extends State<SettingsProfileSujeong> {
  String _selectedGrade = '';
  String _selectedClass = '';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _introController = TextEditingController();
  bool _isProfileLoading = false;
  bool _isSaving = false;
  String? _profileError;
  String? _profileName;
  int? _profileGrade;
  int? _profileClassNo;
  int? _profileNumber;
  String? _nameErrorText;
  String? _numberErrorText;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _numberController.dispose();
    _introController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() {
      _isProfileLoading = true;
      _profileError = null;
    });
    try {
      final dio = ApiClient.instance.dio;
      final response = await dio.get('/api/user/me');
      final data = response.data;
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final username = map['username']?.toString() ?? '';
        final email = map['email']?.toString() ?? '';
        final grade = _parseInt(map['grade']);
        final classNo = _parseInt(map['classNo']);
        final number = _parseInt(map['number']);
        if (!mounted) return;
        setState(() {
          _profileName = username.isEmpty ? null : username;
          _profileGrade = grade;
          _profileClassNo = classNo;
          _profileNumber = number;
          if (username.isNotEmpty) {
            _nameController.text = username;
          }
          if (email.isNotEmpty) {
            _emailController.text = email;
          }
          if (number != null) {
            _numberController.text = number.toString();
          }
          if (grade != null) {
            _selectedGrade = '${grade}학년';
          }
          if (classNo != null) {
            _selectedClass = '${classNo}반';
          }
          _nameErrorText = null;
          _numberErrorText = null;
          _isProfileLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _profileError = '사용자 정보를 불러오지 못했습니다.';
          _isProfileLoading = false;
        });
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _profileError = '사용자 정보를 불러오지 못했습니다. ${e.response?.statusCode ?? ''}';
        _isProfileLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _profileError = '사용자 정보를 불러오지 못했습니다. $e';
        _isProfileLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final width = media.size.width;

    final displayName = _profileName ?? '';
    final classSummary = _buildClassSummary();

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
            children:
                options
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
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                      'assets/images/realLogo.svg',
                      width: width * 0.25,
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.arrow_back, size: width * 0.07),
                        ),
                        SizedBox(width: width * 0.03),
                        GestureDetector(
                          // onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                          child: SvgPicture.asset(
                            'assets/images/bars-3.svg',
                            width: width * 0.074,
                          ),
                        ),
                        SizedBox(width: width * 0.0443),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                                  width: width * 0.22,
                                  height: width * 0.22,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE6ECF4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: width * 0.11,
                                    color: const Color(0xFF7F8EA3),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF0D6EFD),
                                    side: const BorderSide(
                                      color: Color(0xFFB9D5FF),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('사진변경'),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'JPG, PNG 파일만 업로드 가능합니다',
                                  style: TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 12,
                                  ),
                                ),
                                // const SizedBox(height: 14),
                                // if (_isProfileLoading)
                                //   const Padding(
                                //     padding: EdgeInsets.symmetric(vertical: 8),
                                //     child: CircularProgressIndicator.adaptive(),
                                //   )
                                // else ...[
                                //   if (displayName.trim().isNotEmpty)
                                //     Text(
                                //       displayName,
                                //       style: const TextStyle(
                                //         fontSize: 20,
                                //         fontWeight: FontWeight.w700,
                                //         color: Color(0xFF111827),
                                //       ),
                                //     ),
                                //   if (classSummary.isNotEmpty)
                                //     Padding(
                                //       padding: const EdgeInsets.only(top: 4),
                                //       child: Text(
                                //         classSummary,
                                //         style: const TextStyle(
                                //           fontSize: 14,
                                //           color: Color(0xFF4B5563),
                                //         ),
                                //       ),
                                //     ),
                                // ],
                                // if (_profileError != null)
                                //   Padding(
                                //     padding: const EdgeInsets.only(top: 8),
                                //     child: Text(
                                //       _profileError!,
                                //       style: const TextStyle(
                                //         fontSize: 12,
                                //         color: Color(0xFFD14343),
                                //       ),
                                //     ),
                                //   ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          _LabeledField(
                            label: '이름',
                            requiredMark: true,
                            errorText: _nameErrorText,
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
                              decoration: _inputDecoration(
                                '',
                              ).copyWith(fillColor: const Color(0xFFEFF2F7)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          buildChoiceGroup(
                            label: '학년',
                            options: const ['1학년', '2학년', '3학년'],
                            selected: _selectedGrade,
                            onChanged:
                                (value) =>
                                    setState(() => _selectedGrade = value),
                          ),
                          const SizedBox(height: 24),
                          buildChoiceGroup(
                            label: '반',
                            options: const ['1반', '2반', '3반', '4반'],
                            selected: _selectedClass,
                            onChanged:
                                (value) =>
                                    setState(() => _selectedClass = value),
                          ),
                          const SizedBox(height: 24),
                          _LabeledField(
                            label: '번호',
                            requiredMark: true,
                            errorText: _numberErrorText,
                            child: TextFormField(
                              controller: _numberController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
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
                        onPressed: _isSaving ? null : () => _onSavePressed(),
                        child:
                            _isSaving
                                ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text('변경사항 저장'),
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

  Future<void> _onSavePressed() async {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final name = _nameController.text.trim();
    final numberText = _numberController.text.trim();
    final intro = _introController.text.trim();
    String? nameError;
    String? numberError;

    if (name.isEmpty) {
      nameError = '이름을 입력해 주세요.';
    }
    final parsedNumber = int.tryParse(numberText);
    if (numberText.isEmpty) {
      numberError = '번호를 입력해 주세요.';
    } else if (parsedNumber == null) {
      numberError = '번호는 숫자만 입력해 주세요.';
    }

    setState(() {
      _nameErrorText = nameError;
      _numberErrorText = numberError;
    });

    if (nameError != null || numberError != null) {
      return;
    }

    final grade = _parseSelectedValue(_selectedGrade);
    final classNo = _parseSelectedValue(_selectedClass);

    if (grade == null || classNo == null) {
      messenger.showSnackBar(const SnackBar(content: Text('학년과 반을 선택해 주세요.')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final dio = ApiClient.instance.dio;
      await dio.patch(
        '/api/user',
        data: {
          'username': name,
          'description': intro,
          'grade': grade,
          'classNo': classNo,
          'number': parsedNumber!,
        },
      );
      if (!mounted) return;
      setState(() {
        _profileName = name;
        _profileGrade = grade;
        _profileClassNo = classNo;
        _profileNumber = parsedNumber;
      });
      messenger.showSnackBar(const SnackBar(content: Text('변경사항을 저장했습니다.')));
      await _loadProfile();
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            statusCode == null ? '저장에 실패했습니다.' : '저장에 실패했습니다. ($statusCode)',
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('저장에 실패했습니다. $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
    }
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

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  int? _parseSelectedValue(String value) {
    if (value.isEmpty) return null;
    final match = RegExp(r'\d+').firstMatch(value);
    if (match == null) return null;
    return int.tryParse(match.group(0)!);
  }

  Widget _buildLabel(
    String label, {
    required bool requiredMark,
    required double width,
  }) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: const Color(0xFF111827),
          fontWeight: FontWeight.w600,
          fontSize: width * 0.038,
        ),
        children:
            requiredMark
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

  String _buildClassSummary() {
    final parts = <String>[];
    if (_profileGrade != null) {
      parts.add('${_profileGrade}학년');
    }
    if (_profileClassNo != null) {
      parts.add('${_profileClassNo}반');
    }
    if (_profileNumber != null) {
      parts.add('${_profileNumber}번');
    }
    return parts.join(' ');
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    this.requiredMark = false,
    required this.child,
    this.errorText,
  });

  final String label;
  final bool requiredMark;
  final Widget child;
  final String? errorText;

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
            children:
                requiredMark
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
        if (errorText != null) const SizedBox(height: 6),
        if (errorText != null)
          Text(
            errorText!,
            style: const TextStyle(color: Color(0xFFD14343), fontSize: 12),
          ),
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
        boxShadow:
            selected
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
