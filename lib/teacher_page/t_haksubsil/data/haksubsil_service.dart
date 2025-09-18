// tHakSubSilGaJa.dart의 api 통신
// 상세 조회, 첨부 업로드/삭제, 다운로드 바이트 수신 등.

import 'package:clue/api_client.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class HaksubsilService {
  static Future<Map<String, dynamic>?> fetchAssignmentDetail(String id) async {
    try {
      final api = ApiClient.instance.dio;
      final res = await api.get('/api/assignments/$id');
      debugPrint('detail status=${res.statusCode}, data=${res.data}');

      if (res.statusCode == 200 && res.data is Map) {
        return Map<String, dynamic>.from(res.data as Map);
      }
      return null;
    } on DioException catch (e) {
      debugPrint('detail error: ${e.response?.data}');
      return null;
    } catch (e) {
      debugPrint('detail error: $e');
      return null;
    }
  }

  static Future<bool> deleteAttachment(String attachmentId) async {
    try {
      final dio = ApiClient.instance.dio;
      final res = await dio.delete('/api/assignments/attachment/$attachmentId');
      debugPrint('delete status=${res.statusCode}, data=${res.data}');
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      debugPrint('delete error: $e');
      return false;
    }
  }

  static Future<bool> uploadFileAttachment(String assignmentId, PlatformFile file) async {
    try {
      final mf = await MultipartFile.fromFile(file.path!, filename: file.name);
      final form = FormData.fromMap({'files': mf});
      final dio = ApiClient.instance.dio;
      final res = await dio.post('/api/assignments/$assignmentId/file', data: form);
      return (res.statusCode ?? 500) < 300;
    } on DioException catch (e) {
      debugPrint('upload file dio error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('upload file error: $e');
      return false;
    }
  }

  static Future<bool> uploadUrlAttachment(String assignmentId, String url) async {
    try {
      final dio = ApiClient.instance.dio;
      final res = await dio.post('/api/assignments/$assignmentId/link', data: [
        {'url': url.trim()},
      ]);
      final code = res.statusCode ?? 500;
      // debugPrint('요청값 : ${res.data}');
      return code >= 200 && code < 300;
    } on DioException catch (e) {
      debugPrint('upload url dio error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('upload url error: $e');
      return false;
    }
  }

  static Future<List<int>?> downloadAttachmentBytes(String attachmentId) async {
    try {
      final dio = ApiClient.instance.dio;
      final res = await dio.get(
        '/api/assignments/$attachmentId/download',
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (s) => s != null && s < 500,
        ),
      );
      if (res.statusCode == 200) {
        return (res.data as List<int>);
      }
      return null;
    } on DioException catch (e) {
      debugPrint('download dio error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('download error: $e');
      return null;
    }
  }
}
