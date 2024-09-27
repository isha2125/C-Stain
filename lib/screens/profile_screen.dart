import 'package:cstain/models/achievements.dart';
import 'package:cstain/models/user_badges.dart';
import 'package:cstain/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MYProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStream = ref.watch(userStreamProvider);
    final userBadges = ref.watch(userBadgesProvider);
    final userAchievementsStream =
        ref.watch(userAchievementsWithDetailsProvider);

    int itemCount = 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<int>(
            icon: Icon(Icons.more_vert), // Trailing menu icon
            onSelected: (value) {
              switch (value) {
                case 0:
                  // Navigate to Settings
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
                  break;
                case 1:
                  // Call Sign Out function
                  _signOut(context);
                  break;
                case 2:
                  // Call Delete Account function
                  _deleteAccount(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.black),
                    SizedBox(width: 10),
                    Text("Settings"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.black),
                    SizedBox(width: 10),
                    Text("Sign Out"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 10),
                    Text("Delete Account"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: userStream.when(
        data: (myUser) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // User Profile Section
                Row(
                  children: [
                    CircleAvatar(
                      radius: 50, // Profile image size
                      backgroundImage: NetworkImage(myUser.profile_picture_url),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            myUser.username,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            softWrap: true, // Allows wrapping
                            maxLines: 4, // Allows unlimited lines
                            overflow:
                                TextOverflow.visible, // Prevents truncation
                          ),
                          const SizedBox(height: 10),
                          if (myUser.bio.isNotEmpty) ...[
                            Text(
                              myUser.bio,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 10)
                          ],
                          Row(
                            children: [
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '200', // The number part
                                      style: TextStyle(
                                        fontWeight: FontWeight
                                            .bold, // Bold style for the number
                                        color: Color(
                                            0xFF237155), // Your desired color
                                        fontSize:
                                            16, // Optional size adjustment
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' Followers', // The remaining text
                                      style: TextStyle(
                                        color: Color(
                                            0xFF237155), // Your desired color
                                        fontSize:
                                            16, // Optional size adjustment
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '200', // The number part
                                      style: TextStyle(
                                        fontWeight: FontWeight
                                            .bold, // Bold style for the number
                                        color: Color(
                                            0xFF237155), // Your desired color
                                        fontSize:
                                            16, // Optional size adjustment
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' Following', // The remaining text
                                      style: TextStyle(
                                        color: Color(
                                            0xFF237155), // Your desired color
                                        fontSize:
                                            16, // Optional size adjustment
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Follow Button
                // Follow Button
                SizedBox(
                  width: MediaQuery.of(context)
                      .size
                      .width, // Full width of the screen
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF237155), // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: Size(double.infinity, 40),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                // CO2 Saving and Achievement Section
                SizedBox(height: 20),
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total CO2 saving',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            '${myUser.total_CO2_saved.toStringAsFixed(2)} kg',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ],
                      ),
                      Container(
                        width: 2, // Thickness of the divider
                        decoration: BoxDecoration(
                          color: Colors.grey, // Divider color
                          borderRadius:
                              BorderRadius.circular(8), // Rounded edges
                        ),
                        height: double.infinity, // Make it fill the height
                        //margin: EdgeInsets.symmetric(
                        //horizontal: 2), // Adds space around the divider
                      ),
                      // VerticalDivider(
                      //   color: Color.fromARGB(255, 146, 146, 146), // Changed to grey
                      //   thickness: 2.0, // Adjust thickness as needed
                      //   width: 20, // Space between columns
                      // ),

                      userAchievementsStream.when(
                        data: (achievements) {
                          final lastAchievement = achievements.isNotEmpty
                              ? achievements.first
                              : null;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Last Achievement',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              Text(
                                lastAchievement != null
                                    ? lastAchievement[
                                        'name'] // Now displaying the achievement name
                                    : 'No achievements yet',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true, // Allows wrapping
                                maxLines: 4, // Allows unlimited lines
                                overflow: TextOverflow.visible,
                              ),
                            ],
                          );
                        },
                        loading: () => CircularProgressIndicator(),
                        error: (error, stack) => Text('Error: $error'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Expanded Tab Section (Posts and Badges)
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          indicatorColor: Color(0xFF237155),
                          labelColor: Colors.black,
                          tabs: [
                            Tab(text: 'Posts'),
                            Tab(text: 'Badges'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Posts Tab Content

                              itemCount == 0
                                  ? Center(
                                      child: Text(
                                        "No posts yet",
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.grey),
                                      ),
                                    )
                                  : GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                      ),
                                      itemCount:
                                          itemCount, // Placeholder item count or actual count
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: EdgeInsets.all(4),
                                          color: Colors.grey[200],
                                        );
                                      },
                                    ),

                              // GridView.builder(
                              //   gridDelegate:
                              //       SliverGridDelegateWithFixedCrossAxisCount(
                              //     crossAxisCount: 3,
                              //   ),
                              //   itemCount: 15, // For demo purposes
                              //   itemBuilder: (context, index) {
                              //     return Container(
                              //       margin: EdgeInsets.all(4),
                              //       color: Colors.grey[200],
                              //     );
                              //   },
                              // ),
                              // Badges Tab Content
                              userBadges.when(
                                data: (badges) => _buildBadgesList(badges, ref),
                                loading: () => CircularProgressIndicator(),
                                error: (error, stack) =>
                                    Text('Error loading badges: $error'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  // Function to handle Sign Out
  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform sign-out operation
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Signed out successfully')),
                );
              },
              child: Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  // Function to handle Delete Account
  void _deleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text(
            'Are you sure you want to delete your account? This action is irreversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform delete account operation
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Account deleted successfully')),
                );
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

// Placeholder for the Settings screen
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Text("Settings Page"),
      ),
    );
  }
}

Widget _buildBadgesList(List<UserBadgesModel> userBadges, WidgetRef ref) {
  final allBadges = ref.watch(badgesProvider);
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (userBadges.isEmpty)
          Center(
            child: Text(
              'Try to be consistent to earn a badge!',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          )
        else
          allBadges.when(
            data: (badges) {
              final badgeMap = {
                for (var badge in badges) badge.badge_id: badge
              };
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: userBadges.map((userBadge) {
                  final badge = badgeMap[userBadge.badge_id];
                  return Tooltip(
                    message: badge?.description ?? 'Unknown badge',
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(
                                badge?.badge_url ??
                                    'https://placeholder.com/60x60',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          badge?.name ?? 'Unknown',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => CircularProgressIndicator(),
            error: (error, stack) => Text('Error loading badges: $error'),
          ),
      ],
    ),
  );
}
