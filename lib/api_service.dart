import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // The base URL of your backend server
  final String baseUrl = 'https://backend-p02p.onrender.com/predict';

  // Function to send daily summary and get prediction result
  Future<Map<String, dynamic>> getPrediction(String dailySummary) async {
    try {
      // Send POST request with daily summary data
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': dailySummary}),
      );

      // Check for successful response
      if (response.statusCode == 200) {
        // Parse the JSON response
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load prediction');
      }
    } catch (e) {
      // Handle error if any occurs
      throw Exception('Error occurred: $e');
    }
  }
}
