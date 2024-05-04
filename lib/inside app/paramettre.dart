import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:toggle_switch/toggle_switch.dart';

class parametter extends StatefulWidget {
  const parametter({Key? key}) : super(key: key);

  @override
  State<parametter> createState() => _parametterState();

  static int getReadTemp() {
    return _parametterState.readTemp;
  }

  static bool weatherpressed() {
    return _parametterState.isweatherpressed;
  }

  static bool isiswWathervisible() {
    return _parametterState.isweatherVisible;
  }

  static String getThermostatName() {
    return _parametterState.thermostatName;
  }

  static bool getDarkMode() {
    return _parametterState.is_dark_mode;
  }
}

class _parametterState extends State<parametter> {
  static int readTemp = 2;
  static bool isweatherVisible = false;
  static bool isweatherpressed = false;
  static String thermostatName = "Thermostat";
  static bool is_dark_mode = false;

  @override
  void initState() {
    super.initState();
    requestLocationAndFetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: is_dark_mode ? Colors.grey.shade900 : Colors.white,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Change Background Color'),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    _showChangeNameDialog(context);
                  },
                  child: const Text('Change Thermostat Name'),
                ),
                SizedBox(
                  height: 20,
                ),
                ToggleSwitch(
                  minWidth: 120.0,
                  cornerRadius: 20.0,
                  initialLabelIndex: is_dark_mode ? 0 : 1,
                  inactiveBgColor: Colors.grey[800]!,
                  activeFgColor: Colors.white,
                  inactiveFgColor: Colors.white,
                  labels: ['moon', 'sun'],
                  icons: [
                    Icons.nightlight_round,
                    Icons.wb_sunny,
                  ],
                  onToggle: (index) {
                    setState(() {
                      is_dark_mode = index == 0;
                      if (is_dark_mode) {
                        // Define your dark theme
                        var darkTheme = ThemeData.dark().copyWith(
                          // Define your dark theme properties here
                          scaffoldBackgroundColor: Colors.black,
                          // Example: Change background color to black
                          // You can customize other properties as needed
                          elevatedButtonTheme: ElevatedButtonThemeData(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (states) {
                                  return Colors.grey[
                                      850]!; // Change button background color
                                },
                              ),
                              foregroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (states) {
                                  return Colors
                                      .white; // Change button text color
                                },
                              ),
                            ),
                          ),
                        );

                        // Apply dark theme to MaterialApp
                        MaterialApp(
                          theme: darkTheme,
                          home: parametter(),
                          // Add other MaterialApp properties as needed
                        );
                      } else {
                        // Restore to default theme (light mode)
                        MaterialApp(
                          theme:
                              ThemeData.light(), // Set to default light theme
                          home: parametter(),
                          // Add other MaterialApp properties as needed
                        );
                      }
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isweatherpressed = true;
                    });
                    await requestGPSActivation();
                  },
                  child: Text(
                    isweatherVisible
                        ? 'GPS Activated'
                        : 'Request GPS Activation',
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.resolveWith<Color>((states) {
                      if (isweatherVisible) {
                        return Colors.green;
                      } else {
                        return Colors.red;
                      }
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChangeNameDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Thermostat Name'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter new name'),
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
                String newName = controller.text;
                if (newName.isNotEmpty) {
                  setState(() {
                    thermostatName = newName;
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a name'),
                    ),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
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
                onPressed: () async {
                  Navigator.pop(context);
                  await Geolocator.openLocationSettings();
                },
                child: Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    isweatherVisible = false; // Turn off GPS activation button
                  });
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
                onPressed: () async {
                  Navigator.pop(context);
                  await Geolocator.openAppSettings();
                },
                child: Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    isweatherVisible = false; // Turn off GPS activation button
                  });
                },
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      isweatherVisible = true;
    });

    await requestLocationAndFetchWeather();
  }

  Future<void> requestLocationAndFetchWeather() async {
    if (!isweatherpressed) {
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
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    String address =
        placemarks.isNotEmpty ? placemarks[0].name ?? 'Unknown' : 'Unknown';
    print(address);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Weather Information'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Weather Temperature: $readTemp°C'),
              SizedBox(height: 10),
              Text('Location: $address'),
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

  Future<void> fetchWeatherInformation(Position position) async {
    String apiKey = '7a9509c1d4ae4acd92194014240305';
    String apiUrl =
        'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=${position.latitude},${position.longitude}';

    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      double temp = data['current']['temp_c'];
      setState(() {
        readTemp = temp.toInt();
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'Failed to fetch weather information. Please try again later.'),
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
}
