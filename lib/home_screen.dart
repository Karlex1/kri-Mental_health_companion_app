import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'show_user_page.dart';
import 'video_page.dart';
import 'therapist_page.dart';
import 'VideoServices.dart';
import 'daily_summary_popup.dart';
import 'video.dart'; // Make sure you import the Video class

class HomeScreen extends StatefulWidget {
  final String username;
  final String dob;
  final String profession;
  final String email;
  final String endOfDayTime;

  HomeScreen({
    required this.username,
    required this.dob,
    required this.profession,
    required this.email,
    required this.endOfDayTime,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime endOfDay;
  int _selectedIndex = 0;
  String? _sentimentResult;
  List<Map<String, dynamic>> _dailySummaries = [];
  List<FlSpot> _sentimentDataSoFar = [];
  List<Video> _videoRecommendations = [];

  @override
  void initState() {
    super.initState();
    endOfDay = DateTime.parse(widget.endOfDayTime);
    _checkAndShowSummaryPopup();
    _fetchUserData();
  }

  void _checkAndShowSummaryPopup() {
    final currentTime = DateTime.now();
    if (currentTime.isAfter(endOfDay) && _sentimentResult == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showDailySummaryPopup());
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _showDailySummaryPopup() async {
    final summaryData = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => DailySummaryPopup(),
    );

    if (summaryData != null && summaryData.isNotEmpty) {
      final summaryText = summaryData['summary']!;
      final sentiment = summaryData['sentiment']!;

      setState(() {
        _sentimentResult = sentiment;
      });

      _fetchSentimentVideos(sentiment);
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _fetchDailySummaries(user.uid);
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _fetchDailySummaries(String uid) async {
    try {
      final entriesSnapshot = await FirebaseFirestore.instance
          .collection('dailySummaries')
          .doc(uid)
          .collection('entries')
          .orderBy('timestamp', descending: true)
          .limit(7)
          .get();

      setState(() {
        _dailySummaries = entriesSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        _prepareMentalHealthData();
      });
    } catch (e) {
      print("Error fetching daily summaries: $e");
    }
  }

  void _prepareMentalHealthData() {
    List<FlSpot> spots = [];
    int count = 0;

    final recentSummaries = _dailySummaries.reversed.toList();

    for (var summary in recentSummaries) {
      final sentiment = summary['label'] as String;
      double sentimentScore;

      switch (sentiment) {
        case 'Suicidal':
          sentimentScore = 0;
          break;
        case 'Depression':
          sentimentScore = 0.5;
          break;
        case 'Anxiety':
          sentimentScore = 1.0;
          break;
        case 'Stress':
          sentimentScore = 1.5;
          break;
        case 'Normal':
          sentimentScore = 2.0;
          break;
        case 'Bipolar':
          sentimentScore = 2.5;
          break;
        case 'Personality disorder':
          sentimentScore = 3.0;
          break;
        default:
          sentimentScore = 2.0;
          break;
      }

      count++;
      spots.add(FlSpot(count.toDouble(), sentimentScore));
    }

    setState(() {
      _sentimentDataSoFar = spots;
    });
  }

  Future<void> _fetchSentimentVideos(String sentiment) async {
    try {
      // Example mapped phrase for demonstration
      final String mappedPhrase = _mapSentimentToPhrase(sentiment);

      final videos = await fetchVideosBySentiment(sentiment, mappedPhrase);
      setState(() {
        _videoRecommendations = videos;
      });
    } catch (e) {
      print("Error fetching videos: $e");
    }
  }

  String _mapSentimentToPhrase(String sentiment) {
    // Example mapping; replace this with your actual database logic
    const mapping = {
      "Anxiety": "relaxation techniques",
      "Stress": "stress management tips",
      "Depression": "motivational talks",
      "Normal": "positive affirmations",
    };

    return mapping[sentiment] ?? sentiment; // Default to sentiment if no mapping
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  Widget _buildMentalHealthChart() {
    if (_sentimentDataSoFar.isEmpty) {
      return Center(child: Text('No sentiment data available.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 300,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 60,
                  interval: 0.5,
                  getTitlesWidget: (value, meta) {
                    switch (value) {
                      case 0:
                        return Text('Suicidal', style: TextStyle(fontSize: 10));
                      case 0.5:
                        return Text('Depression', style: TextStyle(fontSize: 10));
                      case 1.0:
                        return Text('Anxiety', style: TextStyle(fontSize: 10));
                      case 1.5:
                        return Text('Stress', style: TextStyle(fontSize: 10));
                      case 2.0:
                        return Text('Normal', style: TextStyle(fontSize: 10));
                      case 2.5:
                        return Text('Bipolar', style: TextStyle(fontSize: 10));
                      case 3.0:
                        return Text('Personality', style: TextStyle(fontSize: 10));
                      default:
                        return Text('');
                    }
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 1 && index <= _sentimentDataSoFar.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Day $index',
                          style: TextStyle(fontSize: 10),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: _sentimentDataSoFar,
                isCurved: true,
                barWidth: 2,
                color: Colors.blue,
                belowBarData: BarAreaData(show: false),
              ),
            ],
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Colors.grey.withOpacity(0.5),
                width: 1,
              ),
            ),
            minX: 0,
            maxX: _sentimentDataSoFar.length.toDouble() + 1,
            minY: 0,
            maxY: 3.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the Mental Health Companion!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (_sentimentDataSoFar.isNotEmpty) _buildMentalHealthChart(),
          ],
        ),
      ),
      ShowUserPage(
        email: widget.email,
        username: widget.username,
        dob: widget.dob,
        profession: widget.profession,
        endOfDayTime: widget.endOfDayTime,
      ),
      VideoPage(videos: _videoRecommendations),
      TherapistPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white, // Change background color if needed
        selectedItemColor: Colors.blue, // Set selected item icon color to blue
        unselectedItemColor: Colors.grey, // Set unselected item icon color to grey
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Video',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Therapist',
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showDailySummaryPopup,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
