import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_application_2/inside%20app/Thermostat.dart';
import 'package:flutter_application_2/inside%20app/paramettre.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather_icons/weather_icons.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

bool isToggleVisible = false;

class modeauto extends StatefulWidget {
  @override
  _modeautoState createState() => _modeautoState();
}

class _modeautoState extends State<modeauto>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;
  bool isRelay = true;

  int readTemp = 0;
  int temperature = 0;
  bool isDarkMode = parametter.getDarkMode();
  bool isWeatherVisible = false;
  bool isWeatherPressed = false;
  int realWeather = parametter.getReadTemp();
  bool isweatherVisible = parametter.isiswWathervisible();
  bool handButtonPressed = false;

  String thermoscctatNamez = "";
  bool isweatherpressed = parametter.weatherpressed();

  Color backgroundColor = Colors.white;

  final databaseReference = FirebaseDatabase.instance.reference();

  late StreamSubscription temperatureSubscription;
  //color for

  // Define colors for light mode
  Color lightBackgroundColor = Colors.white;
  Color lightTextColor = Colors.black;
  Color lightIconColor = Colors.orange;
  // Define colors for dark mode
  Color darkBackgroundColor = Colors.grey.shade900;
  Color darkTextColor = Colors.white;
  Color darkIconColor = Colors.orange;

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
    listenToTemperatureChanges();
    listenToTemperatureConsigne();
    fetchWeatherData(); // Fetch weather data on init
  }

  @override
  void dispose() {
    _controller.dispose();
    temperatureSubscription.cancel();
    super.dispose();
  }

  void listenToTemperatureChanges() {
    databaseReference
        .child('project/temperature ambainte')
        .onValue
        .listen((event) {
      final dynamic value = event.snapshot.value;
      if (value is double || value is int) {
        setState(() {
          readTemp = value.toInt();
        });

        // Check if temperature is -5°C
        if (readTemp == -5) {
          // Display emergency notification
        }
      } else {
        print('Invalid temperature value from the database');
      }
    });

    // Listen to changes in relay status
    databaseReference.child('project/relay').onValue.listen((event) {
      final dynamic value = event.snapshot.value;
      if (value == 'on') {
        // If relay is on, show the fire image
        setState(() {
          isRelay = true;
        });
      } else {
        // If relay is off, hide the fire image
        setState(() {
          isRelay = false;
        });
      }
    });
  }

  void listenToTemperatureConsigne() {
    // Your existing code to listen to temperature consigne
  }

  void fetchWeatherData() async {
    // Fetch weather data from API
    final response = await http.get(Uri.parse('API_ENDPOINT_HERE'));
    if (response.statusCode == 200) {
      final weatherData = json.decode(response.body);
      setState(() {
        realWeather = weatherData['main']['temp']; // Update weather data
        isWeatherVisible = true; // Show weather
      });
    } else {
      print('Failed to fetch weather data');
    }
  }

  void sendVacationModeToDatabase(bool isVacationMode) {
    // Send the vacation mode value to the database
    databaseReference
        .child('project/vacation_mode')
        .set(isVacationMode ? 'on' : 'off');
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor =
        isDarkMode ? darkBackgroundColor : lightBackgroundColor;
    Color textColor = isDarkMode ? darkTextColor : lightTextColor;
    Color iconColor = isDarkMode ? darkIconColor : lightIconColor;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  height: MediaQuery.of(context).size.height,
                  alignment: Alignment.center,
                  color: backgroundColor,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: isweatherpressed ? 230 : 0,
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    height: 80,
                                  ),
                                  Visibility(
                                    visible: isweatherVisible,
                                    child: Column(
                                      children: [
                                        Icon(
                                          // Choose weather icon based on temperature
                                          realWeather >= 25
                                              ? WeatherIcons.day_sunny
                                              : realWeather >= 15
                                                  ? WeatherIcons.day_cloudy
                                                  : WeatherIcons.cloud,
                                          size: 50,
                                          color:
                                              iconColor, // Use chosen icon color
                                        ),
                                        Text(
                                          'Its : $realWeather°C',
                                          style: GoogleFonts.lato(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                textColor, // Use chosen text color
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 1),
                      Visibility(
                        visible: isWeatherVisible, // Show weather if visible
                        child: Column(
                          children: [
                            Icon(
                              // Choose weather icon based on temperature
                              realWeather >= 25
                                  ? WeatherIcons.day_sunny
                                  : realWeather >= 15
                                      ? WeatherIcons.day_cloudy
                                      : WeatherIcons.cloud,
                              size: 50,
                              color: iconColor, // Use chosen icon color
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              'It\'s : $realWeather°C',
                              style: GoogleFonts.lato(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: textColor, // Use chosen text color
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DefaultTextStyle(
                            style: TextStyle(
                              color: _animation.value,
                            ),
                            child: SizedBox(
                              height: 120.0,
                              child: TyperAnimatedTextKit(
                                text: [thermoscctatNamez],
                                textStyle: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 145, 87, 1),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40,
                                  ),
                                ),
                                textAlign: TextAlign.start,
                                isRepeatingAnimation: false,
                                speed: Duration(milliseconds: 200),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.0),
                      Visibility(
                        visible: isToggleVisible,
                        child: ToggleSwitch(
                          minWidth: 90.0,
                          cornerRadius: 20.0,
                          activeFgColor: Colors.white,
                          inactiveBgColor: Colors.grey,
                          inactiveFgColor: Colors.white,
                          labels: ['AUTO\nMode', 'MANUAL\nMode'],
                          initialLabelIndex: handButtonPressed ? 0 : 1,
                          onToggle: (index) {
                            setState(() {
                              handButtonPressed = index == 0;
                              if (handButtonPressed) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ThermostatPage()),
                                );
                              }
                            });

                            sendVacationModeToDatabase(handButtonPressed);
                          },
                        ),
                      ),
                      SizedBox(height: 40.0),
                      Text(
                        '$readTemp°C',
                        style: TextStyle(
                          fontSize: 35.0,
                          color: _getColorForTemperature(readTemp),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            child: Text('Night Mode'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !handButtonPressed
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                handButtonPressed =
                                    false; // Turn off vacation mode
                              });
                              sendVacationModeToDatabase(handButtonPressed);
                            },
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            child: Text('Vacation Mode'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: handButtonPressed
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                handButtonPressed = !handButtonPressed;
                                isDarkMode = false; // Turn off night mode
                              });

                              sendVacationModeToDatabase(handButtonPressed);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 130.0),
                      Row(
                        children: [
                          SizedBox(width: 270),
                          Stack(
                            children: [
                              Image.asset(
                                "assets/phone_dark.png",
                                width: 100,
                                height: 100,
                              ),
                              Positioned(
                                top: 20,
                                left: 30,
                                child: isRelay
                                    ? Image.asset(
                                        'assets/fire.png',
                                        width: 40,
                                        height: 40,
                                      )
                                    : SizedBox(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getColorForTemperature(int temp) {
    if (temp > 40) {
      return Colors.red; // Hot
    } else if (temp <= 5) {
      return Colors.blue; // Cold
    } else {
      return Color.fromRGBO(184, 122, 90, 1.0);
    }
  }
}
