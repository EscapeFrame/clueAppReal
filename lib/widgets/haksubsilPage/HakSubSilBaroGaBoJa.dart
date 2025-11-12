import 'package:clue/api_client.dart';
import 'package:clue/widgets/haksubsilPage/HakSubSilSuap.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HakSubSilBaroGaBoJa extends StatelessWidget {
  const HakSubSilBaroGaBoJa({
    super.key,
    required this.noticeList,
    this.subjectFilter,
    this.emptyMessage,
  });

  final List<Map<String, dynamic>> noticeList;
  final String? subjectFilter;
  final String? emptyMessage;

  List<Map<String, dynamic>> _filteredNotices() {
    final validNotices =
        noticeList
            .where(
              (notice) => (notice['classRoomId'] ?? '').toString().trim().isNotEmpty,
            )
            .map((notice) {
              final copy = Map<String, dynamic>.from(notice);
              final name = (copy['name'] ?? '').toString().trim();
              if (name.isEmpty) {
                final fallback = (copy['title'] ?? '').toString().trim();
                if (fallback.isNotEmpty) copy['name'] = fallback;
              }
              return copy;
            })
            .toList();

    if (subjectFilter == null || subjectFilter!.isEmpty) {
      return validNotices;
    }

    return validNotices
        .where(
          (notice) => (notice['subject'] ?? '').toString() == subjectFilter,
        )
        .toList();
  }

  Future<Map<String, dynamic>> _classRoomDetailApi(
    Map<String, dynamic> notice,
  ) async {
    final classRoomId = notice['classRoomId'];
    if (classRoomId == null) return {};

    try {
      final api = ApiClient.instance.dio;
      final response = await api.get('/api/class/$classRoomId/all');
      final raw = response.data;
      if (raw is! Map) return {};

      final data = Map<String, dynamic>.from(raw);
      data['classRoomIdStr'] = (data['classRoomId'] ?? classRoomId).toString();
      return data;
    } on DioException catch (e) {
      debugPrint('classRoom detail dio error: ${e.message}');
      return {};
    } catch (e) {
      debugPrint('classRoom detail error: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final filtered = _filteredNotices();
    final iconChanger = 'asdfasdf'; //임시
    if (filtered.isEmpty) {
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
                  emptyMessage ?? '표시할 학습실이 없습니다.',
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
        itemCount: filtered.length,
        separatorBuilder: (_, __) => SizedBox(height: width * 0.02),
        itemBuilder: (context, index) {
          final notice = filtered[index];
          return GestureDetector(
            onTap: () async {
              final detail = await _classRoomDetailApi(notice);
              if (detail.isEmpty) return;

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Haksubsilsuap(notice: detail),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(
                width * 0.045,
                width * 0.045,
                width * 0.055,
                width * 0.055,
              ),
              decoration: BoxDecoration(
                color: Color(0xffffffff),
                borderRadius: BorderRadius.circular(width * 0.025),
                border: Border.all(color: Color(0xffE9E9E9), width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: width * 0.1,
                              height: width * 0.1,
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child:
                                  iconChanger == 'inmoon'
                                      ? Transform.scale(
                                        scale: width * 0.06 / 20,
                                        child: SvgPicture.asset(
                                          'assets/images/bookIcon.svg',

                                          fit: BoxFit.scaleDown,
                                        ),
                                      )
                                      : iconChanger == 'jeongong'
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
                            Text(
                              (notice['name'] ?? '').toString(),
                              style: TextStyle(
                                fontSize: width * 0.05,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: width * 0.012),
                  Row(
                    children: [
                      Text(
                        '${(notice['sort'] ?? '').toString()}  |  ${(notice['target'] ?? '').toString()}',
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
                        '사람 ${notice['studentCount'] ?? '-'} 명',
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
