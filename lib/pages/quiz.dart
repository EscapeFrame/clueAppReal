import 'package:clue/HamburgerDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:clue/quiz/quiz_enter.dart';
import 'Alarm.dart';

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  static const _backgroundColor = Color(0xffF5F5F5);
  static const _cardShadow = [
    BoxShadow(color: Color(0x11000000), blurRadius: 18, offset: Offset(0, 6)),
  ];

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  final TextEditingController _codeController = TextEditingController();
  final List<String> _characterImages = const [
    'assets/images/owl.png',
    'assets/images/Haeyul.png',
    'assets/images/panda.png',
    'assets/images/ferret.png',
    'assets/images/I.png',
    'assets/images/koala.png',
  ];
  int _currentIndex = 0;
  bool _isCompleted = false;
  String _submittedCode = '';

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onCodeChanged);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onCodeChanged() => setState(() {});

  bool get _isCodeFilled => _codeController.text.trim().isNotEmpty;

  void _handleSubmit() {
    if (!_isCodeFilled) return;
    setState(() {
      _submittedCode = _codeController.text.trim();
      _isCompleted = true;
    });
  }

  void _handleBack() {
    setState(() {
      _isCompleted = false;
      _submittedCode = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;

    return Scaffold(
      backgroundColor: Quiz._backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
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
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: _isCompleted
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: QuizEnter(
                          code: _submittedCode.isNotEmpty
                              ? _submittedCode
                              : _codeController.text.trim(),
                          embed: true,
                          onBack: _handleBack,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 520),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: Quiz._cardShadow,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 32,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '퀴즈 참여 하기',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '학습실 문제 코드를 입력해주세요.',
                                style:
                                    TextStyle(fontSize: 15, color: Colors.black54),
                              ),
                              const SizedBox(height: 28),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _currentIndex =
                                            (_currentIndex -
                                                    1 +
                                                    _characterImages.length) %
                                                _characterImages.length;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Colors.black38,
                                    ),
                                    splashRadius: 20,
                                  ),
                                  SizedBox(
                                    height: width > 420 ? 240 : 200,
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 250),
                                      child: Image.asset(
                                        _characterImages[_currentIndex],
                                        key: ValueKey<String>(
                                          _characterImages[_currentIndex],
                                        ),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _currentIndex =
                                            (_currentIndex + 1) %
                                            _characterImages.length;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Colors.black38,
                                    ),
                                    splashRadius: 20,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 28),

                              TextField(
                                controller: _codeController,
                                onChanged: (_) => setState(() {}),
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  hintText: '코드를 입력해주세요.',
                                  filled: true,
                                  fillColor: const Color(0xFFF7F8FA),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE6E8EB),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFF0A84FF),
                                      width: 1.2,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isCodeFilled ? _handleSubmit : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0A84FF),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    '참가하기',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



