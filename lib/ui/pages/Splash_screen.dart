import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../../core/repository/userRepo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _userRepo = UserRepository();

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Minimum splash display time
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final loggedIn = await _userRepo.isLoggedIn;
    if (!mounted) return;

    if (loggedIn) {
      // Valid, non-expired token found — go straight to dashboard
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // No token or token expired — show startup / onboarding
      Navigator.of(context).pushReplacementNamed('/startup');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Center(child: Image(image: AssetImage('lib/assets/logo_1.png'))),
    );
  }
}
