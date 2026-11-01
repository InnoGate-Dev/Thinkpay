import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';

/// Pill-style segmented tab bar used for top-level sections.
///
/// Examples: the loan hub (Bank & Finance / Credit Card) and the loan detail
/// page (Details / Repayment / Summary).
///
/// The [controller] must be created by the host screen — this widget is
/// presentation only.
class SegmentedTabBar extends StatelessWidget {
  const SegmentedTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.height = 40,
    this.fontSize = 12,
  });

  final TabController controller;

  /// Labels, one per tab. The controller length must match.
  final List<String> tabs;

  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    // The 3px of padding above and below the pill leaves this for each tab.
    final tabHeight = height - 6;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: tc.surface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tc.border, width: 0.5),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(3),
        labelColor: tc.text100,
        unselectedLabelColor: tc.text40,
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: fontSize),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: fontSize),
        tabs: [
          for (final label in tabs) Tab(text: label, height: tabHeight),
        ],
      ),
    );
  }
}
