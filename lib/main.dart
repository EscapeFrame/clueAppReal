import 'package:clue/login.dart';
import 'package:clue/pages/HakSubSil.dart';
import 'package:clue/pages/HomePage.dart';
import 'package:clue/pages/Settings.dart';
import 'package:clue/teacher_page/tHakSubSilSuap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('dotenv load failed: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation Demo',

      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static String code="teacher";
  // static String code = "student";
  final List<Widget> _pages = [
    HomePage(),
    code != 'teacher' ? Haksubsil() : Thaksubsilsuap(),
    // Education(),
    Login(),
    // Test(),
    Settings(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: SvgPicture.asset(
              'assets/images/homen.svg',
              colorFilter: ColorFilter.mode(
                const Color.fromARGB(223, 199, 199, 199),
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              'assets/images/homen.svg',
              colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            ),
            label: '홈',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: SvgPicture.asset(
              'assets/images/bookn.svg',
              colorFilter: ColorFilter.mode(
                const Color.fromARGB(223, 199, 199, 199),
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              'assets/images/bookn.svg',
              colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            ),
            label: '책',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: SvgPicture.asset(
              'assets/images/Union.svg',
              colorFilter: ColorFilter.mode(
                const Color.fromARGB(223, 199, 199, 199),
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              'assets/images/Union.svg',
              colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            ),
            label: '학교공지',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: SvgPicture.asset(
              'assets/images/Setting.svg',
              colorFilter: ColorFilter.mode(
                const Color.fromARGB(223, 199, 199, 199),
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              'assets/images/Setting.svg',
              colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            ),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
