import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/constant/app_colors.dart';
import 'package:Thinkpay/ui/pages/home/home_helpers.dart';

// ── Balance card ──────────────────────────────────────────────────────────────
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expenses,
    required this.goalProgress,
    required this.tc,
  });
  final double balance, income, expenses, goalProgress;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Calculate expense percentage for the visual bar
    final double expenseRatio = income > 0 ? (expenses / income).clamp(0.0, 1.0) : 0.0;
    
    // A mock income growth value for the UI redesign
    final double incomeGrowth = 14.2;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E222D), const Color(0xFF151922)]
              : [Colors.white, const Color(0xFFF8FAFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : tc.border, 
            width: 1),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background graphic/glow (premium touch)
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tc.coreAction.withValues(alpha: isDark ? 0.08 : 0.04),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Section: Balance & Goal Progress ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance & Growth
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL BALANCE',
                            style: GoogleFonts.inter(
                              color: tc.text40,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rs. ${formatAmount(balance)}',
                            style: GoogleFonts.manrope(
                              color: tc.text100,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.0,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Income Growth Badge

                        ],
                      ),
                    ),
                    
                    // Goal Progress Ring
                    Container(
                      width: 58,
                      height: 58,
                      margin: const EdgeInsets.only(left: 12, top: 4),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 6,
                            color: isDark ? const Color(0xFF2A2E39) : const Color(0xFFEDF1F5),
                          ),
                          CircularProgressIndicator(
                            value: goalProgress.isNaN ? 0.0 : goalProgress,
                            strokeWidth: 6,
                            strokeCap: StrokeCap.round,
                            color: tc.coreAction,
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${(goalProgress.isNaN ? 0 : goalProgress * 100).toInt()}%',
                                  style: GoogleFonts.manrope(
                                    color: tc.text100,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Goals',
                                  style: GoogleFonts.inter(
                                    color: tc.text40,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // ── Income & Expenses Stats ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _StatColumn(
                        label: 'Income',
                        amount: income,
                        color: tc.coreAction,
                        icon: Icons.south_west_rounded,
                        tc: tc,
                      ),
                    ),
                    Container(width: 1, height: 36, color: tc.border),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: _StatColumn(
                          label: 'Expenses',
                          amount: expenses,
                          color: tc.accentExpense,
                          icon: Icons.north_east_rounded,
                          tc: tc,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    required this.tc,
  });
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: tc.text40,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Rs. ${formatAmount(amount)}',
                style: GoogleFonts.manrope(
                  color: tc.text100,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
