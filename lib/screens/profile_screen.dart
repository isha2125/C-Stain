// import 'package:cstain/models/achievements.dart';
// import 'package:cstain/models/user_badges.dart';
// import 'package:cstain/providers/providers.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class MYProfileScreen extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final userStream = ref.watch(userStreamProvider);
//     final userBadges = ref.watch(userBadgesProvider);
//     final userAchievementsStream =
//         ref.watch(userAchievementsWithDetailsProvider);

//     int itemCount = 4;
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('User Profile'),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           PopupMenuButton<int>(
//             icon: Icon(Icons.more_vert), // Trailing menu icon
//             onSelected: (value) {
//               switch (value) {
//                 case 0:
//                   // Navigate to Settings
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => SettingsScreen()),
//                   );
//                   break;
//                 case 1:
//                   // Call Sign Out function
//                   _signOut(context);
//                   break;
//                 case 2:
//                   // Call Delete Account function
//                   _deleteAccount(context);
//                   break;
//               }
//             },
//             itemBuilder: (context) => [
//               PopupMenuItem(
//                 value: 0,
//                 child: Row(
//                   children: [
//                     Icon(Icons.settings, color: Colors.black),
//                     SizedBox(width: 10),
//                     Text("Settings"),
//                   ],
//                 ),
//               ),
//               PopupMenuItem(
//                 value: 1,
//                 child: Row(
//                   children: [
//                     Icon(Icons.exit_to_app, color: Colors.black),
//                     SizedBox(width: 10),
//                     Text("Sign Out"),
//                   ],
//                 ),
//               ),
//               PopupMenuItem(
//                 value: 2,
//                 child: Row(
//                   children: [
//                     Icon(Icons.delete_forever, color: Colors.red),
//                     SizedBox(width: 10),
//                     Text("Delete Account"),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: userStream.when(
//         data: (myUser) {
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 // User Profile Section
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 50, // Profile image size
//                       backgroundImage: NetworkImage(myUser.profile_picture_url),
//                     ),
//                     const SizedBox(width: 20),
//                     Flexible(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: 10),
//                           Text(
//                             myUser.username,
//                             style: const TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold),
//                             softWrap: true, // Allows wrapping
//                             maxLines: 4, // Allows unlimited lines
//                             overflow:
//                                 TextOverflow.visible, // Prevents truncation
//                           ),
//                           const SizedBox(height: 10),
//                           if (myUser.bio.isNotEmpty) ...[
//                             Text(
//                               myUser.bio,
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                             SizedBox(height: 10)
//                           ],
//                           Row(
//                             children: [
//                               RichText(
//                                 text: const TextSpan(
//                                   children: [
//                                     TextSpan(
//                                       text: '200', // The number part
//                                       style: TextStyle(
//                                         fontWeight: FontWeight
//                                             .bold, // Bold style for the number
//                                         color: Color(
//                                             0xFF237155), // Your desired color
//                                         fontSize:
//                                             16, // Optional size adjustment
//                                       ),
//                                     ),
//                                     TextSpan(
//                                       text: ' Followers', // The remaining text
//                                       style: TextStyle(
//                                         color: Color(
//                                             0xFF237155), // Your desired color
//                                         fontSize:
//                                             16, // Optional size adjustment
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               RichText(
//                                 text: const TextSpan(
//                                   children: [
//                                     TextSpan(
//                                       text: '200', // The number part
//                                       style: TextStyle(
//                                         fontWeight: FontWeight
//                                             .bold, // Bold style for the number
//                                         color: Color(
//                                             0xFF237155), // Your desired color
//                                         fontSize:
//                                             16, // Optional size adjustment
//                                       ),
//                                     ),
//                                     TextSpan(
//                                       text: ' Following', // The remaining text
//                                       style: TextStyle(
//                                         color: Color(
//                                             0xFF237155), // Your desired color
//                                         fontSize:
//                                             16, // Optional size adjustment
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 20),

