import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_2/auth/loginscreen.dart';

class ThermostatPage extends StatefulWidget {
  @override
  _ThermostatPageState createState() => _ThermostatPageState();
}

class _ThermostatPageState extends State<ThermostatPage>
    with SingleTickerProviderStateMixin {
  // Add SingleTickerProviderStateMixin
  late AnimationController _controller; // Animation controller
  late Animation<Color?> _animation; // Animation for text

  String thermostatName = 'Thermoconfort';
  double temperature = 20.0;
  bool handButtonPressed = false;
  bool isDarkMode = false;
  Color backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500), // Duration of the animation
    );
    _animation = ColorTween(
            begin: Colors.black, end: Colors.blue) // Color transition animation
        .animate(_controller); // Assign animation to controller
    _controller.forward(); // Start the animation
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the animation controller
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
          title: Text('Changer le nom du thermostat'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Nouveau nom'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuler'),
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
          title: Text('Choisir une couleur de fond'),
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
  }

  void decrementTemperature() {
    setState(() {
      temperature -= 1.0;
    });
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

  void disconnect() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 33,
            ),
            Row(
              children: [
                SizedBox(
                  width: 340,
                ),
                IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: disconnect,
                ),
              ],
            ),
            DefaultTextStyle(
              style: TextStyle(
                color: _animation.value, // Apply color animation to text
              ),
              child: SizedBox(
                height: 120.0,
                child: TyperAnimatedTextKit(
                  // Animated text widget
                  text: [thermostatName], // Text to animate
                  textStyle: GoogleFonts.indieFlower(
                    textStyle: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontWeight: FontWeight.w300,
                      fontSize: 40,
                    ),
                  ),
                  textAlign: TextAlign.start,
                  // Remove the alignment parameter
                  isRepeatingAnimation: false, // Animation repetition
                  speed: Duration(milliseconds: 200), // Animation speed
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
                    toggleHandButton();
                  },
                  child: Image.asset(
                    'assets/HAND.png',
                    width: 48.0,
                    height: 48.0,
                  ),
                ),
                SizedBox(width: 16.0),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Fonctionnalités de PARA'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: changeBackgroundColor,
                              child: Text('Changer de couleur'),
                            ),
                            ElevatedButton(
                              onPressed: changeThermostatName,
                              child: Text('Changer le nom du thermostat'),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              child: Text(
                                'Désactiver ou activer les notifications',
                              ),
                            ),
                            ElevatedButton(
                              onPressed: toggleDarkMode,
                              child: Text('Mode sombre ou clair'),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              child: Text('Configurer le langage'),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              child: Text("Demander l'activation du GPS"),
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
                      print('Mode Vacances');
                    },
                    child: Text('Mode Vacances'),
                  ),
                  SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      print('Mode Nuit');
                    },
                    child: Text('Mode Nuit'),
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
      appBar: AppBar(
        title: Text('Graphique'),
      ),
      body: Container(
        child: Center(
          child: Text('Placeholder pour le graphique'),
        ),
      ),
    );
  }
}
