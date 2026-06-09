import 'package:Thinkpay/ui/pages/Splash_screen.dart';
import 'package:Thinkpay/ui/pages/auth/forgetpass.dart';
import 'package:Thinkpay/ui/pages/auth/login.dart';
import 'package:Thinkpay/ui/pages/auth/signup.dart';
import 'package:Thinkpay/ui/pages/startupScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';


void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const ThinkPay());
}

class ThinkPay extends StatelessWidget {
  const ThinkPay({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThinkPay',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: routes
    );
  }
}


final routes = <String, WidgetBuilder>{
  '/startup': (context) => StartupScreen(),
  '/signup': (context) => const SignUp(),
  '/login': (context) => const Login(),
  '/forgetpass': (context) => const ForgotPassword(),
};