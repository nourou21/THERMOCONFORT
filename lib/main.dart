import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_application_2/screens/login_screen/login_screen.dart';
import 'package:flutter_application_2/slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initFirebase();
  runApp(const MyApp());
}

Future<void> _initFirebase() async {
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: 'AIzaSyAW5wcsv8KSEVxQOWwkvqHlXxdB719tPFU',
        appId: '1:735999702577:android:c104eb1f4614908d9f0710',
        messagingSenderId: '735999702577',
        projectId: 'thermoconfort-9df37'),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), // Commencez par le thème clair
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Show a loading indicator while waiting for the future
          } else {
            return snapshot.data ??
                const LOGINN(); // Show login screen if future returns null
          }
        },
      ),
    );
  }

  Future<Widget> _getInitialScreen() async {
    // Check for saved login credentials
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');

    // Check if the user is already authenticated
    final currentUser = FirebaseAuth.instance.currentUser;

    // If the user is already authenticated, return the home screen
    if (currentUser != null) {
      return SliderPage(); // Replace SliderPage() with your actual home screen widget
    }

    // If email and password are not null, attempt to sign in
    if (email != null && password != null) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return SliderPage(); // Replace SliderPage() with your actual home screen widget
      } catch (e) {
        print('Sign in error: $e');
      }
    }

    // If no saved credentials or sign in failed, return the login screen
    return const LOGINN();
  }
}
