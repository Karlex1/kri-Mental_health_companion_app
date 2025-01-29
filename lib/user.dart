import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class UserDetailsPage extends StatefulWidget {
  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController professionController = TextEditingController();
  final TextEditingController endOfDayTimeController = TextEditingController();

  // Function to show a date picker and update the DOB field
  Future<void> _selectDOB(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        dobController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  // Function to select the "End of Day" time
  Future<void> _selectEndOfDayTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        final now = DateTime.now();
        final combinedDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        endOfDayTimeController.text = combinedDateTime.toIso8601String();
      });
    }
  }

  // Function to save user data to Firestore and navigate to HomeScreen
  Future<void> _saveUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User is not logged in.');
      }

      // Validate input fields
      if (usernameController.text.isEmpty ||
          dobController.text.isEmpty ||
          professionController.text.isEmpty ||
          endOfDayTimeController.text.isEmpty) {
        throw Exception('Please fill in all the fields.');
      }

      // Save user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': usernameController.text,
        'dob': dobController.text,
        'profession': professionController.text,
        'endOfDayTime': endOfDayTimeController.text,
        'email': user.email,
      });

      // Navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            username: usernameController.text,
            dob: dobController.text,
            profession: professionController.text,
            email: user.email!,
            endOfDayTime: endOfDayTimeController.text,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save user data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: dobController,
                decoration: InputDecoration(labelText: 'Date of Birth'),
                readOnly: true,
                onTap: () => _selectDOB(context),
              ),
              TextField(
                controller: professionController,
                decoration: InputDecoration(labelText: 'Profession'),
              ),
              TextField(
                controller: endOfDayTimeController,
                decoration: InputDecoration(labelText: 'End of Day Time'),
                readOnly: true,
                onTap: () => _selectEndOfDayTime(context),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUserData,
                child: Text('Save & Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
