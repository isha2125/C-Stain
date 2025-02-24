import 'package:cstain/screens/User%20screens/action_screen.dart';
import 'package:cstain/screens/community_screen.dart';
import 'package:cstain/screens/Corp%20screens/corp_campaign_screen.dart';
import 'package:cstain/screens/Corp%20screens/corp_homescreen.dart';
import 'package:flutter/material.dart';

class CorpBottomNav extends StatefulWidget {
  const CorpBottomNav({super.key});

  @override
  State<CorpBottomNav> createState() => _CorpBottomNavstate();
}

class _CorpBottomNavstate extends State<CorpBottomNav> {
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
              label: 'Campaigns',
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
        CorpHomescreen(),

        /// Actions page
        ActionScreen(),

        /// Dashboard page
        CorpCampaignScreen(),

        /// Community page
        CommunityScreen(),
      ][currentPageIndex],
    );
  }
}
