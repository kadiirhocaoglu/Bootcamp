import 'package:flutter/material.dart';

import '../login/login_screen.dart';
import '../register/registers_screen.dart';

class LoginOrRegisterScreen extends StatefulWidget {
  const LoginOrRegisterScreen({super.key, required bool showLoginPage,});

  @override
  State<LoginOrRegisterScreen> createState() => _LoginOrRegisterScreenState();
}

class _LoginOrRegisterScreenState extends State<LoginOrRegisterScreen> {
  bool showLoginPage = true;

  void toggleScreens() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showLoginPage
        ? LoginScreen(ShowRegisterScreen: toggleScreens)
        : RegisterScreen(ShowLoginScreen: toggleScreens);
  }
}
