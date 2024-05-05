import 'package:flutter/material.dart';
import 'package:flutter_application_2/inside%20app/Thermostat.dart';
import 'package:flutter_application_2/inside%20app/graph.dart';
import 'package:flutter_application_2/inside%20app/paramettre.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:iconly/iconly.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SliderPage extends StatefulWidget {
  const SliderPage({Key? key}) : super(key: key);

  @override
  _SliderPageState createState() => _SliderPageState();

  // Static method to access _pageController from outside
  static PageController getPageController() {
    return _SliderPageState._pageController;
  }
}

class _SliderPageState extends State<SliderPage> {
  int _currentIndex = 0;

  // Declaring _pageController as static
  static late PageController _pageController;

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
    bool is_dark_mode =
        parametter.getDarkMode(); // Retrieve dark mode state here

    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                // Allow scrolling
                physics: AlwaysScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  Container(child: GraphPage()),
                  Container(child: ThermostatPage()),
                  Container(child: parametter()),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: is_dark_mode ? Colors.grey : Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 100),
              curve: Curves.ease,
            );

            // Toggle the visibility of the toggle switch when the specific icon is tapped
            if (index == 1) {
              // Here you can add your logic to toggle visibility
            }
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () {
                _pageController.jumpToPage(0);
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
              padding:
                  EdgeInsets.symmetric(vertical: 1), // Adjust vertical padding
              child: IconButton(
                onPressed: () {
                  _pageController.jumpToPage(1);
                  setState(() {
                    isToggleVisible = !isToggleVisible; // Toggle the visibility
                  });
                },
                icon: Icon(
                  MdiIcons.thumbsUpDownOutline,
                  size: 30, // Reduce the icon size
                ),
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding:
                  EdgeInsets.symmetric(vertical: 6), // Adjust vertical padding
              child: IconButton(
                onPressed: () {
                  _pageController.jumpToPage(2);
                },
                icon: Icon(
                  Icons.settings_suggest_outlined,
                  size: 36, // Adjust the icon size
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
