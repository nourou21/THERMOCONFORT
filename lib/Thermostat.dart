import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_2/auth/loginscreen.dart';

class ThermostatPage extends StatefulWidget {
  @override
  _ThermostatPageState createState() => _ThermostatPageState();
}

class _ThermostatPageState extends State<ThermostatPage> {
  String thermostatName = 'Thermoconfort';
  double temperature = 20.0;
  bool handButtonPressed = false;
  bool isDarkMode = false;
  Color backgroundColor = Colors.white;

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
      // After signing out, you might want to navigate to the login screen
      // You can replace the current page with the login screen using Navigator
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      print('Error signing out: $e');
      // Handle sign out error if any
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(thermostatName),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: disconnect,
          ),
        ],
      ),
      body: Container(
        color: backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20.0),
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

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thermostat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ThermostatPage(),
    );
  }
}
