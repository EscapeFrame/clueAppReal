import 'dart:convert';
import 'dart:io';

import 'package:clue/api_client.dart';
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
  final _numbers = List<String>.generate(30, (index) => '${index + 1}');

  bool _loadingInitial = true;
  bool _submitting = false;
  String? _firstRegisterError;
  String? _email;
  String? _username;
  String? _role;
  String? _registerToken;
  bool _routeResolved = false;

  File? _pickedImage;
  int? _grade;
  int? _klass;
  String? _number;

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
        _role = map['role']?.toString() ?? '';
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('세션 정보가 없습니다. 다시 시도해주세요.')),
        );
      }
      return;
    }
    final intNumber = int.tryParse(_number!) ?? 0;
    setState(() => _submitting = true);
    try {
      final userJson = jsonEncode({
        'grade': _grade,
        'classNo': _klass,
        'number': intNumber,
        'username': _username ?? '',
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
          response.headers.value('Authorization') ?? response.headers.value('authorization');
      String? access = authHeader?.trim();
      if ((access == null || access.isEmpty) && response.data is String) {
        access = (response.data as String).trim();
      } else if ((access == null || access.isEmpty) && response.data is Map) {
        final map = response.data as Map;
        access = map['access_token']?.toString();
      }
      debugPrint('ℹ️ Signup response token raw: ${access ?? '(null)'}');
      if (access != null && access.isNotEmpty) {
        final bearer = access.toLowerCase().startsWith('bearer ') ? access : 'Bearer $access';
        await AuthStorage.instance.saveAccessToken(bearer);
        debugPrint('✅ Access token saved from signup response');
      } else {
        debugPrint('⚠️ Access token missing in signup response');
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('회원가입 정보가 저장되었습니다.')));
        await Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/main', (route) => false);
      }
    } catch (e) {
      debugPrint('register failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('회원가입 실패: $e')));
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

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('회원정보 입력'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body:
          _loadingInitial
              ? const Center(child: CircularProgressIndicator())
              : _firstRegisterError != null
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_firstRegisterError!),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadFirstRegister,
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
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
                            const SizedBox(height: 24),
                            _buildInfoRow('이메일', _email ?? '알 수 없음'),
                            const SizedBox(height: 12),
                            _buildInfoRow('이름', _username ?? '알 수 없음'),
                            if (_role != null && _role!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow('역할', _role!),
                            ],
                            const SizedBox(height: 24),
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
                                  onTap:
                                      () => setState(() => _grade = index + 1),
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
                                  onTap:
                                      () => setState(() => _klass = index + 1),
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
                              onChanged:
                                  (value) => setState(() => _number = value),
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
