// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cstain/providers/campaign%20providers/campaign_providers.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';

// final campaignParticipantsProvider =
//     StreamProvider.family<List<Map<String, dynamic>>, String>(
//   (ref, campaignId) {
//     return FirebaseFirestore.instance
//         .collection('participations')
//         .where('campaignId', isEqualTo: campaignId)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs.map((doc) {
//         return {
//           'userId': doc['userId'],
//           'carbonSaved': (doc['carbonSaved'] as num).toDouble(),
//         };
//       }).toList();
//     });
//   },
// );

// class CampaignDetailScreen extends StatelessWidget {
//   final Map<String, dynamic> campaign;

//   const CampaignDetailScreen({Key? key, required this.campaign})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final bool hasImage = campaign['imageUrl'] != null &&
//         campaign['imageUrl'].toString().isNotEmpty;
//     final List<String> participants =
//         (campaign['participants'] as List<dynamic>?)
//                 ?.map((e) => e.toString())
//                 .toList() ??
//             [];

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(campaign['title']),
//         backgroundColor: Colors.teal,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // If campaign has an image, show it
//             if (hasImage)
//               Stack(
//                 children: [
//                   Image.network(
//                     campaign['imageUrl'],
//                     height: 250,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                   ),
//                   Container(
//                     height: 250,
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.4),
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 16,
//                     left: 16,
//                     child: Text(
//                       campaign['title'],
//                       style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Description",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     campaign['description'],
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                   const SizedBox(height: 16),

//                   _infoRow("Category", campaign['category']),
//                   _infoRow("Action", campaign['action']),
//                   _infoRow("Target CO2 Savings",
//                       "${campaign['totalCarbonSaved']} kg"),
//                   _infoRow("Start Date", _formatDate(campaign['startDate'])),
//                   _infoRow("End Date", _formatDate(campaign['endDate'])),

//                   const SizedBox(height: 20),

//                   _sectionTitle("Participants"),
//                   // Inside CampaignDetailScreen
//                   participants.isEmpty
//                       ? const Text("No participants yet",
//                           style: TextStyle(fontSize: 16, color: Colors.grey))
//                       : ListView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: participants.length,
//                           itemBuilder: (context, index) {
//                             final userId = participants[index];
//                             return Consumer(
//                               builder: (context, ref, child) {
//                                 final participantsAsync = ref.watch(
//                                     campaignParticipantsProvider(
//                                         campaign['campaignId']));

//                                 return participantsAsync.when(
//                                   data: (participants) {
//                                     if (participants.isEmpty) {
//                                       return const Text(
//                                         "No participants yet",
//                                         style: TextStyle(
//                                             fontSize: 16, color: Colors.grey),
//                                       );
//                                     }

//                                     return ListView.builder(
//                                       shrinkWrap: true,
//                                       physics:
//                                           const NeverScrollableScrollPhysics(),
//                                       itemCount: participants.length,
//                                       itemBuilder: (context, index) {
//                                         final participant = participants[index];
//                                         final userId = participant['userId'];
//                                         final carbonSaved =
//                                             participant['carbonSaved'];

//                                         return Consumer(
//                                           builder: (context, ref, child) {
//                                             final usernameAsync = ref.watch(
//                                                 ParticipantUsernameProvider(
//                                                     userId));

//                                             return ListTile(
//                                               leading: const Icon(Icons.person,
//                                                   color: Colors.teal),
//                                               title: usernameAsync.when(
//                                                 data: (username) => Text(
//                                                   "$username - ${carbonSaved.toStringAsFixed(2)} kg CO₂ saved",
//                                                   style: const TextStyle(
//                                                       fontSize: 16),
//                                                 ),
//                                                 loading: () =>
//                                                     const CircularProgressIndicator(),
//                                                 error: (_, __) => const Text(
//                                                     "Error loading user"),
//                                               ),
//                                             );
//                                           },
//                                         );
//                                       },
//                                     );
//                                   },
//                                   loading: () => const Center(
//                                       child: CircularProgressIndicator()),
//                                   error: (_, __) =>
//                                       const Text("Error loading participants"),
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _sectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Text(
//         title,
//         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   // Helper method to format Firestore Timestamp to a readable date
//   String _formatDate(dynamic timestamp) {
//     return DateFormat('dd-MM-yyyy').format((timestamp as Timestamp).toDate());
//   }

//   // Helper method to create an info row
//   Widget _infoRow(String label, String? value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Row(
//         children: [
//           Text(
//             "$label: ",
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           Expanded(
//             child: Text(
//               value ?? "Not specified",
//               style: const TextStyle(fontSize: 16),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//********** */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/models/campaigns.dart';
import 'package:cstain/providers/campaign%20providers/campaign_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final campaignParticipantsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, campaignId) {
    return FirebaseFirestore.instance
        .collection('participations')
        .where('campaignId', isEqualTo: campaignId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'userId': doc['userId'],
          'carbonSaved': (doc['carbonSaved'] as num).toDouble(),
        };
      }).toList();
    });
  },
);

