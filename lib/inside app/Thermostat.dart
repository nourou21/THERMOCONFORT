import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_application_2/inside%20app/graph.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class ThermostatPage extends StatefulWidget {
  @override
  _ThermostatPageState createState() => _ThermostatPageState();
}

class _ThermostatPageState extends State<ThermostatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  String thermostatName = 'Thermoconfort';
  double temperature = 20.0; // Weather temperature variable
  bool handButtonPressed = false;
  bool isDarkMode = false;
  Color backgroundColor = Colors.white;

  final databaseReference = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _animation = ColorTween(
      begin: Colors.black,
      end: Colors.blue,
    ).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void sendVacationModeToDatabase(bool isVacationMode) {
    databaseReference.child('project/vacation_mode').set(isVacationMode);
  }

  void incrementTemperature() {
    setState(() {
      temperature += 1.0;
    });
  }

  void decrementTemperature() {
    setState(() {
      temperature -= 1.0;
    });
  }

  void openGraphPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GraphPage()),
    );
  }

  void changeThermostatName() async {
    final TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Thermostat Name'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'New Name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  thermostatName = controller.text;
                });
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void changeBackgroundColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Background Color'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
      backgroundColor = isDarkMode ? Colors.black : Colors.white;
    });
  }

  Future<void> fetchWeatherInformation(Position position) async {
    // Fetch weather data using position
    String weatherApiKey = 'your_weather_api_key';
    String apiUrl =
        'http://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$weatherApiKey';

    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      double temp = data['main']['temp'];
      setState(() {
        temperature =
            temp - 273.15; // Convert temperature from Kelvin to Celsius
      });
    }
  }

  Future<void> requestGPSActivation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Show popup to enable GPS
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('GPS Activation'),
            content: Text('GPS is disabled. Do you want to enable it?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Open location settings to enable GPS
                  Geolocator.openLocationSettings();
                },
                child: Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('No'),
              ),
            ],
          );
        },
      );
      return;
    }

    // If GPS is enabled, show location information
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    displayLocationInformation(position);
  }

  void displayLocationInformation(Position position) async {
    await fetchWeatherInformation(position);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Latitude: ${position.latitude}'),
              Text('Longitude: ${position.longitude}'),
              Text('Weather Temperature: ${temperature.toStringAsFixed(2)}°C'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
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
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 70,
            ),
            Row(
              children: [
                SizedBox(
                  width: 70,
                ),
                DefaultTextStyle(
                  style: TextStyle(
                    color: _animation.value,
                  ),
                  child: SizedBox(
                    height: 120.0,
                    child: TyperAnimatedTextKit(
                      text: [thermostatName],
                      textStyle: GoogleFonts.indieFlower(
                        textStyle: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontWeight: FontWeight.w300,
                          fontSize: 40,
                        ),
                      ),
                      textAlign: TextAlign.start,
                      isRepeatingAnimation: false,
                      speed: Duration(milliseconds: 200),
                    ),
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 30,
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Settings'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: changeBackgroundColor,
                                  child: Text('Change Background Color'),
                                ),
                                ElevatedButton(
                                  onPressed: changeThermostatName,
                                  child: Text('Change Thermostat Name'),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Toggle Notifications',
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: toggleDarkMode,
                                  child: Text('Toggle Dark Mode'),
                                ),
                                ElevatedButton(
                                  onPressed: () async =>
                                      await requestGPSActivation(),
                                  child: Text("Request GPS Activation"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/PARA.png',
                        width: 30.0,
                        height: 30.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 100,
                ),
                ToggleSwitch(
                  minWidth: 90.0,
                  cornerRadius: 20.0,
                  activeFgColor: Colors.white,
                  inactiveBgColor: Colors.grey,
                  inactiveFgColor: Colors.white,
                  labels: [
                    'Vacation\nMode', // Add line break here
                    'Night\nMode' // Add line break here
                  ],
                  initialLabelIndex: handButtonPressed ? 0 : 1,
                  onToggle: (index) {
                    setState(() {
                      handButtonPressed = index == 0;
                    });
                    sendVacationModeToDatabase(handButtonPressed);
                  },
                ),
              ],
            ),
            SizedBox(height: 40.0),
            GestureDetector(
              onTap: incrementTemperature,
              child: Image.asset(
                'assets/UP.png',
                width: 65.0,
                height: 65.0,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              '$temperature°C', // Display weather temperature
              style: TextStyle(
                fontSize: 35.0,
                color: Color(0xFFB97A57),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            GestureDetector(
              onTap: decrementTemperature,
              child: Image.asset(
                'assets/DOWN.png',
                width: 65.0,
                height: 65.0,
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: openGraphPage,
                  child: Image.asset(
                    'assets/GRAPHE.png',
                    width: 48.0,
                    height: 48.0,
                  ),
                ),
                SizedBox(width: 16.0),
                SizedBox(width: 16.0),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
