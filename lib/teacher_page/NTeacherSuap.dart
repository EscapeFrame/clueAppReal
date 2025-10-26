import 'package:clue/teacher_page/tHakSubsilSuapTrue.dart';
import 'package:flutter/material.dart';

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
      return Container(
        color: const Color(0xffF7F7F7),
        child: Center(
          child: Text(
            emptyMessage ?? '표시할 학습실이 없습니다.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: width * 0.04,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(color: Color(0xffF7F7F7)),
      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(height: width * 0.02),
        itemBuilder: (context, index) {
          final tsuap = items[index];
          final bool isActivated = (tsuap['activation'] ?? false) == true;
          final String name =
              (tsuap['name'] ?? tsuap['classRoomId'] ?? '').toString();
          final String sort = (tsuap['sort'] ?? '').toString();
          final String target = (tsuap['target'] ?? '').toString();
          final String studentCount = (tsuap['studentCount'] ?? '-').toString();

          return Container(
            padding: EdgeInsets.fromLTRB(
              width * 0.045,
              width * 0.045,
              width * 0.055,
              width * 0.037,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width * 0.025),
              border: Border.all(color: Colors.grey, width: 0.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
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
                SizedBox(height: width * 0.008),
                Row(
                  children: [
                    Text(
                      sort,
                      style: TextStyle(
                        fontSize: width * 0.04,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(width: width * 0.01),
                    Text(
                      '|',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: width * 0.035,
                      ),
                    ),
                    SizedBox(width: width * 0.01),
                    Text(
                      target,
                      style: TextStyle(
                        fontSize: width * 0.04,
                        color: Colors.grey,
                      ),
                    ),
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
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xff86C1FF),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '관리',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: width * 0.037,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: width * 0.025),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openDetail(context, tsuap),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 3,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xff86C1FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xff86C1FF),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '학습실보기',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: width * 0.037,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
