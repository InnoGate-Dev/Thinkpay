import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, required this.icon, this.trailing});
  final String title;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Row(
      children: [
        Icon(icon, color: tc.coreAction, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.manrope(color: tc.text100, fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