//                 // Follow Button
//                 // Follow Button
//                 SizedBox(
//                   width: MediaQuery.of(context)
//                       .size
//                       .width, // Full width of the screen
//                   child: ElevatedButton(
//                     onPressed: () {},
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFF237155), // Button color
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       minimumSize: Size(double.infinity, 40),
//                     ),
//                     child: const Text(
//                       'Edit Profile',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),

//                 // CO2 Saving and Achievement Section
//                 SizedBox(height: 20),
//                 IntrinsicHeight(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Total CO2 saving',
//                             style: TextStyle(color: Colors.grey, fontSize: 12),
//                           ),
//                           Text(
//                             '${myUser.total_CO2_saved.toStringAsFixed(2)} kg',
//                             style: const TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color.fromARGB(255, 0, 0, 0)),
//                           ),
//                         ],
//                       ),
//                       Container(
//                         width: 2, // Thickness of the divider
//                         decoration: BoxDecoration(
//                           color: Colors.grey, // Divider color
//                           borderRadius:
//                               BorderRadius.circular(8), // Rounded edges
//                         ),
//                         height: double.infinity, // Make it fill the height
//                         //margin: EdgeInsets.symmetric(
//                         //horizontal: 2), // Adds space around the divider
//                       ),
//                       // VerticalDivider(
//                       //   color: Color.fromARGB(255, 146, 146, 146), // Changed to grey
//                       //   thickness: 2.0, // Adjust thickness as needed
//                       //   width: 20, // Space between columns
//                       // ),

//                       userAchievementsStream.when(
//                         data: (achievements) {
//                           final lastAchievement = achievements.isNotEmpty
//                               ? achievements.first
//                               : null;
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Last Achievement',
//                                 style:
//                                     TextStyle(color: Colors.grey, fontSize: 12),
//                               ),
//                               Text(
//                                 lastAchievement != null
//                                     ? lastAchievement[
//                                         'name'] // Now displaying the achievement name
//                                     : 'No achievements yet',
//                                 style: TextStyle(
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 softWrap: true, // Allows wrapping
//                                 maxLines: 4, // Allows unlimited lines
//                                 overflow: TextOverflow.visible,
//                               ),
//                             ],
//                           );
//                         },
//                         loading: () => CircularProgressIndicator(),
//                         error: (error, stack) => Text('Error: $error'),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 20),

//                 // Expanded Tab Section (Posts and Badges)
//                 Expanded(
//                   child: DefaultTabController(
//                     length: 2,
//                     child: Column(
//                       children: [
//                         TabBar(
//                           indicatorColor: Color(0xFF237155),
//                           labelColor: Colors.black,
//                           tabs: [
//                             Tab(text: 'Posts'),
//                             Tab(text: 'Badges'),
//                           ],
//                         ),
//                         Expanded(
//                           child: TabBarView(
//                             children: [
//                               // Posts Tab Content

//                               itemCount == 0
//                                   ? Center(
//                                       child: Text(
//                                         "No posts yet",
//                                         style: TextStyle(
//                                             fontSize: 18, color: Colors.grey),
//                                       ),
//                                     )
//                                   : GridView.builder(
//                                       gridDelegate:
//                                           SliverGridDelegateWithFixedCrossAxisCount(
//                                         crossAxisCount: 3,
//                                       ),
//                                       itemCount:
//                                           itemCount, // Placeholder item count or actual count
//                                       itemBuilder: (context, index) {
//                                         return Container(
//                                           margin: EdgeInsets.all(4),
//                                           color: Colors.grey[200],
//                                         );
//                                       },
//                                     ),

