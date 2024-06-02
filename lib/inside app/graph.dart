import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class GraphPage extends StatefulWidget {
  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  final databaseReference = FirebaseDatabase.instance.reference();
  List<SalesData> ambientTemperatureData = [];
  List<SalesData> consigneTemperatureData = [];
  late List<StreamSubscription> temperatureSubscriptions;
  String currentMonth = 'Juin';

  @override
  void initState() {
    super.initState();
    temperatureSubscriptions = [];
    fetchTemperatureData();
  }

  @override
  void dispose() {
    for (var subscription in temperatureSubscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  void fetchTemperatureData() {
    List<String> days = List.generate(30, (index) => (index + 1).toString());

    for (String day in days) {
      StreamSubscription ambientSubscription = databaseReference
          .child('project/temperatures/$day/temperature_ambainte')
          .onValue
          .listen((event) {
        final dynamic value = event.snapshot.value;
        if (value != null) {
          setState(() {
            ambientTemperatureData.add(SalesData(day, value.toDouble()));
          });
        } else {
          print('Invalid data from the database for day $day');
        }
      });

      StreamSubscription consigneSubscription = databaseReference
          .child('project/temperatures/$day/temperature_consigne')
          .onValue
          .listen((event) {
        final dynamic value = event.snapshot.value;
        if (value != null) {
          setState(() {
            consigneTemperatureData.add(SalesData(day, value.toDouble()));
          });
        } else {
          print('Invalid data from the database for day $day');
        }
      });

      temperatureSubscriptions.add(ambientSubscription);
      temperatureSubscriptions.add(consigneSubscription);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    bool isDarkMode = false; // Replace with your dark mode condition

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 1),
                          Expanded(
                            child: DefaultTextStyle(
                              style: GoogleFonts.indieFlower(
                                textStyle: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black.withOpacity(0.5),
                                  fontWeight: FontWeight.w300,
                                  fontSize: 40,
                                ),
                              ),
                              child: AnimatedTextKit(
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    'Graph Page - $currentMonth',
                                    speed: Duration(milliseconds: 200),
                                  ),
                                ],
                                totalRepeatCount: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Combined chart with multiple series
                      SfCartesianChart(
                        primaryXAxis: CategoryAxis(
                          labelStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.white
                                : Colors
                                    .black, // Adjust color based on dark mode
                          ),
                        ),
                        primaryYAxis: NumericAxis(
                          labelStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.white
                                : Colors
                                    .black, // Adjust color based on dark mode
                          ),
                        ),
                        legend: Legend(
                          isVisible: true, // Show the legend
                          position: LegendPosition
                              .bottom, // Position the legend at the bottom
                        ),
                        series: [
                          // Ambient temperature line series
                          LineSeries<SalesData, String>(
                            dataSource: ambientTemperatureData,
                            xValueMapper: (SalesData data, _) => data.day,
                            yValueMapper: (SalesData data, _) =>
                                data.temperature,
                            name: 'Ambient Temperature',
                          ),
                          // Consigne temperature line series
                          LineSeries<SalesData, String>(
                            dataSource: consigneTemperatureData,
                            xValueMapper: (SalesData data, _) => data.day,
                            yValueMapper: (SalesData data, _) =>
                                data.temperature,
                            name: 'Consigne Temperature',
                            color: Colors.red, // Set the color to red
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

class SalesData {
  SalesData(this.day, this.temperature);
  final String day;
  final double temperature;
}
