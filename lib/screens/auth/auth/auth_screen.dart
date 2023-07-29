import 'dart:async';

import 'package:bootcamp/custom_widgets/bottom_nav_bar.dart';
import 'package:bootcamp/screens/auth/login_or_register/login_or_register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../splash/splash_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showSplash = true; 

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      setState(() {
        _showSplash = false;
      });
    });
    checkUserLoggedIn();
  }
Future<void> checkUserLoggedIn() async {
    final User? user = await FirebaseAuth.instance.authStateChanges().first;


      setState() {
        _showSplash = false; 

    }
  }
  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    } else {
      return Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(); 
            } else {
              if (snapshot.hasData) {
                return const MyHomePage();
              } else {
                return  const LoginOrRegisterScreen(showLoginPage: true,);
              }
            }
          },
        ),
      );
    }
  }
}
