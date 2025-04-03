// import 'package:cstain/models/campaigns.dart';
// import 'package:cstain/providers/auth_service.dart';
// import 'package:cstain/screens/profile_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// final userCampaignsProvider = StreamProvider<List<Campaign>>((ref) {
//   final userId = FirebaseAuth.instance.currentUser?.uid;
//   if (userId == null) return Stream.value([]);

//   final firestore = FirebaseFirestore.instance;

//   return firestore
//       .collection('participations')
//       .where('userId', isEqualTo: userId)
//       .snapshots()
//       .asyncMap((participantSnapshot) async {
//     final campaignIds =
//         participantSnapshot.docs.map((doc) => doc['campaignId']).toList();

//     if (campaignIds.isEmpty) return [];

//     final campaignSnapshot = await firestore
//         .collection('campaigns')
//         .where(FieldPath.documentId, whereIn: campaignIds)
//         .get();

//     return campaignSnapshot.docs
//         .map((doc) => Campaign.fromMap(doc.data() as Map<String, dynamic>))
//         .toList();
//   });
// });

// class UserCampaignScreen extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final campaignsAsync = ref.watch(userCampaignsProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My Campaigns'),
//         leading: Image.asset('assets/Earth black 1.png'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person),
//             onPressed: () {
//               final authState = ref.read(authStateProvider);
//               final userId = authState.value?.uid;
//               if (userId != null) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         MYProfileScreen(profileUserId: userId),
//                   ),
//                 );
//               } else {
//                 // Handle the case where there's no authenticated user
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('No user logged in')),
//                 );
//               }
//             },
//           )
//         ],
//         automaticallyImplyLeading: false,
//       ),
//       body: Expanded(
//         child: DefaultTabController(
//           length: 3,
//           child: Column(
//             children: [
//               TabBar(
//                 tabs: [
//                   Tab(text: 'Active'),
//                   Tab(text: 'Completed'),
//                   Tab(text: 'Expired'),
//                 ],
//               ),
//               Expanded(
//                 child: TabBarView(
//                   children: [
//                     campaignsAsync.when(
//                       data: (campaigns) {
//                         if (campaigns.isEmpty) {
//                           return Center(
//                               child: Text(
//                                   'You have not participated in any campaigns yet.'));
//                         }
//                         return ListView.builder(
//                           itemCount: campaigns.length,
//                           itemBuilder: (context, index) {
//                             final campaign = campaigns[index];
//                             return Card(
//                               margin: EdgeInsets.all(8.0),
//                               child: ListTile(
//                                 title: Text(campaign.title,
//                                     style:
//                                         TextStyle(fontWeight: FontWeight.bold)),
//                                 subtitle: Text(campaign.description),
//                                 trailing: Icon(Icons.arrow_forward_ios),
//                                 onTap: () {
//                                   // Navigate to campaign details
//                                 },
//                               ),
//                             );
//                           },
//                         );
//                       },
//                       loading: () => Center(child: CircularProgressIndicator()),
//                       error: (error, stackTrace) =>
//                           Center(child: Text('Error: $error')),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//***************************** Updated Campaigns  ********************* */
// import 'package:cstain/models/campaigns.dart';
// import 'package:cstain/providers/auth_service.dart';
// import 'package:cstain/screens/profile_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// final userCampaignsProvider =
//     StreamProvider.autoDispose<Map<String, List<Campaign>>>((ref) {
//   final userId = FirebaseAuth.instance.currentUser?.uid;
//   if (userId == null)
//     return Stream.value({'ongoing': [], 'upcoming': [], 'completed': []});

//   final firestore = FirebaseFirestore.instance;

//   return firestore
//       .collection('participations')
//       .where('userId', isEqualTo: userId)
//       .snapshots()
//       .asyncMap((participantSnapshot) async {
//     final campaignIds =
//         participantSnapshot.docs.map((doc) => doc['campaignId']).toList();

//     if (campaignIds.isEmpty)
//       return {'ongoing': [], 'upcoming': [], 'completed': []};

//     final campaignSnapshot = await firestore
//         .collection('campaigns')
//         .where(FieldPath.documentId, whereIn: campaignIds)
//         .get();

//     List<Campaign> campaigns = campaignSnapshot.docs
//         .map((doc) => Campaign.fromMap(doc.data() as Map<String, dynamic>))
//         .toList();

//     DateTime now = DateTime.now();

//     List<Campaign> ongoingCampaigns = [];
//     List<Campaign> upcomingCampaigns = [];
//     List<Campaign> completedCampaigns = [];

//     for (var campaign in campaigns) {
//       DateTime startDate = (campaign.startDate as Timestamp).toDate();
//       DateTime endDate = (campaign.endDate as Timestamp).toDate();

//       if (startDate.isBefore(now) && endDate.isAfter(now)) {
//         ongoingCampaigns.add(campaign);
//       } else if (startDate.isAfter(now)) {
//         upcomingCampaigns.add(campaign);
//       } else {
//         completedCampaigns.add(campaign);
//       }
//     }

