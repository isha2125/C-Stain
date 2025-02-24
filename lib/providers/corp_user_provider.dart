import 'package:cstain/models/corp_user.dart';
import 'package:cstain/screens/Corp%20screens/corp_bottom_nav.dart';
import 'package:cstain/screens/Corp%20screens/corp_deatilsForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final corpUserRepositoryProvider = Provider((ref) => CorpUserRepository());

class CorpUserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<CorpUserModel?> getCorpUser(String userId) async {
    final doc = await _firestore.collection('corporateUsers').doc(userId).get();
    if (doc.exists) {
      return CorpUserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> saveCorpUser(CorpUserModel corpUser) async {
    await _firestore
        .collection('corporateUsers')
        .doc(corpUser.userId)
        .set(corpUser.toMap());
  }
}

final corpUserProvider =
    FutureProvider.family<CorpUserModel?, String>((ref, userId) {
  return ref.read(corpUserRepositoryProvider).getCorpUser(userId);
});

void checkCorpUser(BuildContext context, WidgetRef ref, String userId) {
  ref.read(corpUserProvider(userId).future).then((corpUser) {
    if (corpUser == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => CorpUserFormScreen(userId: userId)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CorpBottomNav()),
      );
    }
  });
}
