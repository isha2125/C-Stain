import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/models/campaigns.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CampaignRepository {
  final FirebaseFirestore _firestore;

  CampaignRepository(this._firestore);

  Future<void> createCampaign(Campaign campaign) async {
    try {
      await _firestore
          .collection('campaigns')
          .doc(campaign.campaignId)
          .set(campaign.toMap());
    } catch (e) {
      throw Exception('Failed to create campaign: $e');
    }
  }

  Stream<List<Campaign>> getCampaigns() {
    return _firestore.collection('campaigns').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Campaign.fromMap(doc.data())).toList();
    });
  }
}

final campaignRepositoryProvider = Provider<CampaignRepository>(
  (ref) => CampaignRepository(FirebaseFirestore.instance),
);

class CampaignNotifier extends StateNotifier<AsyncValue<List<Campaign>>> {
  final CampaignRepository _repository;

  CampaignNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    _repository.getCampaigns().listen((campaigns) {
      state = AsyncValue.data(campaigns);
    }, onError: (error) {
      state = AsyncValue.error(error, StackTrace.current);
    });
  }

  Future<void> addCampaign(Campaign campaign) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createCampaign(campaign);
      _loadCampaigns();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final campaignProvider =
    StateNotifierProvider<CampaignNotifier, AsyncValue<List<Campaign>>>(
  (ref) {
    final repository = ref.watch(campaignRepositoryProvider);
    return CampaignNotifier(repository);
  },
);
