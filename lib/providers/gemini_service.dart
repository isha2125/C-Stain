import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  static final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  static final String baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

  static Future<String> sendUserDataToGemini(
      Map<String, dynamic> userData, String userQuery) async {
    final Map<String, dynamic> requestPayload = {
      "contents": [
        {
          "parts": [
            {
              "text":
                  "User ${userData['username']} has saved ${userData['total_CO2_saved']} kg of CO2 and participated in campaigns: ${userData['campaigns'].join(', ')}. User asked: '$userQuery'. Generate a response."
            }
          ]
        }
      ],
      "generationConfig": {"temperature": 0.5}
    };

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestPayload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        print("❌ Gemini API Error: ${response.body}");
        return "Error fetching response.";
      }
    } catch (e) {
      print("❌ Exception: $e");
      return "Error fetching response.";
    }
  }
}
