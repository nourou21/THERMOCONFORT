import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

int readTemp = 2;

class parametter extends StatefulWidget {
  const parametter({Key? key}) : super(key: key);

  @override
  State<parametter> createState() => _parametterState();
}

class _parametterState extends State<parametter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              onPressed: () async => await requestGPSActivation(),
              child: const Text("Request GPS Activation"),
            ),
          ],
        ),
      ),
    );
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

    // If GPS is enabled, request location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Show popup to request location permission
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
                  // Open app settings to grant location permission
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

    // If location permission is granted, show location information
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      displayLocationInformation(position);
    } catch (e) {
      // Show error popup
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
        readTemp = (temp - 273.15)
            as int; // Convert temperature from Kelvin to Celsius and assign to readTemp
      });
    }
  }
}
