import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/models/campaigns.dart';
import 'package:cstain/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch user details
  Future<UserModel?> getUserDetails(String userId) async {
    DocumentSnapshot userDoc = await _db.collection("user").doc(userId).get();

    return userDoc.exists
        ? UserModel.fromMap(userDoc.data() as Map<String, dynamic>)
        : null;
  }

  // Fetch user's campaigns
  Future<List<Campaign>> getUserCampaigns(String userId) async {
    QuerySnapshot participationDocs = await _db
        .collection("participations")
        .where("userId", isEqualTo: userId)
        .get();

    List<Campaign> campaigns = [];
    for (var doc in participationDocs.docs) {
      String campaignId = doc["campaignId"];
      DocumentSnapshot campaignDoc =
          await _db.collection("campaigns").doc(campaignId).get();
      if (campaignDoc.exists && campaignDoc.data() != null) {
        campaigns
            .add(Campaign.fromMap(campaignDoc.data() as Map<String, dynamic>));
      }
    }
    return campaigns;
  }

  Future<List<String>> fetchUserAchievements(String userId) async {
    QuerySnapshot achievementsDocs = await _db
        .collection("achievements")
        .where("userId", isEqualTo: userId)
        .get();

    return achievementsDocs.docs.map((doc) => doc["title"] as String).toList();
  }
}
