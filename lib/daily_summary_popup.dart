import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'api_service.dart';

class DailySummaryPopup extends StatefulWidget {
  @override
  _DailySummaryPopupState createState() => _DailySummaryPopupState();
}

class _DailySummaryPopupState extends State<DailySummaryPopup> {
  final TextEditingController _summaryController = TextEditingController();
  bool _isLoading = false;
  String? _sentimentRecommendation = "";
  String? _serverLabel = "";

  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _submitSummary() async {
    final summary = _summaryController.text.trim();
    if (summary.isEmpty) {
      _showSnackBar("Please write a summary before submitting!");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch sentiment prediction
      final prediction = await _apiService.getPrediction(summary);
      if (prediction == null || !prediction.containsKey('success') || prediction['success'] != true) {
        _showSnackBar("Failed to fetch sentiment data. Please try again.");
        return;
      }

      // Extract prediction label
      final predictionMap = prediction['prediction'] as Map<String, dynamic>?;
      if (predictionMap == null || predictionMap.isEmpty) {
        _showSnackBar("Invalid prediction response received.");
        return;
      }

      final predictionLabel = predictionMap.keys.first ?? 'Normal';
      final mappedPhrase = _mapPredictionToPhrase(predictionLabel);

      setState(() {
        _sentimentRecommendation = mappedPhrase;
        _serverLabel = predictionLabel;
      });

      // Save to Firestore
      await _saveToFirestore(summary, predictionLabel, mappedPhrase);
      Navigator.pop(context, {'summary': summary, 'sentiment': mappedPhrase});
    } catch (e) {
      _showSnackBar("An error occurred: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveToFirestore(String summary, String label, String mappedPhrase) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not logged in.");
      }

      final timestamp = DateTime.now();
      await FirebaseFirestore.instance
          .collection('dailySummaries')
          .doc(user.uid)
          .collection('entries')
          .add({
        'summary': summary,
        'label': label,
        'mappedPhrase': mappedPhrase,
        'timestamp': timestamp.toIso8601String(),
      });

      _showSnackBar("Summary and sentiment label saved successfully!");
    } catch (e) {
      _showSnackBar("Failed to save data: ${e.toString()}");
    }
  }

  String _mapPredictionToPhrase(String label) {
    switch (label) {
      case 'Normal':
        return 'Stay Motivated, Keep going';
      case 'Anxiety':
        return 'Cope with Anxiety';
      case 'Depression':
        return 'Handle Depression';
      case 'Suicidal':
        return 'Avoid suicidal thoughts';
      case 'Stress':
        return 'Relieve Stress';
      case 'Bipolar':
        return 'Handle Bipolar Disorder';
      case 'Personality disorder':
        return 'Handle Personality Disorder';
      default:
        return 'Motivation Videos';
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Write Your Daily Summary"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _summaryController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "How was your day?",
                border: OutlineInputBorder(),
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: CircularProgressIndicator(),
              ),
            if (_sentimentRecommendation != null && _sentimentRecommendation!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  "Sentiment Recommendation: $_sentimentRecommendation",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitSummary,
          child: Text("Submit"),
        ),
      ],
    );
  }
}
