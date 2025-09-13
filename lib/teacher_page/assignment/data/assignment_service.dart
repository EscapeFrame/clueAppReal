import 'package:clue/api_client.dart';
import 'package:clue/teacher_page/assignment/models/assignment.dart';
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

