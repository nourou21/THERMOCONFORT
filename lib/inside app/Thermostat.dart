import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';

class ThermostatPage extends StatefulWidget {
  @override
  _ThermostatPageState createState() => _ThermostatPageState();
}

class _ThermostatPageState extends State<ThermostatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  String thermostatName = 'Thermoconfort';
  double temperature = 20.0;
  bool handButtonPressed = false;
  bool isDarkMode = false;
  Color backgroundColor = Colors.white;

  final databaseReference = FirebaseDatabase.instance.reference();

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
      backgroundColor = isDarkMode ? Colors.black : Colors.white;
    });
  }

  void changeThermostatName() async {
    final TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Thermostat Name'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'New Name'),
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
                setState(() {
                  thermostatName = controller.text;
                });
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void changeBackgroundColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Background Color'),
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

  void incrementTemperature() {
    setState(() {
      temperature += 1.0;
    });
    sendTemperatureToDatabase(temperature);
  }

  void decrementTemperature() {
    setState(() {
      temperature -= 1.0;
    });
    sendTemperatureToDatabase(temperature);
  }

  void toggleHandButton() {
    setState(() {
      handButtonPressed = !handButtonPressed;
    });
  }

  void openGraphPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GraphPage()),
    );
  }

  void sendTemperatureToDatabase(double temperature) {
    databaseReference.child('project/temperature').set(temperature);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx7IBkCtYd6ulSfLfDL-aSF3rv6UfmWYxbSE823q36sPiQNVFFLatTFdGeUSnmJ4tUzlo&usqp=CAU',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black, BlendMode.dstATop),
          ),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 70,
            ),
            DefaultTextStyle(
              style: TextStyle(
                color: _animation.value,
              ),
              child: SizedBox(
                height: 120.0,
                child: TyperAnimatedTextKit(
                  text: [thermostatName],
                  textStyle: GoogleFonts.indieFlower(
                    textStyle: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontWeight: FontWeight.w300,
                      fontSize: 40,
                    ),
                  ),
                  textAlign: TextAlign.start,
                  isRepeatingAnimation: false,
                  speed: Duration(milliseconds: 200),
                ),
              ),
            ),
            SizedBox(height: 60.0),
            GestureDetector(
              onTap: incrementTemperature,
              child: Image.asset(
                'assets/UP.png',
                width: 65.0,
                height: 65.0,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              '$temperature°C',
              style: TextStyle(
                fontSize: 35.0,
                color: Color(0xFFB97A57),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            GestureDetector(
              onTap: decrementTemperature,
              child: Image.asset(
                'assets/DOWN.png',
                width: 65.0,
                height: 65.0,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              '$temperature°C',
              style: TextStyle(
                fontSize: 35.0,
                color: Color(0xFFB97A57),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: openGraphPage,
                  child: Image.asset(
                    'assets/GRAPHE.png',
                    width: 48.0,
                    height: 48.0,
                  ),
                ),
                SizedBox(width: 16.0),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      handButtonPressed = !handButtonPressed;
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: 48.0,
                    height: 48.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color:
                          handButtonPressed ? Colors.blue : Colors.transparent,
                    ),
                    padding: EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/HAND.png',
                      width: 24.0,
                      height: 24.0,
                      color: handButtonPressed ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('PARA Features'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: changeBackgroundColor,
                              child: Text('Change Background Color'),
                            ),
                            ElevatedButton(
                              onPressed: changeThermostatName,
                              child: Text('Change Thermostat Name'),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              child: Text(
                                'Toggle Notifications',
                              ),
                            ),
                            ElevatedButton(
                              onPressed: toggleDarkMode,
                              child: Text('Toggle Dark Mode'),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              child: Text('Configure Language'),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              child: Text("Request GPS Activation"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/PARA.png',
                    width: 48.0,
                    height: 48.0,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            if (handButtonPressed)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      print('Vacation Mode');
                    },
                    child: Text('Vacation Mode'),
                  ),
                  SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      print('Night Mode');
                    },
                    child: Text('Night Mode'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class GraphPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx7IBkCtYd6ulSfLfDL-aSF3rv6UfmWYxbSE823q36sPiQNVFFLatTFdGeUSnmJ4tUzlo&usqp=CAU',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black, BlendMode.dstATop),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30), // Adjust the height as needed
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                ),
                SizedBox(height: 20), // Adjust the height as needed
                Expanded(
                  child: Center(
                    child: DefaultTextStyle(
                      style: GoogleFonts.indieFlower(
                        textStyle: TextStyle(
                          color: Colors.black.withOpacity(0.5),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