//     return {
//       'ongoing': ongoingCampaigns,
//       'upcoming': upcomingCampaigns,
//       'completed': completedCampaigns,
//     };
//   });
// });

// class UserCampaignScreen extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final campaignsAsync = ref.watch(userCampaignsProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My Campaigns'),
//         leading: Image.asset('assets/Earth black 1.png'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person),
//             onPressed: () {
//               final authState = ref.read(authStateProvider);
//               final userId = authState.value?.uid;
//               if (userId != null) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         MYProfileScreen(profileUserId: userId),
//                   ),
//                 );
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('No user logged in')),
//                 );
//               }
//             },
//           )
//         ],
//         automaticallyImplyLeading: false,
//       ),
//       body: campaignsAsync.when(
//         data: (campaigns) {
//           return DefaultTabController(
//             length: 3,
//             child: Column(
//               children: [
//                 TabBar(
//                   tabs: [
//                     Tab(text: 'Ongoing'),
//                     Tab(text: 'Upcoming'),
//                     Tab(text: 'Completed'),
//                   ],
//                 ),
//                 Expanded(
//                   child: TabBarView(
//                     children: [
//                       _buildCampaignList(campaigns['ongoing'] ?? [], 'ongoing'),
//                       _buildCampaignList(
//                           campaigns['upcoming'] ?? [], 'upcoming'),
//                       _buildCampaignList(
//                           campaigns['completed'] ?? [], 'completed'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//         loading: () => Center(child: CircularProgressIndicator()),
//         error: (error, stackTrace) => Center(child: Text('Error: $error')),
//       ),
//     );
//   }

//   Widget _buildCampaignList(List<Campaign> campaigns, String category) {
//     if (campaigns.isEmpty) {
//       String message;
//       switch (category) {
//         case 'ongoing':
//           message = 'No ongoing campaigns at the moment.';
//           break;
//         case 'upcoming':
//           message = 'No upcoming campaigns. Stay tuned!';
//           break;
//         case 'completed':
//           message = 'No completed campaigns yet. Keep participating!';
//           break;
//         default:
//           message = 'No campaigns found.';
//       }
//       return Center(
//         child: Text(message,
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//       );
//     }

//     return ListView.builder(
//       itemCount: campaigns.length,
//       itemBuilder: (context, index) {
//         final campaign = campaigns[index];
//         return Card(
//           margin: EdgeInsets.all(8.0),
//           child: ListTile(
//             title: Text(campaign.title,
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             subtitle: Text(campaign.description),
//             trailing: Icon(Icons.arrow_forward_ios),
//             onTap: () {
//               // Navigate to campaign details
//             },
//           ),
//         );
//       },
//     );
//   }
// }
//***************************** Updated Campaigns with user carbon saved data********************* */
import 'package:cstain/components/Global_Chatbot%20_FAB_Component.dart';
import 'package:cstain/components/custom_appBar.dart';
import 'package:cstain/models/campaigns.dart';
// Ensure you import your ParticipationModel here.
import 'package:cstain/models/participations.dart';
import 'package:cstain/providers/auth_service.dart';
import 'package:cstain/screens/Corp%20screens/campaign_detail_screen.dart';
import 'package:cstain/screens/User%20screens/userCampaign_detailScreen.dart';
import 'package:cstain/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Provider for campaigns the user participates in.
final userCampaignsProvider =
    StreamProvider.autoDispose<Map<String, List<Campaign>>>((ref) {
  print("here is error da");
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null)
    return Stream.value({'ongoing': [], 'upcoming': [], 'completed': []});

  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('participations')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .asyncMap((participantSnapshot) async {
    print(
        'Fetched participations: ${participantSnapshot.docs}'); // Log participations
    final campaignIds =
        participantSnapshot.docs.map((doc) => doc['campaignId']).toList();

    if (campaignIds.isEmpty)
      return {'ongoing': [], 'upcoming': [], 'completed': []};

    final campaignSnapshot = await firestore
        .collection('campaigns')
        .where(FieldPath.documentId, whereIn: campaignIds)
        .get();

    List<Campaign> campaigns = campaignSnapshot.docs
        .map((doc) => Campaign.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    DateTime now = DateTime.now();

    List<Campaign> ongoingCampaigns = [];
    List<Campaign> upcomingCampaigns = [];
    List<Campaign> completedCampaigns = [];

    for (var campaign in campaigns) {
      DateTime startDate = (campaign.startDate as Timestamp).toDate();
      DateTime endDate = (campaign.endDate as Timestamp).toDate();

      if (startDate.isBefore(now) && endDate.isAfter(now)) {
        ongoingCampaigns.add(campaign);
      } else if (startDate.isAfter(now)) {
        upcomingCampaigns.add(campaign);
      } else {
        completedCampaigns.add(campaign);
      }
    }

    return {
      'ongoing': ongoingCampaigns,
      'upcoming': upcomingCampaigns,
      'completed': completedCampaigns,
    };
  });
});

