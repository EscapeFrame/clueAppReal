import 'package:clue/HamburgerDialog.dart';
import 'package:clue/api_client.dart';
import 'package:clue/config/app_color.dart';
import 'package:clue/widgets/haksubsilPage/HakSubSilBaroGaBoJa.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'Alarm.dart';

class Haksubsil extends StatefulWidget {
  const Haksubsil({super.key});

  @override
  State<Haksubsil> createState() => _HaksubsilState();
}

class _HaksubsilState extends State<Haksubsil> {
  List<Map<String, dynamic>> _classList = const [];
  final List<String> categories = ['전체', '인문과목', '전공과목', '방과후'];
  int selectedIndex = 0; //기본선택 : 전체
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _showStyledSnackBar(
    String message, {
    bool isError = true,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final Color accent =
        isError ? const Color(0xFFEF4444) : const Color(0xFF22C55E);
    final Color bg = const Color(0xFF111827).withOpacity(0.96);
    final IconData icon =
        isError ? Icons.error_outline_rounded : Icons.check_circle_rounded;

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: accent.withOpacity(0.55),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<bool> haksubsilJoin(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      if (mounted) {
        _showStyledSnackBar('학습실 코드를 입력해 주세요.');
      }
      return false;
    }
    debugPrint("ccooddee : $trimmed");
    try {
      final dio = ApiClient.instance.dio;
      final res = await dio.post('/api/class/$trimmed/members');
      debugPrint(res.toString());
      return true;
    } on DioException catch (e) {
      debugPrint("dioerror : ${e.message}");
      debugPrint("dioerror : ${e.error}");
      if (mounted) {
        final code = e.response?.statusCode;
        final rawMsg = e.response?.data?.toString() ?? e.message ?? 'unknown';
        if (code == 500 && rawMsg.contains('이미')) {
          await _response(); // 이미 참여한 교실이면 목록을 새로고침해 UI에 반영
          if (mounted) {
            _showStyledSnackBar(
              '이미 참여한 학습실입니다. 목록을 새로고침했어요.',
              isError: false,
            );
          }
          return true;
        }
        if (mounted) {
          _showStyledSnackBar('참여에 실패했어요. ($code $rawMsg)');
        }
      }
    } catch (e) {
      debugPrint("error: $e");
      if (mounted) {
        _showStyledSnackBar('참여에 실패했어요. ($e)');
      }
    }
    return false;
  }

  Widget _buildTabContent() {
    if (_isLoading && _classList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final query = _searchQuery.trim().toLowerCase();
    const filters = [null, 'inmoon', 'jeongong', 'banggwahoo'];
    final clampedIndex = selectedIndex.clamp(0, filters.length - 1).toInt();
    final filter = filters[clampedIndex];
    final emptyMessages = [
      '등록된 학습실이 없습니다.',
      '인문과목 학습실이 없습니다.',
      '전공과목 학습실이 없습니다.',
      '방과후 학습실이 없습니다.',
    ];

    final filteredBySearch =
        query.isEmpty
            ? _classList
            : _classList.where((item) {
              final name = (item['name'] ?? '').toString().toLowerCase();
              return name.contains(query);
            }).toList();

    return RefreshIndicator(
      onRefresh: _response,
      color: const Color(0xFF5FA8FF),
      backgroundColor: const Color(0xFFD6EAFF),
      child: HakSubSilBaroGaBoJa(
        key: ValueKey(filter ?? 'all'),
        noticeList: filteredBySearch,
        subjectFilter: filter,
        emptyMessage: emptyMessages[clampedIndex],
      ),
    );
  }

  void showAddClassDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            width: width * 0.8,
            // height: height * 0.2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '학습실 추가하기',
                      style: TextStyle(
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close, size: width * 0.055),
                    ),
                  ],
                ),

                TextField(
                  style: TextStyle(
                    fontSize: width * 0.031,
                    color: Color(0xff666666),
                  ),
                  controller: codeController,
                  cursorColor: AppColor.bblue,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    filled: true,
                    isDense: true,
                    fillColor: Color(0xffF3F3F3),
                    hintText: "학습실 코드를 입력해주세요",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF3395FF)),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.05),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xff555555),
                          side: const BorderSide(color: Color(0xffCCCCCC)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('취소'),
                      ),
                    ),
                    SizedBox(width: width * 0.02),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3395FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () async {
                          final code = codeController.text;
                          final joined = await haksubsilJoin(code);
                          if (!joined || !mounted) return;
                          Navigator.pop(context);
                          await _response();
                          if (!mounted) return;
                          _showStyledSnackBar(
                            '학습실에 참여했어요.',
                            isError: false,
                          );
                        },
                        child: const Text('확인'),
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
  }

  Future<void> _response() async {
    debugPrint('BASE: ${ApiClient.instance.dio.options.baseUrl}');
    try {
      final api = ApiClient.instance.dio;
      final res = await api.get('/api/class');
      final data = res.data;

      List<Map<String, dynamic>> list = [];

      list =
          data
              .whereType<Map>()
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .where(
                (item) =>
                    !(item['activation'] is bool) || item['activation'] == true,
              )
              .toList();

      if (!mounted) return;
      setState(() {
        _classList = list;
      });

      debugPrint(res.data.toString());
    } on DioException catch (e) {
      //Dio 패키지에서 http 통신 중 발생하는 예외타입
      debugPrint(
        'EEError: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint('진입함');
    _response();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddClassDialog(context);
        },
        backgroundColor: Color(0xff0077FF),
        child: const Icon(Icons.add, color: Color(0xffffffff)),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: SvgPicture.asset(
                      'assets/images/realLogo.svg',

                      width: width * 0.25,
                    ),
                  ),

                  Container(
                    child: Row(
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
                          onTap: () => showHamburgerDialog(context),
                          child: SvgPicture.asset(
                            'assets/images/bars-3.svg',
                            width: width * 0.074,
                          ),
                        ),
                        SizedBox(width: width * 0.0443),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.0443),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '나의 학습실',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.055,
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isWide = constraints.maxWidth >= 620;
                      final double maxFieldWidth =
                          isWide ? 540 : constraints.maxWidth;
                      final double trailingPadding = isWide ? 24 : 16;
                      final double verticalPadding = isWide ? 18 : 12;
                      final double radiusValue = isWide ? 18 : 14;
                      final double hintFontSize =
                          isWide ? width * 0.0335 : width * 0.035;
                      final double minHeight = isWide ? 56 : 46;
                      final double iconContainerSize = isWide ? 42 : 36;
                      final double iconSize = isWide ? 22 : 20;
                      final BorderRadius iconRadius = BorderRadius.circular(
                        isWide ? 14 : 12,
                      );
                      final IconData iconData =
                          isWide ? Icons.search_rounded : Icons.search;
                      final Color iconBackground =
                          isWide
                              ? const Color(0xFFE3E9F4)
                              : const Color(0xFFF0F2F5);

                      return Align(
                        alignment: Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxFieldWidth),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: "검색할 내용을 입력하세요",
                              hintStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: hintFontSize,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5F6FA),
                              prefixIcon: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isWide ? 10 : 8,
                                ),
                                child: Container(
                                  width: iconContainerSize,
                                  height: iconContainerSize,
                                  decoration: BoxDecoration(
                                    color: iconBackground,
                                    borderRadius: iconRadius,
                                  ),
                                  child: Icon(
                                    iconData,
                                    size: iconSize,
                                    color: const Color(0xFF0D6EFD),
                                  ),
                                ),
                              ),
                              prefixIconConstraints: BoxConstraints(
                                minWidth:
                                    iconContainerSize + (isWide ? 20 : 16),
                                minHeight: iconContainerSize,
                              ),
                              contentPadding: EdgeInsets.only(
                                top: verticalPadding,
                                bottom: verticalPadding,
                                right: trailingPadding,
                              ),
                              isDense: true,
                              constraints: BoxConstraints(minHeight: minHeight),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  radiusValue,
                                ),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE1E5EC),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  radiusValue,
                                ),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0D6EFD),
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() => _searchQuery = value);
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: height * 0.013),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(categories.length, (index) {
                      final bool isSelected = selectedIndex == index;

                      return GestureDetector(
                        onTap: () {
                          if (selectedIndex != index) {
                            setState(() => selectedIndex = index);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.04,
                            vertical: width * 0.025,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? const Color(0xff0077FF)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            categories[index],
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : Colors.grey[700],
                              fontSize: width * 0.035,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.01),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: _buildTabContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
