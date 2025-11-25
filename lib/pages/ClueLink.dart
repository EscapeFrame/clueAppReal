import 'package:clue/api_client.dart';
import 'package:clue/linksave/LinkList.dart';
import 'package:clue/linksave/LinkSuccessDialog.dart';
import 'package:clue/linksave/LinkSujeong.dart' as link_edit;
import 'package:clue/linksave/LinksaveModal.dart' as link_add;
import 'package:clue/linksave/NoLink.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'Alarm.dart';

class Cluelink extends StatefulWidget {
  const Cluelink({super.key});

  @override
  State<Cluelink> createState() => _CluelinkState();
}

class _CluelinkState extends State<Cluelink> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<String> categories = ['전체', '인문과목', '전공과목', '방과후'];
  int selectedIndex = 0; // 기본 선택 : 전체
  final List<Map<String, dynamic>> _links = [];
  late final TextEditingController _searchController;
  String _searchQuery = '';

  List<Map<String, dynamic>> get _filteredLinks {
    final query = _searchQuery.trim().toLowerCase();
    Iterable<Map<String, dynamic>> items = _links;

    if (selectedIndex != 0) {
      final category = categories[selectedIndex];
      items = items.where((link) {
        final tags =
            (link['tags'] as List?)?.cast<String>() ?? const <String>[];
        return tags.contains(category);
      });
    }

    if (query.isNotEmpty) {
      items = items.where((link) {
        final title = (link['title'] as String? ?? '').toLowerCase();
        return title.contains(query);
      });
    }

    return items.toList();
  }

  List<String> _collectAllTags() {
    final tagSet = <String>{};
    for (final link in _links) {
      final tags = (link['tags'] as List?)?.cast<String>() ?? const <String>[];
      tagSet.addAll(tags);
    }
    tagSet.addAll(categories.where((c) => c != '전체'));
    return tagSet.toList();
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fetchLinkSave();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLinkSave() async {
    try {
      final dio = ApiClient.instance.dio;
      final res = await dio.get('/api/linksave');
      final data = res.data;
      if (data is! List) {
        debugPrint('링크 저장 응답 형식이 리스트가 아닙니다: ${data.runtimeType}');
        return;
      }

      final fetched =
          data
              .whereType<Map<String, dynamic>>()
              .map(_mapApiLinkToUi)
              .whereType<Map<String, dynamic>>()
              .toList();

      if (!mounted) return;
      setState(() {
        _links
          ..clear()
          ..addAll(fetched);
      });
    } on DioException catch (e) {
      debugPrint('링크 저장 요청 실패: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('링크 저장 데이터 변환 오류: $e');
    }
  }

  Map<String, dynamic>? _mapApiLinkToUi(Map<String, dynamic> item) {
    final subjectType = item['subjectType'] as String?;
    final subjectLabel = _subjectTypeToLabel(subjectType);
    return {
      'id': item['id'],
      'title': item['title'] as String? ?? '',
      'url': item['link'] as String? ?? '',
      'description': item['description'] as String?,
      'tags': [
        if (subjectLabel != null && subjectLabel.isNotEmpty) subjectLabel,
      ],
      'restrictByGrade': false,
      'restrictByClass': false,
      'createdAt': item['createdAt'] as String?,
    };
  }

  String? _subjectTypeToLabel(String? subjectType) {
    switch (subjectType) {
      case 'General':
        return '인문과목';
      case 'Professional':
        return '전공과목';
      case 'AfterSchool':
        return '방과후';
      default:
        return null;
    }
  }

  Future<void> _deleteLink(int? id, int originalIndex) async {
    Map<String, dynamic>? removed;
    if (originalIndex >= 0 && originalIndex < _links.length) {
      removed = Map<String, dynamic>.from(_links[originalIndex]);
      setState(() => _links.removeAt(originalIndex));
    }
    try {
      if (id != null) {
        await ApiClient.instance.dio.delete('/api/linksave/$id');
      }
      await _fetchLinkSave();
    } on DioException catch (e) {
      debugPrint('링크 삭제 요청 실패: ${e.response?.data ?? e.message}');
      if (removed != null && mounted) {
        setState(() => _links.insert(originalIndex, removed!));
      }
    } catch (e) {
      debugPrint('링크 삭제 처리 중 오류: $e');
      if (removed != null && mounted) {
        setState(() => _links.insert(originalIndex, removed!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await link_add.showLinkAddDialog(context);
          if (result != null) {
            setState(() {
              _links.insert(0, {
                'title': result.title,
                'url': result.url,
                'description': result.description,
                'tags': result.tags,
                'restrictByGrade': result.restrictByGrade,
                'restrictByClass': result.restrictByClass,
                'createdAt': _formatDate(DateTime.now()),
              });
            });
          }
        },
        backgroundColor: const Color(0xff0077FF),
        child: const Icon(Icons.add, color: Color(0xffffffff)),
      ),
      endDrawer: const _LinkSideMenu(),
      body: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const Alarm(),
                                ),
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
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.0443),
                child: Column(
                  children: [
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
                              onChanged:
                                  (value) =>
                                      setState(() => _searchQuery = value),
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
                            setState(() => selectedIndex = index);
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

              SizedBox(height: height * 0.012),
            ],
          ),
          Expanded(
            child: Container(
              color: Colors.grey.shade200,
              child:
                  _filteredLinks.isEmpty
                      ? const Nolink()
                      : ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          width * 0.05,
                          height * 0.02,
                          width * 0.05,
                          height * 0.04,
                        ),
                        itemBuilder: (context, index) {
                          final item = _filteredLinks[index];
                          final tags =
                              (item['tags'] as List?)?.cast<String>() ??
                              const <String>[];
                          final originalIndex = _links.indexOf(item);
                          return LinkList(
                            title: item['title'] as String? ?? '',
                            url: item['url'] as String? ?? '',
                            description: item['description'] as String?,
                            tags: tags,
                            restrictByGrade: item['restrictByGrade'] == true,
                            restrictByClass: item['restrictByClass'] == true,
                            createdAt: item['createdAt'] as String?,
                            onDelete:
                                originalIndex == -1
                                    ? null
                                    : () async {
                                      await _deleteLink(
                                        item['id'] as int?,
                                        originalIndex,
                                      );
                                    },
                            onEdit:
                                originalIndex == -1
                                    ? null
                                    : () async {
                                      final edited = await link_edit
                                          .showLinkEditDialog(
                                            context,
                                            initial: link_edit.LinkEditPayload(
                                              title:
                                                  item['title'] as String? ??
                                                  '',
                                              url: item['url'] as String? ?? '',
                                              description:
                                                  item['description']
                                                      as String?,
                                              tags: List<String>.from(tags),
                                              restrictByGrade:
                                                  item['restrictByGrade'] ==
                                                  true,
                                              restrictByClass:
                                                  item['restrictByClass'] ==
                                                  true,
                                            ),
                                            allTags: _collectAllTags(),
                                          );
                                      if (edited != null) {
                                        setState(() {
                                          final updated =
                                              Map<String, dynamic>.from(
                                                _links[originalIndex],
                                              );
                                          updated
                                            ..['title'] = edited.title
                                            ..['url'] = edited.url
                                            ..['description'] =
                                                edited.description
                                            ..['tags'] = edited.tags
                                            ..['restrictByGrade'] =
                                                edited.restrictByGrade
                                            ..['restrictByClass'] =
                                                edited.restrictByClass;
                                          _links[originalIndex] = updated;
                                        });
                                        if (!context.mounted) return;
                                        await showDialog<void>(
                                          context: context,
                                          barrierDismissible: false,
                                          builder:
                                              (_) => const LinkSuccessDialog(),
                                        );
                                      }
                                    },
                          );
                        },
                        separatorBuilder:
                            (_, __) => SizedBox(height: height * 0.02),
                        itemCount: _filteredLinks.length,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkSideMenu extends StatelessWidget {
  const _LinkSideMenu();

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final theme = Theme.of(context);
    final double drawerWidth =
        (media.size.width * 0.78).clamp(280.0, media.size.width).toDouble();

    return Drawer(
      width: drawerWidth,

      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    splashRadius: 20,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 24),
                const _MenuEntry(text: 'CLUE 서비스로 이동'),
                const SizedBox(height: 22),
                const _MenuEntry(text: '설정'),
                const SizedBox(height: 22),
                const _MenuEntry(text: '문의하기'),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F3FF),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE1E5EB),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '공덕한',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0D6EFD),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.copy_outlined,
                        size: 20,
                        color: Color(0xFF0D6EFD),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuEntry extends StatelessWidget {
  const _MenuEntry({required this.text, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w500,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Text(text, style: style)),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _MenuIndicator extends StatelessWidget {
  const _MenuIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.only(left: 12),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF3BC56C),
      ),
    );
  }
}
