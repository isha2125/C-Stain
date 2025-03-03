//**************************added image url code****************************************************
// import 'package:cstain/providers/campaign%20providers/campaign_providers.dart';
// import 'package:cstain/screens/Corp%20screens/corp_createcampaignscreen.dart';
// import 'package:firebase_ui_auth/firebase_ui_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// class CorpCampaignScreen extends ConsumerWidget {
//   const CorpCampaignScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final user = ref.watch(currentUserProvider);
//     final campaignsAsync = ref.watch(campaignsProvider);

//     if (user == null) {
//       return const Scaffold(
//         body: Center(
//           child: Text(
//             'You are not logged in. Please log in to view your campaigns.',
//             textAlign: TextAlign.center,
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Campaigns',
//             style: TextStyle(fontWeight: FontWeight.w400)),
//         leading: Image.asset('assets/Earth black 1.png'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const ProfileScreen()),
//               );
//             },
//           )
//         ],
//         automaticallyImplyLeading: false,
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             child: ElevatedButton(
//               onPressed: () async {
//                 final newCampaign = await Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => CreateCampaignForm()),
//                 );
//                 if (newCampaign != null) {
//                   ref.refresh(campaignsProvider);
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF237155),
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//               ),
//               child: const Text(
//                 'Create New Campaign',
//                 style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white),
//               ),
//             ),
//           ),
//           const Divider(thickness: 1, indent: 16, endIndent: 16),
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Text(
//               'Campaigns Posted by You',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             child: RefreshIndicator(
//               onRefresh: () async {
//                 final newValue = ref.refresh(campaignsProvider);
//                 await newValue.whenData((_) => null);
//               },
//               child: campaignsAsync.when(
//                 data: (campaigns) {
//                   if (campaigns.isEmpty) {
//                     return Center(
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             color: Colors.grey.shade200,
//                           ),
//                           padding: const EdgeInsets.all(16),
//                           child: const Text(
//                             'No campaigns posted yet. Start by creating one!',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(fontSize: 16, color: Colors.grey),
//                           ),
//                         ),
//                       ),
//                     );
//                   }
//                   return ListView.builder(
//                     padding: const EdgeInsets.all(16.0),
//                     itemCount: campaigns.length,
//                     itemBuilder: (context, index) {
//                       final campaign = campaigns[index];
//                       return Card(
//                         margin: const EdgeInsets.symmetric(vertical: 8),
//                         elevation: 4,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                         child: Stack(
//                           children: [
//                             if (campaign['imageUrl'] != null)
//                               Stack(
//                                 children: [
//                                   ClipRRect(
//                                     borderRadius: BorderRadius.circular(12),
//                                     child: Image.network(
//                                       campaign['imageUrl'],
//                                       height: 200,
//                                       width: double.infinity,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                   Container(
//                                     height: 200,
//                                     decoration: BoxDecoration(
//                                       color: const Color.fromARGB(255, 0, 0, 0)
//                                           .withOpacity(
//                                               0.5), // Light color overlay
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             Padding(
//                               padding: const EdgeInsets.all(16.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Center(
//                                     child: Text(
//                                       campaign['title'],
//                                       style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                           color: campaign['imageUrl'] != null
//                                               ? Colors.white
//                                               : Colors.teal),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 12),
//                                   Text(
//                                     campaign['description'],
//                                     style: TextStyle(
//                                         fontSize: 14,
//                                         color: campaign['imageUrl'] != null
//                                             ? Colors.white
//                                             : Colors.black87),
//                                   ),
//                                   const SizedBox(height: 16),
//                                   Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text('Category:',
//                                                 style: TextStyle(
//                                                     fontSize: 14,
//                                                     fontWeight: FontWeight.bold,
//                                                     color:
//                                                         campaign['imageUrl'] !=
//                                                                 null
//                                                             ? Colors.white70
//                                                             : Colors.grey)),
//                                             Text(
//                                                 campaign['category'] ??
//                                                     'No Category',
//                                                 style: TextStyle(
//                                                     fontSize: 14,
//                                                     color:
//                                                         campaign['imageUrl'] !=
//                                                                 null
//                                                             ? Colors.white
//                                                             : const Color(
//                                                                 0xFF237155))),
//                                           ],
//                                         ),
//                                       ),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text('Action:',
//                                                 style: TextStyle(
//                                                     fontSize: 14,
//                                                     fontWeight: FontWeight.bold,
//                                                     color:
//                                                         campaign['imageUrl'] !=
//                                                                 null
//                                                             ? Colors.white70
//                                                             : Colors.grey)),
//                                             Text(
//                                                 campaign['action'] ??
//                                                     'No Action',
//                                                 style: TextStyle(
//                                                     fontSize: 14,
//                                                     color:
//                                                         campaign['imageUrl'] !=
//                                                                 null
//                                                             ? Colors.white
//                                                             : const Color(
//                                                                 0xFF237155))),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 16),
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                           DateFormat('dd-MM-yyyy').format(
//                                               (campaign['startDate']
//                                                       as Timestamp)
//                                                   .toDate()),
//                                           style: TextStyle(
//                                               fontSize: 12,
//                                               color:
//                                                   campaign['imageUrl'] != null
//                                                       ? Colors.white70
//                                                       : Colors.grey)),
//                                       Text(
//                                           'Target: ${campaign['targetCO2Savings']} kg',
//                                           style: TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w500,
//                                               color:
//                                                   campaign['imageUrl'] != null
//                                                       ? Colors.white
//                                                       : Colors.black)),
//                                       Text(
//                                           DateFormat('dd-MM-yyyy').format(
//                                               (campaign['endDate'] as Timestamp)
//                                                   .toDate()),
//                                           style: TextStyle(
//                                               fontSize: 12,
//                                               color:
//                                                   campaign['imageUrl'] != null
//                                                       ? Colors.white70
//                                                       : Colors.grey)),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   );
//                 },
//                 loading: () => const Center(child: CircularProgressIndicator()),
//                 error: (error, stackTrace) =>
//                     Center(child: Text('Error: $error')),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//******************************************* Modifying the features and ui of corp campaign screen ********************************************** */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/providers/campaign%20providers/campaign_providers.dart';
import 'package:cstain/screens/Corp%20screens/campaign_detail_screen.dart';
import 'package:cstain/screens/Corp%20screens/corp_createcampaignscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CorpCampaignScreen extends ConsumerWidget {
  const CorpCampaignScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final campaignsAsync = ref.watch(categorizedCampaignsProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'You are not logged in. Please log in to view your campaigns.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Campaigns',
              style: TextStyle(fontWeight: FontWeight.w400)),
          bottom: const TabBar(
            indicatorColor: Colors.teal,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Ongoing"),
              Tab(text: "Upcoming"),
              Tab(text: "Completed"),
            ],
          ),
        ),
        body: campaignsAsync.when(
          data: (categorizedCampaigns) {
            return TabBarView(
              children: [
                CampaignList(categorizedCampaigns['ongoing'] ?? []),
                CampaignList(categorizedCampaigns['upcoming'] ?? []),
                CampaignList(categorizedCampaigns['completed'] ?? []),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final newCampaign = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateCampaignForm()),
            );
            if (newCampaign != null) {
              ref.refresh(categorizedCampaignsProvider);
            }
          },
          backgroundColor: const Color(0xFF237155),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class CampaignList extends StatelessWidget {
  final List<Map<String, dynamic>> campaigns;
  const CampaignList(this.campaigns, {super.key});

  @override
  Widget build(BuildContext context) {
    if (campaigns.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No campaigns available in this category.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: campaigns.length,
      itemBuilder: (context, index) {
        final campaign = campaigns[index];
        return CampaignCard(
          campaign: campaign,
          onTap: () {
            // Navigate to campaign details screen or perform any action
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CampaignDetailScreen(campaign: campaign),
              ),
            );
          },
        );
      },
    );
  }
}

