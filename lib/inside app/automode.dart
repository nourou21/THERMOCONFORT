import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/inside%20app/Thermostat.dart';
import 'package:flutter_application_2/inside%20app/paramettre.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather_icons/weather_icons.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

bool isToggleVisible = false;

class ModeAuto extends StatefulWidget {
  @override
  _ModeAutoState createState() => _ModeAutoState();
}

class _ModeAutoState extends State<ModeAuto>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;
  bool isRelay = true;
  bool showDelayButtons = false;
  int readTemp = 0;
  int temperature = 0;
  bool isDarkMode = parametter.getDarkMode();
  bool isWeatherVisible = false;
  bool isWeatherPressed = false;
  int realWeather = parametter.getReadTemp();

  bool handButtonPressed = false;
  bool daymode = true;
  bool isNightMode = false;
  bool isVacationMode = false; // Initialize vacation mode variable
  bool isShortDelaySelected = false;
  bool isLongDelaySelected = false;
  String thermoscctatNamez = "";
  String modeText = '';

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
    fetchInitialModeFromDatabase(); // Fetch initial mode settings

    // Set daymode to true initially and update database
    daymode = true;
    isNightMode = false; // Initialize night mode to false
    isVacationMode = false; // Initialize vacation mode to false
    sendAutomode(true);
    updateModeText(); // Call updateModeText here
  }

  @override
  void dispose() {
    _controller.dispose();
    temperatureSubscription.cancel();
    super.dispose();
  }

  void listenToTemperatureChanges() {
    databaseReference
        .child('project/temperature consigne')
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

  void sendTemperatureConsigneToDatabase(int temperature) {
    // Send the temperature consigne value to the database
    databaseReference.child('project/temperature consigne').set(temperature);
  }

  void sendDayModeToDatabase(bool isDayMode) {
    // Send the day mode value to the database
    databaseReference.child('project/_mode').set(isDayMode ? 'on' : 'off');
  }

  void sendNightModeToDatabase(bool isNightMode) {
    // Send the night mode value to the database
    databaseReference.child('project/_mode').set(isNightMode ? 'on' : 'off');
  }

  void sendVacationModeToDatabase(bool isVacationMode) {
    // Send the vacation mode value to the database
    databaseReference
        .child('project/vacation_mode')
        .set(isVacationMode ? 'on' : 'off');
    showDelayButtons = isVacationMode;
    updateModeText();
  }

  void long_mode(bool isLongDelaySelected) {
    databaseReference
        .child('project/long_mode')
        .set(isLongDelaySelected ? 'on' : 'off');
    showDelayButtons = isLongDelaySelected;
    updateModeText();
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

  void fetchInitialModeFromDatabase() {
    // Fetch initial mode settings from the database
    databaseReference
        .child('project/vacation_mode')
        .once()
        .then((DatabaseEvent event) {
      final value = event.snapshot.value;
      setState(() {
        isVacationMode = value == 'on'; // Update vacation mode state
      });
    });
  }

  void sendAutomode(bool isAutoMode) {
    databaseReference.child('project/_mode').once().then((DatabaseEvent event) {
      final value = event.snapshot.value;
      setState(() {
        daymode = value == 'on'; // Update vacation mode state
        updateModeText();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
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
                          Center(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 30,
                                ),
                                if (showDelayButtons)
                                  Row(
                                    children: [
                                      SizedBox(width: 65),
                                      // Short Delay Toggle Switch
                                      Column(
                                        children: [
                                          Text(
                                            'Short Mode',
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: isShortDelaySelected
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          FlutterSwitch(
                                            width: 55.0,
                                            height: 25.0,
                                            value: isShortDelaySelected,
                                            borderRadius: 30.0,
                                            padding: 2.0,
                                            showOnOff: false,
                                            activeToggleColor: Colors
                                                .blue, // Customize colors as needed
                                            inactiveToggleColor: Colors
                                                .grey, // Customize colors as needed
                                            onToggle: (value) {
                                              setState(() {
                                                isShortDelaySelected = value;
                                                if (value) {
                                                  isLongDelaySelected =
                                                      false; // Turn off long mode
                                                  // Update temperature consigne based on toggle state
                                                  sendTemperatureConsigneToDatabase(
                                                      15);
                                                } else {
                                                  // If short mode is turned off, set temperature consigne to default
                                                  sendTemperatureConsigneToDatabase(
                                                      19);
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 30,
                                      ),

                                      // Long Mode Toggle Switch
                                      Column(
                                        children: [
                                          Text(
                                            'Long Mode',
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: isLongDelaySelected
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          FlutterSwitch(
                                            width: 55.0,
                                            height: 25.0,
                                            value: isLongDelaySelected,
                                            borderRadius: 30.0,
                                            padding: 2.0,
                                            showOnOff: false,
                                            activeToggleColor: Colors
                                                .blue, // Customize colors as needed
                                            inactiveToggleColor: Colors
                                                .grey, // Customize colors as needed
                                            onToggle: (value) {
                                              setState(() {
                                                isLongDelaySelected = value;
                                                if (value) {
                                                  isShortDelaySelected =
                                                      false; // Turn off short mode
                                                  // Update temperature consigne based on toggle state
                                                  sendTemperatureConsigneToDatabase(
                                                      8);
                                                  long_mode(true);
                                                } else {
                                                  // If long mode is turned off, set temperature consigne to default
                                                  sendTemperatureConsigneToDatabase(
                                                      19);
                                                  long_mode(false);
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: isWeatherPressed ? 230 : 0,
                              ),
                              Column(
                                children: [
                                  Visibility(
                                    visible: isWeatherVisible,
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
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 500),
                        child: Text(
                          modeText,
                          key: ValueKey<String>(modeText),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
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
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DefaultTextStyle(
                            style: TextStyle(
                              color: _animation.value,
                            ),
                            child: SizedBox(
                              height: 40.0,
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
                      Row(
                        children: [
                          SizedBox(
                            width: 300,
                          ),
                        ],
                      ),
                      if (isNightMode && !isVacationMode)
                        Column(
                          children: [
                            SizedBox(
                              height: 40,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 280,
                                ),
                              ],
                            ),
                          ],
                        ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          if ((!daymode || !isVacationMode) && isNightMode) ...[
                            Row(
                              children: [
                                SizedBox(width: 320),
                                Image.asset(
                                  'assets/zzz.png',
                                  width: 45,
                                  height: 60,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: 70,
                                ),
                                Row(
                                  children: [
                                    SizedBox(width: 205),
                                    Text(
                                      '$readTemp°C',
                                      style: TextStyle(
                                        fontSize: 50.0,
                                        color: Colors.grey.shade700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(height: 80),
                                FaIcon(
                                  FontAwesomeIcons.solidMoon,
                                  size: 180.0,
                                  color: isDarkMode
                                      ? Colors.grey
                                      : Colors.grey.shade700,
                                ),
                              ],
                            ),
                          ] else ...[
                            Column(
                              children: [
                                SizedBox(
                                  height: 70,
                                ),
                                Row(
                                  children: [
                                    SizedBox(width: 136),
                                    Text(
                                      '$readTemp°C',
                                      style: TextStyle(
                                        fontSize: 50.0,
                                        color: Colors.grey.shade700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(width: 130),
                          Stack(
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Image.asset(
                                    "assets/phone_dark.png",
                                    width: 100,
                                    height: 100,
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 50,
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
                      SizedBox(
                        height: 35,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 160,
                            height: 90,
                            child: ElevatedButton(
                              child: Text('Night Mode',
                                  style: TextStyle(fontSize: 18)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: !handButtonPressed
                                    ? Colors.green
                                    : Colors.grey,
                                padding: EdgeInsets.symmetric(vertical: 10),
                              ),
                              onPressed: () {
                                setState(() {
                                  handButtonPressed = false;
                                  isNightMode = true;
                                  isVacationMode = false;
                                  daymode = false; // Deactivate AUTO mode
                                });
                                sendVacationModeToDatabase(handButtonPressed);
                                sendTemperatureConsigneToDatabase(16);
                              },
                            ),
                          ),
                          SizedBox(width: 20),
                          SizedBox(
                            width: 160,
                            height: 90,
                            child: ElevatedButton(
                              child: Text('Vacation Mode',
                                  style: TextStyle(fontSize: 18)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: handButtonPressed
                                    ? Colors.green
                                    : Colors.grey,
                                padding: EdgeInsets.symmetric(vertical: 10),
                              ),
                              onPressed: () {
                                setState(() {
                                  handButtonPressed = !handButtonPressed;
                                  isNightMode = false;
                                  isVacationMode = handButtonPressed;
                                  daymode = false; // Deactivate AUTO mode
                                });
                                sendVacationModeToDatabase(handButtonPressed);
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: 160,
                        height: 90,
                        child: ElevatedButton(
                          child: Text(
                            'Day Mode',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                daymode ? Colors.green : Colors.grey,
                            padding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () {
                            setState(() {
                              daymode = true; // Activate day mode
                              isNightMode = false; // Turn off night mode
                              isVacationMode = false; // Turn off vacation mode
                            });
                            sendDayModeToDatabase(daymode); // Update database
                            sendTemperatureConsigneToDatabase(
                                19); // Set temperature consigne to 19
                          },
                        ),
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

  void updateModeText() {
    setState(() {
      if (isVacationMode) {
        modeText = 'Vacation Mode';
      } else if (isLongDelaySelected) {
        modeText = 'Long Mode';
      } else if (isShortDelaySelected) {
        modeText = 'Short Mode';
      } else if (isNightMode) {
        modeText = 'Night Mode';
      } else {
        modeText = ''; // Default text when no mode is selected
      }
    });
  }
}
