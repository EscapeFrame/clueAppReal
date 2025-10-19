import 'dart:async';
import 'dart:io';

import 'package:clue/api_client.dart';
import 'package:clue/notification.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const String assignmentSyncTaskName = 'assignment_sync_task';
const String assignmentSyncUniqueNameAndroid = 'assignment_sync_worker';
const String assignmentSyncUniqueNameIOS = 'assignment_sync_worker_ios';

class AssignmentNotificationService {
  AssignmentNotificationService._();

  static const _notifiedKey = 'notified_assignment_triggers';
  static bool _backgroundTaskRegistered = false;

  static Future<void> ensureBackgroundTaskRegistered() async {
    if (_backgroundTaskRegistered) return;
    if (!(Platform.isAndroid || Platform.isIOS)) return;

    try {
      await Workmanager().initialize(
        assignmentSyncCallbackDispatcher,
        isInDebugMode: false,
      );

      if (Platform.isAndroid) {
        await Workmanager().registerPeriodicTask(
          assignmentSyncUniqueNameAndroid,
          assignmentSyncTaskName,
          frequency: const Duration(hours: 1),
          initialDelay: const Duration(minutes: 15),
          constraints: Constraints(networkType: NetworkType.connected),
          existingWorkPolicy: ExistingWorkPolicy.keep,
        );
      } else {
        await Workmanager().registerOneOffTask(
          assignmentSyncUniqueNameIOS,
          Workmanager.iOSBackgroundTask,
          initialDelay: const Duration(minutes: 15),
          existingWorkPolicy: ExistingWorkPolicy.keep,
        );
      }

      _backgroundTaskRegistered = true;
    } catch (e) {
      debugPrint('Workmanager setup failed: $e');
    }
  }

  static Future<List<Map<String, dynamic>>?> syncAssignments({
    bool requestPermission = false,
  }) async {
    await _ensureEnvLoaded();

    await FlutterLocalNotification.init(); //로컬 알림 플러그인 초기화
    if (requestPermission) {
      await FlutterLocalNotification.requestNotificationPermission(); //권한 요청
    }

    final assignments = await _fetchAssignments();
    if (assignments == null) {
      return null;
    }

    if (assignments.isEmpty) {
      await _cleanupObsoleteAssignments(<String>{});
      return assignments;
    }

    await _processAssignments(assignments);
    return assignments;
  }

  static Future<void> _ensureEnvLoaded() async {
    if (dotenv.env.isEmpty) {
      try {
        await dotenv.load(fileName: '.env');
      } catch (_) {
        // Ignore missing env when running in background isolates without assets.
      }
    }
  }

  static Future<List<Map<String, dynamic>>?> _fetchAssignments() async {
    final dio = ApiClient.instance.dio;
    try {
      final response = await dio.get('/api/assignments/me');
      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } on DioException catch (e) {
      debugPrint('Assignment fetch failed: ${e.message}');
    } catch (e) {
      debugPrint('Assignment fetch error: $e');
    }
    return null;
  }

  static Future<void> _processAssignments(
    List<Map<String, dynamic>> assignments,
  ) async {
    SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('SharedPreferences init failed: $e');
      return;
    }
    final notified = prefs.getStringList(_notifiedKey)?.toSet() ?? <String>{};
    final activeAssignmentIds = <String>{};
    bool updated = false;

    final now = DateTime.now();

