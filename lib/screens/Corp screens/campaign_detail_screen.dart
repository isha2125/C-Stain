import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/providers/campaign%20providers/campaign_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CampaignDetailScreen extends StatelessWidget {
  final Map<String, dynamic> campaign;

  const CampaignDetailScreen({Key? key, required this.campaign})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasImage = campaign['imageUrl'] != null &&
        campaign['imageUrl'].toString().isNotEmpty;
    final List<String> participants =
        (campaign['participants'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

    return Scaffold(
      appBar: AppBar(
        title: Text(campaign['title']),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // If campaign has an image, show it
            if (hasImage)
              Stack(
                children: [
                  Image.network(
                    campaign['imageUrl'],
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
                      campaign['title'],
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
                    campaign['description'],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  _infoRow("Category", campaign['category']),
                  _infoRow("Action", campaign['action']),
                  _infoRow("Target CO2 Savings",
                      "${campaign['targetCO2Savings']} kg"),
                  _infoRow("Start Date", _formatDate(campaign['startDate'])),
                  _infoRow("End Date", _formatDate(campaign['endDate'])),

                  const SizedBox(height: 20),

                  _sectionTitle("Participants"),
                  // Inside CampaignDetailScreen
                  participants.isEmpty
                      ? const Text("No participants yet",
                          style: TextStyle(fontSize: 16, color: Colors.grey))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: participants.length,
                          itemBuilder: (context, index) {
                            final userId = participants[index];

                            return Consumer(
                              builder: (context, ref, child) {
                                final usernameAsync = ref
                                    .watch(ParticipantUsernameProvider(userId));

                                return ListTile(
                                  leading: const Icon(Icons.person,
                                      color: Colors.teal),
                                  title: usernameAsync.when(
                                    data: (username) => Text(
                                      username!,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    loading: () =>
                                        const CircularProgressIndicator(),
                                    error: (_, __) =>
                                        const Text("Error loading user"),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
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