// Provider to map each campaignId to its ParticipationModel.
final userParticipationsMapProvider =
    StreamProvider.autoDispose<Map<String, ParticipationModel>>((ref) {
  print("here is error da part 2");
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value({});
  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('participations')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
    final Map<String, ParticipationModel> map = {};

    for (var doc in snapshot.docs) {
      final participation = ParticipationModel.fromMap({
        'participationId': doc.id, // merging doc id into the map
        ...doc.data() as Map<String, dynamic>,
      });
      map[participation.campaignId] = participation;
    }
    return map;
  });
});

//Provider to calculate total contribution across all participations.
final userParticipationContributionProvider =
    StreamProvider.autoDispose<double>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value(0.0);

  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('participations')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
    double totalContribution = 0.0;
    for (var doc in snapshot.docs) {
      totalContribution += (doc['carbonSaved'] as num).toDouble();
    }
    return totalContribution;
  });
});

class UserCampaignScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(userCampaignsProvider);
    final contributionAsync = ref.watch(userParticipationContributionProvider);
    final participationMapAsync = ref.watch(userParticipationsMapProvider);

    return Scaffold(
      floatingActionButton: GlobalChatbotFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      appBar: CustomAppBar(
        title: "My Campaigns",
      ),
      body: campaignsAsync.when(
        data: (campaigns) {
          return participationMapAsync.when(
            data: (participationMap) {
              return Column(
                children: [
                  // Overall contribution summary.
                  contributionAsync.when(
                    data: (totalContribution) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Total Contribution: $totalContribution kgs of carbon saved!",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    loading: () => Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) =>
                        Center(child: Text('Error: $error')),
                  ),
                  // Campaign Tabs.
                  Expanded(
                    child: DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          TabBar(
                            tabs: [
                              Tab(text: 'Ongoing'),
                              Tab(text: 'Upcoming'),
                              Tab(text: 'Completed'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildCampaignList(campaigns['ongoing'] ?? [],
                                    'ongoing', participationMap),
                                _buildCampaignList(campaigns['upcoming'] ?? [],
                                    'upcoming', participationMap),
                                _buildCampaignList(campaigns['completed'] ?? [],
                                    'completed', participationMap),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text('Error: $error')),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }

//   Widget _buildCampaignList(List<Campaign> campaigns, String category,
//       Map<String, ParticipationModel> participationMap) {
//     if (campaigns.isEmpty) {
//       String message;
//       switch (category) {
//         case 'ongoing':
//           message = 'No ongoing campaigns at the moment.';
//           break;
//         case 'upcoming':
//           message = 'No upcoming campaigns. Stay tuned!';
//           break;
//         case 'completed':
//           message = 'No completed campaigns yet. Keep participating!';
//           break;
//         default:
//           message = 'No campaigns found.';
//       }
//       return Center(
//         child: Text(message,
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//       );
//     }

//     return ListView.builder(
//       itemCount: campaigns.length,
//       itemBuilder: (context, index) {
//         final campaign = campaigns[index];
//         // Assuming Campaign has an 'id' property that matches the participation's campaignId.
//         final participation = participationMap[campaign.campaignId];
//         return Card(
//           margin: EdgeInsets.all(8.0),
//           child: ListTile(
//             title: Text(campaign.title,
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text('Action: '),
//                     Text(campaign.action),
//                   ],
//                 ),
//                 if (participation != null) ...[
//                   //SizedBox(height: 8.0),
//                   Text(
//                     "Your Contribution: ${participation.carbonSaved} kgs",
//                     style: TextStyle(fontSize: 14),
//                   ),
//                   Text(
//                     "Ends at: ${DateFormat('dd-MM-yy').format(campaign.endDate.toDate())}",
//                     style: TextStyle(fontSize: 14),
//                   ),
//                 ],
//               ],
//             ),
//             trailing: Icon(Icons.arrow_forward_ios),
//             onTap: () {
//               // Navigate to campaign details
//             },
//           ),
//         );
//       },
//     );
//   }
// }
  Widget _buildCampaignList(List<Campaign> campaigns, String category,
      Map<String, ParticipationModel> participationMap) {
    if (campaigns.isEmpty) {
      String message;
      switch (category) {
        case 'ongoing':
          message = 'No ongoing campaigns at the moment.';
          break;
        case 'upcoming':
          message = 'No upcoming campaigns. Stay tuned!';
          break;
        case 'completed':
          message = 'No completed campaigns yet. Keep participating!';
          break;
        default:
          message = 'No campaigns found.';
      }
      return Center(
        child: Text(message,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      );
    }

    return ListView.builder(
      itemCount: campaigns.length,
      itemBuilder: (context, index) {
        final campaign = campaigns[index];
        final participation = participationMap[campaign.campaignId];

        return Card(
          margin: EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailCampaignScreen(
                    campaign: campaign,
                    participation: participation,
                  ),
                ),
              );
            },
            child: ListTile(
              title: Text(campaign.title,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Action: '),
                      Text(campaign.action),
                    ],
                  ),
                  if (participation != null) ...[
                    Text(
                      "Your Contribution: ${participation.carbonSaved} kgs",
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      "Ends at: ${DateFormat('dd-MM-yy').format(campaign.endDate.toDate())}",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
        );
      },
    );
  }
}
