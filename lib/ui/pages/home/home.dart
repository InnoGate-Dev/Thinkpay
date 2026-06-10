import 'package:flutter/material.dart';

const _kGreen = Color(0xFFC1FF72);
const _kDark = Color(0xFF0A0A0A);
const _kSurface = Color(0xFF141414);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kDark,
      appBar: AppBar(
        backgroundColor: _kSurface,
        elevation: 0,
        titleSpacing: 20,
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            children: [
              TextSpan(text: 'Home', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white70),
            onPressed: () {
              Navigator.pushNamed(context, '/notification');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const Center(
        child: Text(
          'Home',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}


