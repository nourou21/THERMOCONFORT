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
}

class _SliderPageState extends State<SliderPage> {
  int _currentIndex = 0;

  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  Container(child: GraphPage()),
                  Container(child: ThermostatPage()),
                  Container(
                    child: Container(child: parametter()),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageIndicator(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 500),
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
                'assets/GRAPHE.png',
                width: 36,
                height: 36,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () {
                _pageController.jumpToPage(1);
                setState(() {
                  isToggleVisible = !isToggleVisible; // Toggle the visibility
                });
              },
              icon: Icon(
                MdiIcons.thumbsUpDownOutline,
                size: 30,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () {
                _pageController.jumpToPage(2);
              },
              icon: Icon(
                Icons.settings_suggest_outlined,
                size: 40,
              ),
            ),
            label: '',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    return List.generate(
      3,
      (index) => _indicator(index == _currentIndex),
    );
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.purple : Colors.brown,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
