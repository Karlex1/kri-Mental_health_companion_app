import 'package:http/http.dart' as http;
import 'dart:convert';
import 'video.dart'; // Import Video model

Future<List<Video>> fetchVideosBySentiment(String sentiment, String mappedPhrase) async {
  final url = Uri.parse(
      "https://backend-p02p.onrender.com/recommendations?sentiment=$sentiment&mappedPhrase=$mappedPhrase");

  try {
    print('Fetching videos from URL: $url');  // Debugging print

    final response = await http.get(url);

    print('Response status: ${response.statusCode}');  // Print status code
    print('Response body: ${response.body}');  // Print response body

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print('Response JSON: $data');  // Print the decoded JSON data

      if (data['success'] == true) {
        final videos = (data['videos'] as List)
            .map((videoJson) => Video.fromJson(videoJson))
            .toList();

        print('Fetched videos: $videos');  // Print the list of videos fetched
        return videos;
      } else {
        throw Exception(data['error'] ?? 'Failed to fetch videos');
      }
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching videos: $e');  // Print error details
    throw Exception('Error fetching videos: $e');
  }
}
