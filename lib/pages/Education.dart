import 'package:clue/HamburgerDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'Alarm.dart';

class Education extends StatefulWidget {
  const Education({super.key});

  @override
  State<Education> createState() => _EducationState();
}

class _EducationState extends State<Education>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging &&
          _currentIndex != _tabController.index) {
        setState(() => _currentIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final width = media.size.width;

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(width: width),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _SectionHeader(width: width)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(const [
                        _TimetableBlock(period: '8~9교시'),
                        SizedBox(height: 28),
                        _TimetableBlock(period: '10~11교시'),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            const SafeArea(
              minimum: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: _ApplyButton(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: SvgPicture.asset(
                'assets/images/realLogo.svg',
                width: width * 0.25,
              ),
            ),
            Container(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const Alarm()),
                      );
                    },
                    child: SvgPicture.asset(
                      'assets/images/jong.svg',
                      width: width * 0.055,
                    ),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: width * 0.05,
    );

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text('수강신청', style: titleStyle),
          const SizedBox(height: 14),
          Row(
            children: [
              GestureDetector(
                onTap: () => {},
                child: _PeriodChip(label: '8~9교시', active: true),
              ),
              SizedBox(width: 12),
              GestureDetector(
                onTap: () => {},
                child: _PeriodChip(label: '10~11교시', active: false),
              ),
            ],
          ),
          // const SizedBox(height: 16),
          // Container(
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     color: const Color(0xFFE8F2FF),
          //     borderRadius: BorderRadius.circular(16),
          //   ),
          //   child: Row(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       const Icon(Icons.info_rounded, color: Color(0xFF3B82F6)),
          //       const SizedBox(width: 12),
          //       Expanded(
          //         child: Text(
          //           '아래 표에서 원하는 요일과 시간대의 활동을 클릭하여 선택하세요. 각 요일과 시간대별로 하나의 활동만 선택할 수 있습니다. 같은 활동을 다시 클릭하면 선택이 취소됩니다. 활동을 선택하지 않으면 자동으로 자습으로 배정됩니다.',
          //           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          //             color: const Color(0xFF2563EB),
          //             height: 1.4,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final background =
        active ? const Color(0xFFE8F2FF) : const Color(0xFFF9FAFB);
    final borderColor =
        active ? const Color(0xFF3B82F6) : const Color(0xFFD1D5DB);
    final textColor =
        active ? const Color(0xFF1D4ED8) : const Color(0xFF6B7280);

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: active ? 1.6 : 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: textColor,
        ),
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.centerRight,
      children: [chip, Positioned(right: -6, child: SizedBox.shrink())],
    );
  }
}

class _EducationAppBar extends StatelessWidget {
  const _EducationAppBar({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: width * 0.05,
    );

    return Column(
      children: [
        Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: SvgPicture.asset(
                    'assets/images/realLogo.svg',

                    width: width * 0.25,
                  ),
                ),

                Container(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const Alarm()),
                          );
                        },
                        child: SvgPicture.asset(
                          'assets/images/jong.svg',
                          width: width * 0.055,
                        ),
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
                ),
              ],
            ),
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('수강신청', style: titleStyle),
              const SizedBox(height: 14),
              Row(
                children: const [
                  _PeriodChip(label: '8~9교시', active: true),
                  SizedBox(width: 12),
                  _PeriodChip(label: '10~11교시', active: false),
                ],
              ),
              // const SizedBox(height: 16),
              // Container(
              //   padding: const EdgeInsets.all(16),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFFE8F2FF),
              //     borderRadius: BorderRadius.circular(16),
              //   ),
              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       const Icon(Icons.info_rounded, color: Color(0xFF3B82F6)),
              //       const SizedBox(width: 12),
              //       Expanded(
              //         child: Text(
              //           '아래 표에서 원하는 요일과 시간대의 활동을 클릭하여 선택하세요. 각 요일과 시간대별로 하나의 활동만 선택할 수 있습니다. 같은 활동을 다시 클릭하면 선택이 취소됩니다. 활동을 선택하지 않으면 자동으로 자습으로 배정됩니다.',
              //           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              //             color: const Color(0xFF2563EB),
              //             height: 1.4,
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimetableBlock extends StatelessWidget {
  const _TimetableBlock({required this.period});

  final String period;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                period,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: width * 0.05,
                ),
              ),
              const SizedBox(width: 12),

              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Color(0xFF059669),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '수업선택 완료',
                      style: TextStyle(color: Color(0xFF047857), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._buildDayCards(context),
        ],
      ),
    );
  }

  List<Widget> _buildDayCards(BuildContext context) {
    const data = [
      {
        'day': '월요일',
        'main': '자습',
        'sub': '자습감독 선생님 | 각반교실',
        'alternatives': [
          {'title': '영어기초', 'desc': '이** 선생님 | 2-4'},
          {'title': '독서클럽', 'desc': '김** 선생님 | 도서실'},
          {'title': '심화수학', 'desc': '박** 선생님 | 3-1'},
        ],
      },
      {
        'day': '화요일',
        'main': '정보보호실무',
        'sub': '강 덕실 선생님 | 전담교실',
        'alternatives': [
          {'title': '영어기초', 'desc': '이** 선생님 | 2-4'},
          {'title': '웹디자인', 'desc': '정** 선생님 | 디자인실'},
        ],
      },
      {
        'day': '수요일',
        'main': '자습',
        'sub': '자습감독 선생님 | 각반교실',
        'alternatives': [
          {'title': '영어기초', 'desc': '이** 선생님 | 2-4'},
          {'title': '영어자료실', 'desc': '이** 선생님 | 2-4'},
        ],
      },
      {
        'day': '목요일',
        'main': '자습',
        'sub': '자습감독 선생님 | 각반교실',
        'alternatives': [
          {'title': '영어기초', 'desc': '이** 선생님 | 2-4'},
        ],
      },
    ];

    return [
      for (final item in data) ...[
        _DayCard(
          day: item['day'] as String,
          mainTitle: item['main'] as String,
          subtitle: item['sub'] as String,
          alternatives: (item['alternatives'] as List<Map<String, String>>),
        ),
        const SizedBox(height: 16),
      ],
    ];
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.day,
    required this.mainTitle,
    required this.subtitle,
    required this.alternatives,
  });

  final String day;
  final String mainTitle;
  final String subtitle;
  final List<Map<String, String>> alternatives;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2933),
              fontSize: width * 0.038,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFD9DDE5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F0FF),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFBFD9FF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mainTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F3A8A),
                          fontSize: width * 0.04,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF4B5563),
                          fontSize: width * 0.033,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: const [
                    Expanded(child: Divider(color: Color(0xFFDEE2EB))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '또는',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Color(0xFFDEE2EB))),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final alt in alternatives) ...[
                      Text(
                        alt['title'] ?? '',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: width * 0.035,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alt['desc'] ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6B7280),
                          fontSize: width * 0.032,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplyButton extends StatelessWidget {
  const _ApplyButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,

          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {},
        child: const Text('신청하기'),
      ),
    );
  }
}
