// import 'package:cstain/models/campaigns.dart';
// import 'package:cstain/models/user.dart';
// import 'package:cstain/providers/gemini_service.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cstain/providers/chatbot_providers.dart' as chatbot;

// final chatbotProvider =
//     StateNotifierProvider<ChatbotNotifier, List<Map<String, String>>>((ref) {
//   return ChatbotNotifier(ref);
// });

// class ChatbotNotifier extends StateNotifier<List<Map<String, String>>> {
//   final chatbot.FirestoreService _firestoreService = chatbot.FirestoreService();
//   final Ref _ref;

//   ChatbotNotifier(this._ref)
//       : super([
//           {'bot': "How can I assist you today?"}
//         ]);

//   Future<void> processUserQuery(String userId, String query) async {
//     state = [
//       ...state,
//       {'user': query}
//     ]; // Add user message to state

//     try {
//       print("🔹 Fetching user details for userId: $userId");
//       UserModel? user = await _firestoreService.getUserDetails(userId);

//       if (user == null) {
//         print("❌ User not found!");
//         state = [
//           ...state,
//           {'bot': "User details not found."}
//         ];
//         return;
//       }

//       print("✅ User fetched: ${user.username}");

//       print("🔹 Fetching user campaigns...");
//       List<Campaign> campaigns =
//           await _firestoreService.getUserCampaigns(userId);
//       print("✅ Campaigns fetched: ${campaigns.length}");

//       // Convert data into a map
//       Map<String, dynamic> userData = {
//         "username": user.username,
//         "total_CO2_saved": user.total_CO2_saved ?? 0.0,
//         "current_streak": user.currentStreak ?? 0,
//         "campaigns": campaigns.map((c) => c.title).toList(),
//       };

//       print("🔹 Sending user data to Gemini AI: $userData");
//       String geminiResponse =
//           await GeminiService.sendUserDataToGemini(userData);

//       state = [
//         ...state,
//         {'bot': geminiResponse}
//       ]; // Add bot response to state
//       print("✅ Query processed successfully.");
//     } catch (e) {
//       print("❌ Error: $e");
//       state = [
//         ...state,
//         {
//           'bot':
//               "I am unable to fetch the information right now. Please try again later."
//         }
//       ];
//     }
//   }
// }

import 'package:cstain/models/campaigns.dart';
import 'package:cstain/models/user.dart';
import 'package:cstain/providers/gemini_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cstain/providers/chatbot_providers.dart' as chatbot;

final chatbotFABVisibilityProvider = StateProvider<bool>((ref) => true);

final chatbotProvider =
    StateNotifierProvider<ChatbotNotifier, List<Map<String, String>>>((ref) {
  return ChatbotNotifier(ref);
});

class ChatbotNotifier extends StateNotifier<List<Map<String, String>>> {
  final chatbot.FirestoreService _firestoreService = chatbot.FirestoreService();
  final Ref _ref;

  ChatbotNotifier(this._ref)
      : super([
          {'bot': "How can I assist you today?"}
        ]);

  Future<void> processUserQuery(String userId, String query) async {
    state = [
      ...state,
      {'user': query}
    ];

    try {
      print("🔹 Fetching user details for userId: $userId");
      UserModel? user = await _firestoreService.getUserDetails(userId);

      if (user == null) {
        print("❌ User not found!");
        state = [
          ...state,
          {'bot': "User details not found."}
        ];
        return;
      }

      print("✅ User fetched: ${user.username}");

      print("🔹 Fetching user campaigns...");
      List<Campaign> campaigns =
          await _firestoreService.getUserCampaigns(userId);
      print("✅ Campaigns fetched: ${campaigns.length}");

      // Convert data into a map
      Map<String, dynamic> userData = {
        "username": user.username,
        "total_CO2_saved": user.total_CO2_saved ?? 0.0,
        "current_streak": user.currentStreak ?? 0,
        "campaigns": campaigns.map((c) => c.title).toList(),
      };

      print("🔹 Sending user data to Gemini AI: $userData");
      String geminiResponse =
          await GeminiService.sendUserDataToGemini(userData, query);

      state = [
        ...state,
        {'bot': geminiResponse}
      ];
      print("✅ Query processed successfully.");
    } catch (e) {
      print("❌ Error: $e");
      state = [
        ...state,
        {
          'bot':
              "I am unable to fetch the information right now. Please try again later."
        }
      ];
    }
  }
}
