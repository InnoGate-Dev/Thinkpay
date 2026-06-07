import 'package:Thinkpay/ui/pages/Splash_screen.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const ThinkPay());
}

class ThinkPay extends StatelessWidget {
  const ThinkPay({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}


