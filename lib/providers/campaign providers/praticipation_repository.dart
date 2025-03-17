// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class ParticipantRepository {
//   final FirebaseFirestore _firestore;

//   ParticipantRepository(this._firestore);

//   Future<void> registerParticipant(String campaignId, String userId) async {
//     try {
//       final campaignRef = _firestore.collection('campaigns').doc(campaignId);
//       await _firestore.runTransaction((transaction) async {
//         final campaignDoc = await transaction.get(campaignRef);
//         if (!campaignDoc.exists) {
//           throw Exception("Campaign does not exist");
//         }
//         List<String> participants =
//             List<String>.from(campaignDoc.data()?['participants'] ?? []);

//         if (!participants.contains(userId)) {
//           participants.add(userId);
//           transaction.update(campaignRef, {'participants': participants});
//         }
//       });
//     } catch (e) {
//       throw Exception("Failed to register participant: $e");
//     }
//   }
// }

// final participantRepositoryProvider = Provider<ParticipantRepository>((ref) {
//   return ParticipantRepository(FirebaseFirestore.instance);
// });

// class ParticipantNotifier extends StateNotifier<AsyncValue<void>> {
//   final ParticipantRepository _repository;

//   ParticipantNotifier(this._repository) : super(const AsyncValue.data(null));

//   Future<void> participate(String campaignId, String userId) async {
//     state = const AsyncValue.loading();
//     try {
//       await _repository.registerParticipant(campaignId, userId);
//       state = const AsyncValue.data(null);
//     } catch (e, stackTrace) {
//       state = AsyncValue.error(e, stackTrace);
//     }
//   }
// }

// final participantProvider =
//     StateNotifierProvider<ParticipantNotifier, AsyncValue<void>>((ref) {
//   final repository = ref.watch(participantRepositoryProvider);
//   return ParticipantNotifier(repository);
// });

//*****************with participation model also ************** */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/models/participations.dart';
import 'package:cstain/providers/action%20providers/providers.dart';
import 'package:cstain/providers/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class ParticipantRepository {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  ParticipantRepository(this._firestore);

  Future<void> registerParticipant(String campaignId, String userId) async {
    try {
      final campaignRef = _firestore.collection('campaigns').doc(campaignId);
      final participationId = _uuid.v4(); // Unique participation ID
      final participationRef =
          _firestore.collection('participations').doc(participationId);

      await _firestore.runTransaction((transaction) async {
        final campaignDoc = await transaction.get(campaignRef);
        if (!campaignDoc.exists) {
          throw Exception("Campaign does not exist");
        }

        List<String> participants =
            List<String>.from(campaignDoc.data()?['participants'] ?? []);

        if (!participants.contains(userId)) {
          participants.add(userId);
          transaction.update(campaignRef, {'participants': participants});

          // Store participation record in "participations" collection
          final participation = ParticipationModel(
            participationId: participationId,
            campaignId: campaignId,
            userId: userId,
            joinedAt: Timestamp.fromDate(DateTime.now()),
            carbonSaved: 0.0,
            contributionIds: [],
          );

          transaction.set(participationRef, participation.toMap());
        }
      });
    } catch (e) {
      throw Exception("Failed to register participant: $e");
    }
  }

  /// Check if user has already participated in a campaign
//   Stream<bool> hasParticipated(String campaignId, String userId) {
//     return _firestore
//         .collection('participations')
//         .where('campaignId', isEqualTo: campaignId)
//         .where('userId', isEqualTo: userId)
//         .snapshots()
//         .map((snapshot) => snapshot.docs.isNotEmpty);
//   }
// }
  Stream<bool> hasParticipated(String campaignId, String userId) {
    print(
        "Checking participation for userId: $userId, campaignId: $campaignId");
    return _firestore
        .collection('participations')
        .where('campaignId', isEqualTo: campaignId)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      print("Participation snapshot docs length: ${snapshot.docs.length}");
      return snapshot.docs.isNotEmpty;
    });
  }
}

//list of providers
final participantRepositoryProvider = Provider<ParticipantRepository>((ref) {
  return ParticipantRepository(FirebaseFirestore.instance);
});

class ParticipantNotifier extends StateNotifier<AsyncValue<void>> {
  final ParticipantRepository _repository;

  ParticipantNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> participate(String campaignId, String userId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.registerParticipant(campaignId, userId);

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// ✅ Provider to handle participation actions
final participantProvider =
    StateNotifierProvider<ParticipantNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(participantRepositoryProvider);
  return ParticipantNotifier(repository);
});

// ✅ StreamProvider to check if the user has already participated
// final checkParticipationProvider =
//     StreamProvider.family<bool, String>((ref, campaignId) {
//   final repository = ref.watch(participantRepositoryProvider);
//   final userId = ref.watch(userStreamProvider).value?.uid;
//   print('check participant provider ${userId}'); // ✅ Get the logged-in user ID
//   if (userId == null) {
//     return Stream.value(false); // Return false if user is not logged in
//   }
//   return repository.hasParticipated(campaignId, userId);
// });

final checkParticipationProvider =
    StreamProvider.family<bool, String>((ref, campaignId) {
  return ref.watch(userStreamProvider).when(
    data: (userModel) {
      final userId = userModel.uid;
      print('check participant provider ${userId}');
      if (userId == null) {
        return Stream.value(false);
      }
      final repository = ref.watch(participantRepositoryProvider);
      return repository.hasParticipated(campaignId, userId);
    },
    loading: () {
      print('check participant provider loading');
      return Stream.value(false); // Or a loading indicator
    },
    error: (error, stackTrace) {
      print('check participant provider error $error');
      return Stream.value(false); // Or an error message
    },
  );
});
