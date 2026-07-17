import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/constant/app_colors.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, required this.tc});
  final String message;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(36),
    decoration: BoxDecoration(
      color: tc.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: tc.border, width: 0.8),
    ),
    child: Center(
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, color: tc.text20, size: 40),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: tc.text40,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    ),
  );
}
