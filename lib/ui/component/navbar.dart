import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Thinkpay/ui/Budget/budget.dart';
import 'package:Thinkpay/ui/pages/chat/AiChat.dart';
import 'package:Thinkpay/ui/pages/home/home.dart';
import 'package:Thinkpay/ui/pages/profile/Profile.dart';
import 'package:Thinkpay/ui/pages/transections/Trasections.dart';

const _kGreen   = Color(0xFFC1FF72);
const _kDark    = Color(0xFF0A0A0A);
const _kSurface = Color(0xFF141414);
const _kBorder  = Color(0xFF2A2A2A);

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
    Profile(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kDark,
      extendBody: true, // lets content go behind the nav bar
      body: FadeTransition(
        opacity: _fadeAnim,
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: _ThinkPayNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Nav bar
// ─────────────────────────────────────────────
class _ThinkPayNavBar extends StatelessWidget {
  const _ThinkPayNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _kSurface,
        border: Border(top: BorderSide(color: _kBorder, width: 1.0)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _RegularTab(icon: Icons.home_outlined,        activeIcon: Icons.home_rounded,         label: 'Home',         index: 0, current: currentIndex, onTap: onTap),
              _RegularTab(icon: Icons.pie_chart_outline,    activeIcon: Icons.pie_chart,            label: 'Budget',       index: 1, current: currentIndex, onTap: onTap),
              // ── AI Chat FAB ──
              _AiChatFab(isActive: currentIndex == 2, onTap: () => onTap(2)),
              _RegularTab(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long,        label: 'Transactions', index: 3, current: currentIndex, onTap: onTap),
              _RegularTab(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,     label: 'Profile',      index: 4, current: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Floating AI Chat button
// ─────────────────────────────────────────────
class _AiChatFab extends StatelessWidget {
  const _AiChatFab({required this.isActive, required this.onTap});

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: const Offset(0, -20), // lifts the FAB above the bar
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isActive ? _kGreen : _kGreen,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _kDark, width: 3),
                boxShadow: isActive
                    ? [BoxShadow(color: _kGreen.withOpacity(0.35), blurRadius: 16, spreadRadius: 1)]
                    : [],
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: _kDark,
                size: 26,
              ),
            ),
          ),
          // label sits below (at bar level)
          Transform.translate(
            offset: const Offset(0, -16),
            child: Text(
              'AI Chat',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? _kGreen : _kGreen.withOpacity(0.8),
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Regular nav tab
// ─────────────────────────────────────────────
class _RegularTab extends StatelessWidget {
  const _RegularTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

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
          color: _isSelected ? _kGreen.withOpacity(0.1) : Colors.transparent,
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
                color: _isSelected ? _kGreen : Colors.white.withOpacity(0.3),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 10,
                fontWeight: _isSelected ? FontWeight.w600 : FontWeight.w400,
                color: _isSelected ? _kGreen : Colors.white.withOpacity(0.3),
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