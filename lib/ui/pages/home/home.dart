import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/constant/app_colors.dart';
import 'package:Thinkpay/model/transaction_model.dart';
import 'package:Thinkpay/providers/finance_provider.dart';
import 'package:Thinkpay/providers/user_profile_store.dart';
import 'package:Thinkpay/ui/component/add_transaction_sheet.dart';

import '../../component/carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _provider = FinanceProvider();
  final _profileStore = UserProfileStore();

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([_provider, _profileStore]),
      builder: (context, _) {
        final balance  = _provider.balance;
        final income   = _provider.totalIncome;
        final expenses = _provider.totalExpenses;
        final recent   = _provider.recentTransactions;
        final name     = _profileStore.name.split(' ').first;
        final hour     = DateTime.now().hour;
        final greeting = hour < 12
            ? 'Good morning'
            : hour < 17
                ? 'Good afternoon'
                : 'Good evening';

        return Scaffold(
          backgroundColor: tc.background,
          drawerEnableOpenDragGesture: false,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: tc.surface2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: tc.border),
                ),
                child: Icon(Icons.person_rounded, color: tc.text70, size: 18),
              ),
            ),
            backgroundColor: tc.background,
            elevation: 0,
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $name',
                  style: GoogleFonts.inter(
                    color: tc.text40,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  'DayOne',
                  style: GoogleFonts.manrope(
                    color: tc.text100,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                children: [
                  IconButton(
                    icon: Stack(
                      children: [
                        Icon(Icons.notifications_outlined, color: tc.text70, size: 22),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: tc.coreAction,
                              shape: BoxShape.circle,
                              border: Border.all(color: tc.background, width: 1.2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/notification'),
                  ),
                ],
              ),

              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/news'),
                icon: Stack(
                  children: [
                    Icon(Icons.newspaper_outlined, color: tc.text70, size: 22),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: tc.coreAction,
                          shape: BoxShape.circle,
                          border: Border.all(color: tc.background, width: 1.2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              // ── Net Worth card ──────────────────────────────────────────
              _BalanceCard(
                balance: balance,
                income: income,
                expenses: expenses,
                tc: tc,
              ),
              const SizedBox(height: 20),

              // ── ThinkPay Co-Pilot ───────────────────────────────────────
              _CopilotCard(
                tc: tc,
                pct: income > 0
                    ? ((income - expenses) / income).clamp(0.0, 1.0)
                    : 0.0,
              ),
              const SizedBox(height: 28),

              // ── Recent transactions ─────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: GoogleFonts.manrope(
                      color: tc.text100,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/transaction");
                    },
                    child: Text(
                      'See all',
                      style: GoogleFonts.inter(
                        color: tc.coreAction,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (recent.isEmpty)
                _EmptyState(
                  message: 'No transactions yet.\nTap + to record one.',
                  tc: tc,
                ),
              if (recent.isNotEmpty)
                _TransactionList(transactions: recent, tc: tc),
            ],
          ),
        );
      },
    );
  }
}

// ── Balance card ──────────────────────────────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.income,
    required this.expenses,
    required this.tc,
  });
  final double balance, income, expenses;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF151922), const Color(0xFF0F1116)]
              : [Colors.white, const Color(0xFFF8FAFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tc.border, width: 0.8),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            'TOTAL BALANCE',
            style: GoogleFonts.inter(
              color: tc.text40,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          // Balance amount
          Text(
            'Rs. ${_fmt(balance)}',
            style: GoogleFonts.manrope(
              color: tc.text100,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),

          // Balance change indicator
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: balance >= 0 ? tc.coreActionDim : tc.accentExpenseDim,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      balance >= 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 12,
                      color: balance >= 0 ? tc.coreAction : tc.accentExpense,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      balance >= 0 ? 'Positive balance' : 'Negative balance',
                      style: GoogleFonts.inter(
                        color: balance >= 0 ? tc.coreAction : tc.accentExpense,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: tc.border, height: 1, thickness: 0.5),
          const SizedBox(height: 16),

          // Income & Expenses row
          Row(
            children: [
              Expanded(
                child: _BalanceStat(
                  label: 'Income',
                  amount: income,
                  color: tc.coreAction,
                  icon: Icons.arrow_downward_rounded,
                  tc: tc,
                ),
              ),
              Container(width: 0.5, height: 36, color: tc.border),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: _BalanceStat(
                    label: 'Expenses',
                    amount: expenses,
                    color: tc.accentExpense,
                    icon: Icons.arrow_upward_rounded,
                    tc: tc,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  const _BalanceStat({
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
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 10),
        Column(
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
              'Rs. ${_fmt(amount)}',
              style: GoogleFonts.manrope(
                color: tc.text100,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── ThinkPay Co-Pilot ─────────────────────────────────────────────────────────
class _CopilotCard extends StatelessWidget {
  const _CopilotCard({required this.tc, required this.pct});
  final ThemeColors tc;
  final double pct;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: tc.intelligenceAccent.withValues(alpha: isDark ? 0.07 : 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: tc.intelligenceAccent.withValues(alpha: 0.18),
              width: 0.8,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pulsing AI icon
              _PulsingAIIcon(tc: tc),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'AI Co-Pilot',
                          style: GoogleFonts.manrope(
                            color: tc.text100,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: tc.intelligenceAccent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'LIVE',
                            style: GoogleFonts.inter(
                              color: tc.intelligenceAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pct >= 0.2
                          ? 'You\'re on track — saving ${(pct * 100).toStringAsFixed(1)}% of income this month. Keep it up!'
                          : 'Consider cutting back. You\'re saving only ${(pct * 100).toStringAsFixed(1)}% of your income right now.',
                      style: GoogleFonts.inter(
                        color: tc.text70,
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Savings rate bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 4,
                        backgroundColor: tc.intelligenceAccentDim,
                        valueColor: AlwaysStoppedAnimation(
                          pct >= 0.2 ? tc.coreAction : tc.accentExpense,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingAIIcon extends StatefulWidget {
  const _PulsingAIIcon({required this.tc});
  final ThemeColors tc;

  @override
  State<_PulsingAIIcon> createState() => _PulsingAIIconState();
}

class _PulsingAIIconState extends State<_PulsingAIIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = widget.tc;
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (_, __) => Transform.scale(
        scale: _scaleAnim.value,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: tc.intelligenceAccent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color:
                    tc.intelligenceAccent.withValues(alpha: _scaleAnim.value * 0.2),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: tc.intelligenceAccent,
            size: 18,
          ),
        ),
      ),
    );
  }
}

// ── Transaction list (flush grouped style) ────────────────────────────────────
class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.transactions, required this.tc});
  final List<TransactionModel> transactions;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tc.border, width: 0.8),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < transactions.length; i++) ...[
            _TransactionTile(transaction: transactions[i], tc: tc),
            if (i < transactions.length - 1)
              Divider(
                color: tc.divider,
                height: 1,
                thickness: 0.5,
                indent: 68,
              ),
          ],
        ],
      ),
    );
  }
}

// ── Transaction tile ──────────────────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.tc});
  final TransactionModel transaction;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final accentColor = isIncome ? tc.coreAction : tc.accentExpense;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _categoryIcon(transaction.category),
              color: accentColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),

          // Title & category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: GoogleFonts.inter(
                    color: tc.text100,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  transaction.category,
                  style: GoogleFonts.inter(
                    color: tc.text40,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Amount & date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '−'} Rs. ${_fmt(transaction.amount)}',
                style: GoogleFonts.manrope(
                  color: isIncome ? tc.coreAction : tc.text100,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _dateStr(transaction.date),
                style: GoogleFonts.inter(
                  color: tc.text40,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.tc});
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

