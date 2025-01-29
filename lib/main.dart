import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth.dart';
import 'user.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ensure Firebase is initialized
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Health Companion',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          // If the user is logged in, check if user data exists in Firestore
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (userSnapshot.data != null && userSnapshot.data!.exists) {
                // User data exists, navigate to HomeScreen
                final userData = userSnapshot.data!;
                return HomeScreen(
                  username: userData['username'] ?? 'Unknown User',  // Ensure defaults
                  dob: userData['dob'] ?? 'Not Provided',
                  profession: userData['profession'] ?? 'Not Provided',
                  email: userData['email'] ?? 'Not Provided',
                  endOfDayTime: userData['endOfDayTime'] ?? '2024-12-31T23:59:59Z', // Ensure a fallback default
                );
              }
              // User data doesn't exist, navigate to UserDetailsPage
              return UserDetailsPage();
            },
          );
        }
        // If the user is not logged in, navigate to AuthPage
        return AuthPage();
      },
    );
  }
}
