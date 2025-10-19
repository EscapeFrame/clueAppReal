import 'package:clue/config/app_data_.dart';
import 'package:clue/linksave/LinkList.dart';
import 'package:clue/linksave/LinkSujeong.dart' as link_edit;
import 'package:clue/linksave/LinksaveModal.dart' as link_add;
import 'package:clue/linksave/NoLink.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Cluelink extends StatefulWidget {
  const Cluelink({super.key});

  @override
  State<Cluelink> createState() => _CluelinkState();
}

class _CluelinkState extends State<Cluelink> {
  final List<String> categories = ['전체', '인문과목', '전공과목', '방과후'];
  final List<Map<String, dynamic>> _links =
      AppData.getLinkDummyList()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
  int selectedIndex = 0; //기본선택 : 전체

  List<Map<String, dynamic>> get _filteredLinks {
    if (selectedIndex == 0) return _links;
    final category = categories[selectedIndex];
    return _links.where((link) {
      final tags = (link['tags'] as List?)?.cast<String>() ?? const <String>[];
      return tags.contains(category);
    }).toList();
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
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
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
        child: const Icon(
          Icons.add,
          color: Color(0xffffffff),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.062),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/link.svg',
                            width: width * 0.1,
                          ),
                          SvgPicture.asset(
                            'assets/images/cluelinkText.svg',
                            width: width * 0.25,
                          ),
                        ],
                      ),
                    ),

                    Container(
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/bars-3.svg',
                            width: width * 0.074,
                          ),
                          SizedBox(width: width * 0.03),
                          SvgPicture.asset(
                            'assets/images/jong.svg',
                            width: width * 0.055,
                          ),
                          SizedBox(width: width * 0.0443),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.02),
                Container(
                  decoration: BoxDecoration(
                    // color: Colors.grey.shade200,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: double.infinity,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "검색할 내용을 입력하세요",
                      hintStyle: TextStyle(color: Colors.grey.shade700),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 17,
                      ),
                      // suffixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                    ),
                  ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
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
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: height * 0.012),
              ],
            ),
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
                            onEdit:
                                originalIndex == -1
                                    ? null
                                    : () async {
                                        final edited =
                                            await link_edit.showLinkEditDialog(
                                          context,
                                          initial: link_edit.LinkEditPayload(
                                            title:
                                                item['title'] as String? ?? '',
                                            url: item['url'] as String? ?? '',
                                            description:
                                                item['description'] as String?,
                                            tags: List<String>.from(tags),
                                            restrictByGrade:
                                                item['restrictByGrade'] == true,
                                            restrictByClass:
                                                item['restrictByClass'] == true,
                                          ),
                                          allTags: _collectAllTags(),
                                        );
                                        if (edited != null) {
                                          setState(() {
                                            final updated = Map<String,
                                                dynamic>.from(
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
                                        }
                                      },
                          );
                        },
                        separatorBuilder: (_, __) => SizedBox(height: height * 0.02),
                        itemCount: _filteredLinks.length,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
