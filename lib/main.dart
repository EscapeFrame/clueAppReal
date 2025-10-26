import 'package:clue/login.dart';
import 'package:clue/pages/ClueLink.dart';
import 'package:clue/pages/HakSubSil.dart';
import 'package:clue/pages/HomePage.dart';
import 'package:clue/pages/Settings.dart';
import 'package:clue/services/assignment_notification_service.dart';
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
  await AssignmentNotificationService.ensureBackgroundTaskRegistered();
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
  late final List<Widget> _pages;
  late final List<GlobalKey<NavigatorState>> _navigatorKeys;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(),
      code != 'teacher' ? Haksubsil() : Thaksubsilsuap(),
      Login(),
      Settings(),
      Cluelink(),
    ];
    _navigatorKeys = List.generate(
      _pages.length,
      (_) => GlobalKey<NavigatorState>(),
    );
  }

  Future<bool> _onWillPop() async {
    final navigator = _navigatorKeys[_selectedIndex].currentState;
    if (navigator?.canPop() ?? false) {
      navigator!.pop();
      return false;
    }
    return true;
  }

  Widget _buildTabNavigator(int index, Widget child) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => child,
        settings: settings,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            for (var i = 0; i < _pages.length; i++)
              _buildTabNavigator(i, _pages[i]),
          ],
        ),
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
              label: '링크',
            ),
          ],
        ),
      ),
    );
  }
}
