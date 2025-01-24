import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CampaignRepository {
  final FirebaseFirestore _firestore;

  CampaignRepository(this._firestore);

  Future<void> createCampaign(Map<String, dynamic> campaignData) async {
    try {
      await _firestore.collection('campaigns').add(campaignData);
    } catch (e) {
      throw Exception('Failed to create campaign: $e');
    }
  }
}

final campaignRepositoryProvider = Provider<CampaignRepository>(
  (ref) => CampaignRepository(FirebaseFirestore.instance),
);

class CampaignNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final CampaignRepository _repository;

  CampaignNotifier(this._repository) : super([]);

  Future<void> addCampaign(Map<String, dynamic> campaignData) async {
    await _repository.createCampaign(campaignData);
    state = [...state, campaignData];
  }
}

final campaignProvider =
    StateNotifierProvider<CampaignNotifier, List<Map<String, dynamic>>>(
  (ref) {
    final repository = ref.watch(campaignRepositoryProvider);
    return CampaignNotifier(repository);
  },
);