class CampaignDetailScreen extends ConsumerWidget {
  final String campaignId;

  const CampaignDetailScreen({Key? key, required this.campaignId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignAsync = ref.watch(campaignStreamProvider(campaignId));

    return Scaffold(
      appBar: AppBar(
        title: campaignAsync.when(
          data: (campaign) => Text(campaign.title),
          loading: () => const Text("Loading..."),
          error: (_, __) => const Text("Error"),
        ),
        backgroundColor: Colors.teal,
      ),
      body: campaignAsync.when(
        data: (campaign) => _buildCampaignDetails(context, campaign),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text("Error: $error")),
      ),
    );
  }

  Widget _buildCampaignDetails(BuildContext context, Campaign campaign) {
    final bool hasImage =
        campaign.imageUrl != null && campaign.imageUrl!.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            Stack(
              children: [
                Image.network(
                  campaign.imageUrl!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Text(
                    campaign.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Description",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  campaign.description,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                _infoRow("Category", campaign.category),
                _infoRow("Action", campaign.action),
                _infoRow(
                    "Target CO2 Savings", "${campaign.targetCO2Savings} kgs"),
                _infoRow(
                    "Total Carbon Saved", "${campaign.totalCarbonSaved} kgs"),
                _infoRow("Start Date", _formatDate(campaign.startDate)),
                _infoRow("End Date", _formatDate(campaign.endDate)),
                const SizedBox(height: 20),
                _sectionTitle("Participants Ranking"),
                ParticipantsList(campaignId: campaign.campaignId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper method to format Firestore Timestamp to a readable date
  String _formatDate(dynamic timestamp) {
    return DateFormat('dd-MM-yyyy').format((timestamp as Timestamp).toDate());
  }

  // Helper method to create an info row
  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value ?? "Not specified",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class ParticipantsList extends ConsumerWidget {
  final String campaignId;

  const ParticipantsList({Key? key, required this.campaignId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync =
        ref.watch(campaignParticipantsProvider(campaignId));
    final campaignAsync = ref.watch(campaignStreamProvider(campaignId));

    return participantsAsync.when(
      data: (participants) {
        if (participants.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "No participants yet",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        // Sort participants by highest carbonSaved first
        participants
            .sort((a, b) => b['carbonSaved'].compareTo(a['carbonSaved']));

        return campaignAsync.when(
          data: (campaign) {
            // Check if campaign is ongoing or ended
            bool isOngoing = campaign.endDate.toDate().isAfter(DateTime.now());

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final participant = participants[index];
                final userId = participant['userId'];
                final carbonSaved = participant['carbonSaved'];

                return Consumer(
                  builder: (context, ref, child) {
                    final userDataAsync =
                        ref.watch(participantUserDataProvider(userId));

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: userDataAsync.when(
                          data: (userData) {
                            String? profilePicture = userData['profilePicture'];
                            String? username = userData['username'];

                            return CircleAvatar(
                              backgroundColor: Colors.teal.shade200,
                              backgroundImage: (profilePicture != null &&
                                      profilePicture.isNotEmpty)
                                  ? NetworkImage(profilePicture)
                                  : null,
                              child: (profilePicture == null ||
                                      profilePicture.isEmpty)
                                  ? Text(
                                      username!.isNotEmpty
                                          ? username[0].toUpperCase()
                                          : "?",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : null,
                            );
                          },
                          loading: () =>
                              const CircularProgressIndicator(strokeWidth: 2),
                          error: (_, __) =>
                              const Icon(Icons.error, color: Colors.red),
                        ),
                        title: userDataAsync.when(
                          data: (userData) => Text(
                            userData['username'] ?? "Unknown User",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          loading: () => const Text("Loading..."),
                          error: (_, __) => const Text("Error loading name"),
                        ),
                        subtitle: Text(
                          "${carbonSaved.toStringAsFixed(2)} kgs CO₂ saved",
                          style:
                              const TextStyle(fontSize: 14, color: Colors.teal),
                        ),
                        trailing: isOngoing
                            ? _buildOngoingPosition(
                                index) // Show rank dynamically
                            : _buildFinalRanking(
                                index), // Show Winner/Runner-up after campaign ends
                      ),
                    );
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text("Error loading campaign data"),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text("Error loading participants"),
    );
  }

  // 📌 When campaign is ongoing, display positions dynamically (#1, #2, etc.)
  Widget _buildOngoingPosition(int index) {
    return Text(
      "#${index + 1}",
      style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
    );
  }

  // 🏆 When campaign has ended, display ranking labels (Winner, Runner-up, etc.)
  Widget _buildFinalRanking(int index) {
    if (index == 0) {
      return const Text("Winner 🏆",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
    } else if (index == 1) {
      return const Text("Runner-up 🥈",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
    } else if (index == 2) {
      return const Text("3rd Place 🥉",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
    } else {
      return Text(
        "#${index + 1}",
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
      );
    }
  }
}
