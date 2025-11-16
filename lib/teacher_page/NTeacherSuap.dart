import 'package:clue/teacher_page/tHakSubsilSuapTrue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TeacherSuapListSection extends StatelessWidget {
  const TeacherSuapListSection({
    super.key,
    required this.teacherHakSubSil,
    this.activationFilter,
    this.onRefresh,
    this.emptyMessage,
  });

  final List<Map<String, dynamic>> teacherHakSubSil;
  final bool? activationFilter;
  final Future<void> Function()? onRefresh;
  final String? emptyMessage;

  List<Map<String, dynamic>> _filteredItems() {
    if (activationFilter == null) {
      return teacherHakSubSil.map(Map<String, dynamic>.from).toList();
    }
    return teacherHakSubSil
        .where((item) => (item['activation'] ?? false) == activationFilter)
        .map(Map<String, dynamic>.from)
        .toList();
  }

  Future<void> _openDetail(
    BuildContext context,
    Map<String, dynamic> tsuap,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => Thaksubsilsuaptrue(tsuap: tsuap)),
    );
    if (onRefresh != null) {
      await onRefresh!.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final items = _filteredItems();

    if (items.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                color: const Color(0xffF7F7F7),
                alignment: Alignment.center,
                child: Text(
                  emptyMessage ?? '게시된 수업이 없습니다.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      );
    }

    return Container(
      decoration: const BoxDecoration(color: Color(0xffF7F7F7)),
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: width * 0.03,
      ),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(height: width * 0.02),
        itemBuilder: (context, index) {
          final tsuap = items[index];
          final String name =
              (tsuap['name'] ?? tsuap['classRoomId'] ?? '').toString();
          final String sort = (tsuap['sort'] ?? '').toString();
          final String target = (tsuap['target'] ?? '').toString();
          final String studentCount = (tsuap['studentCount'] ?? '-').toString();
          final String iconKey =
              (tsuap['subject'] ?? tsuap['sort'] ?? '')
                  .toString()
                  .toLowerCase();
          final bool isActivated = (tsuap['activation'] ?? false) == true;

          return GestureDetector(
            onTap: () => _openDetail(context, tsuap),
            child: Container(
              padding: EdgeInsets.fromLTRB(
                width * 0.045,
                width * 0.045,
                width * 0.055,
                width * 0.055,
              ),
              decoration: BoxDecoration(
                color: const Color(0xffffffff),
                borderRadius: BorderRadius.circular(width * 0.025),
                border: Border.all(color: const Color(0xffE9E9E9), width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: width * 0.1,
                              height: width * 0.1,
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child:
                                  iconKey == 'inmoon'
                                      ? Transform.scale(
                                        scale: width * 0.06 / 20,
                                        child: SvgPicture.asset(
                                          'assets/images/bookIcon.svg',
                                          fit: BoxFit.scaleDown,
                                        ),
                                      )
                                      : iconKey == 'jeongong'
                                      ? Transform.scale(
                                        scale: width * 0.06 / 20,
                                        child: SvgPicture.asset(
                                          'assets/images/capIcon.svg',
                                          fit: BoxFit.scaleDown,
                                        ),
                                      )
                                      : Transform.scale(
                                        scale: width * 0.06 / 20,
                                        child: SvgPicture.asset(
                                          'assets/images/bangGwaHooIcon.svg',
                                          fit: BoxFit.scaleDown,
                                        ),
                                      ),
                            ),
                            SizedBox(width: width * 0.027),
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: width * 0.05,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: width * 0.02),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xff86C1FF),
                        ),
                        child: Text(
                          isActivated ? '활성화' : '비활성화',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: width * 0.012),
                  Row(
                    children: [
                      Text(
                        '$sort  |  $target',
                        style: TextStyle(
                          fontSize: width * 0.04,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: width * 0.01),
                    ],
                  ),
                  SizedBox(height: width * 0.008),
                  Row(
                    children: [
                      const Icon(Icons.people, color: Colors.grey),
                      const SizedBox(width: 10),
                      Text(
                        '학생 $studentCount 명',
                        style: TextStyle(fontSize: width * 0.04),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
