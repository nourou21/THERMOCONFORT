import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/inside%20app/paramettre.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GraphPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    bool is_dark_mode = parametter.getDarkMode();

    // Sample data for the first series
    List<SalesData> chartData1 = [
      SalesData('Jan', 37),
      SalesData('Feb', 28),
      SalesData('Mar', 34),
      SalesData('Apr', 32),
      SalesData('May', 40),
      SalesData('Jun', 45),
    ];

    // Sample data for the second series
    List<SalesData> chartData2 = [
      SalesData('Jan', 20),
      SalesData('Feb', 30),
      SalesData('Mar', 25),
      SalesData('Apr', 40),
      SalesData('May', 35),
      SalesData('Jun', 45),
    ];

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: is_dark_mode ? Colors.grey.shade900 : Colors.white,
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
                                  color: is_dark_mode
                                      ? Colors.white
                                      : Colors.black.withOpacity(0.5),
                                  fontWeight: FontWeight.w300,
                                  fontSize: 40,
                                ),
                              ),
                              child: AnimatedTextKit(
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    'Graph page',
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
                            color: is_dark_mode
                                ? Colors.white
                                : Colors
                                    .black, // Adjust color based on dark mode
                          ),
                        ),
                        primaryYAxis: NumericAxis(
                          labelStyle: TextStyle(
                            color: is_dark_mode
                                ? Colors.white
                                : Colors
                                    .black, // Adjust color based on dark mode
                          ),
                        ),
                        series: [
                          // First line series
                          LineSeries<SalesData, String>(
                            dataSource: chartData1,
                            xValueMapper: (SalesData sales, _) => sales.year,
                            yValueMapper: (SalesData sales, _) => sales.sales,
                          ),
                          // Second line series in red
                          LineSeries<SalesData, String>(
                            dataSource: chartData2,
                            xValueMapper: (SalesData sales, _) => sales.year,
                            yValueMapper: (SalesData sales, _) => sales.sales,
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
  SalesData(this.year, this.sales);
  final String year;
  final double sales;
}