//                               // GridView.builder(
//                               //   gridDelegate:
//                               //       SliverGridDelegateWithFixedCrossAxisCount(
//                               //     crossAxisCount: 3,
//                               //   ),
//                               //   itemCount: 15, // For demo purposes
//                               //   itemBuilder: (context, index) {
//                               //     return Container(
//                               //       margin: EdgeInsets.all(4),
//                               //       color: Colors.grey[200],
//                               //     );
//                               //   },
//                               // ),
//                               // Badges Tab Content
//                               userBadges.when(
//                                 data: (badges) => _buildBadgesList(badges, ref),
//                                 loading: () => CircularProgressIndicator(),
//                                 error: (error, stack) =>
//                                     Text('Error loading badges: $error'),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//         loading: () => Center(
//           child: CircularProgressIndicator(),
//         ),
//         error: (error, stack) => Center(
//           child: Text('Error: $error'),
//         ),
//       ),
//     );
//   }

// // import 'package:cstain/models/achievements.dart';
// // import 'package:cstain/models/user_badges.dart';
// // import 'package:cstain/providers/providers.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';

// // class MYProfileScreen extends ConsumerWidget {
// //   final String profileUserId; // ID of the profile being viewed

// //   MYProfileScreen({Key? key, required this.profileUserId}) : super(key: key);

// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     final currentUser = ref.watch(currentUserProvider);
// //     final profileUserStream = ref.watch(userStreamProvider(profileUserId)); // Fetch the profile's data
// //     final userBadges = ref.watch(userBadgesProvider);
// //     final userAchievementsStream = ref.watch(userAchievementsWithDetailsProvider);

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('User Profile'),
// //         leading: IconButton(
// //           icon: Icon(Icons.arrow_back),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //         actions: [
// //           if (profileUserId == currentUser?.uid) // Only show menu for the current user
// //             PopupMenuButton<int>(
// //               icon: Icon(Icons.more_vert),
// //               onSelected: (value) {
// //                 switch (value) {
// //                   case 0:
// //                     // Navigate to Settings
// //                     Navigator.push(
// //                       context,
// //                       MaterialPageRoute(builder: (context) => SettingsScreen()),
// //                     );
// //                     break;
// //                   case 1:
// //                     // Sign out
// //                     _signOut(context);
// //                     break;
// //                   case 2:
// //                     // Delete Account
// //                     _deleteAccount(context);
// //                     break;
// //                 }
// //               },
// //               itemBuilder: (context) => [
// //                 PopupMenuItem(
// //                   value: 0,
// //                   child: Row(
// //                     children: [
// //                       Icon(Icons.settings, color: Colors.black),
// //                       SizedBox(width: 10),
// //                       Text("Settings"),
// //                     ],
// //                   ),
// //                 ),
// //                 PopupMenuItem(
// //                   value: 1,
// //                   child: Row(
// //                     children: [
// //                       Icon(Icons.exit_to_app, color: Colors.black),
// //                       SizedBox(width: 10),
// //                       Text("Sign Out"),
// //                     ],
// //                   ),
// //                 ),
// //                 PopupMenuItem(
// //                   value: 2,
// //                   child: Row(
// //                     children: [
// //                       Icon(Icons.delete_forever, color: Colors.red),
// //                       SizedBox(width: 10),
// //                       Text("Delete Account"),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //         ],
// //       ),
// //       body: profileUserStream.when(
// //         data: (profileUser) {
// //           final isCurrentUser = profileUserId == currentUser?.uid;

// //           return Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Column(
// //               children: [
// //                 // Profile Header Section
// //                 Row(
// //                   children: [
// //                     CircleAvatar(
// //                       radius: 50,
// //                       backgroundImage: NetworkImage(profileUser.profile_picture_url),
// //                     ),
// //                     const SizedBox(width: 20),
// //                     Flexible(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             profileUser.username,
// //                             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //                           ),
// //                           const SizedBox(height: 10),
// //                           if (profileUser.bio.isNotEmpty)
// //                             Text(
// //                               profileUser.bio,
// //                               style: const TextStyle(fontSize: 14, color: Colors.grey),
// //                             ),
// //                           const SizedBox(height: 10),
// //                           Row(
// //                             children: [
// //                               Text(
// //                                 '200 Followers',
// //                                 style: TextStyle(color: Color(0xFF237155)),
// //                               ),
// //                               const SizedBox(width: 10),
// //                               Text(
// //                                 '200 Following',
// //                                 style: TextStyle(color: Color(0xFF237155)),
// //                               ),
// //                             ],
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 SizedBox(height: 20),

