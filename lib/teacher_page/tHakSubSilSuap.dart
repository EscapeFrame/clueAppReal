import 'package:clue/api_client.dart';
import 'package:clue/teacher_page/thaksubsilTabBar_/ActivateTeacherSuap.dart';
import 'package:clue/teacher_page/thaksubsilTabBar_/AllTeacherSuap.dart';
import 'package:clue/teacher_page/thaksubsilTabBar_/UnActivateTeacherSuap.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Thaksubsilsuap extends StatefulWidget {
  const Thaksubsilsuap({super.key});

  @override
  State<Thaksubsilsuap> createState() => _ThaksubsilsuapState();
}

class _ThaksubsilsuapState extends State<Thaksubsilsuap> {
  List<Map<String, dynamic>> teacherHakSubSil = [];

  Future<void> tHakSubSilApi() async {
    try {
      final api = ApiClient.instance.dio;
      final res = await api.get('/api/class');
      debugPrint('Response data: ${res.data}');
      setState(() {
        teacherHakSubSil = List<Map<String, dynamic>>.from(res.data);
      });
    } on DioException catch (e) {
      debugPrint('status : ${e.response?.statusCode}');
      debugPrint('data   : ${e.response?.data}');
      debugPrint('headers: ${e.response?.headers}');
      debugPrint('msg    : ${e.message}');
    } catch (e) {
      debugPrint("EERROORR : $e");
    }
  }

  @override
  void initState() {
    super.initState();
    tHakSubSilApi();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _openCreateClassSheet,
          backgroundColor: Color(0xff86C1FF),
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.06,
                vertical: height * 0.015,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        'assets/images/clueLogo.svg',
                        width: width * 0.25,
                      ),
                      Container(
                        margin: EdgeInsets.only(right: width * 0.035),
                        child: SvgPicture.asset(
                          'assets/images/jong.svg',
                          width: width * 0.055,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.05),
                  Text(
                    '나의 학습실',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.045,
                    ),
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    '학습실을 확인하고 관리해주세요!',
                    style: TextStyle(fontSize: width * 0.038),
                  ),
                  SizedBox(height: height * 0.003),
                  TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.lightBlue,
                    indicatorWeight: 3,
                    labelStyle: TextStyle(
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                    ),
                    tabs: [
                      Tab(
                        child: SizedBox(
                          height: height * 0.04,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '전체',
                              style: TextStyle(fontSize: width * 0.045),
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        child: SizedBox(
                          height: height * 0.04,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '활성화',
                              style: TextStyle(fontSize: width * 0.045),
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        child: SizedBox(
                          height: height * 0.04,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '비활성화',
                              style: TextStyle(fontSize: width * 0.045),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Allteachersuap(
                    teacherHakSubSil: teacherHakSubSil,
                    onRefresh: () async => await tHakSubSilApi(),
                  ),
                  Activateteachersuap(
                    teacherHakSubSil: teacherHakSubSil,
                    onRefresh: () async => await tHakSubSilApi(),
                  ),
                  Unactivateteachersuap(
                    teacherHakSubSil: teacherHakSubSil,
                    onRefresh: () async => await tHakSubSilApi(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreateClassSheet() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final sortController = TextEditingController();
    final targetController = TextEditingController();
    bool isActivation = true;

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
            selectionColor: Color(0x3386C1FF),
            selectionHandleColor: Color(0xff578FCA),
          ),
        );
        return Theme(
          data: sheetTheme,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 12,
            ),
            child: StatefulBuilder(
              builder: (sheetContext, setSheetState) {
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
                          '수업 만들기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'name',
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff578FCA)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descriptionController,
                          minLines: 3,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'description',
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff578FCA)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: sortController,
                          decoration: const InputDecoration(
                            labelText: 'sort',
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff578FCA)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: targetController,
                          decoration: const InputDecoration(
                            labelText: 'target',
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff578FCA)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('isActivation'),
                            const SizedBox(width: 8),
                            Switch(
                              value: isActivation,
                              activeColor: const Color(0xff578FCA),
                              onChanged: (v) {
                                setSheetState(() => isActivation = v);
                              },
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
                                  final name = nameController.text.trim();
                                  final description = descriptionController.text.trim();
                                  final sort = sortController.text.trim();
                                  final target = targetController.text.trim();

                                  if (name.isEmpty || sort.isEmpty || target.isEmpty) {
                                    ScaffoldMessenger.of(this.context).showSnackBar(
                                      const SnackBar(content: Text('name, sort, target을 입력해 주세요.')),
                                    );
                                    return;
                                  }

                                  final body = {
                                    'name': name,
                                    'description': description,
                                    'sort': sort,
                                    'target': target,
                                    'isActivation': isActivation,
                                  };

                                  try {
                                    final api = ApiClient.instance.dio;
                                    final res = await api.post('/api/class', data: body);
                                    if (!mounted) return;
                                    if (res.statusCode == 200 || res.statusCode == 201) {
                                      Navigator.of(ctx).pop();
                                      await tHakSubSilApi();
                                      ScaffoldMessenger.of(this.context).showSnackBar(
                                        const SnackBar(content: Text('수업이 생성되었습니다.')),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(this.context).showSnackBar(
                                        SnackBar(content: Text('생성 실패: ${res.statusCode}')),
                                      );
                                    }
                                  } on DioException catch (e) {
                                    if (!mounted) return;
                                    final code = e.response?.statusCode;
                                    final msg = e.response?.data?.toString() ?? e.message ?? 'unknown error';
                                    ScaffoldMessenger.of(this.context).showSnackBar(
                                      SnackBar(content: Text('오류: $code $msg')),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(this.context).showSnackBar(
                                      SnackBar(content: Text('오류: $e')),
                                    );
                                  }
                                },
                                child: const Text('생성'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
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
}