// class CampaignCard extends StatelessWidget {
//   final Map<String, dynamic> campaign;

//   const CampaignCard({Key? key, required this.campaign}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     bool hasImage = campaign['imageUrl'] != null;
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       //elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Stack(
//         children: [
//           if (hasImage)
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.network(
//                 campaign['imageUrl'],
//                 height: 200,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//             ),

//           // Black overlay of same size as card
//           if (hasImage)
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color:
//                       Colors.black.withOpacity(0.5), // Adjust opacity as needed
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Text(
//                     campaign['title'],
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: hasImage ? Colors.white : Colors.teal,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   campaign['description'],
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: hasImage ? Colors.white : Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Category:',
//                               style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   color:
//                                       hasImage ? Colors.white70 : Colors.grey)),
//                           Text(campaign['category'] ?? 'No Category',
//                               style: TextStyle(
//                                   fontSize: 14,
//                                   color: hasImage
//                                       ? Colors.white
//                                       : Color(0xFF237155))),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Action:',
//                               style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   color:
//                                       hasImage ? Colors.white70 : Colors.grey)),
//                           Text(campaign['action'] ?? 'No Action',
//                               style: TextStyle(
//                                   fontSize: 14,
//                                   color: hasImage
//                                       ? Colors.white
//                                       : Color(0xFF237155))),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       DateFormat('dd-MM-yyyy').format(
//                           (campaign['startDate'] as Timestamp).toDate()),
//                       style: TextStyle(
//                           fontSize: 12,
//                           color: hasImage ? Colors.white70 : Colors.grey),
//                     ),
//                     Text(
//                       'Target: ${campaign['targetCO2Savings']} kg',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: hasImage ? Colors.white : Colors.black,
//                       ),
//                     ),
//                     Text(
//                       DateFormat('dd-MM-yyyy')
//                           .format((campaign['endDate'] as Timestamp).toDate()),
//                       style: TextStyle(
//                           fontSize: 12,
//                           color: hasImage ? Colors.white70 : Colors.grey),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class CampaignCard extends StatelessWidget {
  final Map<String, dynamic> campaign;
  final VoidCallback onTap; // Callback function when card is clicked

  const CampaignCard({Key? key, required this.campaign, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasImage = campaign['imageUrl'] != null &&
        campaign['imageUrl'].toString().isNotEmpty;

    return GestureDetector(
      onTap: onTap, // Makes the entire card clickable
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            // If campaign has an image, display it
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  campaign['imageUrl'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            // Black overlay of same size as card
            if (hasImage)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

            // Campaign content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      campaign['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: hasImage ? Colors.white : Colors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    campaign['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: hasImage ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _infoColumn('Category', campaign['category'], hasImage),
                      _infoColumn('Action', campaign['action'], hasImage),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _dateText(campaign['startDate'], hasImage),
                      Text(
                        'Target: ${campaign['targetCO2Savings']} kg',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: hasImage ? Colors.white : Colors.black,
                        ),
                      ),
                      _dateText(campaign['endDate'], hasImage),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to show category and action info
  Widget _infoColumn(String title, String? value, bool hasImage) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: hasImage ? Colors.white70 : Colors.grey)),
          Text(value ?? 'Not Specified',
              style: TextStyle(
                  fontSize: 14,
                  color: hasImage ? Colors.white : const Color(0xFF237155))),
        ],
      ),
    );
  }

  // Helper function to format and display date
  Widget _dateText(dynamic timestamp, bool hasImage) {
    return Text(
      DateFormat('dd-MM-yyyy').format((timestamp as Timestamp).toDate()),
      style: TextStyle(
          fontSize: 12, color: hasImage ? Colors.white70 : Colors.grey),
    );
  }
}
