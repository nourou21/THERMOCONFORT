import 'package:flutter/material.dart';
import 'package:flutter_application_2/Thermostat.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_2/auth/loginscreen.dart';

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
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), // Commencez par le thème clair
      home: LoginScreen(),
    );
  }
}
