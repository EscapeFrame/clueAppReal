// 과제 제출 및 제출 취소 API 호출.
import 'package:clue/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';


Future<void> submitAssignment(String submissionId) async {
  debugPrint("submit id: $submissionId");
  try {
    final api = ApiClient.instance.dio;
    final data = await api.patch('/api/submissions/$submissionId/submit');
    debugPrint('과제 제출 응답: $data');
  } on DioException catch (e) {
    debugPrint('과제 제출 오류: ${e.message}');
  } catch (e) {
    debugPrint('과제 제출 오류: $e');
  }
}

/// Cancels a submission by submissionId.
Future<void> cancelSubmission(String submissionId) async {
  debugPrint("cancel id: $submissionId");
  try {
    final api = ApiClient.instance.dio;
    final data = await api.patch('/api/submissions/$submissionId/cancel');
    debugPrint('과제 제출 취소 응답: $data');
  } on DioException catch (e) {
    debugPrint('과제 제출 취소 오류: ${e.message}');
  } catch (e) {
    debugPrint('과제 제출 취소 오류: $e');
  }
}
