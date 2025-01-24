import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/screens/corp_createcampaignscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CorpCampaignScreen extends StatefulWidget {
  const CorpCampaignScreen({Key? key}) : super(key: key);

  @override
  State<CorpCampaignScreen> createState() => _CorpCampaignScreenState();
}

class _CorpCampaignScreenState extends State<CorpCampaignScreen> {
  final User? _currentUser =
      FirebaseAuth.instance.currentUser; // Get the logged-in user
  @override
  void initState() {
    super.initState();
    print(_currentUser?.uid);
  }

  @override
  Widget build(BuildContext context) {
    // Ensure user is logged in before attempting to fetch campaigns
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'You are not logged in. Please log in to view your campaigns.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Campaigns',
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
        leading: Image.asset('assets/Earth black 1.png'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<ProfileScreen>(
                  builder: (context) => ProfileScreen(
                    appBar: AppBar(
                      title: const Text('User Profile'),
                    ),
                    actions: [
                      SignedOutAction((context) {
                        Navigator.of(context).pop();
                      })
                    ],
                    children: [
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.asset('assets/Earth black 1.png'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        ],
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ElevatedButton(
              onPressed: () async {
                final newCampaign = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateCampaignForm(),
                  ),
                );
                // Refresh the UI after creating a campaign
                if (newCampaign != null) {
                  setState(() {});
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF237155),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Create New Campaign',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          const Divider(
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Campaigns Posted by You',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('campaigns')
                  .where('corpUserId',
                      isEqualTo:
                          _currentUser.uid) // Use the logged-in user's ID
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade200,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: const Text(
                          'No campaigns posted yet. Start by creating one!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final campaigns = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: campaigns.length,
                  itemBuilder: (context, index) {
                    final campaign =
                        campaigns[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4, // Shadow effect
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Rounded corners
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                            16.0), // Add padding inside the card
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Campaign Title
                            Center(
                              child: Text(
                                campaign['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12), // Spacing after title

                            // Campaign Description
                            Text(
                              campaign['description'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(
                                height: 16), // Spacing after description

                            // Category and Action
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Category:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        campaign['category'] ?? 'No Category',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF237155),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Action
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Action:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        campaign['action'] ?? 'No Action',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF237155),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                                height:
                                    16), // Spacing after category and action

                            // Additional Details
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('dd-MM-yyyy').format(
                                    (campaign['startDate'] as Timestamp)
                                        .toDate(),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'Target: ${campaign['targetCO2Savings']} kg',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                                Text(
                                  DateFormat('dd-MM-yyyy').format(
                                    (campaign['endDate'] as Timestamp).toDate(),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );

                // return ListView.builder(
                //   padding: const EdgeInsets.all(16.0),
                //   itemCount: campaigns.length,
                //   itemBuilder: (context, index) {
                //     final campaign =
                //         campaigns[index].data() as Map<String, dynamic>;
                //     return Card(
                //       margin: const EdgeInsets.symmetric(vertical: 8),
                //       child: ListTile(
                //         title: Text(campaign['title']),
                //         subtitle: Text(campaign['description']),
                //         trailing: Text(
                //           DateFormat('yyyy-MM-dd').format(
                //             (campaign['created_at'] as Timestamp).toDate(),
                //           ),
                //         ),
                //       ),
                //     );
                //   },
                // );
              },
            ),
          ),
        ],
      ),
    );
  }
}