// //                 // Button (Edit Profile or Follow)
// //                 SizedBox(
// //                   width: MediaQuery.of(context).size.width,
// //                   child: ElevatedButton(
// //                     onPressed: () {
// //                       if (isCurrentUser) {
// //                         Navigator.push(
// //                           context,
// //                           MaterialPageRoute(
// //                             builder: (context) => EditProfileScreen(),
// //                           ),
// //                         );
// //                       } else {
// //                         _followUser(profileUserId); // Implement follow logic here
// //                       }
// //                     },
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: Color(0xFF237155),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(30),
// //                       ),
// //                     ),
// //                     child: Text(
// //                       isCurrentUser ? 'Edit Profile' : 'Follow',
// //                       style: TextStyle(color: Colors.white),
// //                     ),
// //                   ),
// //                 ),

// //                 // CO2 Savings and Achievements Section
// //                 SizedBox(height: 20),
// //                 IntrinsicHeight(
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                     children: [
// //                       Column(
// //                         children: [
// //                           const Text(
// //                             'Total CO2 Saving',
// //                             style: TextStyle(color: Colors.grey),
// //                           ),
// //                           Text(
// //                             '${profileUser.total_CO2_saved.toStringAsFixed(2)} kg',
// //                             style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
// //                           ),
// //                         ],
// //                       ),
// //                       Container(
// //                         width: 2,
// //                         color: Colors.grey,
// //                         height: double.infinity,
// //                       ),
// //                       userAchievementsStream.when(
// //                         data: (achievements) {
// //                           final lastAchievement = achievements.isNotEmpty ? achievements.first : null;
// //                           return Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               Text('Last Achievement', style: TextStyle(color: Colors.grey)),
// //                               Text(
// //                                 lastAchievement?.name ?? 'No achievements yet',
// //                                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
// //                               ),
// //                             ],
// //                           );
// //                         },
// //                         loading: () => CircularProgressIndicator(),
// //                         error: (error, stack) => Text('Error: $error'),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 SizedBox(height: 20),

// //                 // Tab Section for Posts and Badges
// //                 Expanded(
// //                   child: DefaultTabController(
// //                     length: 2,
// //                     child: Column(
// //                       children: [
// //                         TabBar(
// //                           indicatorColor: Color(0xFF237155),
// //                           labelColor: Colors.black,
// //                           tabs: [
// //                             Tab(text: 'Posts'),
// //                             Tab(text: 'Badges'),
// //                           ],
// //                         ),
// //                         Expanded(
// //                           child: TabBarView(
// //                             children: [
// //                               // Posts Tab Content
// //                               GridView.builder(
// //                                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //                                   crossAxisCount: 3,
// //                                 ),
// //                                 itemCount: 9, // Replace with actual post count
// //                                 itemBuilder: (context, index) {
// //                                   return Container(
// //                                     margin: EdgeInsets.all(4),
// //                                     color: Colors.grey[200],
// //                                   );
// //                                 },
// //                               ),
// //                               // Badges Tab Content
// //                               userBadges.when(
// //                                 data: (badges) => _buildBadgesList(badges),
// //                                 loading: () => CircularProgressIndicator(),
// //                                 error: (error, stack) => Text('Error: $error'),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           );
// //         },
// //         loading: () => Center(child: CircularProgressIndicator()),
// //         error: (error, stack) => Center(child: Text('Error: $error')),
// //       ),
// //     );
// //   }

// //******************************************************************************* */
//   // Function to handle Sign Out
//   void _signOut(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Sign Out'),
//           content: Text('Are you sure you want to sign out?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 // Perform sign-out operation
//                 Navigator.of(context).pop();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Signed out successfully')),
//                 );
//               },
//               child: Text('Sign Out'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Function to handle Delete Account
//   void _deleteAccount(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Delete Account'),
//           content: Text(
//             'Are you sure you want to delete your account? This action is irreversible.',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 // Perform delete account operation
//                 Navigator.of(context).pop();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Account deleted successfully')),
//                 );
//               },
//               child: Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// // Placeholder for the Settings screen
// class SettingsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Settings'),
//       ),
//       body: Center(
//         child: Text("Settings Page"),
//       ),
//     );
//   }
// }

// Widget _buildBadgesList(List<UserBadgesModel> userBadges, WidgetRef ref) {
//   final allBadges = ref.watch(badgesProvider);
//   return Padding(
//     padding: const EdgeInsets.all(16.0),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (userBadges.isEmpty)
//           Center(
//             child: Text(
//               'Try to be consistent to earn a badge!',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontStyle: FontStyle.italic,
//                 color: Colors.grey[600],
//               ),
//             ),
//           )
//         else
//           allBadges.when(
//             data: (badges) {
//               final badgeMap = {
//                 for (var badge in badges) badge.badge_id: badge
//               };
//               return Wrap(
//                 spacing: 12,
//                 runSpacing: 12,
//                 children: userBadges.map((userBadge) {
//                   final badge = badgeMap[userBadge.badge_id];
//                   return Tooltip(
//                     message: badge?.description ?? 'Unknown badge',
//                     child: Column(
//                       children: [
//                         Container(
//                           width: 100,
//                           height: 100,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             image: DecorationImage(
//                               image: NetworkImage(
//                                 badge?.badge_url ??
//                                     'https://placeholder.com/60x60',
//                               ),
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           badge?.name ?? 'Unknown',
//                           style: TextStyle(
//                               fontSize: 14, fontWeight: FontWeight.w600),
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               );
//             },
//             loading: () => CircularProgressIndicator(),
//             error: (error, stack) => Text('Error loading badges: $error'),
//           ),
//       ],
//     ),
//   );
// }
// **************************************************************
// import 'package:cstain/models/achievements.dart';
// import 'package:cstain/models/user_badges.dart';
// import 'package:cstain/providers/auth_service.dart';
// import 'package:cstain/providers/providers.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class MYProfileScreen extends ConsumerWidget {
//   final String profileUserId;

