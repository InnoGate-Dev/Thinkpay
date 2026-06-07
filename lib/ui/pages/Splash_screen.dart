import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.lightGreenAccent,
      body: Center(child: Image(image: AssetImage('lib/assets/logo.png'))),
    );
  }

}
