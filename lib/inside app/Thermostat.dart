import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_application_2/inside%20app/automode.dart';
import 'package:flutter_application_2/inside%20app/graph.dart';
import 'package:flutter_application_2/inside%20app/paramettre.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather_icons/weather_icons.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

bool isToggleVisible = false;

class ThermostatPage extends StatefulWidget {
  @override
  _ThermostatPageState createState() => _ThermostatPageState();
}

class _ThermostatPageState extends State<ThermostatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;
  bool isrelay = true;

  int readTemp = 0;
  int temperature = 0;
  bool isweatherVisible = parametter.isiswWathervisible();
  bool isweatherpressed = parametter.weatherpressed();
  int realWeather = parametter.getReadTemp();
  bool handButtonPressed = false;
  bool is_dark_mode = parametter.getDarkMode();

  String thermoscctatNamez = parametter.getThermostatName();

  Color backgroundColor = Colors.white;

  final databaseReference = FirebaseDatabase.instance.reference();

  late StreamSubscription temperatureSubscription;
  //change mode
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
          showEmergencyNotification();
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
          isrelay = true;
        });
      } else {
        // If relay is off, hide the fire image
        setState(() {
          isrelay = false;
        });
      }
    });
  }

  void sendTemperatureToDatabase(int temperature) {
    databaseReference.child('project/temperature consigne').set(temperature);
  }

  void listenToTemperatureConsigne() {
    databaseReference
        .child('project/temperature consigne')
        .onValue
        .listen((event) {
      final dynamic value = event.snapshot.value;
      if (value is double || value is int) {
        setState(() {
          temperature = value.toInt();
        });
      } else {
        print('Invalid temperature value from the database');
      }
    });
  }

  void sendVacationModeToDatabase(bool isVacationMode) {
    databaseReference.child('project/vacation_mode').set(isVacationMode);
  }

  void incrementTemperature() {
    setState(() {
      temperature += 1;
      sendTemperatureToDatabase(temperature);
    });
  }

  void decrementTemperature() {
    setState(() {
      temperature -= 1;
      sendTemperatureToDatabase(temperature);
    });
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

  Future<void> fetchWeatherInformation(Position position) async {
    String weatherApiKey = '7a9509c1d4ae4acd92194014240305';
    String apiUrl =
        'http://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$weatherApiKey';

    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      double temp = data['main']['temp'];
      setState(() {
        readTemp = (temp - 273.15).toInt();
      });
    }
  }

  Future<void> requestGPSActivation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
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

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Location Permission'),
            content: Text(
                'This app requires access to your location. Please grant permission in settings.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Geolocator.openAppSettings();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      displayLocationInformation(position);
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Error fetching location: $e'),
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
              Text('Weather Temperature: ${readTemp.toStringAsFixed(2)}°C'),
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
    Color backgroundColor =
        is_dark_mode ? darkBackgroundColor : lightBackgroundColor;
    Color textColor = is_dark_mode ? darkTextColor : lightTextColor;
    Color iconColor = is_dark_mode ? darkIconColor : lightIconColor;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  alignment: Alignment.center,
                  color: backgroundColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: isweatherpressed ? 230 : 0,
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
                                  color: iconColor, // Use chosen icon color
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Its : $realWeather°C',
                                  style: GoogleFonts.lato(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: textColor, // Use chosen text color
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DefaultTextStyle(
                            style: TextStyle(
                              color: _animation.value,
                            ),
                            child: SizedBox(
                              height: 80.0,
                              child: TyperAnimatedTextKit(
                                text: [thermoscctatNamez],
                                textStyle: GoogleFonts.lato(
                                  // Using Lato font as an example
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
                      Visibility(
                        visible: isToggleVisible,
                        child: ToggleSwitch(
                          minWidth: 90.0,
                          cornerRadius: 20.0,
                          activeFgColor: Colors.white,
                          inactiveBgColor: Colors.grey,
                          inactiveFgColor: Colors.white,
                          labels: [
                            'AUTO\nMode', // Add line break here
                            'MANUAL\nMode' // Add line break here
                          ],
                          initialLabelIndex: handButtonPressed ? 0 : 1,
                          onToggle: (index) {
                            setState(() {
                              handButtonPressed = index == 0;
                              if (handButtonPressed) {
                                // Navigate to auto mode page if index is 0 (AUTO mode)
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => modeauto()),
                                );
                              }
                            });

                            sendVacationModeToDatabase(handButtonPressed);
                          },
                        ),
                      ),
                      SizedBox(height: 20.0),
                      GestureDetector(
                        onTap: incrementTemperature,
                        child: Image.asset(
                          'assets/UP.png',
                          width: 100.0,
                          height: 100.0,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        '$temperature°C',
                        style: TextStyle(
                          fontSize: 50.0,
                          color: Color(0xFFB97A57),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.0),
                      GestureDetector(
                        onTap: decrementTemperature,
                        child: Image.asset(
                          'assets/DOWN.png',
                          width: 100.0,
                          height: 100.0,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Column(
                        children: [],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 80,
                          ),
                          Text(
                            '$readTemp°C',
                            style: TextStyle(
                              fontSize: 35.0,
                              color: _getColorForTemperature(readTemp),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            width: 60,
                          ),
                          Stack(
                            children: [
                              Image.asset(
                                'assets/phone_dark.png',
                                width: 100,
                                height: 100,
                              ),
                              Positioned(
                                top: 20, // Adjust the position as needed
                                left: 30, // Adjust the position as needed
                                child: isrelay
                                    ? Image.asset(
                                        'assets/fire.png', // First image
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

  // Method to display an emergency notification
  void showEmergencyNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'emergency_channel',
        title: 'Emergency!',
        body: 'Temperature has reached -5°C. Close the windows or the door.',
      ),
    );
  }
}
