import 'package:flutter/material.dart';
import 'package:flutter_application_2/inside%20app/Thermostat.dart';
import 'package:flutter_application_2/inside%20app/automode.dart';
import 'package:flutter_application_2/inside%20app/graph.dart';
import 'package:flutter_application_2/inside%20app/paramettre.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SliderPage extends StatefulWidget {
  const SliderPage({Key? key}) : super(key: key);

  @override
  _SliderPageState createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  int _currentIndex = 0;
  int _thermostatTapCount = 0; // Track the number of taps on Thermostat icon
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = parametter.getDarkMode(); // Retrieve dark mode state here

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(), // Block scrolling
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                ThermostatPage(),
                GraphPage(),
                parametter(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDarkMode ? Colors.grey : Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 100),
              curve: Curves.ease,
            );
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () {
                _pageController.jumpToPage(1);
              },
              icon: Image.asset(
                'assets/graphdark.png',
                width: 36,
                height: 36,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 1),
              child: IconButton(
                onPressed: () {
                  _thermostatTapCount++; // Increment tap count
                  if (_thermostatTapCount == 2) {
                    _thermostatTapCount = 0; // Reset tap count
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModeAuto(),
                      ),
                    );
                  } else {
                    _pageController.jumpToPage(0);
                  }
                },
                icon: Icon(
                  MdiIcons.thumbsUpDownOutline,
                  size: 30,
                ),
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: IconButton(
                onPressed: () {
                  _pageController.jumpToPage(2);
                },
                icon: Icon(
                  Icons.settings_suggest_outlined,
                  size: 36,
                ),
              ),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
