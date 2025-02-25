// import 'package:cstain/models/campaigns.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// final userCampaignsProvider = FutureProvider<List<Campaign>>((ref) async {
//   final userId = FirebaseAuth.instance.currentUser?.uid;
//   if (userId == null) return [];

//   final firestore = FirebaseFirestore.instance;

//   // Fetch participant records where the user has participated
//   final participantSnapshot = await firestore
//       .collection('participations')
//       .where('userId', isEqualTo: userId)
//       .get();

//   final campaignIds =
//       participantSnapshot.docs.map((doc) => doc['campaignId']).toList();

//   if (campaignIds.isEmpty) return [];

//   // Fetch campaigns using the campaign IDs
//   final campaignSnapshot = await firestore
//       .collection('campaigns')
//       .where(FieldPath.documentId, whereIn: campaignIds)
//       .get();

//   return campaignSnapshot.docs
//       .map((doc) => Campaign.fromMap(doc.data() as Map<String, dynamic>))
//       .toList();
// });

// class UserCampaignScreen extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final campaignsAsync = ref.watch(userCampaignsProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My Campaigns'),
//       ),
//       body: campaignsAsync.when(
//         data: (campaigns) {
//           if (campaigns.isEmpty) {
//             return Center(
//                 child: Text('You have not participated in any campaigns yet.'));
//           }
//           return ListView.builder(
//             itemCount: campaigns.length,
//             itemBuilder: (context, index) {
//               final campaign = campaigns[index];
//               return Card(
//                 margin: EdgeInsets.all(8.0),
//                 child: ListTile(
//                   title: Text(campaign.title,
//                       style: TextStyle(fontWeight: FontWeight.bold)),
//                   subtitle: Text(campaign.description),
//                   trailing: Icon(Icons.arrow_forward_ios),
//                   onTap: () {
//                     // Navigate to campaign details
//                   },
//                 ),
//               );
//             },
//           );
//         },
//         loading: () => Center(child: CircularProgressIndicator()),
//         error: (error, stackTrace) => Center(child: Text('Error: $error')),
//       ),
//     );
//   }
// }
//*****************using stream providers for realtime updates******* */

import 'package:cstain/models/campaigns.dart';
import 'package:cstain/providers/auth_service.dart';
import 'package:cstain/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final userCampaignsProvider = StreamProvider<List<Campaign>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('participations')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .asyncMap((participantSnapshot) async {
    final campaignIds =
        participantSnapshot.docs.map((doc) => doc['campaignId']).toList();

    if (campaignIds.isEmpty) return [];

    final campaignSnapshot = await firestore
        .collection('campaigns')
        .where(FieldPath.documentId, whereIn: campaignIds)
        .get();

    return campaignSnapshot.docs
        .map((doc) => Campaign.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  });
});

class UserCampaignScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(userCampaignsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Campaigns'),
        leading: Image.asset('assets/Earth black 1.png'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              final authState = ref.read(authStateProvider);
              final userId = authState.value?.uid;
              if (userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MYProfileScreen(profileUserId: userId),
                  ),
                );
              } else {
                // Handle the case where there's no authenticated user
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No user logged in')),
                );
              }
            },
          )
        ],
        automaticallyImplyLeading: false,
      ),
      body: campaignsAsync.when(
        data: (campaigns) {
          if (campaigns.isEmpty) {
            return Center(
                child: Text('You have not participated in any campaigns yet.'));
          }
          return ListView.builder(
            itemCount: campaigns.length,
            itemBuilder: (context, index) {
              final campaign = campaigns[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(campaign.title,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(campaign.description),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to campaign details
                  },
                ),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
