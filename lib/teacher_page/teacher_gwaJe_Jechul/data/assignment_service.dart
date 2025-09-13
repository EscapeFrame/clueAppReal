import 'package:clue/api_client.dart';
import 'package:clue/teacher_page/teacher_gwaJe_Jechul/models/assignment.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AssignmentService {
  static Future<List<Map<String, dynamic>>> fetchAssignments(String classRoomId) async {
    try {
      final api = ApiClient.instance.dio;
      final res = await api.get(
        '/api/assignments/$classRoomId/all',
        options: Options(validateStatus: (_) => true),
      );
      final data = res.data;
      if (res.statusCode == 200 && data is List) {
        return normalizeAssignments(data);
      }
      return <Map<String, dynamic>>[];
    } on DioException catch (e) {
      debugPrint('status : ${e.response?.statusCode}');
      debugPrint('data   : ${e.response?.data}');
      debugPrint('headers: ${e.response?.headers}');
      debugPrint('msg    : ${e.message}');
      return <Map<String, dynamic>>[];
    } catch (e) {
      debugPrint('assignments load error: $e');
      return <Map<String, dynamic>>[];
    }
  }
}
// 과제 목록/데이터를 서버에서 가져오는 서비스 레이어.
// API 호출과 모델 정규화(normalizeAssignments)를 연결해 화면에서 바로 쓸 수 있게 반환합니다.
