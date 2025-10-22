import 'package:clue/api_client.dart';
import 'package:clue/widgets/haksubsilPage/HakSubSilSuap.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

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
    if (subjectFilter == null || subjectFilter!.isEmpty) {
      return List<Map<String, dynamic>>.from(noticeList);
    }

    return noticeList
        .where(
          (notice) => (notice['subject'] ?? '').toString() == subjectFilter,
        )
        .map((notice) => Map<String, dynamic>.from(notice))
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
      data['classRoomIdStr'] =
          (data['classRoomId'] ?? classRoomId).toString();
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

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          emptyMessage ?? '표시할 학습실이 없습니다.',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: width * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
      child: ListView.separated(
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
                          (notice['name'] ?? notice['classRoomId'] ?? '')
                              .toString(),
                          style: TextStyle(
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: width * 0.008),
                  Row(
                    children: [
                      Text(
                        (notice['sort'] ?? '').toString(),
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
                        (notice['target'] ?? '').toString(),
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
                        '사람 ${notice['studentCount'] ?? '-'} 명',
                        style: TextStyle(fontSize: width * 0.04),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Spacer(),
                      Text(
                        '과제 보기 >',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: width * 0.04,
                        ),
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
