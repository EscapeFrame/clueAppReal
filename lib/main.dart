import 'package:clue/asdf.dart';
import 'package:clue/login.dart';
import 'package:clue/pages/ClueLink.dart';
import 'package:clue/pages/Education.dart';
import 'package:clue/pages/HakSubSil.dart';
import 'package:clue/pages/HomePage.dart';
import 'package:clue/pages/Settings.dart';
import 'package:clue/services/assignment_notification_service.dart';
import 'package:clue/teacher_page/tHakSubSilSuap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:math' as math;
import 'pages/welcome.dart';

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
      home: const WelcomeScreen(),
      routes: {'/main': (_) => const MainScreen()},
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static Route<dynamic> get route =>
      MaterialPageRoute(builder: (_) => const MainScreen());
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  // static String code = "student";
  static String code = "teacher";
  late final List<Widget> _pages;
  late final List<GlobalKey<NavigatorState>> _navigatorKeys;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(),
      code != 'teacher' ? Haksubsil() : Thaksubsilsuap(),
      Cluelink(),

      Login(),
      Settings(),
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
      onGenerateRoute:
          (settings) =>
              MaterialPageRoute(builder: (_) => child, settings: settings),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _diamondIcon(bool selected) {
    const bg = Color(0xFFD6EAFF);
    final fg = selected ? Colors.blue : const Color(0xFF5FA8FF);
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Transform.rotate(
          angle: -math.pi / 4,
          child: Center(
            child: SvgPicture.asset(
              'assets/images/LinksaveIcon.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const barHeight = 60.0;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // extendBody: true,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            for (var i = 0; i < _pages.length; i++)
              _buildTabNavigator(i, _pages[i]),
          ],
        ),

        // 가운데 다이아 버튼(FAB)
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Transform.translate(
          offset: const Offset(0, 20),
          child: SizedBox(
            width: 50,
            height: 50,
            child: InkWell(
              onTap: () => _onItemTapped(2),
              borderRadius: BorderRadius.circular(20),
              child: _diamondIcon(_selectedIndex == 2),
            ),
          ),
        ),

        bottomNavigationBar: SizedBox(
          height: barHeight + bottomInset,
          child: Material(
            elevation: 8,
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    iconPath: 'assets/images/homen.svg',
                    active: _selectedIndex == 0,
                    onTap: () => _onItemTapped(0),
                  ),
                  _NavItem(
                    iconPath: 'assets/images/bookn.svg',
                    active: _selectedIndex == 1,
                    onTap: () => _onItemTapped(1),
                  ),
                  const SizedBox(width: 56),
                  _NavItem(
                    iconPath: 'assets/images/Union.svg',
                    active: _selectedIndex == 3,
                    onTap: () => _onItemTapped(3),
                  ),
                  _NavItem(
                    iconPath: 'assets/images/Setting.svg',
                    active: _selectedIndex == 4,
                    onTap: () => _onItemTapped(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String iconPath;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({
    super.key,
    required this.iconPath,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color inactive = const Color.fromARGB(223, 199, 199, 199);
    final Color activeC = Colors.blue;
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        child: SvgPicture.asset(
          iconPath,
          width: 22,
          height: 22,
          colorFilter: ColorFilter.mode(
            active ? activeC : inactive,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
