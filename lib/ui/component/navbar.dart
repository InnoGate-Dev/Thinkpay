import 'package:Thinkpay/ui/pages/goal/Goal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Thinkpay/constant/app_colors.dart';
import 'package:Thinkpay/model/transaction_model.dart';
import 'package:Thinkpay/ui/component/add_budget_sheet.dart';
import 'package:Thinkpay/ui/component/add_goal_sheet.dart';
import 'package:Thinkpay/ui/component/add_transaction_sheet.dart';
import 'package:Thinkpay/ui/pages/Budget/budget.dart';
import 'package:Thinkpay/ui/pages/chat/AiChat.dart';
import 'package:Thinkpay/ui/pages/home/home.dart';
import 'package:Thinkpay/ui/pages/transections/Trasections.dart';

/// Set to `true` when the home drawer is open so AppShell can hide the nav bar.
final drawerOpenNotifier = ValueNotifier<bool>(false);

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;


  final List<Widget> _pages = const [
    HomeScreen(),
    BudgetPage(),
    Aichat(),
    Transection(),
    SetGoalPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ));

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      value: 1.0,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _onTabTapped(int index) async {
    if (index == _currentIndex) return;
    await _fadeCtrl.reverse();
    setState(() => _currentIndex = index);
    _fadeCtrl.forward();
  }

  void _openAddBudget() {
    final type = budgetTabIndexNotifier.value == 0
        ? TransactionType.expense
        : TransactionType.income;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBudgetSheet(initialType: type),
    );
  }

  void _openAddTransaction() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionSheet(),
    );
  }

  void _openAddGoal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddGoalSheet(),
    );
  }

  /// Returns the FAB widget for the current page, or null for pages without one.
  Widget? _fabFor(ThemeColors tc) {
    switch (_currentIndex) {
      case 1: // Budget
        return FloatingActionButton(
          heroTag: 'fab_budget',
          onPressed: _openAddBudget,
          backgroundColor: tc.lime,
          foregroundColor: tc.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add_rounded, size: 28),
        );
      case 3: // Transactions
        return FloatingActionButton.extended(
          heroTag: 'fab_transaction',
          onPressed: _openAddTransaction,
          backgroundColor: tc.lime,
          foregroundColor: tc.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Add Transaction',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        );
      case 4: // Goals
        return FloatingActionButton.extended(
          heroTag: 'fab_goal',
          onPressed: _openAddGoal,
          backgroundColor: tc.lime,
          foregroundColor: tc.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'New Goal',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.background,
      extendBody: true,
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim) => ScaleTransition(
          scale: anim,
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: _fabFor(tc),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder<bool>(
        valueListenable: drawerOpenNotifier,
        builder: (context, drawerOpen, _) {
          return AnimatedSlide(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            offset: drawerOpen ? const Offset(0, 1) : Offset.zero,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: drawerOpen ? 0.0 : 1.0,
              child: _ThinkPayNavBar(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Nav bar ───────────────────────────────────────────────────────────────────
class _ThinkPayNavBar extends StatelessWidget {
  const _ThinkPayNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: tc.surface,
        border: Border(top: BorderSide(color: tc.border, width: 1.0)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _RegularTab(icon: Icons.home_outlined,         activeIcon: Icons.home_rounded,         label: 'Home',         index: 0, current: currentIndex, onTap: onTap, tc: tc),
              _RegularTab(icon: Icons.pie_chart_outline,     activeIcon: Icons.pie_chart,            label: 'Budget',       index: 1, current: currentIndex, onTap: onTap, tc: tc),
              _AiChatFab(isActive: currentIndex == 2, onTap: () => onTap(2), tc: tc),
              _RegularTab(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long,         label: 'Transactions', index: 3, current: currentIndex, onTap: onTap, tc: tc),
              _RegularTab(icon: Icons.currency_bitcoin, activeIcon: Icons.currency_bitcoin,      label: 'Goal',      index: 4, current: currentIndex, onTap: onTap, tc: tc),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Floating AI Chat button ───────────────────────────────────────────────────
class _AiChatFab extends StatelessWidget {
  const _AiChatFab({
    required this.isActive,
    required this.onTap,
    required this.tc,
  });

  final bool isActive;
  final VoidCallback onTap;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: const Offset(0, -20),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: tc.lime,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: tc.background, width: 3),
                boxShadow: isActive
                    ? [BoxShadow(color: tc.lime.withValues(alpha: 0.35), blurRadius: 16, spreadRadius: 1)]
                    : [],
              ),
              child: Icon(Icons.auto_awesome_rounded, color: tc.background, size: 26),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -16),
            child: Text(
              'AI Chat',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? tc.lime : tc.lime.withValues(alpha: 0.7),
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Regular nav tab ───────────────────────────────────────────────────────────
class _RegularTab extends StatelessWidget {
  const _RegularTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
    required this.tc,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;
  final ThemeColors tc;

  bool get _isSelected => index == current;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _isSelected ? tc.lime.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                _isSelected ? activeIcon : icon,
                key: ValueKey(_isSelected),
                color: _isSelected ? tc.lime : tc.text40,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 10,
                fontWeight: _isSelected ? FontWeight.w600 : FontWeight.w400,
                color: _isSelected ? tc.lime : tc.text40,
                letterSpacing: 0.2,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}