// ── Helpers ───────────────────────────────────────────────────────────────────
String _fmt(double v) {
  if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return v.toStringAsFixed(0);
}

String _dateStr(DateTime d) {
  final now = DateTime.now();
  if (d.year == now.year && d.month == now.month && d.day == now.day) {
    return 'Today';
  }
  if (d.year == now.year &&
      d.month == now.month &&
      d.day == now.day - 1) {
    return 'Yesterday';
  }
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${d.day} ${months[d.month - 1]}';
}

IconData _categoryIcon(String cat) {
  switch (cat.toLowerCase()) {
    case 'food':          return Icons.restaurant_rounded;
    case 'transport':     return Icons.directions_car_rounded;
    case 'shopping':      return Icons.shopping_bag_rounded;
    case 'entertainment': return Icons.movie_rounded;
    case 'utilities':     return Icons.bolt_rounded;
    case 'health':        return Icons.favorite_rounded;
    case 'education':     return Icons.school_rounded;
    case 'rent':          return Icons.home_rounded;
    case 'salary':        return Icons.account_balance_wallet_rounded;
    case 'freelance':     return Icons.work_rounded;
    case 'business':      return Icons.business_center_rounded;
    case 'investment':    return Icons.trending_up_rounded;
    case 'gift':          return Icons.card_giftcard_rounded;
    default:              return Icons.receipt_rounded;
  }
}
