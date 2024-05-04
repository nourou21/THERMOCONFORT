import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_2/screens/login_screen/components/forgetpassword.dart';
import 'package:flutter_application_2/screens/login_screen/components/utils/constants.dart';
import 'package:flutter_application_2/screens/login_screen/components/utils/helper_functions.dart';
import 'package:flutter_application_2/slider.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String _errorMessage = '';
  bool _showPassword = false;
  bool rememberMe = false;
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
    String hint,
    IconData iconData,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
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
                          _showPassword = value;
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
      User? user = _auth.currentUser;
      await user?.sendEmailVerification();
      setState(() {
        _errorMessage = "Sign up successful! Verification email sent.";
        _errorMessageVisibilityController.add(true);
      });
      Timer(Duration(seconds: 5), () {
        _errorMessageVisibilityController.add(false);
      });
    } catch (e) {
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
      saveLoginState(true);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SliderPage()),
      );
    } catch (e) {
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

  void saveLoginState(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', isLoggedIn);
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
    super.initState();
    loginContent = [
      _inputField('Email', Ionicons.mail_outline, emailController),
      _inputField('Password', Ionicons.lock_closed_outline, passwordController,
          isPassword: true),
      loginButton('Log In', onPressed: () {
        loginPressed(emailController.text, passwordController.text);
      }),
      forgotPassword(),
    ];

    createAccountContent = [
      _inputField('Name', Ionicons.person_outline, nameController),
      _inputField('Email', Ionicons.mail_outline, emailController),
      _inputField('Password', Ionicons.lock_closed_outline, passwordController,
          isPassword: true),
      loginButton('Sign Up', onPressed: () {
        signUpPressed(
            nameController.text, emailController.text, passwordController.text);
      }),
      orDivider(),
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

    loadRememberMeState();
  }

  void loadRememberMeState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  void saveRememberMeState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('rememberMe', value);
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
        Positioned(
          top: 570,
          left: 100,
          child: Row(
            children: [
              Checkbox(
                value: rememberMe,
                onChanged: (value) {
                  setState(() {
                    rememberMe = value ?? false;
                  });
                  saveRememberMeState(rememberMe);
                },
              ),
              Text(
                'Remember Me',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
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
          bottom: 0,
          left: 0,
          right: 0,
          child: StreamBuilder<bool>(
            stream: _errorMessageVisibilityController.stream,
            initialData: false,
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  color: _errorMessage.contains('successful')
                      ? Colors.green
                      : Colors.red,
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
                return Container();
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
        widget.onChanged(!widget.showPassword);
      },
    );
  }

  void saveLoginCredentials(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
    prefs.setString('password', password);
  }
}
