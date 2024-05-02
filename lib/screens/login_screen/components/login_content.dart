import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_2/inside%20app/slider.dart';
import 'package:flutter_application_2/screens/login_screen/components/forgetpassword.dart';
import 'package:flutter_application_2/utils/constants.dart';
import 'package:flutter_application_2/utils/helper_functions.dart';
import 'package:ionicons/ionicons.dart';

import '../animations/change_screen_animation.dart';
import 'bottom_text.dart';
import 'top_text.dart';

enum Screens {
  welcomeBack,
  createAccount,
}

class LoginContent extends StatefulWidget {
  const LoginContent({Key? key}) : super(key: key);

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent>
    with TickerProviderStateMixin {
  late final List<Widget> createAccountContent;
  late final List<Widget> loginContent;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String _errorMessage = ''; // Store error messages
  bool _showPassword = false;

  StreamController<bool> _errorMessageVisibilityController =
      StreamController<bool>();

  @override
  void dispose() {
    ChangeScreenAnimation.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _errorMessageVisibilityController.close();
    super.dispose();
  }

  Widget _inputField(
      String hint, IconData iconData, TextEditingController controller,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
      child: SizedBox(
        height: 50,
        child: Material(
          elevation: 8,
          shadowColor: Colors.black87,
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          child: TextFormField(
            controller: controller,
            textAlignVertical: TextAlignVertical.bottom,
            obscureText: isPassword && !_showPassword,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              hintText: hint,
              prefixIcon: Icon(iconData),
              suffixIcon: isPassword
                  ? PasswordVisibilityToggle(
                      showPassword: _showPassword,
                      onChanged: (value) {
                        setState(() {
                          _showPassword =
                              value; // Update the _showPassword variable
                        });
                      },
                    )
                  : null,
            ),
            keyboardType: isPassword
                ? TextInputType.visiblePassword
                : TextInputType.emailAddress,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget loginButton(String title, {VoidCallback? onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 135, vertical: 16),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: kSecondaryColor,
          shape: const StadiumBorder(),
          elevation: 8,
          shadowColor: Colors.black87,
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget orDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 130, vertical: 8),
      child: Row(
        children: [
          Flexible(
            child: Container(
              height: 1,
              color: kPrimaryColor,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
          Flexible(
            child: Container(
              height: 1,
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget forgotPassword() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 110),
      child: TextButton(
        onPressed: () {
          // Navigate to the forgot password screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Forgetpass()),
          );
        },
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: kSecondaryColor,
          ),
        ),
      ),
    );
  }

  Future<void> signUpPressed(String name, String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      // Send verification email
      User? user = _auth.currentUser;
      await user?.sendEmailVerification();
      // Show success message upon successful sign up
      setState(() {
        _errorMessage = "Sign up successful! Verification email sent.";
        _errorMessageVisibilityController.add(true);
      });
      Timer(Duration(seconds: 5), () {
        _errorMessageVisibilityController.add(false);
      });
    } catch (e) {
      // Handle sign up errors
      print("Sign up error: $e");
      setState(() {
        _errorMessage = _getErrorMessage(e);
        _errorMessageVisibilityController.add(true);
      });
      Timer(Duration(seconds: 5), () {
        _errorMessageVisibilityController.add(false);
      });
    }
  }

  Future<void> loginPressed(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Navigate to InitPage upon successful login
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SliderPage()),
      );
    } catch (e) {
      // Handle login errors
      print("Login error: $e");
      setState(() {
        _errorMessage = _getErrorMessage(e);
        _errorMessageVisibilityController.add(true);
      });
      Timer(Duration(seconds: 5), () {
        _errorMessageVisibilityController.add(false);
      });
    }
  }

  String _getErrorMessage(dynamic error) {
    String errorMessage = 'An error occurred. Please try again later.';
    if (error is FirebaseAuthException) {
      if (error.code == 'email-already-in-use') {
        errorMessage = 'Email is already in use.';
      } else if (error.code == 'user-not-found' ||
          error.code == 'wrong-password') {
        errorMessage = 'Incorrect email or password.';
      } else {
        errorMessage = 'Login failed. Please try again later.';
      }
    }
    return errorMessage;
  }

  @override
  void initState() {
    createAccountContent = [
      _inputField('Name', Ionicons.person_outline, nameController),
      _inputField('Email', Ionicons.mail_outline, emailController),
      _inputField('Password', Ionicons.lock_closed_outline, passwordController,
          isPassword: true),
      loginButton('Sign Up', onPressed: () {
        // Implement sign up functionality
        signUpPressed(
            nameController.text, emailController.text, passwordController.text);
      }),
      orDivider(),
    ];

    loginContent = [
      _inputField('Email', Ionicons.mail_outline, emailController),
      _inputField('Password', Ionicons.lock_closed_outline, passwordController,
          isPassword: true),
      loginButton('Log In', onPressed: () {
        // Implement login functionality
        loginPressed(emailController.text, passwordController.text);
      }),
      forgotPassword(),
    ];

    ChangeScreenAnimation.initialize(
      vsync: this,
      createAccountItems: createAccountContent.length,
      loginItems: loginContent.length,
    );

    for (var i = 0; i < createAccountContent.length; i++) {
      createAccountContent[i] = HelperFunctions.wrapWithAnimatedBuilder(
        animation: ChangeScreenAnimation.createAccountAnimations[i],
        child: createAccountContent[i],
      );
    }

    for (var i = 0; i < loginContent.length; i++) {
      loginContent[i] = HelperFunctions.wrapWithAnimatedBuilder(
        animation: ChangeScreenAnimation.loginAnimations[i],
        child: loginContent[i],
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: 136,
          left: 24,
          child: TopText(),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: loginContent,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: createAccountContent,
              ),
            ],
          ),
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: BottomText(),
          ),
        ),
        Positioned(
          bottom: 0, // Position the error message at the bottom of the screen
          left: 0,
          right: 0,
          child: StreamBuilder<bool>(
            stream: _errorMessageVisibilityController.stream,
            initialData: false,
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return Container(
                  padding: EdgeInsets.symmetric(
                      vertical: 8), // Adjust padding as needed
                  color: _errorMessage.contains('successful')
                      ? Colors
                          .green // Change background color to green if successful
                      : Colors.red, // Change background color to red if error
                  child: Text(
                    _errorMessage,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                return Container(); // Return empty container if error message is not visible
              }
            },
          ),
        ),
      ],
    );
  }
}

class PasswordVisibilityToggle extends StatefulWidget {
  final bool showPassword;
  final ValueChanged<bool> onChanged;

  const PasswordVisibilityToggle({
    required this.showPassword,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  _PasswordVisibilityToggleState createState() =>
      _PasswordVisibilityToggleState();
}

class _PasswordVisibilityToggleState extends State<PasswordVisibilityToggle> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        widget.showPassword ? Icons.visibility : Icons.visibility_off,
        color: Colors.grey,
      ),
      onPressed: () {
        widget.onChanged(!widget.showPassword); // Toggle the showPassword state
      },
    );
  }
}
