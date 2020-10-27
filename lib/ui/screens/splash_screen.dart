import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = "/splashScreen";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
