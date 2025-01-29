import 'package:flutter/material.dart';

class ShowUserPage extends StatelessWidget {
  final String username;
  final String dob;
  final String profession;
  final String email;
  final String endOfDayTime;

  ShowUserPage({
    required this.username,
    required this.dob,
    required this.profession,
    required this.email,
    required this.endOfDayTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Information')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Username: $username',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Date of Birth: $dob',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Profession: $profession',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Email: $email',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'End of Day Time: $endOfDayTime',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // You can add functionality to edit or logout here
              },
              child: Text('Edit Profile'),  // Optional button to edit profile
            ),
          ],
        ),
      ),
    );
  }
}
