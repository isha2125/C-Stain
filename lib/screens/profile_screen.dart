import 'package:cstain/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MYProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStream = ref.watch(userStreamProvider);
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
          data: (myUser) => Padding(
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
                                        color:
                                            Colors.green, // Your desired color
                                        fontSize:
                                            16, // Optional size adjustment
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' Followers', // The remaining text
                                      style: TextStyle(
                                        color:
                                            Colors.green, // Your desired color
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
                                        color:
                                            Colors.green, // Your desired color
                                        fontSize:
                                            16, // Optional size adjustment
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' Following', // The remaining text
                                      style: TextStyle(
                                        color:
                                            Colors.green, // Your desired color
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
                      backgroundColor: Colors.green, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: Size(double.infinity, 40),
                    ),
                    child: const Text('Follow'),
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
                                fontSize: 22, fontWeight: FontWeight.bold),
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
                        margin: EdgeInsets.symmetric(
                            horizontal: 20), // Adds space around the divider
                      ),
                      // VerticalDivider(
                      //   color: Color.fromARGB(255, 146, 146, 146), // Changed to grey
                      //   thickness: 2.0, // Adjust thickness as needed
                      //   width: 20, // Space between columns
                      // ),
                      const Column(
                        children: [
                          Text(
                            'Achievement',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'Green Guardian',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
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
                          indicatorColor: Colors.green,
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
                              GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                ),
                                itemCount: 15, // For demo purposes
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.all(4),
                                    color: Colors.grey[200],
                                  );
                                },
                              ),
                              // Badges Tab Content
                              Center(child: Text('Badges')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          loading: () => Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        ));
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