//   MYProfileScreen({required this.profileUserId});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authStateProvider);
//     final currentUser = authState.value;
//     final isCurrentUserProfile = currentUser?.uid == profileUserId;

//     final userStream = ref.watch(userStreamProvider);

//     final userBadges = ref.watch(userBadgesProvider);
//     final userAchievementsStream =
//         ref.watch(userAchievementsWithDetailsProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('User Profile'),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           if (isCurrentUserProfile)
//             PopupMenuButton<int>(
//               icon: Icon(Icons.more_vert),
//               onSelected: (value) {
//                 switch (value) {
//                   case 0:
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => SettingsScreen()),
//                     );
//                     break;
//                   case 1:
//                     _signOut(context);
//                     break;
//                   case 2:
//                     _deleteAccount(context);
//                     break;
//                 }
//               },
//               itemBuilder: (context) => [
//                 PopupMenuItem(
//                   value: 0,
//                   child: Row(
//                     children: [
//                       Icon(Icons.settings, color: Colors.black),
//                       SizedBox(width: 10),
//                       Text("Settings"),
//                     ],
//                   ),
//                 ),
//                 PopupMenuItem(
//                   value: 1,
//                   child: Row(
//                     children: [
//                       Icon(Icons.exit_to_app, color: Colors.black),
//                       SizedBox(width: 10),
//                       Text("Sign Out"),
//                     ],
//                   ),
//                 ),
//                 PopupMenuItem(
//                   value: 2,
//                   child: Row(
//                     children: [
//                       Icon(Icons.delete_forever, color: Colors.red),
//                       SizedBox(width: 10),
//                       Text("Delete Account"),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//         ],
//       ),
//       body: userStream.when(
//         data: (myUser) {
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 50,
//                       backgroundImage: NetworkImage(myUser.profile_picture_url),
//                     ),
//                     const SizedBox(width: 20),
//                     Flexible(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             myUser.username,
//                             style: const TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 10),
//                           if (myUser.bio.isNotEmpty) ...[
//                             Text(
//                               myUser.bio,
//                               style: const TextStyle(
//                                   fontSize: 14, color: Colors.grey),
//                             ),
//                             SizedBox(height: 10)
//                           ],
//                           Row(
//                             children: [
//                               Text('200 Followers',
//                                   style: TextStyle(color: Color(0xFF237155))),
//                               const SizedBox(width: 10),
//                               Text('200 Following',
//                                   style: TextStyle(color: Color(0xFF237155))),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 20),
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (isCurrentUserProfile) {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => EditProfileScreen()));
//                       } else {
//                         _toggleFollow(ref, profileUserId);
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFF237155),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30)),
//                     ),
//                     child: Text(
//                       isCurrentUserProfile ? 'Edit Profile' : 'Follow',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 IntrinsicHeight(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text('Total CO2 saving',
//                               style:
//                                   TextStyle(color: Colors.grey, fontSize: 12)),
//                           Text(
//                             '${myUser.total_CO2_saved.toStringAsFixed(2)} kg',
//                             style: const TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black),
//                           ),
//                         ],
//                       ),
//                       Container(
//                         width: 2,
//                         decoration: BoxDecoration(
//                           color: Colors.grey,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         height: double.infinity,
//                       ),
//                       userAchievementsStream.when(
//                         data: (achievements) {
//                           final lastAchievement = achievements.isNotEmpty
//                               ? achievements.first
//                               : null;
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Last Achievement',
//                                   style: TextStyle(
//                                       color: Colors.grey, fontSize: 12)),
//                               Text(
//                                 lastAchievement != null
//                                     ? lastAchievement['name']
//                                     : 'No achievements yet',
//                                 style: TextStyle(
//                                     fontSize: 22, fontWeight: FontWeight.bold),
//                                 softWrap: true,
//                                 maxLines: 4,
//                                 overflow: TextOverflow.visible,
//                               ),
//                             ],
//                           );
//                         },
//                         loading: () => CircularProgressIndicator(),
//                         error: (error, stack) => Text('Error: $error'),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Expanded(
//                   child: DefaultTabController(
//                     length: 2,
//                     child: Column(
//                       children: [
//                         TabBar(
//                           indicatorColor: Color(0xFF237155),
//                           labelColor: Colors.black,
//                           tabs: [
//                             Tab(text: 'Posts'),
//                             Tab(text: 'Badges'),
//                           ],
//                         ),
//                         Expanded(
//                           child: TabBarView(
//                             children: [
//                               GridView.builder(
//                                 gridDelegate:
//                                     SliverGridDelegateWithFixedCrossAxisCount(
//                                         crossAxisCount: 3),
//                                 itemCount: 9,
//                                 itemBuilder: (context, index) {
//                                   return Container(
//                                     margin: EdgeInsets.all(4),
//                                     color: Colors.grey[200],
//                                   );
//                                 },
//                               ),
//                               userBadges.when(
//                                 data: (badges) => _buildBadgesList(badges, ref),
//                                 loading: () => CircularProgressIndicator(),
//                                 error: (error, stack) =>
//                                     Text('Error loading badges: $error'),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//         loading: () => Center(child: CircularProgressIndicator()),
//         error: (error, stack) => Center(child: Text('Error: $error')),
//       ),
//     );
//   }

