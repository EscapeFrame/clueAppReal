import 'package:clue/api_client.dart';
import 'package:clue/teacher_page/tHakSubSilGaJa.dart';
import 'package:clue/teacher_page/teacher_check.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

String formatFileSize(int bytes) {
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  } else {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
}

class TeacherGwajeJechul extends StatefulWidget {
  final List<Map<String, dynamic>> dataList;
  final Function(int index, bool submitted)? onSubmissionChanged;
  final String classRoomId; // path param for API

  const TeacherGwajeJechul({
    super.key,
    required this.dataList,
    this.onSubmissionChanged,
    required this.classRoomId,
  });

  @override
  State<TeacherGwajeJechul> createState() => TeacherGwajeJechulState();
}

class TeacherGwajeJechulState extends State<TeacherGwajeJechul> {
  late List<Map<String, dynamic>> dataList;
  List<bool> isEditMode = [];
  bool showTeacherCheck = false;
  bool showAssignmentDetail = false;
  Map<String, dynamic>? selectedAssignment;

  void _closeAssignmentDetail() {
    setState(() {
      showAssignmentDetail = false;
      selectedAssignment = null;
    });
  }

  String _formatDate(DateTime? dt) =>
      dt == null ? '' : dt.toIso8601String().split('T').first;

  String _formatDateTimeReadable(DateTime? dt) {
    if (dt == null) return '';
    String p2(int v) => v.toString().padLeft(2, '0');
    return '${dt.year}-${p2(dt.month)}-${p2(dt.day)} ${p2(dt.hour)}:${p2(dt.minute)}';
  }
  // API 전송용 포맷: YYYY-MM-DD HH:MM (초/타임존 제외)
  String _formatApiDateTime(DateTime? dt) {
    if (dt == null) return '';
    String p2(int v) => v.toString().padLeft(2, '0');
    return '${dt.year}-${p2(dt.month)}-${p2(dt.day)} ${p2(dt.hour)}:${p2(dt.minute)}';
  }

  String _formatIsoLocal(DateTime? dt) {
    if (dt == null) return '';
    String p2(int v) => v.toString().padLeft(2, '0');
    // ISO-8601 without milliseconds/timezone, e.g. 2025-09-07T14:30:00
    return '${dt.year}-${p2(dt.month)}-${p2(dt.day)}T${p2(dt.hour)}:${p2(dt.minute)}:00';
  }
  
  String _formatTimeLeftFrom(DateTime? end) {
    if (end == null) return '-';
    final diff = end.difference(DateTime.now());
    if (diff.isNegative) return '마감됨';
    final d = diff.inDays, h = diff.inHours % 24, m = diff.inMinutes % 60;
    if (d > 0) return '$d일 $h시간 남음';
    if (diff.inHours > 0) return '${diff.inHours}시간 $m분 남음';
    return '$m분 남음';
  }

