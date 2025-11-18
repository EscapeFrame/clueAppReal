import 'package:clue/api_client.dart';
import 'package:clue/settings/Settings_set.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'Alarm.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  static const _backgroundColor = Color(0xffF5F5F5);
  static const _cardShadow = [
    BoxShadow(color: Color(0x11000000), blurRadius: 18, offset: Offset(0, 6)),
  ];

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _isProfileLoading = false;
  Map<String, dynamic>? _profile;
  String? _profileError;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isProfileLoading = true;
      _profileError = null;
    });
    try {
      final dio = ApiClient.instance.dio;
      final res = await dio.get('/api/user/me');
      if (!mounted) return;
      if (res.data is Map) {
        setState(() {
          _profile = Map<String, dynamic>.from(res.data as Map);
          _isProfileLoading = false;
        });
      } else {
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

    return Scaffold(
      backgroundColor: Settings._backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 로고 + 아이콘 바
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
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const Alarm()),
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/images/jong.svg',
                            width: width * 0.055,
                          ),
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

            // 내용
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 프로필 카드
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: Settings._cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE6ECF4),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xFF7F8EA3),
                                  size: 36,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: width * 0.008),
                                  if (_isProfileLoading)
                                    SizedBox(
                                      width: width * 0.08,
                                      height: width * 0.08,
                                      child:
                                          const CircularProgressIndicator.adaptive(),
                                    )
                                  else ...[
                                    Text(
                                      _profile?['username']?.toString() ??
                                          '사용자명',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: width * 0.048,
                                          ),
                                    ),
                                    // const SizedBox(height: 2),
                                    Text(
                                      _buildClassSummary(),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: const Color(0xFF5C6672),
                                            fontSize: width * 0.035,
                                          ),
                                    ),
                                    if (_profileError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          _profileError!,
                                          style: const TextStyle(
                                            color: Color(0xFFD14343),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 설정 리스트
                    const SettingsSet(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 하단 저장 버튼
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SizedBox(
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
      ),
    );
  }

  String _buildClassSummary() {
    final grade = _profile?['grade'];
    final classNo = _profile?['classNo'];
    final number = _profile?['number'];
    final parts = <String>[];
    if (grade != null) parts.add('${grade}학년');
    if (classNo != null) parts.add('${classNo}반');
    if (number != null) parts.add('${number}번');
    return parts.isEmpty ? '학년/반 정보 없음' : parts.join(' ');
  }
}