//   void _toggleFollow(WidgetRef ref, String profileUserId) {
//     // Implement follow/unfollow logic here
//   }

//   void _signOut(BuildContext context) {
//     // Implement sign out logic
//   }

//   void _deleteAccount(BuildContext context) {
//     // Implement delete account logic
//   }
// }

// class SettingsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Settings')),
//       body: Center(child: Text("Settings Page")),
//     );
//   }
// }

// class EditProfileScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Edit Profile')),
//       body: Center(child: Text("Edit Profile Page")),
//     );
//   }
// }

// Widget _buildBadgesList(List<UserBadgesModel> userBadges, WidgetRef ref) {
//   final allBadges = ref.watch(badgesProvider);
//   return Padding(
//     padding: const EdgeInsets.all(16.0),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (userBadges.isEmpty)
//           Center(
//             child: Text(
//               'Try to be consistent to earn a badge!',
//               style: TextStyle(
//                   fontSize: 16,
//                   fontStyle: FontStyle.italic,
//                   color: Colors.grey[600]),
//             ),
//           )
//         else
//           allBadges.when(
//             data: (badges) {
//               final badgeMap = {
//                 for (var badge in badges) badge.badge_id: badge
//               };
//               return Wrap(
//                 spacing: 12,
//                 runSpacing: 12,
//                 children: userBadges.map((userBadge) {
//                   final badge = badgeMap[userBadge.badge_id];
//                   return Tooltip(
//                     message: badge?.description ?? 'Unknown badge',
//                     child: Column(
//                       children: [
//                         Container(
//                           width: 100,
//                           height: 100,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             image: DecorationImage(
//                               image: NetworkImage(badge?.badge_url ??
//                                   'https://placeholder.com/60x60'),
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           badge?.name ?? 'Unknown',
//                           style: TextStyle(
//                               fontSize: 14, fontWeight: FontWeight.w600),
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               );
//             },
//             loading: () => CircularProgressIndicator(),
//             error: (error, stack) => Text('Error loading badges: $error'),
//           ),
//       ],
//     ),
//   );
// }
//************
// */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/models/post.dart';
import 'package:cstain/models/user_badges.dart';
import 'package:cstain/providers/auth_service.dart';
import 'package:cstain/providers/providers.dart';
import 'package:cstain/screens/community_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

