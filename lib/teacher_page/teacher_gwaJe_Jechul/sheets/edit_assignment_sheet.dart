import 'package:clue/api_client.dart';
import 'package:clue/teacher_page/teacher_gwaJe_Jechul/sheets/widgets/assignment_sheet_widgets.dart';
import 'package:clue/teacher_page/teacher_gwaJe_Jechul/utils/date_time.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

Future<Map<String, dynamic>?> showEditAssignmentSheet({
  required BuildContext context,
  required Map<String, dynamic> assignment,
}) async {
  final titleController = TextEditingController(
    text: (assignment['title'] ?? '').toString(),
  );
  final contentController = TextEditingController(
    text: (assignment['content'] ?? '').toString(),
  );
  final formKey = GlobalKey<FormState>();

  DateTime? startDate;
  DateTime? endDate;

  DateTime? tryParse(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      return DateTime.parse(s.replaceAll(' ', 'T'));
    } catch (_) {
      return null;
    }
  }

  startDate = tryParse(assignment['startDate']?.toString());
  endDate =
      tryParse(assignment['endDate']?.toString()) ??
      tryParse(assignment['due']?.toString());

  var isSubmitting = false;
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
          primary: const Color(0xff0077FF),
          secondary: const Color(0xff0077FF),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.black,
          selectionColor: Colors.black.withOpacity(0.2),
          selectionHandleColor: Colors.black,
        ),
      );
      return Theme(
        data: sheetTheme,
        child: FractionallySizedBox(
          heightFactor: 0.95,
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
                        primary: const Color(0xff0077FF),
                        secondary: const Color(0xff0077FF),
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                      textTheme: base.textTheme.apply(
                        bodyColor: Colors.black,
                        displayColor: Colors.black,
                      ),
                      datePickerTheme: DatePickerThemeData(
                        backgroundColor: Colors.white,
                        headerBackgroundColor: Colors.white,
                        headerForegroundColor: Colors.black,
                        cancelButtonStyle: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(
                            Colors.black,
                          ),
                        ),
                        confirmButtonStyle: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(
                            const Color(0xff0077FF),
                          ),
                        ),
                      ),
                      dialogTheme: const DialogThemeData(
                        backgroundColor: Colors.white,
                      ),
                    );
                    return Theme(data: themed, child: child!);
                  },
                );
                if (picked != null) {
                  final initialTime =
                      startDate != null
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
                          primary: const Color(0xff0077FF),
                          secondary: const Color(0xff0077FF),
                          surface: Colors.white,
                          onSurface: Colors.black,
                        ),
                        dialogTheme: const DialogThemeData(
                          backgroundColor: Colors.white,
                        ),
                        timePickerTheme: TimePickerThemeData(
                          backgroundColor: Colors.white,
                          hourMinuteColor: WidgetStateColor.resolveWith((
                            states,
                          ) {
                            if (states.contains(WidgetState.selected) ||
                                states.contains(WidgetState.focused)) {
                              return const Color(0xFFE0E0E0);
                            }
                            return Colors.white;
                          }),
                          dayPeriodColor: WidgetStateColor.resolveWith((
                            states,
                          ) {
                            if (states.contains(WidgetState.selected)) {
                              return const Color(0xff0077FF);
                            }
                            return Colors.white;
                          }),
                          dialBackgroundColor: const Color(0xFFE0E0E0),
                        ),
                        inputDecorationTheme: const InputDecorationTheme(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff0077FF)),
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
                        primary: const Color(0xff0077FF),
                        secondary: const Color(0xff0077FF),
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                      textTheme: base.textTheme.apply(
                        bodyColor: Colors.black,
                        displayColor: Colors.black,
                      ),
                      datePickerTheme: DatePickerThemeData(
                        backgroundColor: Colors.white,
                        headerBackgroundColor: Colors.white,
                        headerForegroundColor: Colors.black,
                        cancelButtonStyle: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(
                            Colors.black,
                          ),
                        ),
                        confirmButtonStyle: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(
                            const Color(0xff0077FF),
                          ),
                        ),
                      ),
                      dialogTheme: const DialogThemeData(
                        backgroundColor: Colors.white,
                      ),
                    );
                    return Theme(data: themed, child: child!);
                  },
                );
                if (picked != null) {
                  final initialTime =
                      endDate != null
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
                          primary: const Color(0xff0077FF),
                          secondary: const Color(0xff0077FF),
                          surface: Colors.white,
                          onSurface: Colors.black,
                        ),
                        dialogTheme: const DialogThemeData(
                          backgroundColor: Colors.white,
                        ),
                        timePickerTheme: TimePickerThemeData(
                          backgroundColor: Colors.white,
                          hourMinuteColor: WidgetStateColor.resolveWith((
                            states,
                          ) {
                            if (states.contains(WidgetState.selected) ||
                                states.contains(WidgetState.focused)) {
                              return const Color(0xFFE0E0E0);
                            }
                            return Colors.white;
                          }),
                          dayPeriodColor: WidgetStateColor.resolveWith((
                            states,
                          ) {
                            if (states.contains(WidgetState.selected)) {
                              return const Color(0xff0077FF);
                            }
                            return Colors.white;
                          }),
                          dialBackgroundColor: const Color(0xFFE0E0E0),
                        ),
                        inputDecorationTheme: const InputDecorationTheme(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff0077FF)),
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

              final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

              return AssignmentSheetScaffold(
                title: '과제 수정',
                subtitle: '이미 공지된 과제를 빠르게 업데이트하세요.',
                onClose: () {
                  if (Navigator.of(ctx).canPop()) {
                    Navigator.of(ctx).pop();
                  }
                },
                child: Form(
                  key: formKey,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(12, 8, 12, bottomInset + 24),
                    children: [
                      const SizedBox(height: 4),
                      AssignmentSectionCard(
                        title: '기본 정보',
                        icon: Icons.edit_note_outlined,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: AssignmentFilledTextField(
                                controller: titleController,
                                label: 'title',
                                hint: '과제 제목',
                                icon: Icons.title_outlined,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return '과제 제목을 입력해 주세요';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: AssignmentFilledTextField(
                                controller: contentController,
                                label: 'content',
                                hint: '학생들에게 보여질 안내 내용을 수정하세요',
                                icon: Icons.notes_outlined,
                                minLines: 3,
                                maxLines: 5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AssignmentSectionCard(
                        title: '기간 설정',
                        icon: Icons.schedule_outlined,
                        child: AssignmentDateRangeSelector(
                          startLabel: 'start (날짜/시간)',
                          startValue:
                              startDate == null
                                  ? '시작 일시 선택'
                                  : formatDateTimeReadable(startDate),
                          onTapStart: pickStartDate,
                          endLabel: 'end (날짜/시간)',
                          endValue:
                              endDate == null
                                  ? '마감 일시 선택'
                                  : formatDateTimeReadable(endDate),
                          onTapEnd: pickEndDate,
                        ),
                      ),
                    ],
                  ),
                ),
                bottomAction: AssignmentSheetActionBar(
                  primaryLabel: '저장',
                  secondaryLabel: '취소',
                  isBusy: isSubmitting,
                  onSecondary: () => Navigator.of(ctx).pop(),
                  onPrimary: () async {
                    final id = (assignment['assignmentId'] ?? '').toString();
                    if (id.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('과제 ID를 찾을 수 없습니다.')),
                      );
                      return;
                    }
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    final title = titleController.text.trim();
                    final content = contentController.text.trim();
                    final end = formatApiDateTime(endDate);
                    final start =
                        startDate == null ? end : formatApiDateTime(startDate);

                    if (end.isEmpty || start.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('시작/마감 일시를 선택해 주세요.')),
                      );
                      return;
                    }
                    if (startDate != null &&
                        endDate != null &&
                        startDate!.isAfter(endDate!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('시작 시각이 마감 시각보다 빠를 수 있어야 해요.'),
                        ),
                      );
                      return;
                    }

                    final body = {
                      'title': title,
                      'content': content,
                      'start_date': start,
                      'end_date': end,
                    };

                    setSheetState(() {
                      isSubmitting = true;
                    });

                    try {
                      final dio = ApiClient.instance.dio;
                      await dio.patch('/api/assignments/$id', data: body);

                      result = {
                        'title': title,
                        'content': content,
                        'startDate': start,
                        'endDate': end,
                        'due': formatDate(endDate),
                        'timeLeft': formatTimeLeftFrom(endDate),
                      };

                      if (Navigator.of(ctx).canPop()) {
                        Navigator.of(ctx).pop(result);
                      }
                    } on DioException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '수정 실패: ${e.response?.statusCode ?? ''}',
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('오류: $e')));
                    } finally {
                      setSheetState(() {
                        isSubmitting = false;
                      });
                    }
                  },
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
