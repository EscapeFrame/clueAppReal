// 과제 생성 모달창
// 제목/내용/날짜 입력을 받고 유효성 검사 후 post로 전달.

import 'package:clue/api_client.dart';
import 'package:clue/teacher_page/teacher_gwaJe_Jechul/utils/date_time.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

Future<Map<String, dynamic>?> showCreateAssignmentSheet({
  required BuildContext context,
  required String classRoomId,
}) async {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  Map<String, dynamic>? result;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final base = Theme.of(ctx);
      final sheetTheme = base.copyWith(
        colorScheme: base.colorScheme.copyWith(
          primary: const Color(0xff578FCA),
          secondary: const Color(0xff578FCA),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xff578FCA),
          selectionColor: Color(0x33578FCA),
          selectionHandleColor: Color(0xff578FCA),
        ),
      );
      return Theme(
        data: sheetTheme,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 12,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              Future<void> pickStartDate() async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: startDate ?? now,
                  firstDate: DateTime(now.year - 1),
                  lastDate: DateTime(now.year + 5),
                  builder: (context, child) {
                    final base = Theme.of(context);
                    final cs = base.colorScheme;
                    final themed = ThemeData.light().copyWith(
                      colorScheme: cs.copyWith(
                        primary: const Color(0xff578FCA),
                        secondary: const Color(0xff578FCA),
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                      textTheme: base.textTheme.apply(
                        bodyColor: Colors.black,
                        displayColor: Colors.black,
                      ),
                      datePickerTheme: const DatePickerThemeData(
                        backgroundColor: Colors.white,
                        headerBackgroundColor: Colors.white,
                        headerForegroundColor: Colors.black,
                      ),
                      dialogTheme: const DialogTheme(
                        backgroundColor: Colors.white,
                      ),
                    );
                    return Theme(data: themed, child: child!);
                  },
                );
                if (picked != null) {
                  final initialTime = startDate != null
                      ? TimeOfDay.fromDateTime(startDate!)
                      : TimeOfDay.now();
                  final t = await showTimePicker(
                    context: context,
                    initialTime: initialTime,
                    initialEntryMode: TimePickerEntryMode.input,
                    builder: (context, child) {
                      final base = Theme.of(context);
                      final cs = base.colorScheme;
                      final themed = ThemeData.light().copyWith(
                        colorScheme: cs.copyWith(
                          primary: const Color(0xff578FCA),
                          secondary: const Color(0xff86C1FF),
                          surface: Colors.white,
                          onSurface: Colors.black,
                        ),
                        dialogTheme: const DialogTheme(
                          backgroundColor: Colors.white,
                        ),
                        timePickerTheme: TimePickerThemeData(
                          backgroundColor: Colors.white,
                          hourMinuteColor: WidgetStateColor.resolveWith((states) {
                            if (states.contains(WidgetState.selected) ||
                                states.contains(WidgetState.focused)) {
                              return const Color(0xFFE0E0E0);
                            }
                            return Colors.white;
                          }),
                          dayPeriodColor: WidgetStateColor.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return const Color(0xff86C1FF);
                            }
                            return Colors.white;
                          }),
                          dialBackgroundColor: const Color(0xFFE0E0E0),
                        ),
                        inputDecorationTheme: const InputDecorationTheme(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff86C1FF)),
                          ),
                        ),
                        textTheme: base.textTheme.apply(
                          bodyColor: Colors.black,
                          displayColor: Colors.black,
                        ),
                      );
                      return Theme(data: themed, child: child!);
                    },
                  );
                  final time = t ?? const TimeOfDay(hour: 0, minute: 0);
                  setSheetState(() {
                    startDate = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              }

              Future<void> pickEndDate() async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: endDate ?? (startDate ?? now),
                  firstDate: DateTime(now.year - 1),
                  lastDate: DateTime(now.year + 5),
                  builder: (context, child) {
                    final base = Theme.of(context);
                    final cs = base.colorScheme;
                    final themed = ThemeData.light().copyWith(
                      colorScheme: cs.copyWith(
                        primary: const Color(0xff578FCA),
                        secondary: const Color(0xff578FCA),
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                      textTheme: base.textTheme.apply(
                        bodyColor: Colors.black,
                        displayColor: Colors.black,
                      ),
                      datePickerTheme: const DatePickerThemeData(
                        backgroundColor: Colors.white,
                        headerBackgroundColor: Colors.white,
                        headerForegroundColor: Colors.black,
                      ),
                      dialogTheme: const DialogTheme(
                        backgroundColor: Colors.white,
                      ),
                    );
                    return Theme(data: themed, child: child!);
                  },
                );
                if (picked != null) {
                  final initialTime = endDate != null
                      ? TimeOfDay.fromDateTime(endDate!)
                      : const TimeOfDay(hour: 23, minute: 59);
                  final t = await showTimePicker(
                    context: context,
                    initialTime: initialTime,
                    initialEntryMode: TimePickerEntryMode.input,
                    builder: (context, child) {
                      final base = Theme.of(context);
                      final cs = base.colorScheme;
                      final themed = ThemeData.light().copyWith(
                        colorScheme: cs.copyWith(
                          primary: const Color(0xff578FCA),
                          secondary: const Color(0xff86C1FF),
                          surface: Colors.white,
                          onSurface: Colors.black,
                        ),
                        dialogTheme: const DialogTheme(
                          backgroundColor: Colors.white,
                        ),
                        timePickerTheme: TimePickerThemeData(
                          backgroundColor: Colors.white,
                          hourMinuteColor: WidgetStateColor.resolveWith((states) {
                            if (states.contains(WidgetState.selected) ||
                                states.contains(WidgetState.focused)) {
                              return const Color(0xFFE0E0E0);
                            }
                            return Colors.white;
                          }),
                          dayPeriodColor: WidgetStateColor.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return const Color(0xff86C1FF);
                            }
                            return Colors.white;
                          }),
                          dialBackgroundColor: const Color(0xFFE0E0E0),
                        ),
                        inputDecorationTheme: const InputDecorationTheme(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff86C1FF)),
                          ),
                        ),
                        textTheme: base.textTheme.apply(
                          bodyColor: Colors.black,
                          displayColor: Colors.black,
                        ),
                      );
                      return Theme(data: themed, child: child!);
                    },
                  );
                  final time = t ?? const TimeOfDay(hour: 23, minute: 59);
                  setSheetState(() {
                    endDate = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              }

              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          width: 48,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '과제 만들기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'title',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff578FCA)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: contentController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'content',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff578FCA)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: pickStartDate,
                              splashColor: const Color(0xff578FCA).withOpacity(0.2),
                              highlightColor: const Color(0xff578FCA).withOpacity(0.1),
                              overlayColor: WidgetStateProperty.resolveWith(
                                (states) => const Color(0xff578FCA)
                                    .withOpacity(states.contains(WidgetState.pressed) ? 0.2 : 0.1),
                              ),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'start (날짜/시간)',
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xff86C1FF)),
                                  ),
                                ),
                                child: Text(
                                  startDate == null
                                      ? '날짜/시간 선택'
                                      : formatDateTimeReadable(startDate),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: pickEndDate,
                              splashColor: const Color(0xff578FCA).withOpacity(0.2),
                              highlightColor: const Color(0xff578FCA).withOpacity(0.1),
                              overlayColor: WidgetStateProperty.resolveWith(
                                (states) => const Color(0xff578FCA)
                                    .withOpacity(states.contains(WidgetState.pressed) ? 0.2 : 0.1),
                              ),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'end (날짜/시간)',
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xff86C1FF)),
                                  ),
                                ),
                                child: Text(
                                  endDate == null
                                      ? '날짜/시간 선택'
                                      : formatDateTimeReadable(endDate),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('취소', style: TextStyle(color: Colors.black)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff86C1FF),
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () async {
                                final title = titleController.text.trim();
                                final content = contentController.text.trim();
                                final start = formatApiDateTime(startDate);
                                final end = formatApiDateTime(endDate);

                                if (title.isEmpty || end.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('제목과 마감일을 입력해 주세요.')),
                                  );
                                  return;
                                }
                                if (start.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('시작 날짜/시간을 선택해 주세요.')),
                                  );
                                  return;
                                }
                                if (startDate != null && endDate != null && startDate!.isAfter(endDate!)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('시작 시각은 마감 시각보다 이전이어야 합니다.')),
                                  );
                                  return;
                                }

                                final body = {
                                  'class_id': classRoomId,
                                  'title': title,
                                  'content': content,
                                  'start_date': start,
                                  'end_date': end,
                                };

                                try {
                                  final dio = ApiClient.instance.dio;
                                  final res = await dio.post('/api/assignments', data: body);
                                  final status = res.statusCode ?? 500;
                                  if (status < 200 || status >= 300) {
                                    // 실패로 간주하되, 로컬에 즉시 반영하는 기존 UX 유지
                                    result = {
                                      'assignmentId': res.data is Map ? (res.data['assignmentId'] ?? '') : '',
                                      'title': title,
                                      'content': content,
                                      'startDate': start,
                                      'endDate': end,
                                      'status': '미제출',
                                      'submitted': false,
                                      'due': formatDate(endDate),
                                      'timeLeft': formatTimeLeftFrom(endDate),
                                      'files': <Map<String, dynamic>>[],
                                    };
                                    // 결과 반환
                                    if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop(result);
                                    return;
                                  }

                                  result = {
                                    'assignmentId': res.data is Map ? (res.data['assignmentId'] ?? '') : '',
                                    'title': title,
                                    'content': content,
                                    'startDate': start,
                                    'endDate': end,
                                    'status': '미제출',
                                    'submitted': false,
                                    'due': formatDate(endDate),
                                    'timeLeft': formatTimeLeftFrom(endDate),
                                    'files': <Map<String, dynamic>>[],
                                  };

                                  if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop(result);
                                } on DioException catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('네트워크 오류: ${e.message}')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('오류: $e')),
                                  );
                                }
                              },
                              child: const Text('등록'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );

  return result;
}

