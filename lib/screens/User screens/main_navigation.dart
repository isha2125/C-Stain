import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/screens/User%20screens/action_screen.dart';
import 'package:cstain/screens/User%20screens/user_campaign_screen.dart';
import 'package:cstain/screens/community_screen.dart';
import 'package:cstain/screens/Corp%20screens/corp_bottom_nav.dart';
import 'package:cstain/screens/User%20screens/dashboard_screen.dart';
import 'package:cstain/screens/User%20screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserBottomNav extends StatefulWidget {
  const UserBottomNav({super.key});

  @override
  State<UserBottomNav> createState() => _UserBottomNavigationState();
}

class _UserBottomNavigationState extends State<UserBottomNav> {
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .get();

      final role = userDoc.data()?['role'] ?? 'user'; // Default to 'user'

      if (role == 'corp') {
        // Redirect to CorpDashboard
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => CorpBottomNav()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

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
              selectedIcon: Icon(Icons.assessment),
              icon: Icon(Icons.assessment_outlined),
              label: 'Dashboard',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.check_circle),
              icon: Icon(Icons.check_circle_outline),
              label: 'Actions',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.campaign),
              icon: Icon(Icons.campaign_outlined),
              label: 'Campaign',
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

        /// Dashboard page
        DashboardScreen(),

        /// Actions page
        ActionScreen(),

        /// Campaign Screen
        UserCampaignScreen(),

        /// Community page
        CommunityScreen(),
      ][currentPageIndex],
    );
  }
}
