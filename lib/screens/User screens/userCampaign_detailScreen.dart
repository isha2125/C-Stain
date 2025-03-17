import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/models/campaigns.dart';
import 'package:cstain/models/participations.dart';
import 'package:cstain/providers/campaign%20providers/campaign_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class UserDetailCampaignScreen extends ConsumerWidget {
  final Campaign campaign;
  final ParticipationModel? participation;

  const UserDetailCampaignScreen({
    required this.campaign,
    this.participation,
    Key? key,
  }) : super(key: key);

  // Helper to format Timestamp to a readable date
  String _formatDate(dynamic timestamp) {
    return DateFormat('dd-MM-yyyy').format(timestamp.toDate());
  }

  double calculateContributionPercentage(
      double? userContribution, double target) {
    if (userContribution == null || target == 0) return 0.0;
    return (userContribution / target) * 100;
  }

  // Helper to build an info row with a label and value
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // Helper to build a section title
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double userContribution = participation?.carbonSaved ?? 0.0;
    double contributionPercentage = calculateContributionPercentage(
        userContribution, campaign.targetCO2Savings);
    // Listen for live updates to the campaign document
    final campaignStream =
        ref.watch(campaignStreamProvider(campaign.campaignId));

    return campaignStream.when(
      data: (updatedCampaign) => Scaffold(
        appBar: AppBar(
          title: Text(updatedCampaign.title),
          backgroundColor: Colors.teal,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show image only if available
              if (updatedCampaign.imageUrl != null &&
                  updatedCampaign.imageUrl!.isNotEmpty)
                Image.network(
                  updatedCampaign.imageUrl!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Description"),
                    Text(
                      updatedCampaign.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    // Fetch and display the creator's name
                    Consumer(
                      builder: (context, ref, child) {
                        final corpUserNameAsync = ref.watch(
                            corpUserNameProvider(updatedCampaign.corpUserId));
                        return corpUserNameAsync.when(
                          data: (name) => _infoRow("Created By", name),
                          loading: () => _infoRow("Created By", "Loading..."),
                          error: (error, stack) =>
                              _infoRow("Created By", "Error loading creator"),
                        );
                      },
                    ),
                    // const SizedBox(height: 16),
                    _infoRow("Category", updatedCampaign.category),
                    _infoRow("Action", updatedCampaign.action),
                    _infoRow("Target CO2 Savings",
                        "${updatedCampaign.targetCO2Savings} kgs"),
                    _infoRow("Total Carbon Saved",
                        "${updatedCampaign.totalCarbonSaved} kgs"),

                    _infoRow(
                        "Start Date", _formatDate(updatedCampaign.startDate)),
                    _infoRow("End Date", _formatDate(updatedCampaign.endDate)),
                    if (updatedCampaign.participants != null &&
                        updatedCampaign.participants!.isNotEmpty)
                      _infoRow("Participants",
                          updatedCampaign.participants!.length.toString()),
                    const SizedBox(height: 16),
                    if (participation != null) ...[
                      const Divider(),
                      _sectionTitle("Your Participation"),
                      _infoRow(
                          "Joined At", _formatDate(participation!.joinedAt)),
                      if (participation!.carbonSaved != null)
                        _infoRow("Carbon Saved",
                            "${participation!.carbonSaved} kgs"),
                      if (participation!.contributionIds != null &&
                          participation!.contributionIds!.isNotEmpty)
                        _infoRow("Contributions",
                            participation!.contributionIds!.length.toString()),
                      _infoRow("Your Precentage Contribution",
                          " ${contributionPercentage.toStringAsFixed(2)}%")
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text(campaign.title),
          backgroundColor: Colors.teal,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: Text(campaign.title),
          backgroundColor: Colors.teal,
        ),
        body: Center(child: Text("Error: $error")),
      ),
    );
  }
}
