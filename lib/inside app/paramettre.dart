import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class parametter extends StatefulWidget {
  const parametter({Key? key}) : super(key: key);

  @override
  State<parametter> createState() => _parametterState();
}

class _parametterState extends State<parametter> {
  int readTemp = 2;

  @override
  void initState() {
    super.initState();
    // Fetch weather information when the widget is initialized
    requestLocationAndFetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Block back button press
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
                  onPressed: () async => await requestGPSActivation(),
                  child: const Text("Request GPS Activation"),
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
      // Show popup to enable GPS
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
                  // Open location settings to enable GPS
                  await Geolocator.openLocationSettings();
                  // Request location after settings are enabled
                  await requestLocationAndFetchWeather();
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
                onPressed: () async {
                  Navigator.pop(context);
                  // Open app settings to grant location permission
                  await Geolocator.openAppSettings();
                  // Request location after permission is granted
                  await requestLocationAndFetchWeather();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // If location permission is granted, request location and fetch weather
    await requestLocationAndFetchWeather();
  }

  Future<void> requestLocationAndFetchWeather() async {
    // Request location
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      // Display location information
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
    // Fetch weather information using the obtained position
    await fetchWeatherInformation(position);
    // Get the address details using Geolocator
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    String address =
        placemarks.isNotEmpty ? placemarks[0].name ?? 'Unknown' : 'Unknown';
    print(address);

    // Display weather and location information in a popup
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
    // Fetch weather data using position
    String apiKey = '7a9509c1d4ae4acd92194014240305';
    String apiUrl =
        'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=${position.latitude},${position.longitude}';

    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      double temp = data['current']['temp_c']; // Temperature in Celsius
      setState(() {
        readTemp = temp.toInt();
      });
    } else {
      // If API call fails, show an error message
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
