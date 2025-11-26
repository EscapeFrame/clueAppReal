import 'package:clue/HamburgerDialog.dart';
import 'package:clue/api_client.dart';
import 'package:clue/teacher_page/NTeacherSuap.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Thaksubsilsuap extends StatefulWidget {
  const Thaksubsilsuap({super.key});

  @override
  State<Thaksubsilsuap> createState() => _ThaksubsilsuapState();
}

class _ThaksubsilsuapState extends State<Thaksubsilsuap> {
  List<Map<String, dynamic>> teacherHakSubSil = [];
  final List<String> categories = ['전체', '활성화', '비활성화'];
  int selectedIndex = 0; //기본선택 : 전체
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Future<void> tHakSubSilApi() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    try {
      final api = ApiClient.instance.dio;
      final res = await api.get('/api/class');
      debugPrint('Response datad: ${res.data}');
      final data = res.data;
      final list =
          data is List
              ? data
                  .whereType<Map>()
                  .map<Map<String, dynamic>>(
                    (e) => Map<String, dynamic>.from(e),
                  )
                  .toList()
              : <Map<String, dynamic>>[];
      if (!mounted) return;
      setState(() {
        teacherHakSubSil = list;
        _isLoading = false;
      });
    } on DioException catch (e) {
      debugPrint('status : ${e.response?.statusCode}');
      debugPrint('data   : ${e.response?.data}');
      debugPrint('headers: ${e.response?.headers}');
      debugPrint('msg    : ${e.message}');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("EERROORR : $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTabContent() {
    if (_isLoading && teacherHakSubSil.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final query = _searchQuery.trim().toLowerCase();
    const filters = [null, true, false];
    final clampedIndex = selectedIndex.clamp(0, filters.length - 1).toInt();
    final filter = filters[clampedIndex];
    final filteredBySearch =
        query.isEmpty
            ? teacherHakSubSil
            : teacherHakSubSil.where((item) {
              final name = (item['name'] ?? '').toString().toLowerCase();
              return name.contains(query);
            }).toList();
    final emptyMessages = [
      '등록된 학습실이 없습니다.',
      '활성화된 학습실이 없습니다.',
      '비활성화된 학습실이 없습니다.',
    ];

    return TeacherSuapListSection(
      key: ValueKey(filter ?? 'all'),
      teacherHakSubSil: filteredBySearch,
      activationFilter: filter,
      emptyMessage: emptyMessages[clampedIndex],
      onRefresh: tHakSubSilApi,
    );
  }

  @override
  void initState() {
    super.initState();
    tHakSubSilApi();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _openCreateClassSheet,
          backgroundColor: Color(0xff0077FF),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 0,
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
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
                          SvgPicture.asset(
                            'assets/images/jong.svg',
                            width: width * 0.055,
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
                            constraints: BoxConstraints(
                              maxWidth: maxFieldWidth,
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: _handleSearchChanged,
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
                                constraints: BoxConstraints(
                                  minHeight: minHeight,
                                ),
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
                                    isSelected
                                        ? Colors.white
                                        : Colors.grey[700],
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
      ),
    );
  }

  Future<void> _openCreateClassSheet() async {
    final created = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'create-class',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder:
          (_, __, ___) => _CreateClassDialog(
            hostContext: context,
            onRefreshRequest: tHakSubSilApi,
          ),
    );

    if (created == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('수업이 생성되었습니다.')));
    }
  }
}

class _CreateClassDialog extends StatefulWidget {
  const _CreateClassDialog({
    required this.hostContext,
    required this.onRefreshRequest,
  });

  final BuildContext hostContext;
  final Future<void> Function() onRefreshRequest;

  @override
  State<_CreateClassDialog> createState() => _CreateClassDialogState();
}

