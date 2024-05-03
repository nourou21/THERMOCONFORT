import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

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
}

class _parametterState extends State<parametter> {
  static int readTemp = 2;
  static bool isweatherVisible = false;
  static bool isweatherpressed = false;

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
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Change Background Color'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Change Thermostat Name'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Toggle Notifications'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Toggle Dark Mode'),
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
                  // Do not set isweatherVisible to true here
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
                  // Do not set isweatherVisible to true here
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

    // If GPS is enabled and location permission is granted,
    // set isweatherVisible to true to change the button color to green
    setState(() {
      isweatherVisible = true;
    });

    // Request location and fetch weather information
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
