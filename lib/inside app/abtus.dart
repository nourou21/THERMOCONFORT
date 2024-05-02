import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart'; // Import SystemServices

class Apropsdenous extends StatefulWidget {
  Apropsdenous({Key? key}) : super(key: key);

  @override
  _ApropsdenousState createState() => _ApropsdenousState();
}

class _ApropsdenousState extends State<Apropsdenous> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late ScrollController _scrollController;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    // Initialize the scroll controller and add a listener to detect scrolling
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    // Hide the system task bar initially
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    // Dispose of the scroll controller when not needed
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Check if the user is scrolling up or down
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      // User is scrolling down, hide the task bar
      if (!_isScrolling) {
        setState(() {
          _isScrolling = true;
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        });
      }
    } else {
      // User is scrolling up, show the task bar
      if (_isScrolling) {
        setState(() {
          _isScrolling = false;
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller:
            _scrollController, // Assign the scroll controller to the SingleChildScrollView
        child: Container(
          color: const Color.fromARGB(
              255, 194, 101, 210), // Change background color to purple
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Row(
                    children: [
                      SizedBox(width: 20),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "    Thermoconfort ",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 188, 145, 82),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                    ),
                    Center(
                      child: Text(
                        "Notre equipe :",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              _buildTeamMember(
                'anonymous',
                'assets/anonymous.jpg', // Change image path
                'https://www.linkedin.com',
                'https://www.facebook.com/',
                'mailto:@gmail.com',
              ),
              _buildTeamMember(
                'anonymous',
                'assets/assil.jpg', // Change image path
                'https://www.facebook.com//',
                'https://www.facebook.com',
                'mailto:',
              ),
              // Add more team members as needed
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMember(String name, String? imagePath, String linkedInUrl,
      String facebookUrl, String emailUrl) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        color: Colors.grey.shade800,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imagePath != null) // Show image if available
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ClipOval(
                    child: Image.asset(
                      imagePath,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Text(
                name,
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.linkedin),
                    onPressed: () {
                      _launchURL(linkedInUrl);
                    },
                    color: Colors.blue,
                  ),
                  IconButton(
                    icon: Icon(Icons.facebook),
                    onPressed: () {
                      _launchURL(facebookUrl);
                    },
                    color: Colors.blue,
                  ),
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.envelope),
                    onPressed: () {
                      _launchURL(emailUrl);
                    },
                    color: Colors.pink,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