  Future<void> _openCreateAssignmentSheet() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final assignmentIdController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

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
                        dialogTheme: DialogThemeData(
                          backgroundColor: Colors.white,
                        ),
                      );
                      return Theme(data: themed, child: child!);
                    },
                  );
                  if (picked != null) {
                    // Pick time after date
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
                            // 시/분 필드 배경: 선택/포커스 시 회색, 기본은 흰색
                            hourMinuteColor: WidgetStateColor.resolveWith((states) {
                              if (states.contains(WidgetState.selected) || states.contains(WidgetState.focused)) {
                                return const Color(0xFFE0E0E0); // grey
                              }
                              return Colors.white;
                            }),
                            // AM/PM 선택 배경: 선택 시 #86C1FF, 기본은 흰색
                            dayPeriodColor: WidgetStateColor.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) {
                                return const Color(0xff86C1FF);
                              }
                              return Colors.white;
                            }),
                            // 다이얼(시계) 배경색
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
                        dialogTheme: DialogThemeData(
                          backgroundColor: Colors.white,
                        ),
                      );
                      return Theme(data: themed, child: child!);
                    },
                  );
                  if (picked != null) {
                    // Pick time after date (default to 23:59 if canceled)
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
                              if (states.contains(WidgetState.selected) || states.contains(WidgetState.focused)) {
                                return const Color(0xFFE0E0E0); // grey
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
                        SizedBox(height: 8),
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
                                splashColor: const Color(
                                  0xff578FCA,
                                ).withOpacity(0.2),
                                highlightColor: const Color(
                                  0xff578FCA,
                                ).withOpacity(0.1),
                                overlayColor: WidgetStateProperty.resolveWith(
                                  (states) =>
                                      const Color(0xff578FCA).withOpacity(
                                        states.contains(WidgetState.pressed)
                                            ? 0.2
                                            : 0.1,
                                      ),
                                ),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'start (날짜/시간)',
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xff86C1FF),
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    startDate == null
                                        ? '날짜/시간 선택'
                                        : _formatDateTimeReadable(startDate),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: pickEndDate,
                                splashColor: const Color(
                                  0xff578FCA,
                                ).withOpacity(0.2),
                                highlightColor: const Color(
                                  0xff578FCA,
                                ).withOpacity(0.1),
                                overlayColor: WidgetStateProperty.resolveWith(
                                  (states) =>
                                      const Color(0xff578FCA).withOpacity(
                                        states.contains(WidgetState.pressed)
                                            ? 0.2
                                            : 0.1,
                                      ),
                                ),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'end (날짜/시간)',
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xff86C1FF),
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    endDate == null
                                        ? '날짜/시간 선택'
                                        : _formatDateTimeReadable(endDate),
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
                                child: const Text(
                                  '취소',
                                  style: TextStyle(color: Colors.black),
                                ),
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
                                  final classId = widget.classRoomId;
                                  final title = titleController.text.trim();
                                  final content = contentController.text.trim();
                                  final start = _formatApiDateTime(startDate);
                                  final end = _formatApiDateTime(endDate);

                                  if (title.isEmpty || end.isEmpty) {
                                    debugPrint(
                                      '[Assign] 유효성 실패 title:${title.isEmpty} end:${end.isEmpty}',
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('제목과 마감일을 입력해 주세요.'),
                                      ),
                                    );
                                    return;
                                  }
                                  if (start.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('시작 날짜/시간을 선택해 주세요.')),
                                    );
                                    return;
                                  }
                                  // Optional: start <= end check
                                  if (startDate != null && endDate != null && startDate!.isAfter(endDate!)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('시작 시각은 마감 시각보다 이전이어야 합니다.')),
                                    );
                                    return;
                                  }

                                  final body = {
                                    'class_id': classId,
                                    'title': title,
                                    'content': content,
                                    'start_date': start,
                                    'end_date': end,
                                  };
                                  debugPrint('[Assign] POST /api/assignments body: ${body['start_date']} ~ ${body['end_date']}');

                                  try {
                                    final dio = ApiClient.instance.dio;
                                    final res = await dio.post(
                                      '/api/assignments',
                                      data: body,
                                    );
                                    final status = res.statusCode ?? 500;
                                    debugPrint(
                                      '[Assign] 응답 status:$status data:${res.data}',
                                    );
                                    if (status < 200 || status >= 300) {
                                      setState(() {
                                        dataList.insert(0, {
                                          'assignmentId':
                                              res.data is Map
                                                  ? (res.data['assignmentId'] ??
                                                      '')
                                                  : '',
                                          'title': title,
                                          'content': content,
                                          'startDate': start,
                                          'endDate': end,
                                          'status': '미제출',
                                          'submitted': false,
                                          'due': end,
                                          'timeLeft': _formatTimeLeftFrom(
                                            endDate,
                                          ),
                                          'files': <Map<String, dynamic>>[],
                                        });
                                        isEditMode = List.generate(
                                          dataList.length,
                                          (index) => false,
                                        );
                                      });

                                      if (!mounted) return;
                                      Navigator.of(ctx).pop();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('과제를 생성했어요.'),
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() {
                                      dataList.insert(0, {
                                        'assignmentId':
                                            res.data is Map
                                                ? (res.data['assignmentId'] ??
                                                    '')
                                                : '',
                                        'title': title,
                                        'content': content,
                                        'startDate': start,
                                        'endDate': end,
                                        'status': '미제출',
                                        'submitted': false,
                                        'due': end,
                                        'timeLeft': _formatTimeLeftFrom(
                                          endDate,
                                        ),
                                        'files': <Map<String, dynamic>>[],
                                      });
                                      isEditMode = List.generate(
                                        dataList.length,
                                        (index) => false,
                                      );
                                    });

                                    if (!mounted) return;
                                    Navigator.of(ctx).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('과제를 생성했어요.'),
                                      ),
                                    );
                                  } on DioException catch (e) {
                                    debugPrint(
                                      '[Assign] DioException status:${e.response?.statusCode} msg:${e.message} data:${e.response?.data}',
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('네트워크 오류: ${e.message}'),
                                      ),
                                    );
                                  } catch (e) {
                                    debugPrint('[Assign] 예외: $e');
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
  }

  Future<void> _openEditAssignmentSheet(Map<String, dynamic> assignment) async {
    final titleController = TextEditingController(text: (assignment['title'] ?? '').toString());
    final contentController = TextEditingController(text: (assignment['content'] ?? '').toString());
    DateTime? startDate;
    DateTime? endDate;

    // Try to parse existing dates from assignment
    DateTime? tryParse(String? s) {
      if (s == null || s.isEmpty) return null;
      try {
        return DateTime.parse(s.replaceAll(' ', 'T'));
      } catch (_) {
        return null;
      }
    }
    startDate = tryParse(assignment['startDate']?.toString());
    // fallback: some list uses 'due' as YYYY-MM-DD only
    endDate = tryParse(assignment['endDate']?.toString()) ?? tryParse(assignment['due']?.toString());
    // start_date가 없더라도 화면에는 비워둔 채로 노출하고,
    // 전송 시에만 end_date로 대체할 것이므로 별도 표시 제어는 하지 않음.

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
                        dialogTheme: DialogThemeData(
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
                              if (states.contains(WidgetState.selected) || states.contains(WidgetState.focused)) {
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
                        dialogTheme: DialogThemeData(
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
                              if (states.contains(WidgetState.selected) || states.contains(WidgetState.focused)) {
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
                        SizedBox(height: 8),
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
                          '과제 수정',
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
                                  (states) => const Color(0xff578FCA).withOpacity(
                                    states.contains(WidgetState.pressed) ? 0.2 : 0.1,
                                  ),
                                ),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'start (날짜/시간)',
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xff578FCA)),
                                    ),
                                  ),
                                  child: Text(
                                    startDate == null
                                        ? '날짜/시간 선택'
                                        : _formatDateTimeReadable(startDate),
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
                                  (states) => const Color(0xff578FCA).withOpacity(
                                    states.contains(WidgetState.pressed) ? 0.2 : 0.1,
                                  ),
                                ),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'end (날짜/시간)',
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xff578FCA)),
                                    ),
                                  ),
                                  child: Text(
                                    endDate == null
                                        ? '날짜/시간 선택'
                                        : _formatDateTimeReadable(endDate),
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
                                  final id = (assignment['assignmentId'] ?? '').toString();
                                  final title = titleController.text.trim();
                                  final content = contentController.text.trim();
                                  final end = _formatApiDateTime(endDate);
                                  final start = startDate == null ? end : _formatApiDateTime(startDate);

                                  if (id.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('과제 ID를 찾을 수 없습니다.')),
                                    );
                                    return;
                                  }
                                  if (title.isEmpty || end.isEmpty || start.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('제목, 시작/마감 날짜·시간을 입력해 주세요.')),
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
                                    'title': title,
                                    'content': content,
                                    'start_date': start,
                                    'end_date': end,
                                  };
                                  debugPrint('[Assign Edit] PATCH /api/assignments/$id body: $body');

                                  try {
                                    final dio = ApiClient.instance.dio;
                                    final res = await dio.patch('/api/assignments/$id', data: body);
                                    final status = res.statusCode;
                                    debugPrint('[Assign Edit] status:$status data:${res.data}');

                                    // 즉시 반영: 로컬 아이템 업데이트
                                    final idx = dataList.indexWhere((e) => (e['assignmentId']?.toString() ?? '') == id);
                                    if (idx != -1) {
                                      setState(() {
                                        dataList[idx]['title'] = title;
                                        dataList[idx]['content'] = content;
                                        dataList[idx]['startDate'] = start;
                                        dataList[idx]['endDate'] = end;
                                        dataList[idx]['due'] = (endDate != null) ? _formatDate(endDate) : end;
                                        dataList[idx]['timeLeft'] = _formatTimeLeftFrom(endDate);
                                      });
                                    }

                                    // 서버 데이터 재동기화
                                    await gwaJeJeChul();

                                    if (!mounted) return;
                                    Navigator.of(ctx).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('과제를 수정했어요.')),
                                    );
                                  } on DioException catch (e) {
                                    debugPrint('[Assign Edit] DioException status:${e.response?.statusCode} msg:${e.message} data:${e.response?.data}');
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('수정 실패: ${e.response?.statusCode ?? ''}')),
                                    );
                                  } catch (e) {
                                    debugPrint('[Assign Edit] error: $e');
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('오류: $e')),
                                    );
                                  }
                                },
                                child: const Text('저장'),
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
  }

  // 응답을 UI 포맷으로 변환
  List<Map<String, dynamic>> _normalizeAssignments(List<dynamic> raw) {
    DateTime? parseDate(String? s) {
      if (s == null || s.isEmpty) return null;
      try {
        // 서버가 'YYYY-MM-DD HH:MM' 형식으로 줄 수 있어 공백을 'T'로 보정
        return DateTime.parse(s.replaceAll(' ', 'T'));
      } catch (_) {
        return null;
      }
    }

    String formatDue(DateTime? dt) =>
        dt == null ? '-' : dt.toIso8601String().split('T').first;
    String formatTimeLeft(DateTime? end) {
      if (end == null) return '-';
      final diff = end.difference(DateTime.now());
      if (diff.isNegative) return '마감됨';
      final d = diff.inDays, h = diff.inHours % 24, m = diff.inMinutes % 60;
      if (d > 0) return '$d일 $h시간 남음';
      if (diff.inHours > 0) return '${diff.inHours}시간 $m분 남음';
      return '$m분 남음';
    }

    String fmtSize(dynamic bytes) => bytes is int ? formatFileSize(bytes) : '';

    return raw.whereType<Map>().map<Map<String, dynamic>>((e) {
      final m = Map<String, dynamic>.from(e);
      // 원본 필드(케이스 혼재 대비)
      final rawStart = (m['startDate'] ?? m['start_date'])?.toString();
      final rawEnd = (m['endDate'] ?? m['end_date'])?.toString();
      final end = parseDate(rawEnd);
      final attachments =
          (m['AssignmentAttachments'] is List)
              ? (m['AssignmentAttachments'] as List)
              : const [];
      final files =
          attachments
              .whereType<Map>()
              .map(
                (a) => {
                  'name': (a['originalFileName'] ?? '').toString(),
                  'size': fmtSize(a['size']),
                  // 'url': a['url'] // 서버가 제공 시 연결
                },
              )
              .toList();

      return {
        'assignmentId': m['assignmentId'],
        'title': (m['title'] ?? '').toString(),
        // 수정 시트에서 원본을 띄우기 위해 보존
        'content': (m['content'] ?? '').toString(),
        'startDate': rawStart ?? '',
        'endDate': rawEnd ?? '',
        'status': '미제출',
        'submitted': false,
        'due': formatDue(end),
        'timeLeft': formatTimeLeft(end),
        'files': files,
      };
    }).toList();
  }

  Future<void> gwaJeJeChul() async {
    try {
      final assignmentsApi = ApiClient.instance.dio;
      final id = widget.classRoomId;
      final submissionsRes = await assignmentsApi.get(
        '/api/assignments/$id/all',
        options: Options(validateStatus: (_) => true),
      );
      final submissionData = submissionsRes.data;
      debugPrint("제출:${submissionData.toString()}");
      if (submissionsRes.statusCode == 200 && submissionData is List) {
        final parsed = _normalizeAssignments(submissionData);
        if (!mounted) return;
        setState(() {
          dataList = parsed;
          isEditMode = List.generate(dataList.length, (index) => false);
        });
      }
    } on DioException catch (e) {
      debugPrint('status : ${e.response?.statusCode}');
      debugPrint('data   : ${e.response?.data}');
      debugPrint('headers: ${e.response?.headers}');
      debugPrint('msg    : ${e.message}');
    } catch (e) {
      debugPrint('assignments load error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    gwaJeJeChul();
    dataList = List.from(widget.dataList);

    isEditMode = List.generate(dataList.length, (index) => false);

    for (var data in dataList) {
      if (data['files'] == null || data['files'] is! List) {
        data['files'] = [];
      }
      data['files'].removeWhere((f) => f == null);
    }
  }

  Future<void> downloadFile(
    BuildContext context,
    String url,
    String fileName,
  ) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/$fileName';
      await Dio().download(url, savePath);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('다운로드 완료: $fileName')));
      await OpenFile.open(savePath);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('다운로드 실패: $e')));
    }
  }

  void toggleSubmissionStatus(int index) {
    setState(() {});
  }

  Future<void> pickFile(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        dataList[index]['files'].add({
          'name': file.name,
          'size': formatFileSize(file.size),
        });
      });
    }
  }

  void removeFile(int dataIndex, int fileIndex) {
    setState(() {
      dataList[dataIndex]['files'].removeAt(fileIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      floatingActionButton: showAssignmentDetail
          ? null
          : FloatingActionButton(
              onPressed: () {
                _openCreateAssignmentSheet();
              },
              backgroundColor: const Color(0xff86C1FF),
              child: const Icon(Icons.add),
            ),
      body: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 245, 245, 245),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0), // 오른쪽에서 슬라이드 인
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: showAssignmentDetail
              ? Thaksubsilgaja(
                  key: const ValueKey('assignmentDetail'),
                  assignment: selectedAssignment!,
                  onClose: _closeAssignmentDetail,
                )
              : showTeacherCheck
                  ? TeacherCheck(
                      key: const ValueKey('teacherCheck'),
                      onBack: () {
                        setState(() {
                          showTeacherCheck = false;
                        });
                      },
                    )
                  : _buildAssignmentList(context, width, height),
        ),
      ),
    );
  }

  Widget _buildAssignmentList(
    BuildContext context,
    double width,
    double height,
  ) {
    return ListView(
      key: const ValueKey('assignmentList'),
      padding: EdgeInsets.symmetric(vertical: height * 0.01),
      children:
          dataList.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            return GestureDetector(
              onTap: () {
                setState(() {
                  final mapped = Map<String, dynamic>.from(data);
                  if (!(mapped.containsKey('file')) &&
                      mapped['files'] is List &&
                      (mapped['files'] as List).isNotEmpty) {
                    mapped['file'] = (mapped['files'] as List).first;
                  } else if (!mapped.containsKey('file')) {
                    mapped['file'] = {'name': ''};
                  }
                  // Ensure assignmentId is present for detail/upload actions
                  if (mapped['assignmentId'] == null) {
                    final dynamic altId = mapped['id'] ?? mapped['assignment_id'];
                    if (altId != null) {
                      final parsed = int.tryParse(altId.toString());
                      mapped['assignmentId'] = parsed ?? altId;
                    }
                  }
                  selectedAssignment = mapped;
                  showAssignmentDetail = true;
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: height * 0.012,
                ),
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(width * 0.04),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: width * 0.02,
                      offset: Offset(0, width * 0.01),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data['title'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: width * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: width * 0.02),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.025,
                            vertical: height * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color:
                                data['submitted']
                                    ? Colors.blue[100]
                                    : Colors.grey[300],
                            borderRadius: BorderRadius.circular(width * 0.05),
                          ),
                          child: Text(
                            data['status'],
                            style: TextStyle(
                              fontSize: width * 0.03,
                              color:
                                  data['submitted'] ? Colors.blue : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.012),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: width * 0.04,
                          color: Colors.grey,
                        ),
                        SizedBox(width: width * 0.015),
                        Text(
                          "마감일:  ${data['due']}",
                          style: TextStyle(fontSize: width * 0.03),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.008),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: width * 0.04,
                          color: Colors.blue,
                        ),
                        SizedBox(width: width * 0.015),
                        Text(
                          data['timeLeft'],
                          style: TextStyle(
                            fontSize: width * 0.03,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.018),
              
                    ...List.generate(data['files'].length, (fileIdx) {
                      final file = data['files'][fileIdx];
                      return Container(
                        margin: EdgeInsets.only(bottom: 6),
                        padding: EdgeInsets.all(width * 0.03),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(width * 0.025),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.insert_drive_file_outlined,
                              size: width * 0.05,
                            ),
                            SizedBox(width: width * 0.025),
              
                            GestureDetector(
                              onTap: () {
                                if (file['url'] != null &&
                                    file['url'].toString().isNotEmpty) {
                                  downloadFile(
                                    context,
                                    file['url'],
                                    file['name'],
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('다운로드 URL이 없습니다.')),
                                  );
                                }
                              },
                              child: SizedBox(
                                width: width * 0.5,
                                child: Text(
                                  file['name'],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: width * 0.03,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: width * 0.02),
                            Text(
                              '(${file['size']})',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: width * 0.025,
                                color: Colors.grey,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => removeFile(index, fileIdx),
                              child: Icon(Icons.close, size: width * 0.045),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (isEditMode[index]) ...[
                      SizedBox(height: height * 0.012),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => pickFile(index),
                          icon: Icon(Icons.attach_file),
                          label: Text(
                            '파일 추가',
                            style: TextStyle(fontSize: width * 0.032),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[100],
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(width * 0.025),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: height * 0.012,
                              horizontal: width * 0.04,
                            ),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: height * 0.018),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            child: ElevatedButton.icon(
                              onPressed: () => _openEditAssignmentSheet(dataList[index]),
                              label: Text(
                                '내용수정',
                                style: TextStyle(fontSize: width * 0.035),
                              ),
                              icon: Icon(Icons.edit),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    width * 0.025,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: height * 0.018,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: width * 0.03),
                        Expanded(
                          child: SizedBox(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  showTeacherCheck = true;
                                });
                              },
                              label: Text(
                                '확인/채점',
                                style: TextStyle(fontSize: width * 0.035),
                              ),
                              icon: Icon(Icons.check),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB9DCFF),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    width * 0.025,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: height * 0.018,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
