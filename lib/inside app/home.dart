import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/login_screen/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class homescreen extends StatefulWidget {
  const homescreen({Key? key}) : super(key: key);

  @override
  State<homescreen> createState() => _homescreenState();
}

class _homescreenState extends State<homescreen> {
  bool isEmailCorrect = false;

  final DatabaseReference _ledReference =
      FirebaseDatabase.instance.reference().child('project/led');

  void disconnect() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LOGINN()),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  void turnOn() {
    _ledReference.set('on');
  }

  void turnOff() {
    _ledReference.set('off');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx7IBkCtYd6ulSfLfDL-aSF3rv6UfmWYxbSE823q36sPiQNVFFLatTFdGeUSnmJ4tUzlo&usqp=CAU',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black, BlendMode.dstATop),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'WELCOME',
                    style: GoogleFonts.indieFlower(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: turnOn,
            tooltip: 'Turn On',
            child: Icon(Icons.power_settings_new),
          ),
          SizedBox(height: 16.0),
          FloatingActionButton(
            onPressed: turnOff,
            tooltip: 'Turn Off',
            child: Icon(Icons.power_settings_new),
          ),
          SizedBox(height: 16.0),
          FloatingActionButton(
            onPressed: disconnect,
            tooltip: 'Sign Out',
            child: Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
