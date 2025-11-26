import 'dart:convert';
import 'dart:io';

import 'package:clue/api_client.dart';
import 'package:clue/widgets/common/app_snackbar.dart';
import 'package:clue/auth_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _picker = ImagePicker();
  final _numbers = List<String>.generate(16, (index) => '${index + 1}');

  bool _loadingInitial = true;
  bool _submitting = false;
  String? _firstRegisterError;
  String? _email;
  String? _username;
  String? _role;
  String? _registerToken;
  bool _routeResolved = false;
  final TextEditingController _nameController = TextEditingController();

  File? _pickedImage;
  int? _grade;
  int? _klass;
  String? _number;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeResolved) return;
    _routeResolved = true;
    _resolveRegisterToken();
  }

  Future<void> _resolveRegisterToken() async {
    String? sid = _extractTokenFromRouteSync();
    debugPrint('ℹ️ signup token from route args: $sid');
    sid ??= await AuthStorage.instance.readRegisterToken();
    debugPrint('ℹ️ signup token from storage: $sid');

    if (!mounted) return;
    setState(() {
      _registerToken = sid;
    });

    if (sid != null && sid.isNotEmpty) {
      await AuthStorage.instance.saveRegisterToken(sid);
    }

    if (_registerToken == null || _registerToken!.isEmpty) {
      setState(() {
        _firstRegisterError = '세션 정보가 없습니다.';
        _loadingInitial = false;
      });
      return;
    }
    _loadFirstRegister();
  }

  String? _extractTokenFromRouteSync() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['signupToken'] != null) {
      final value = args['signupToken'];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }

    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName != null && routeName.contains('token=')) {
      try {
        final uri = Uri.parse('scheme://host$routeName');
        final sid = uri.queryParameters['token'];
        if (sid != null && sid.isNotEmpty) return sid;
      } catch (_) {
        // ignore malformed route name
      }
    }

    final base = Uri.base;
    final sidFromQuery = base.queryParameters['token'];
    if (sidFromQuery != null && sidFromQuery.isNotEmpty) return sidFromQuery;

    if (base.fragment.isNotEmpty) {
      for (final pair in base.fragment.split('&')) {
        final parts = pair.split('=');
        if (parts.length != 2) continue;
        if (parts[0] == 'token' && parts[1].isNotEmpty) {
          return Uri.decodeComponent(parts[1]);
        }
      }
    }
    return null;
  }

  Future<void> _loadFirstRegister() async {
    if (_registerToken == null || _registerToken!.isEmpty) {
      setState(() {
        _firstRegisterError = '세션 정보가 없습니다.';
        _loadingInitial = false;
      });
      return;
    }
    setState(() {
      _loadingInitial = true;
      _firstRegisterError = null;
    });
    try {
      debugPrint('➡️ calling /app/first-register with token=${_registerToken}');
      final response = await ApiClient.instance.dio.get(
        '/app/first-register',
        queryParameters: {'token': _registerToken},
        options: Options(headers: {'token': _registerToken}),
      );
      final data = response.data;
      final map =
          data is Map
              ? Map<String, dynamic>.from(data.cast<String, dynamic>())
              : <String, dynamic>{};
      setState(() {
        _email = map['email']?.toString() ?? '';
        _username = map['username']?.toString() ?? '';
        _nameController.text = _username ?? '';
        _role = map['role']?.toString() ?? '';
        _klass ??= 1;
        _loadingInitial = false;
      });
    } catch (e) {
      if (e is DioException) {
        debugPrint(
          'failed to load first-register: status=${e.response?.statusCode} data=${e.response?.data}',
        );
      } else {
        debugPrint('failed to load first-register: $e');
      }
      setState(() {
        _firstRegisterError = '회원정보를 불러오는 데 실패했습니다.';
        _loadingInitial = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final result = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (result == null) return;
    setState(() => _pickedImage = File(result.path));
  }

  Future<void> _submitProfile() async {
    if (_submitting || _grade == null || _klass == null || _number == null) {
      return;
    }
    if (_registerToken == null || _registerToken!.isEmpty) {
      if (mounted) {
        showAppSnackBar(context, '세션 정보가 없습니다. 다시 시도해주세요.');
      }
      return;
    }
    final intNumber = int.tryParse(_number!) ?? 0;
    setState(() => _submitting = true);
    try {
      final name =
          _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : (_username ?? '');
      final userJson = jsonEncode({
        'grade': _grade,
        'classNo': _klass,
        'number': intNumber,
        'username': name,
      });

      final formDataMap = <String, dynamic>{
        'user': MultipartFile.fromString(
          userJson,
          contentType: MediaType('application', 'json'),
        ),
      };

      if (_pickedImage != null) {
        final ext = _pickedImage!.path.toLowerCase();
        final imageType = ext.endsWith('.png') ? 'png' : 'jpeg';
        formDataMap['image'] = await MultipartFile.fromFile(
          _pickedImage!.path,
          contentType: MediaType('image', imageType),
        );
      }

      final formData = FormData.fromMap(formDataMap);
      debugPrint(
        '➡️ posting /app/register token=${_registerToken} grade=$_grade class=$_klass number=$intNumber',
      );
      final response = await ApiClient.instance.dio.post(
        '/app/register',
        data: formData,
        queryParameters: {'token': _registerToken},
        options: Options(headers: {'token': _registerToken}),
      );
      // 서버가 회원가입 성공 시 내려주는 access token 저장
      final authHeader =
          response.headers.value('Authorization') ??
          response.headers.value('authorization');
      String? access = authHeader?.trim();
      if ((access == null || access.isEmpty) && response.data is String) {
        access = (response.data as String).trim();
      } else if ((access == null || access.isEmpty) && response.data is Map) {
        final map = response.data as Map;
        access = map['access_token']?.toString();
      }
      debugPrint('ℹ️ Signup response token raw: ${access ?? '(null)'}');
      if (access != null && access.isNotEmpty) {
        final bearer =
            access.toLowerCase().startsWith('bearer ')
                ? access
                : 'Bearer $access';
        await AuthStorage.instance.saveAccessToken(bearer);
        debugPrint('✅ Access token saved from signup response');
      } else {
        debugPrint('⚠️ Access token missing in signup response');
      }
      if (mounted) {
        showAppSnackBar(
          context,
          '회원가입 정보가 저장되었습니다.',
          isError: false,
        );
        await Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/main', (route) => false);
      }
    } catch (e) {
      debugPrint('register failed: $e');
      if (mounted) {
        showAppSnackBar(context, '회원가입 실패: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      } else {
        _submitting = false;
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
      showCheckmark: false,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        !_submitting && _grade != null && _klass != null && _number != null;
    if ((_username != null && _username!.isNotEmpty) &&
        _nameController.text.isEmpty) {
      _nameController.text = _username!;
    }

    final theme = Theme.of(context);
    final palette = (
      bgTop: const Color(0xFFF0F4FF),
      bgBottom: const Color(0xFFFDFDFE),
      card: Colors.white,
      accent: const Color(0xFF0D6EFD),
      text: const Color(0xFF0F172A),
      muted: const Color(0xFF6B7280),
    );

    return Scaffold(
      backgroundColor: palette.bgBottom,
      appBar: AppBar(
        title: const Text('회원정보 입력'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: palette.text,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [palette.bgTop, palette.bgBottom],
                ),
              ),
            ),
          ),
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: palette.accent.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: palette.accent.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          if (_loadingInitial)
            const Center(child: CircularProgressIndicator())
          else if (_firstRegisterError != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _firstRegisterError!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: palette.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadFirstRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            )
          else
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: palette.card,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 24,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '프로필',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: palette.text,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '이메일과 이름은 인증 정보를 기반으로 불러왔어요.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: palette.muted,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '프로필 사진',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 38,
                                    backgroundColor: const Color(0xFFE5E7EB),
                                    backgroundImage:
                                        _pickedImage != null
                                            ? FileImage(_pickedImage!)
                                            : null,
                                    child:
                                        _pickedImage == null
                                            ? const Icon(
                                              Icons.person,
                                              size: 36,
                                              color: Colors.white54,
                                            )
                                            : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ElevatedButton(
                                        onPressed: _pickImage,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: palette.text,
                                          side: BorderSide(
                                            color: palette.accent.withOpacity(
                                              0.25,
                                            ),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: const Text('사진 변경'),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'JPG, PNG 파일만 업로드 가능합니다.',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: palette.muted),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            '이름',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            cursorColor: palette.accent,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF111827),
                            ),
                            decoration: InputDecoration(
                              hintText: '이름을 입력해주세요',
                              hintStyle: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: palette.accent,
                                  width: 1.8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow('이메일', _email ?? '알 수 없음'),
                          if (_role != null && _role!.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _buildInfoRow('역할', _role!),
                          ],
                          const SizedBox(height: 22),

                          const Text(
                            '학년 *',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
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
                          const SizedBox(height: 20),
                          const Text(
                            '반 *',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: List.generate(4, (index) {
                              final label = '${index + 1}반';
                              final selected = _klass == index + 1;
                              return SizedBox(
                                height: 44,
                                child: _buildChoice(
                                  label: label,
                                  selected: selected,
                                  onTap:
                                      () => setState(() => _klass = index + 1),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            '번호 *',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            menuMaxHeight: 250,

                            value: _number,
                            hint: Text(
                              '번호를 선택해주세요',
                              style: TextStyle(color: palette.muted),
                            ),
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: palette.muted,
                            ),
                            items:
                                _numbers.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text('$value번'),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _number = newValue;
                              });
                            },
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: palette.accent,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: canSubmit ? _submitProfile : null,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(56),
                                backgroundColor:
                                    canSubmit
                                        ? palette.accent
                                        : palette.accent.withOpacity(0.2),
                                foregroundColor:
                                    canSubmit
                                        ? Colors.white
                                        : palette.text.withOpacity(0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child:
                                  _submitting
                                      ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : const Text(
                                        '회원가입 완료',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
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
        ],
      ),
    );
  }
}
