import 'package:clue/HamburgerDialog.dart';
import 'package:clue/api_client.dart';
import 'package:clue/teacher_page/tHakSubSilSetting.dart';
import 'package:clue/teacher_page/teacher_gwaJe_Jechul.dart';
import 'package:clue/widgets/common/app_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum _DirectoryAction { rename, delete, addResource }

class Thaksubsilsuaptrue extends StatefulWidget {
  final Map<String, dynamic> tsuap;
  final VoidCallback? onCreateLesson;

  const Thaksubsilsuaptrue({
    super.key,
    required this.tsuap,
    this.onCreateLesson,
  });
  @override
  State<Thaksubsilsuaptrue> createState() => _HaksubsilsuapState();
}

class _HaksubsilsuapState extends State<Thaksubsilsuaptrue> {
  late List<Map<String, dynamic>> assignments;
  Map<String, dynamic> _detail = {};
  bool _isLoading = true;
  final TextEditingController _lessonNameController = TextEditingController();

  Future<void> _loadDetail() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      final api = ApiClient.instance.dio;
      final id =
          (widget.tsuap['classRoomId'] ?? widget.tsuap['classRoomIdStr'])
              ?.toString();

      final res = await api.get('/api/class/$id/all');
      final data = res.data;
      debugPrint('teacher detail: $data');
      if (!mounted) return;
      if (data is Map) {
        final m = Map<String, dynamic>.from(data);
        setState(() {
          _detail = m;
          // Fetch된 상세 데이터를 화면의 기본 데이터로 반영
          widget.tsuap['name'] =
              (m['classRoomName'] ?? widget.tsuap['name'] ?? '').toString();
          if (m['description'] != null) {
            widget.tsuap['description'] = m['description'].toString();
          }
          if (m['sort'] != null) {
            widget.tsuap['sort'] = m['sort'].toString();
          }
          if (m['target'] != null) {
            widget.tsuap['target'] = m['target'].toString();
          }
          final raw = m['assignments'];
          if (raw is List) {
            assignments = List<Map<String, dynamic>>.from(
              raw.whereType<Map>().map((a) {
                final map = Map<String, dynamic>.from(a);
                if (map['files'] == null) {
                  if (map['file'] != null) {
                    map['files'] = [map['file']];
                  } else {
                    map['files'] = [];
                  }
                }
                return map;
              }),
            );
          }
        });
      }
    } catch (e, st) {
      debugPrint('로그 컨텍스트: $e');
      debugPrint('$st');
      if (mounted) {
        showAppSnackBar(context, '수업 정보를 불러오지 못했습니다. 다시 시도해주세요.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final rawAssignments = widget.tsuap['assignments'];
    if (rawAssignments is List) {
      assignments = List<Map<String, dynamic>>.from(
        rawAssignments.map((a) {
          // file → files 변환
          if (a['files'] == null) {
            if (a['file'] != null) {
              a['files'] = [a['file']];
            } else {
              a['files'] = [];
            }
          }
          return a;
        }),
      );
    } else {
      assignments = <Map<String, dynamic>>[];
    }
    _loadDetail();
  }

  @override
  void dispose() {
    _lessonNameController.dispose();
    super.dispose();
  }

  void updateSubmissionStatus(int index, bool submitted) {
    setState(() {
      assignments[index]['submitted'] = submitted;
      assignments[index]['status'] = submitted ? '제출됨' : '미제출';
      widget.tsuap['assignments'] = assignments;
    });
  }

  void _onTapAddLessonCard() {
    if (widget.onCreateLesson != null) {
      widget.onCreateLesson!();
      return;
    }
    _handleCreateLesson();
  }

  Future<void> _handleCreateLesson() async {
    final name = await _promptLessonName();
    if (name == null || name.trim().isEmpty) return;
    await _createDirectory(name.trim());
  }

  Future<void> _renameDirectory(Map<String, dynamic> lesson) async {
    final currentName = lesson['directoryName']?.toString() ?? '';
    final newName = await _promptLessonName(
      dialogTitle: '디렉토리 이름 변경',
      dialogSubtitle: '새 이름을 입력하세요.',
      labelText: '디렉토리 이름',
      hintText: '예: 1주차 자료',
      actionText: '저장',
      initialValue: currentName,
    );
    final trimmedName = newName?.trim();
    if (trimmedName == null ||
        trimmedName.isEmpty ||
        trimmedName == currentName) {
      return;
    }
    final directoryId = lesson['directoryId']?.toString();
    final dynamic classIdValue =
        _detail.isNotEmpty
            ? _detail['classRoomId'] ?? _detail['classRoomIdStr']
            : widget.tsuap['classRoomId'] ?? widget.tsuap['classRoomIdStr'];
    final classRoomId = classIdValue?.toString();
    if (directoryId == null ||
        directoryId.isEmpty ||
        classRoomId == null ||
        classRoomId.isEmpty) {
      if (!mounted) return;
      showAppSnackBar(context, '디렉토리 정보를 불러오지 못했습니다.');
      return;
    }
    try {
      final api = ApiClient.instance.dio;
      await api.patch(
        '/api/directory',
        data: {
          'directoryId': directoryId,
          'classRoomId': classRoomId,
          'name': trimmedName,
        },
      );
      if (!mounted) return;
      showAppSnackBar(
        context,
        '이름을 저장했어요.',
        isError: false,
      );
      await _loadDetail();
    } catch (e, st) {
      debugPrint('로그 컨텍스트: $e');
      debugPrint('$st');
      if (!mounted) return;
      showAppSnackBar(context, '이름 변경에 실패했습니다. 다시 시도해주세요.');
    }
  }

  Future<bool?> _confirmDirectoryDelete(String lessonName) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final width = MediaQuery.of(dialogContext).size.width;
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: width * 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [Color(0xfffdfdfd), Color(0xfff6f7fb)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xfffe6a6a), Color(0xffef5350)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.delete, color: Colors.white, size: 32),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '정말 삭제하시겠어요?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.05,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '“$lessonName”은 삭제하면 복구할 수 없습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * 0.035,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xffd3d8ec)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text(
                          '취소',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffd32f2f),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text(
                          '삭제하기',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
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
      },
    );
  }

  Future<void> _deleteDirectory(Map<String, dynamic> lesson) async {
    final lessonName = lesson['directoryName']?.toString() ?? '디렉토리';
    final confirmed = await _confirmDirectoryDelete(lessonName);
    if (confirmed != true) return;
    final directoryId = lesson['directoryId']?.toString();
    final dynamic classIdValue =
        _detail.isNotEmpty
            ? _detail['classRoomId'] ?? _detail['classRoomIdStr']
            : widget.tsuap['classRoomId'] ?? widget.tsuap['classRoomIdStr'];
    final classRoomId = classIdValue?.toString();
    if (directoryId == null ||
        directoryId.isEmpty ||
        classRoomId == null ||
        classRoomId.isEmpty) {
      if (!mounted) return;
      showAppSnackBar(context, '디렉토리 정보를 불러오지 못했습니다.');
      return;
    }
    try {
      final api = ApiClient.instance.dio;
      await api.delete(
        '/api/directory',
        data: {
          'directoryId': directoryId,
          'classRoomId': classRoomId,
          'name': lessonName,
        },
      );
      if (!mounted) return;
      showAppSnackBar(
        context,
        '디렉토리가 삭제되었습니다.',
        isError: false,
      );
      await _loadDetail();
    } catch (e, st) {
      debugPrint('로그 컨텍스트: $e');
      debugPrint('$st');
      if (!mounted) return;
      showAppSnackBar(context, '디렉토리 삭제에 실패했습니다. 다시 시도해주세요.');
    }
  }

  Future<void> _handleDirectoryAction(
    _DirectoryAction action,
    Map<String, dynamic> lesson,
  ) async {
    final lessonName = lesson['directoryName']?.toString() ?? 'Directory';
    switch (action) {
      case _DirectoryAction.rename:
        await _renameDirectory(lesson);
        break;
      case _DirectoryAction.delete:
        await _deleteDirectory(lesson);
        break;
      case _DirectoryAction.addResource:
        showAppSnackBar(
          context,
          '곧 $lessonName에 자료를 추가할 수 있게 될 예정입니다.',
          isError: false,
        );
        break;
    }
  }

  Future<void> _confirmAndDeleteClass() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final width = MediaQuery.of(dialogContext).size.width;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.06,
              vertical: width * 0.05,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xffffebee),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Color(0xffd32f2f),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '수업을 삭제할까요?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff1f2937),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '삭제하면 과제 및 구성 정보가 모두 사라집니다. 정말로 진행하시겠어요?',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Color(0xff4b5563),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xffd1d5db)),
                          foregroundColor: const Color(0xff1f2937),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('취소'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xffef5350),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text(
                          '삭제하기',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final String? id =
        (widget.tsuap['classRoomId'] ?? widget.tsuap['classRoomIdStr'])
            ?.toString();
    if (id == null || id.isEmpty) {
      if (!mounted) return;
      showAppSnackBar(context, '수업 ID를 찾을 수 없습니다.');
      return;
    }

    try {
      final api = ApiClient.instance.dio;
      await api.delete('/api/class/$id');
      if (!mounted) return;
      showAppSnackBar(
        context,
        '수업이 삭제되었습니다.',
        isError: false,
      );
      Navigator.of(context).pop(true);
    } catch (e, st) {
      debugPrint('로그 컨텍스트: $e');
      debugPrint('$st');
      if (!mounted) return;
      showAppSnackBar(context, '수업 삭제에 실패했습니다. 다시 시도해주세요.');
    }
  }

  Future<String?> _promptLessonName({
    String dialogTitle = "수업을 만들까요?",
    String dialogSubtitle = "수업 이름을 입력하면 바로 자료를 추가하고 진행할 수 있습니다.",
    String labelText = "수업 이름",
    String hintText = "예: 1주차 로드맵",
    String actionText = "바로 만들기",
    String initialValue = "",
  }) async {
    final effectiveInitial = initialValue;
    _lessonNameController.value = TextEditingValue(
      text: effectiveInitial,
      selection: TextSelection.collapsed(offset: effectiveInitial.length),
    );
    String? errorText;
    final name = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xffF5F9FF), Colors.white],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: const Color(0xffE8F0FF),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xff246BFD),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      dialogTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dialogSubtitle,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _lessonNameController,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: labelText,
                        hintText: hintText,
                        filled: true,
                        fillColor: const Color(0xffF5F8FF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xffC7D7FF),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xffE0E7FF),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xff246BFD),
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.redAccent),
                        ),
                        errorText: errorText,
                      ),
                      onSubmitted: (_) {
                        final trimmed = _lessonNameController.text.trim();
                        if (trimmed.isNotEmpty) {
                          Navigator.of(dialogContext).pop(trimmed);
                        } else {
                          setStateDialog(() {
                            errorText = 'Please enter a name.';
                          });
                        }
                      },
                      onChanged: (value) {
                        if (errorText != null && value.trim().isNotEmpty) {
                          setStateDialog(() {
                            errorText = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: const BorderSide(color: Color(0xffCBD5F5)),
                            ),
                            child: const Text(
                              '취소',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              final trimmed = _lessonNameController.text.trim();
                              if (trimmed.isEmpty) {
                                setStateDialog(() {
                                  errorText = 'Please enter a name.';
                                });
                                return;
                              }
                              Navigator.of(dialogContext).pop(trimmed);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xff246BFD),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(actionText),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    _lessonNameController.clear();
    return name;
  }

  Future<void> _createDirectory(String name) async {
    final dynamic idValue =
        widget.tsuap['classRoomId'] ?? widget.tsuap['classRoomIdStr'];
    final classRoomId = idValue?.toString();
    if (classRoomId == null || classRoomId.isEmpty) {
      showAppSnackBar(
        context,
        '반 정보를 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.',
      );
      return;
    }
    try {
      final api = ApiClient.instance.dio;
      await api.post(
        '/api/directory',
        data: {'classRoomId': classRoomId, 'name': name, 'directoryOrder': 0},
      );
      if (!mounted) return;
      showAppSnackBar(
        context,
        '새 수업이 추가되었습니다.',
        isError: false,
      );
      await _loadDetail();
    } catch (e, st) {
      debugPrint('로그 컨텍스트: $e');
      debugPrint('$st');
      if (!mounted) return;
      showAppSnackBar(
        context,
        '수업 추가에 실패했습니다. 다시 시도해 주세요.',
      );
    }
  }

  Future<void> _openDocumentMarkdown(Map<String, dynamic> doc) async {
    final docId = doc['documentId']?.toString();
    if (docId == null || docId.isEmpty) {
      if (!mounted) return;
      showAppSnackBar(context, '문서 정보를 찾을 수 없어요.');
      return;
    }
    final String title = doc['title']?.toString() ?? '';
    final navigator = Navigator.of(context, rootNavigator: true);
    var loaderClosed = false;
    void closeLoader() {
      if (!loaderClosed) {
        navigator.pop();
        loaderClosed = true;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final dio = ApiClient.instance.dio;
      final response = await dio.get(
        '/api/document/$docId/download',
        options: Options(responseType: ResponseType.plain),
      );
      closeLoader();
      if (!mounted) return;
      final markdownContent = response.data?.toString() ?? '';
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => _DocumentMarkdownPage(
                title: title,
                markdown: markdownContent,
              ),
        ),
      );
    } catch (e, st) {
      debugPrint('로그 컨텍스트: $e');
      debugPrint('$st');
      closeLoader();
      if (!mounted) return;
      showAppSnackBar(
        context,
        '문서 정보를 불러오지 못했습니다. 다시 시도해주세요.',
      );
    }
  }

  Widget _buildAddLessonCard(double width, double height) {
    final borderRadius = width * 0.03;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: height * 0.004,
      ),
      child: InkWell(
        onTap: _onTapAddLessonCard,
        borderRadius: BorderRadius.circular(borderRadius),
        child: CustomPaint(
          painter: _DashedRectPainter(
            color: const Color(0xff7EA6FF),
            strokeWidth: 1.5,
            dashLength: 7,
            dashGap: 4,
            radius: borderRadius,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.012,
            ),
            decoration: BoxDecoration(
              color: const Color(0xffF4F7FF),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Row(
              children: [
                Container(
                  width: width * 0.1,
                  height: width * 0.1,
                  decoration: BoxDecoration(
                    color: const Color(0xffE3EDFF),
                    borderRadius: BorderRadius.circular(width * 0.05),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xff0057FF),
                    size: 22,
                  ),
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  child: Text(
                    '새 수업',
                    style: TextStyle(
                      color: const Color(0xff0057FF),
                      fontWeight: FontWeight.w700,
                      fontSize: width * 0.038,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: const Color(0xff0057FF),
                  size: width * 0.038,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final header = _detail.isNotEmpty ? _detail : widget.tsuap;
    final title =
        (header['classRoomName'] ?? header['title'] ?? header['name'])
            ?.toString() ??
        '';
    final description = header['description']?.toString() ?? '';
    final teacherNames = header['teacherNames'];
    String teacherName = '';
    if (teacherNames is List && teacherNames.isNotEmpty) {
      teacherName = teacherNames
          .where((name) => name != null)
          .map((name) => name.toString())
          .join(', ');
    } else if (header['teacherName'] != null) {
      teacherName = header['teacherName'].toString();
    }
    final dynamic classCodeValue =
        header['code'] ??
        header['classRoomCode'] ??
        header['classCode'] ??
        header['classRoomIdStr'] ??
        header['classRoomId'];
    final classCode = classCodeValue?.toString() ?? '';
    final List<dynamic> directoryList =
        (header['directoryList'] as List?) ?? const [];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(
                  'assets/images/realLogo.svg',
                  width: width * 0.25,
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back, size: width * 0.07),
                    ),
                    SizedBox(width: width * 0.03),
                    GestureDetector(
                      onTap: () => showHamburgerDialog(context),
                      child: SvgPicture.asset(
                        'assets/images/bars-3.svg',
                        width: width * 0.074,
                      ),
                    ),
                    SizedBox(width: width * 0.0443),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              width * 0.07,
              0,
              height * 0.01,
              height * 0.01,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: width * 0.065,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.003),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text(
                    description,
                    style: TextStyle(fontSize: width * 0.035),
                  ),
                ),
                SizedBox(height: height * 0.004),
                if (teacherName.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: width * 0.06,
                        color: Colors.black54,
                      ),
                      SizedBox(width: width * 0.005),
                      Text(
                        teacherName,
                        style: TextStyle(
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.w600,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '수업코드',
                      style: TextStyle(
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff0077FF),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      classCode.isEmpty ? '-' : classCode,
                      style: TextStyle(
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: const Color(0xff0077FF),
                      unselectedLabelColor: Colors.black,
                      indicatorColor: const Color(0xff0077FF),
                      indicatorWeight: 3,
                      indicatorPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(
                          child: Text(
                            '수업',
                            style: TextStyle(fontSize: width * 0.045),
                          ),
                        ),
                        Tab(
                          child: Text(
                            '과제',
                            style: TextStyle(fontSize: width * 0.045),
                          ),
                        ),
                        Tab(
                          child: Text(
                            '사용자',
                            style: TextStyle(fontSize: width * 0.045),
                          ),
                        ),
                        Tab(
                          child: Text(
                            '설정',
                            style: TextStyle(fontSize: width * 0.045),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 245, 245, 245),
                              // color:Colors.white,
                            ),
                            child: ListView.builder(
                              itemCount: directoryList.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Column(
                                    children: [
                                      SizedBox(height: height * 0.012),
                                      _buildAddLessonCard(width, height),
                                    ],
                                  );
                                }
                                final rawLesson =
                                    (directoryList[index - 1] as Map?) ??
                                    const {};
                                final lesson = Map<String, dynamic>.from(
                                  rawLesson,
                                );
                                final List<dynamic> documents =
                                    (lesson['documentList'] as List?) ??
                                    const [];
                                return Column(
                                  children: [
                                    SizedBox(height: height * 0.01),
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: width * 0.05,
                                        vertical: height * 0.0025,
                                      ),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          width: 0.25,
                                          color: const Color(0xffCCCCCC),
                                        ),
                                        color: Colors.white,
                                      ),
                                      child: Theme(
                                        data: Theme.of(context).copyWith(
                                          dividerColor: Colors.transparent,
                                        ),
                                        child: ExpansionTile(
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          tilePadding: EdgeInsets.symmetric(
                                            horizontal: width * 0.03,
                                            vertical: height * 0.003,
                                          ),
                                          title: Text(
                                            lesson['directoryName']
                                                    ?.toString() ??
                                                '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: width * 0.045,
                                            ),
                                          ),
                                          trailing: PopupMenuButton<
                                            _DirectoryAction
                                          >(
                                            padding: EdgeInsets.zero,
                                            tooltip: '추가 작업',
                                            icon: Icon(
                                              Icons.more_vert,
                                              size: width * 0.045,
                                              color: Colors.black54,
                                            ),
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            onSelected:
                                                (action) =>
                                                    _handleDirectoryAction(
                                                      action,
                                                      lesson,
                                                    ),
                                            itemBuilder:
                                                (context) => [
                                                  PopupMenuItem<
                                                    _DirectoryAction
                                                  >(
                                                    value:
                                                        _DirectoryAction.rename,
                                                    child: Row(
                                                      children: const [
                                                        Icon(
                                                          Icons.edit,
                                                          size: 18,
                                                          color: Color(
                                                            0xff0057FF,
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text('이름 변경'),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem<
                                                    _DirectoryAction
                                                  >(
                                                    value:
                                                        _DirectoryAction.delete,
                                                    child: Row(
                                                      children: const [
                                                        Icon(
                                                          Icons.delete_outline,
                                                          size: 18,
                                                          color: Color(
                                                            0xffef5350,
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text('삭제'),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                          ),
                                          children:
                                              documents.map<Widget>((docItem) {
                                                final doc =
                                                    Map<String, dynamic>.from(
                                                      (docItem as Map?) ??
                                                          const {},
                                                    );
                                                return Column(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                        left: width * 0.028,
                                                        right: width * 0.028,
                                                        bottom: height * 0.012,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xffF5F5F5,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        border: Border.all(
                                                          width: 0.01,
                                                          color: const Color(
                                                            0xffCCCCCC,
                                                          ),
                                                        ),
                                                      ),
                                                      child: ListTile(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        onTap:
                                                            () =>
                                                                _openDocumentMarkdown(
                                                                  doc,
                                                                ),
                                                        contentPadding:
                                                            EdgeInsets.symmetric(
                                                              horizontal:
                                                                  width * 0.04,
                                                            ),
                                                        title: Text(
                                                          doc['title']
                                                                  ?.toString() ??
                                                              '',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                width * 0.035,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xffffffff),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TeacherGwajeJechul(
                                    dataList: assignments,
                                    onSubmissionChanged: updateSubmissionStatus,
                                    classRoomId:
                                        (header['classRoomId'] ??
                                                header['classRoomIdStr'])
                                            ?.toString() ??
                                        '',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(child: const Placeholder()),
                          Container(
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(
                                  context,
                                ).colorScheme.copyWith(
                                  primary: const Color(0xff578FCA),
                                  secondary: const Color(0xff578FCA),
                                ),
                                textSelectionTheme:
                                    const TextSelectionThemeData(
                                      cursorColor: Color(0xff578FCA),
                                      selectionColor: Color(0x33578FCA),
                                      selectionHandleColor: Color(0xff578FCA),
                                    ),
                              ),
                              child: Thaksubsilsetting(
                                tsuap: widget.tsuap,
                                onApply: (updated) {
                                  // 서버 데이터로 재동기화를 위해 상세 재호출 (A방법)
                                  _loadDetail();
                                  // 즉시 화면 반영: 현재 상세 헤더(_detail)가 있으면 동기 업데이트
                                  setState(() {
                                    widget.tsuap.addAll(updated);
                                    if (_detail.isNotEmpty) {
                                      if (updated['name'] != null) {
                                        _detail['classRoomName'] =
                                            updated['name'];
                                      }
                                      if (updated['description'] != null) {
                                        _detail['description'] =
                                            updated['description'];
                                      }
                                      if (updated['sort'] != null) {
                                        _detail['sort'] = updated['sort'];
                                      }
                                      if (updated['target'] != null) {
                                        _detail['target'] = updated['target'];
                                      }
                                    }
                                  });
                                },
                                onDeleteClass: _confirmAndDeleteClass,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentMarkdownPage extends StatelessWidget {
  final String title;
  final String markdown;

  const _DocumentMarkdownPage({required this.title, required this.markdown});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final theme = Theme.of(context);
    final baseTextTheme = theme.textTheme;
    final markdownStyle = MarkdownStyleSheet.fromTheme(
      theme.copyWith(
        textTheme: baseTextTheme.apply(
          bodyColor: const Color(0xff111827),
          displayColor: const Color(0xff111827),
        ),
      ),
    ).copyWith(
      h1: baseTextTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xff111827),
      ),
      h2: baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xff111827),
      ),
      p: baseTextTheme.bodyMedium?.copyWith(
        height: 1.5,
        fontSize: baseTextTheme.bodyMedium?.fontSize ?? 14,
        color: const Color(0xff1f2937),
      ),
      listBullet: baseTextTheme.bodyMedium?.copyWith(
        color: const Color(0xff1f2937),
      ),
    );

    final content =
        markdown.trim().isEmpty
            ? '\ud45c\uc2dc\ud560 \ub0b4\uc6a9\uc774 \uc5c6\uc2b5\ub2c8\ub2e4.'
            : markdown;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    'assets/images/realLogo.svg',
                    width: width * 0.25,
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.black87,
                        iconSize: width * 0.07,
                        tooltip: '\ub4a4\ub85c',
                      ),
                      SizedBox(width: width * 0.03),
                      IconButton(
                        onPressed: () => showHamburgerDialog(context),
                        icon: SvgPicture.asset(
                          'assets/images/bars-3.svg',
                          width: width * 0.074,
                        ),
                        tooltip: '\uba54\ub274',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xffe2e8f0)),
            if (title.isNotEmpty && !content.trimLeft().startsWith('#'))
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: baseTextTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff111827),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Markdown(
                data: content,
                selectable: true,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                styleSheet: markdownStyle,
                shrinkWrap: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;
  final double radius;

  const _DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashGap,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final Path path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double nextDistance = distance + dashLength;
        final double end =
            nextDistance < metric.length ? nextDistance : metric.length;
        final Path segment = metric.extractPath(distance, end);
        canvas.drawPath(segment, paint);
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        dashLength != oldDelegate.dashLength ||
        dashGap != oldDelegate.dashGap ||
        radius != oldDelegate.radius;
  }
}