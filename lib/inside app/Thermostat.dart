import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_application_2/inside%20app/graph.dart';
import 'package:flutter_application_2/inside%20app/paramettre.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather_icons/weather_icons.dart';

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
  String thermostatName = 'Thermoconfort';
  int readTemp = 0;
  int temperature = 0;
  bool isweatherpressed = parametter.weatherpressed();
  int realWeather = parametter.getReadTemp();
  bool handButtonPressed = false;
  bool isDarkMode = false;

  Color backgroundColor = Colors.white;

  final databaseReference = FirebaseDatabase.instance.reference();

  late StreamSubscription temperatureSubscription;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    temperatureSubscription.cancel();
    super.dispose();
  }

  void listenToTemperatureChanges() {
    databaseReference.child('project/read_temp').onValue.listen((event) {
      final dynamic value = event.snapshot.value;
      if (value is double || value is int) {
        setState(() {
          readTemp = value.toInt();
        });
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
    databaseReference.child('project/temperature').set(temperature);
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
                            width: isweatherpressed
                                ? 170
                                : 0, // Set width to 0 if isweatherpressed is false
                          ),
                          if (isweatherpressed == true) ...[
                            Icon(
                              // Choose weather icon based on temperature
                              realWeather >= 25
                                  ? WeatherIcons.day_sunny
                                  : realWeather >= 15
                                      ? WeatherIcons.day_cloudy
                                      : WeatherIcons.cloud,
                              size: 50,
                              color: Colors.orange,
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Text(
                              'Its : $realWeather°C',
                              style: GoogleFonts.lato(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
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
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Visibility(
                        visible: isToggleVisible,
                        child: ToggleSwitch(
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
                      ),
                      SizedBox(height: 20.0),
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
                        '$temperature°C',
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
                      Text(
                        '$readTemp°C',
                        style: TextStyle(
                          fontSize: 35.0,
                          color: _getColorForTemperature(readTemp),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 250,
                          ),
                          Stack(
                            children: [
                              Image.asset(
                                'assets/phone.png', // Second image
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
}

Color _getColorForTemperature(int temp) {
  if (temp > 40) {
    return Colors.red; // Hot
  } else if (temp <= 5) {
    return Colors.blue; // Cold
  } else {
    return Colors.black; // Normal
  }
}