class _CreateClassDialogState extends State<_CreateClassDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();

  final _nameFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _targetFocus = FocusNode();

  final List<String> _sortOptions = ['인문과목', '전공과목', '방과후'];

  final _scrollController = ScrollController();

  final _nameFieldKey = GlobalKey();
  final _descriptionFieldKey = GlobalKey();
  final _sortFieldKey = GlobalKey();
  final _targetFieldKey = GlobalKey();

  bool _isActivation = true;
  bool _isSubmitting = false;
  String? _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedSort = _sortOptions.first;
    _registerAutoScroll(_nameFocus, _nameFieldKey);
    _registerAutoScroll(_descriptionFocus, _descriptionFieldKey);
    _registerAutoScroll(_targetFocus, _targetFieldKey);
  }

  void _registerAutoScroll(FocusNode node, GlobalKey key) {
    node.addListener(() {
      if (!node.hasFocus) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = key.currentContext;
        if (ctx == null) return;
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.2,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _descriptionFocus.dispose();
    _targetFocus.dispose();
    _scrollController.dispose();

    _nameController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final sort = _selectedSort?.trim();
    final target = _targetController.text.trim();

    if (name.isEmpty || sort == null || sort.isEmpty || target.isEmpty) {
      ScaffoldMessenger.of(widget.hostContext).showSnackBar(
        const SnackBar(content: Text('name, sort, target을 입력해 주세요.')),
      );
      return;
    }
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    final body = {
      // "classRoomId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "name": name,
      "description": description,
      "sort": sort,
      "target": target,
      "isActivation": _isActivation,
      // "teacherNames": ["string"],
      // "createdAt": "2025-10-25T08:45:13.252Z",
    };

    try {
      final api = ApiClient.instance.dio;
      final res = await api.post('/api/class', data: body);
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        await widget.onRefreshRequest();
        if (!mounted) return;
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(
          widget.hostContext,
        ).showSnackBar(SnackBar(content: Text('생성 실패: ${res.statusCode}')));
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final code = e.response?.statusCode;
      final msg = e.response?.data?.toString() ?? e.message ?? 'unknown error';
      ScaffoldMessenger.of(
        widget.hostContext,
      ).showSnackBar(SnackBar(content: Text('오류: $code $msg')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        widget.hostContext,
      ).showSnackBar(SnackBar(content: Text('오류: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _closeDialog() {
    if (_isSubmitting) return;
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboardHeight = media.viewInsets.bottom;
    final availableWidth = media.size.width;
    final modalWidth = availableWidth >= 640 ? 560.0 : availableWidth - 32;
    final modalHeight = (media.size.height - media.viewPadding.vertical) * 0.9;

    final themed = Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(
        primary: const Color(0xff578FCA),
        secondary: const Color(0xff578FCA),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Color(0xff578FCA),
        selectionColor: Color(0x3386C1FF),
        selectionHandleColor: Color(0xff578FCA),
      ),
    );

    return Theme(
      data: themed,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: modalWidth,
                  maxHeight: modalHeight,
                ),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: LayoutBuilder(
                    builder: (layoutContext, constraints) {
                      final width = constraints.maxWidth;

                      InputDecoration inputDecoration(String hint) {
                        return InputDecoration(
                          hintText: hint,
                          hintStyle: TextStyle(fontSize: width * 0.03 + 3),
                        );
                      }

                      Widget buildLabeledField({
                        required String label,
                        bool requiredMark = false,
                        String? helper,
                        required Widget child,
                        required double widthFactor,
                        Key? fieldKey,
                      }) {
                        final baseTheme = Theme.of(context);
                        final labelStyle = baseTheme.textTheme.bodyMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: widthFactor * 0.04,
                            );
                        final decoratedChild = Theme(
                          data: baseTheme.copyWith(
                            inputDecorationTheme: const InputDecorationTheme(
                              filled: true,
                              fillColor: Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                          ),
                          child: child,
                        );
                        final content = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: label,
                                style: labelStyle,
                                children:
                                    requiredMark
                                        ? const [
                                          TextSpan(
                                            text: ' *',
                                            style: TextStyle(
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ]
                                        : const [],
                              ),
                            ),
                            if (helper != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                helper,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: widthFactor * 0.033,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            decoratedChild,
                          ],
                        );
                        if (fieldKey == null) return content;
                        return Container(key: fieldKey, child: content);
                      }

                      return SingleChildScrollView(
                        controller: _scrollController,
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          24,
                          20,
                          24,
                          24 + keyboardHeight,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '수업 만들기',
                                    style: TextStyle(
                                      fontSize: width * 0.055,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  splashRadius: 20,
                                  onPressed: _closeDialog,
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            buildLabeledField(
                              label: '수업 이름',
                              requiredMark: true,
                              widthFactor: width,
                              fieldKey: _nameFieldKey,
                              child: TextFormField(
                                controller: _nameController,
                                focusNode: _nameFocus,
                                decoration: inputDecoration('수업 이름을 입력해주세요.'),
                              ),
                            ),
                            const SizedBox(height: 18),
                            buildLabeledField(
                              label: '설명',
                              widthFactor: width,
                              fieldKey: _descriptionFieldKey,
                              child: TextFormField(
                                controller: _descriptionController,
                                focusNode: _descriptionFocus,
                                minLines: 3,
                                maxLines: 5,
                                decoration: inputDecoration('간단한 설명을 입력해주세요.'),
                              ),
                            ),
                            const SizedBox(height: 18),
                            buildLabeledField(
                              label: '과목 분류',
                              requiredMark: true,
                              widthFactor: width,
                              fieldKey: _sortFieldKey,
                              child: DropdownButtonFormField<String>(
                                value: _selectedSort,
                                isExpanded: true,
                                menuMaxHeight: 260,
                                borderRadius: BorderRadius.circular(14),
                                dropdownColor: Colors.white,
                                items:
                                    _sortOptions
                                        .map(
                                          (option) => DropdownMenuItem(
                                            value: option,
                                            child: Text(
                                              option,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: width * 0.035,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                decoration: inputDecoration('과목 분류를 선택해 주세요'),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xff578FCA),
                                ),
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: width * 0.035,
                                  fontWeight: FontWeight.w600,
                                ),
                                onChanged:
                                    (value) =>
                                        setState(() => _selectedSort = value),
                              ),
                            ),
                            const SizedBox(height: 18),
                            buildLabeledField(
                              label: '대상',
                              requiredMark: true,
                              widthFactor: width,
                              fieldKey: _targetFieldKey,
                              child: TextFormField(
                                controller: _targetController,
                                focusNode: _targetFocus,
                                decoration: inputDecoration('예: 2학년, 전교생'),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF4FE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '학습실 공개',
                                          style: TextStyle(
                                            fontSize: width * 0.04,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '학생들에게 학습실을 공개할지 선택하세요.',
                                          style: TextStyle(
                                            fontSize: width * 0.032,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: _isActivation,
                                    activeColor: const Color(0xff578FCA),
                                    onChanged:
                                        (value) => setState(
                                          () => _isActivation = value,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _closeDialog,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black87,
                                      side: const BorderSide(
                                        color: Color(0xFFD0D5DD),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('취소'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff578FCA),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed:
                                        _isSubmitting ? null : _handleSubmit,
                                    child:
                                        _isSubmitting
                                            ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                      Colors.white,
                                                    ),
                                              ),
                                            )
                                            : const Text('생성'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
