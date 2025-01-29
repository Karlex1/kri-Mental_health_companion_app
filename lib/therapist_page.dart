import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Assuming you have a service that fetches therapist data from the API
class TherapistService {
  // Fetch therapists with pagination
  Future<List<Therapist>> fetchTherapists({required int page, required int perPage}) async {
    final response = await http.get(
      Uri.parse('https://backend-p02p.onrender.com/therapists?page=$page&per_page=$perPage'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final therapistsJson = data['therapists'] as List;
      return therapistsJson.map((json) => Therapist.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load therapists');
    }
  }

  // Fetch random therapists for recommendations
  Future<List<Therapist>> fetchRandomTherapists() async {
    final response = await http.get(Uri.parse('https://backend-p02p.onrender.com/therapists'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final therapistsJson = data['therapists'] as List;
      return therapistsJson.map((json) => Therapist.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recommended therapists');
    }
  }
}

class Therapist {
  final String id;
  final String name;
  final String specialization;
  final int experienceYears;
  final int consultationFee;
  final String clinicLocation;
  final int ratingPercentage;
  final int reviewsCount;

  Therapist({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experienceYears,
    required this.consultationFee,
    required this.clinicLocation,
    required this.ratingPercentage,
    required this.reviewsCount,
  });

  // Convert JSON to Therapist object
  factory Therapist.fromJson(Map<String, dynamic> json) {
    return Therapist(
      id: json['id'],
      name: json['name'],
      specialization: json['specialization'],
      experienceYears: json['experience_years'],
      consultationFee: json['consultation_fee'],
      clinicLocation: json['clinic_location'],
      ratingPercentage: json['rating_percentage'],
      reviewsCount: json['reviews_count'],
    );
  }
}

class TherapistPage extends StatefulWidget {
  @override
  _TherapistPageState createState() => _TherapistPageState();
}

class _TherapistPageState extends State<TherapistPage> {
  late Future<List<Therapist>> futureTherapists;
  late Future<List<Therapist>> futureRandomTherapists;
  int currentPage = 1;
  int perPage = 10;
  int totalPages = 1;

  @override
  void initState() {
    super.initState();
    loadTherapists();
  }

  void loadTherapists() {
    futureTherapists = TherapistService().fetchTherapists(
      page: currentPage,
      perPage: perPage,
    );
    futureRandomTherapists = TherapistService().fetchRandomTherapists();
  }

  // Modal to display therapist details
  void _showTherapistDetails(Therapist therapist) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(therapist.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Specialization: ${therapist.specialization}"),
              Text("Experience: ${therapist.experienceYears} years"),
              Text("Consultation Fee: ₹${therapist.consultationFee}"),
              Text("Location: ${therapist.clinicLocation}"),
              Text("Rating: ${therapist.ratingPercentage}%"),
              Text("Reviews: ${therapist.reviewsCount}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Therapists"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // List of therapists with pagination
            FutureBuilder<List<Therapist>>(
              future: futureTherapists,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  List<Therapist> therapists = snapshot.data!;
                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: therapists.length,
                        itemBuilder: (context, index) {
                          final therapist = therapists[index];
                          return ListTile(
                            leading: Icon(Icons.person),
                            title: Text(therapist.name),
                            subtitle: Text(therapist.specialization),
                            onTap: () {
                              _showTherapistDetails(therapist);
                            },
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: currentPage > 1
                                ? () {
                              setState(() {
                                currentPage--;
                                loadTherapists();
                              });
                            }
                                : null,
                            child: Text("Previous"),
                          ),
                          ElevatedButton(
                            onPressed: currentPage < totalPages
                                ? () {
                              setState(() {
                                currentPage++;
                                loadTherapists();
                              });
                            }
                                : null,
                            child: Text("Next"),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Center(child: Text('No therapists found.'));
                }
              },
            ),

            SizedBox(height: 20),

            // Random therapists section

          ],
        ),
      ),
    );
  }
}
