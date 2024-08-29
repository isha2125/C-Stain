import 'package:cstain/screens/action_screen.dart';
import 'package:cstain/screens/community_screen.dart';
import 'package:cstain/screens/dashboard_screen.dart';
import 'package:cstain/screens/home_screen.dart';
import 'package:flutter/material.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor:
              const Color(0xFFE0FFF4), // Light mint background color
          indicatorColor:
              const Color(0xFFABD5C5), // Light green indicator color
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Color.fromRGBO(0, 0, 0, 1));
            }
            return TextStyle(color: Colors.grey.shade700);
          }),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.black);
            }
            return IconThemeData(color: Colors.grey.shade700);
          }),
        ),
        child: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.check_circle),
              icon: Icon(Icons.check_circle_outline),
              label: 'Actions',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.assessment),
              icon: Icon(Icons.assessment_outlined),
              label: 'Dashboard',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.groups),
              icon: Icon(Icons.groups_2_outlined),
              label: 'Community',
            ),
          ],
        ),
      ),
      body: <Widget>[
        /// Home page
        HomeScreen(),

        /// Actions page
        ActionScreen(),

        /// Dashboard page
        DashboardScreen(),

        /// Community page
        CommunityScreen(),
      ][currentPageIndex],
    );
  }
}
