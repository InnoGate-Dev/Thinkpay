import 'package:flutter/material.dart';

const _kGreen = Color(0xFFC1FF72);
const _kDark = Color(0xFF0A0A0A);
const _kSurface = Color(0xFF141414);

class Aichat extends StatefulWidget {
  const Aichat({super.key});

  @override
  State<Aichat> createState() => _AichatState();
}

class _AichatState extends State<Aichat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kDark,
      appBar: AppBar(
        backgroundColor: _kSurface,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _kGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: _kGreen, size: 16),
            ),
            const SizedBox(width: 10),
            const Text(
              'AI Chat',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'AI Chat',
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