    for (final assignment in assignments) {
      final assignmentId = (assignment['assignmentId'] ?? '').toString();
      if (assignmentId.isEmpty) {
        continue;
      }
      activeAssignmentIds.add(assignmentId);

      final endDate = _parseDate((assignment['endDate'] ?? '').toString());
      if (endDate == null) {
        continue;
      }

      if (!endDate.isAfter(now)) {
        await FlutterLocalNotification.cancelAllAssignmentReminders(
          assignmentId,
        );
        updated = notified.remove(_triggerKey(assignmentId, 3)) || updated;
        updated = notified.remove(_triggerKey(assignmentId, 1)) || updated;
        continue;
      }

      final remaining = endDate.difference(now);
      if (remaining > const Duration(days: 3)) {
        // 너무 멀리 있는 마감은 아직 알림을 예약하지 않는다.
        await FlutterLocalNotification.cancelAllAssignmentReminders(
          assignmentId,
        );
        updated = notified.remove(_triggerKey(assignmentId, 3)) || updated;
        updated = notified.remove(_triggerKey(assignmentId, 1)) || updated;
        continue;
      }

      final title = (assignment['title'] ?? '과제').toString();
      final threeDayTrigger = endDate.subtract(const Duration(days: 3));
      final oneDayTrigger = endDate.subtract(const Duration(days: 1));

      if (threeDayTrigger.isAfter(now)) {
        await FlutterLocalNotification.scheduleAssignmentReminder(
          assignmentId: assignmentId,
          title: title,
          endDate: endDate,
          daysBefore: 3,
        );
        if (notified.remove(_triggerKey(assignmentId, 3))) {
          updated = true;
        }
      } else if (oneDayTrigger.isAfter(now)) {
        final key = _triggerKey(assignmentId, 3);
        if (!notified.contains(key)) {
          await FlutterLocalNotification.showAssignmentReminderNow(
            assignmentId: assignmentId,
            title: title,
            daysBefore: 3,
          );
          notified.add(key);
          updated = true;
        }
      }

      if (oneDayTrigger.isAfter(now)) {
        await FlutterLocalNotification.scheduleAssignmentReminder(
          assignmentId: assignmentId,
          title: title,
          endDate: endDate,
          daysBefore: 1,
        );
        if (notified.remove(_triggerKey(assignmentId, 1))) {
          updated = true;
        }
      } else {
        final key = _triggerKey(assignmentId, 1);
        if (!notified.contains(key)) {
          await FlutterLocalNotification.showAssignmentReminderNow(
            assignmentId: assignmentId,
            title: title,
            daysBefore: 1,
          );
          notified.add(key);
          updated = true;
        }
      }
    }

    updated =
        await _cleanupObsoleteAssignments(activeAssignmentIds, notified) ||
        updated;

    if (updated) {
      await prefs.setStringList(_notifiedKey, notified.toList());
    }
  }

  static Future<bool> _cleanupObsoleteAssignments(
    Set<String> activeAssignments, [
    Set<String>? notified,
  ]) async {
    SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('SharedPreferences init failed: $e');
      return false;
    }

    final set = notified ?? prefs.getStringList(_notifiedKey)?.toSet();
    if (set == null || set.isEmpty) {
      return false;
    }

    bool updated = false;
    final entries = set.toList();
    for (final entry in entries) {
      final assignmentId = entry.split('|').first;
      if (!activeAssignments.contains(assignmentId)) {
        await FlutterLocalNotification.cancelAllAssignmentReminders(
          assignmentId,
        );
        updated = set.remove(entry) || updated;
      }
    }

    if (updated && notified == null) {
      await prefs.setStringList(_notifiedKey, set.toList());
    }

    return updated;
  }

  static DateTime? _parseDate(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      return DateTime.parse(s.replaceAll(' ', 'T'));
    } catch (_) {
      return null;
    }
  }

  static String _triggerKey(String assignmentId, int daysBefore) =>
      '$assignmentId|$daysBefore';
}

@pragma('vm:entry-point')
void assignmentSyncCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      if (task == assignmentSyncTaskName ||
          task == Workmanager.iOSBackgroundTask) {
        await AssignmentNotificationService.syncAssignments();
        if (Platform.isIOS) {
          await Workmanager().registerOneOffTask(
            assignmentSyncUniqueNameIOS,
            Workmanager.iOSBackgroundTask,
            initialDelay: const Duration(minutes: 15),
            existingWorkPolicy: ExistingWorkPolicy.replace,
          );
        }
      }
      return Future.value(true);
    } catch (e) {
      debugPrint('Background assignment sync failed: $e');
      return Future.value(false);
    }
  });
}