final userPostsProvider =
    StreamProvider.family<List<PostModel>, String>((ref, profileUserId) {
  return FirebaseFirestore.instance
      .collection('posts')
      .where('posted_user_id', isEqualTo: profileUserId)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            // Convert doc.data() to a Map<String, dynamic> and add 'id'
            final postData = doc.data() as Map<String, dynamic>;

            // Manually add the document ID into the map
            postData['id'] = doc.id;

            // Now call fromMap with the modified map
            return PostModel.fromMap(postData);
          }).toList());
});

class MYProfileScreen extends ConsumerWidget {
  final String profileUserId;

  MYProfileScreen({required this.profileUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUser = authState.value;
    final isCurrentUserProfile = currentUser?.uid == profileUserId;

    final userStream = ref.watch(userStreamProvider);
    final userBadges = ref.watch(userBadgesProvider);
    final userAchievementsStream =
        ref.watch(userAchievementsWithDetailsProvider);
    final userPosts = ref.watch(userPostsProvider(profileUserId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isCurrentUserProfile)
            PopupMenuButton<int>(
              icon: Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 0:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                    break;
                  case 1:
                    _signOut(context);
                    break;
                  case 2:
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
                Row(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(myUser.profile_picture_url),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            myUser.username,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          if (myUser.bio.isNotEmpty) ...[
                            Text(
                              myUser.bio,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                            SizedBox(height: 10)
                          ],
                          Row(
                            children: [
                              Text('200 Followers',
                                  style: TextStyle(color: Color(0xFF237155))),
                              const SizedBox(width: 10),
                              Text('200 Following',
                                  style: TextStyle(color: Color(0xFF237155))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isCurrentUserProfile) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditProfileScreen()));
                      } else {
                        _toggleFollow(ref, profileUserId);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF237155),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      isCurrentUserProfile ? 'Edit Profile' : 'Follow',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total CO2 saving',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(
                            '${myUser.total_CO2_saved.toStringAsFixed(2)} kg',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ],
                      ),
                      Container(
                        width: 2,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        height: double.infinity,
                      ),
                      userAchievementsStream.when(
                        data: (achievements) {
                          final lastAchievement = achievements.isNotEmpty
                              ? achievements.first
                              : null;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Last Achievement',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              Text(
                                lastAchievement != null
                                    ? lastAchievement['name']
                                    : 'No achievements yet',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                                softWrap: true,
                                maxLines: 4,
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
                              // Posts Tab
                              userPosts.when(
                                data: (posts) {
                                  return ListView.builder(
                                    padding: const EdgeInsets.all(16.0),
                                    itemCount: posts.length,
                                    itemBuilder: (context, index) {
                                      final post = posts[index];
                                      return PostCard(post: post);
                                    },
                                  );
                                },
                                loading: () =>
                                    Center(child: CircularProgressIndicator()),
                                error: (error, stack) =>
                                    Center(child: Text('Error: $error')),
                              ),

                              // Badges Tab
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
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _toggleFollow(WidgetRef ref, String profileUserId) {
    // Implement follow/unfollow logic here
  }

  void _signOut(BuildContext context) {
    // Implement sign out logic
  }

  void _deleteAccount(BuildContext context) {
    // Implement delete account logic
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Center(child: Text("Settings Page")),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Center(child: Text("Edit Profile Page")),
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
                  color: Colors.grey[600]),
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
                              image: NetworkImage(badge?.badge_url ??
                                  'https://placeholder.com/60x60'),
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

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  Future<DocumentSnapshot?> _getUserData(String userId) async {
    try {
      return await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .get();
    } catch (e) {
      print('Error fetching user data: $e');
      return null; // Return null in case of an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fetch and display user info (profile image, username)
            FutureBuilder<DocumentSnapshot?>(
              future:
                  _getUserData(post.posted_user_id), // Fetch user data by ID
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        child: Icon(
                            Icons.person), // Placeholder icon during loading
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Loading...',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                } else if (snapshot.hasError ||
                    snapshot.data == null ||
                    !snapshot.data!.exists) {
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        child: Icon(Icons
                            .person), // Default person icon for error/anonymous
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Anonymous',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                } else {
                  var userData = snapshot.data!.data() as Map<String, dynamic>?;
                  String username = userData?['username'] ?? 'Anonymous';
                  String? profileImageUrl = userData?['profileImageUrl'];

                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: profileImageUrl != null
                            ? NetworkImage(profileImageUrl)
                            : null, // Use null to show the default icon if no image is available
                        child: profileImageUrl == null
                            ? Icon(
                                Icons.person) // Default person icon if no image
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        username,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            // Post title and body
            Text(post.title, style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(post.body),
            const SizedBox(height: 12),
            // Media (image/video) preview if exists
            if (post.media_url != null && post.media_type == 'image')
              Image.network(post.media_url!),
            if (post.media_url != null && post.media_type == 'video')
              VideoPlayerWidget(mediaUrl: post.media_url!),
            const SizedBox(height: 12),
            // Post actions like like, comment, share
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(onPressed: () {}, icon: Icon(Icons.thumb_up)),
                IconButton(onPressed: () {}, icon: Icon(Icons.comment)),
                IconButton(
                  onPressed: () {
                    _sharePost(post); // Implement sharing function
                  },
                  icon: Icon(Icons.share),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _sharePost(PostModel post) {
  String shareText = "${post.title}\n\n${post.body}";
  if (post.media_url != null) {
    shareText += "\n\nCheck this out: ${post.media_url}";
  }

  Share.share(shareText, subject: post.title); // Use the Share package
}
