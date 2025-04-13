import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/components/custom_appBar.dart';
import 'package:cstain/providers/auth_service.dart';
import 'package:cstain/providers/campaign%20providers/campaign_providers.dart';
import 'package:cstain/screens/Corp%20screens/campaign_detail_screen.dart';
import 'package:cstain/screens/Corp%20screens/corp_createcampaignscreen.dart';
import 'package:cstain/screens/profile_screen.dart';
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
          leading: Image.asset('assets/Earth black 1.png'),
          title: const Text(
            'Campaigns',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            Consumer(
              builder: (context, ref, child) {
                final authState = ref.watch(authStateProvider);
                final userId = authState.value?.uid;
                final profileImageAsync = ref.watch(userProfileProvider);

                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: userId == null
                      ? IconButton(
                          icon: const Icon(Icons.person),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('No user logged in')),
                            );
                          },
                        )
                      : GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MYProfileScreen(profileUserId: userId),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                Colors.grey.shade300, // Default background
                            backgroundImage: profileImageAsync.when(
                              data: (imageUrl) => imageUrl != null
                                  ? NetworkImage(imageUrl)
                                  : null,
                              loading: () => null, // No image during loading
                              error: (_, __) => null, // No image on error
                            ),
                            child: profileImageAsync.when(
                              data: (imageUrl) => imageUrl == null
                                  ? const Icon(Icons.person,
                                      color: Colors.white)
                                  : null, // Show icon only if image is null
                              loading: () => const CircularProgressIndicator(
                                  strokeWidth: 2),
                              error: (_, __) =>
                                  const Icon(Icons.person, color: Colors.white),
                            ),
                          ),
                        ),
                );
              },
            ),
          ],
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
                builder: (context) =>
                    CampaignDetailScreen(campaignId: campaign['campaignId']),
              ),
            );
          },
        );
      },
    );
  }
}

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
