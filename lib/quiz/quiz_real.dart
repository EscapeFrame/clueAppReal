import 'package:flutter/material.dart';

class QuizReal extends StatefulWidget {
  const QuizReal({super.key});

  @override
  State<QuizReal> createState() => _QuizRealState();
}

class _QuizRealState extends State<QuizReal> {
  static const progress = 0.3; // example: 30%
  static const questionNumber = 1;
  static const totalQuestions = 10;
  static const score = 12;
  static const totalScore = 59;
  static const timerSeconds = 10;

  int selectedIndex = -1;
  bool _showResult = false;

  final List<_AnswerData> _answers = const [
    _AnswerData(
      numberText: '①',
      label: '캡슐화',
      accentColor: Color(0xFF0A84FF),
      fillColor: Color(0xFFE3F1FF),
      count: 18,
    ),
    _AnswerData(
      numberText: '②',
      label: '추상화',
      accentColor: Color(0xFFE3568E),
      fillColor: Color(0xFFFAD8E6),
      count: 15,
    ),
    _AnswerData(
      numberText: '③',
      label: '다형성',
      accentColor: Color(0xFFE59B1D),
      fillColor: Color(0xFFFFF4C6),
      count: 20,
    ),
    _AnswerData(
      numberText: '④',
      label: '포함',
      accentColor: Color(0xFFB77FFF),
      fillColor: Color(0xFFF4EBFF),
      count: 16,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '퀴즈 나가기',
          style: TextStyle(color: Colors.black87, fontSize: 16),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14),
                  children: [
                    const TextSpan(
                      text: '문제 ',
                      style: TextStyle(color: Colors.black54),
                    ),
                    TextSpan(
                      text: '$questionNumber',
                      style: const TextStyle(
                        color: Color(0xFF0A84FF),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: ' / $totalQuestions',
                      style: const TextStyle(color: Colors.black45),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        toolbarHeight: 48,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!_showResult) const SizedBox(height: 28),
            if (!_showResult)
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF0A84FF),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '$timerSeconds',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (!_showResult) const SizedBox(height: 12),
            if (!_showResult)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    color: const Color(0xFF0A84FF),
                    backgroundColor: const Color(0xFFE5E5E5),
                  ),
                ),
              ),
            if (!_showResult) const SizedBox(height: 10),
            Expanded(
              child:
                  _showResult
                      ? _ResultView(
                        question: '자바에서 객체지향 프로그래밍의 핵심 개념이 아닌 것은?',
                        answers: _answers,
                        selectedIndex: selectedIndex,
                      )
                      : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x11000000),
                                blurRadius: 14,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: '$score',
                                          style: TextStyle(
                                            color: Color(0xFF0A84FF),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '/$totalScore',
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '자바에서 객체지향 프로그래밍의 핵심 개념이 아닌 것은?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Column(
                                children: [
                                  _AnswerButton(
                                    numberText: '①',
                                    label: '캡슐화',
                                    accentColor: const Color(0xFF0A84FF),
                                    dimmed:
                                        selectedIndex != -1 &&
                                        selectedIndex != 0,
                                    onTap:
                                        selectedIndex == -1
                                            ? () {
                                              setState(() => selectedIndex = 0);
                                            }
                                            : null,
                                  ),
                                  const SizedBox(height: 2),
                                  _AnswerButton(
                                    numberText: '②',
                                    label: '추상화',
                                    accentColor: const Color(0xFFE3568E),
                                    dimmed:
                                        selectedIndex != -1 &&
                                        selectedIndex != 1,
                                    onTap:
                                        selectedIndex == -1
                                            ? () {
                                              setState(() => selectedIndex = 1);
                                            }
                                            : null,
                                  ),
                                  const SizedBox(height: 2),
                                  _AnswerButton(
                                    numberText: '③',
                                    label: '다형성',
                                    accentColor: const Color(0xFFE59B1D),
                                    dimmed:
                                        selectedIndex != -1 &&
                                        selectedIndex != 2,
                                    onTap:
                                        selectedIndex == -1
                                            ? () {
                                              setState(() => selectedIndex = 2);
                                            }
                                            : null,
                                  ),
                                  const SizedBox(height: 2),
                                  _AnswerButton(
                                    numberText: '④',
                                    label: '포함',
                                    accentColor: const Color(0xFFB77FFF),
                                    fillColor: const Color(0xFFF4EBFF),
                                    dimmed:
                                        selectedIndex != -1 &&
                                        selectedIndex != 3,
                                    onTap:
                                        selectedIndex == -1
                                            ? () {
                                              setState(() => selectedIndex = 3);
                                            }
                                            : null,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
            ),
            if (!_showResult)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: ElevatedButton(
                  onPressed:
                      selectedIndex != -1
                          ? () {
                            setState(() {
                              _showResult = true;
                            });
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A84FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '정답 확인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFE5E5E5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '랭킹보기',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A84FF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '다음문제',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.question,
    required this.answers,
    required this.selectedIndex,
  });

  final String question;
  final List<_AnswerData> answers;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final maxCount =
        answers.map((a) => a.count).reduce((a, b) => a > b ? a : b).toDouble();
    const double maxBarHeight = 220;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text(
            question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          if (selectedIndex >= 0)
            Text(
              '${answers[selectedIndex].numberText} ${answers[selectedIndex].label}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0A84FF),
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final answer in answers) ...[
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: (answer.count / maxCount) * maxBarHeight,
                              decoration: BoxDecoration(
                                color: answer.fillColor.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: answer.accentColor.withOpacity(0.6),
                                  width: 1.2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${answer.count}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (answer != answers.last) const SizedBox(width: 12),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    for (final answer in answers) ...[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          margin:
                              answer == answers.last
                                  ? EdgeInsets.zero
                                  : const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: answer.fillColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: answer.accentColor.withOpacity(0.6),
                            ),
                          ),
                          child: Text(
                            '${answer.numberText} ${answer.label}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
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

class _AnswerData {
  const _AnswerData({
    required this.numberText,
    required this.label,
    required this.accentColor,
    required this.fillColor,
    required this.count,
  });

  final String numberText;
  final String label;
  final Color accentColor;
  final Color fillColor;
  final int count;
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.numberText,
    required this.label,
    required this.accentColor,
    this.fillColor,
    this.dimmed = false,
    this.onTap,
  });

  final String numberText;
  final String label;
  final Color accentColor;
  final Color? fillColor;
  final bool dimmed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E5E5)),
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color:
                  dimmed
                      ? const Color(0xFFF3F3F3)
                      : (fillColor ?? accentColor.withOpacity(0.14)),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    dimmed
                        ? const Color(0xFFE0E0E0)
                        : accentColor.withOpacity(0.4),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  numberText,
                  style: TextStyle(
                    color: dimmed ? Colors.black45 : accentColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: dimmed ? Colors.black54 : Colors.black87,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
