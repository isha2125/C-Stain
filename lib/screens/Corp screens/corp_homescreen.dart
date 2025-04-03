import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/components/custom_appBar.dart';
import 'package:cstain/providers/auth_service.dart';
import 'package:cstain/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';

final corpDataProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value({});

  return FirebaseFirestore.instance
      .collection('campaigns')
      .where('corpUserId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
    int totalCampaigns = snapshot.docs.length;
    double totalCO2Saved = 0.0;
    String? mostPopularCampaign;
    String? upcomingCampaign;
    String? completedCampaign;
    int maxParticipants = 0;

    // DateTime now = DateTime.now();
    // for (var doc in snapshot.docs) {
    //   var data = doc.data();
    //   totalCO2Saved += (data['totalCarbonSaved'] as num?)?.toDouble() ?? 0.0;
    //   int participants = data['participants']?.length ?? 0;
    //   if (participants > maxParticipants) {
    //     maxParticipants = participants;
    //     mostPopularCampaign = data['title'];
    //   }
    //   DateTime endDate = (data['endDate'] as Timestamp).toDate();
    //   if (endDate.isBefore(now)) {
    //     completedCampaign = data['title'];
    //   } else {
    //     upcomingCampaign ??= data['title'];
    //   }
    // }
    DateTime now = DateTime.now();
    DateTime latestCompletedDate = DateTime(2000); // Default old date
    DateTime earliestUpcomingDate = DateTime(2100); // Default future date

    for (var doc in snapshot.docs) {
      var data = doc.data();
      totalCO2Saved += (data['totalCarbonSaved'] as num?)?.toDouble() ?? 0.0;

      int participants = data['participants']?.length ?? 0;
      if (participants > maxParticipants) {
        maxParticipants = participants;
        mostPopularCampaign = data['title'];
      }

      DateTime startDate = (data['startDate'] as Timestamp).toDate();
      DateTime endDate = (data['endDate'] as Timestamp).toDate();

      // Find the latest completed campaign
      if (endDate.isBefore(now) && endDate.isAfter(latestCompletedDate)) {
        latestCompletedDate = endDate;
        completedCampaign = data['title'];
      }

      // Find the upcoming campaign (start date must be in the future)
      if (startDate.isAfter(now) && startDate.isBefore(earliestUpcomingDate)) {
        earliestUpcomingDate = startDate;
        upcomingCampaign = data['title'];
      }
    }

    return {
      'totalCO2Saved': totalCO2Saved.toStringAsFixed(2),
      'totalCampaigns': totalCampaigns,
      'mostPopularCampaign': mostPopularCampaign,
      'upcomingCampaign': upcomingCampaign,
      'completedCampaign': completedCampaign,
    };
  });
});

class CorpHomescreen extends ConsumerWidget {
  const CorpHomescreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final corpDataAsync = ref.watch(corpDataProvider);

    return Scaffold(
      appBar: CustomAppBar(),
      body: corpDataAsync.when(
        data: (data) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // _buildHeader("Overview"),
                Expanded(
                  child: ListView(
                    children: [
                      _buildCO2SavedTile(data['totalCO2Saved']),
                      // _buildGradientTile(
                      //     "Total CO2 Saved",
                      //     "${data['totalCO2Saved']} kg",
                      //     FontAwesomeIcons.leaf, [
                      //   Color.fromARGB(255, 60, 188, 141),
                      //   Color(0xFF237155)
                      // ]),
                      _buildGradientTile(
                          "Total Campaigns",
                          "${data['totalCampaigns']}",
                          FontAwesomeIcons.clipboardList,
                          [Colors.blue[700]!, Colors.blue[300]!]),
                      _buildGradientTile(
                          "Most Popular Campaign",
                          data['mostPopularCampaign'] ?? "N/A",
                          FontAwesomeIcons.star,
                          [Colors.amber[700]!, Colors.amber[300]!]),
                      _buildUpcomingCompletedTile(
                          "Campaign Status",
                          data['upcomingCampaign'] ?? "N/A",
                          data['completedCampaign'] ?? "N/A",
                          FontAwesomeIcons.calendarCheck,
                          const Color.fromARGB(255, 255, 255, 255),
                          context,
                          [Colors.purple[700]!, Colors.purple[300]!])
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  // Widget _buildHeader(String title) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 10.0),
  //     child: Text(
  //       title,
  //       style: TextStyle(
  //         fontSize: 20,
  //         fontWeight: FontWeight.bold,
  //         color: Colors.green[800],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildCO2SavedTile(String totalCO2Saved) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 60, 188, 141),
            Color(0xFF237155),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total CO2 Saved',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '$totalCO2Saved kg',
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(
            Icons.eco,
            color: Colors.white,
            size: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildGradientTile(
      String title, String value, IconData icon, List<Color> gradientColors) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          trailing: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

Widget _buildUpcomingCompletedTile(
    String title,
    String upcoming,
    String completed,
    IconData icon,
    Color iconColor,
    BuildContext context,
    List<Color> gradientColors) {
  double screenWidth = MediaQuery.of(context).size.width;

  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    margin: const EdgeInsets.only(bottom: 12.0),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: screenWidth * 0.06,
        ),
        title: Text(
          title,
          style: TextStyle(
            // fontSize: screenWidth * 0.045,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(221, 255, 255, 255),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Upcoming: ",
                style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 185, 185, 185),
                    fontSize: screenWidth * 0.04)),
            Text(upcoming,
                style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.05)),
            SizedBox(height: 5),
            Text("Completed: ",
                style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 189, 189, 189),
                    fontSize: screenWidth * 0.04)),
            Text(completed,
                style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.05)),
          ],
        ),
        trailing: Icon(icon, color: iconColor, size: 30),
      ),
    ),
  );
}
