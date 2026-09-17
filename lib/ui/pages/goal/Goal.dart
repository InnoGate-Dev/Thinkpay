import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/core/repository/goalRepo.dart';
import 'package:Thinkpay/model/goal_model.dart';
import 'package:Thinkpay/providers/finance_provider.dart';
import 'package:Thinkpay/ui/component/add_goal_sheet.dart';

class SetGoalPage extends StatefulWidget {
  const SetGoalPage({super.key});

  @override
  State<SetGoalPage> createState() => _SetGoalPageState();
}

class _SetGoalPageState extends State<SetGoalPage>
    with SingleTickerProviderStateMixin {
  final _provider = FinanceProvider();
  final _repo = GoalRepository();
  late TabController _tabController;

  bool _isLoading = false;
  String? _error;

  // ── Data loading ──────────────────────────────────────────────────────────

  Future<void> _loadGoals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final goals = await _repo.getGoals();
      _provider.setGoals(goals);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── CRUD helpers ─────────────────────────────────────────────────────────

  Future<void> _deleteGoal(GoalModel goal) async {
    // Optimistic remove
    _provider.deleteGoal(goal.id);
    try {
      await _repo.deleteGoal(goal.id);
    } catch (e) {
      // Roll back on error
      _provider.addGoal(goal);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete goal: $e'),
            backgroundColor: ThemeColors.of(context).accentExpense,
          ),
        );
      }
    }
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGoals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddGoal() {
    GoalType defaultType = GoalType.savings;
    if (_tabController.index == 2) {
      defaultType = GoalType.investment;
    } else if (_tabController.index == 1) {
      defaultType = GoalType.savings;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddGoalSheet(initialType: defaultType),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        final allGoals = _provider.goals;
        // Filter out loan/debt goals (_L) from this widget
        final displayGoals = allGoals.where((g) {
          final cleanId = g.id.trim().toUpperCase();
          return g.type != GoalType.debt && !cleanId.endsWith('_L');
        }).toList();

        final savings = displayGoals
            .where((g) => g.type == GoalType.savings || g.id.trim().toUpperCase().endsWith('_S'))
            .toList();
        final investments = displayGoals
            .where((g) => g.type == GoalType.investment || g.id.trim().toUpperCase().endsWith('_I'))
            .toList();
        final completed = displayGoals.where((g) => g.isCompleted).toList();

        final totalTarget = displayGoals.fold(0.0, (s, g) => s + g.targetAmount);
        final totalSaved = displayGoals.fold(0.0, (s, g) => s + g.savedAmount);
        final overallPct = totalTarget > 0 ? (totalSaved / totalTarget) : 0.0;

        return Scaffold(
          backgroundColor: tc.background,
          drawerEnableOpenDragGesture: false,
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_goal',
            onPressed: _openAddGoal,
            backgroundColor: tc.coreAction,
            foregroundColor: tc.background,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(
              'New Goal',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Goals',
                              style: GoogleFonts.manrope(
                                color: tc.text100,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Track savings & investments',
                              style: GoogleFonts.inter(
                                color: tc.text40,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Refresh button
                      IconButton(
                        onPressed: _isLoading ? null : _loadGoals,
                        icon: _isLoading
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: tc.coreAction,
                                ),
                              )
                            : Icon(Icons.refresh_rounded,
                                color: tc.text40, size: 20),
                      ),
                      // Completed badge
                      if (completed.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: tc.coreActionDim,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: tc.limeBorder,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_rounded,
                                color: tc.coreAction,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${completed.length} done',
                                style: GoogleFonts.inter(
                                  color: tc.coreAction,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Error banner ────────────────────────────────────────────
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: tc.accentExpense.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: tc.accentExpense.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded,
                              color: tc.accentExpense, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Failed to load goals. Tap ↺ to retry.',
                              style: GoogleFonts.inter(
                                  color: tc.accentExpense, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Segmented tabs ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _GoalTabBar(controller: _tabController, tc: tc),
                ),
                const SizedBox(height: 12),

                // ── Tab content ─────────────────────────────────────────────
                Expanded(
                  child: _isLoading && displayGoals.isEmpty
                      ? Center(
                          child: CircularProgressIndicator(color: tc.coreAction),
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            // ── Overview tab: dashboard summary ────────────
                            _GoalOverviewTab(
                              tc: tc,
                              displayGoals: displayGoals,
                              savings: savings,
                              investments: investments,
                              completed: completed,
                              totalTarget: totalTarget,
                              totalSaved: totalSaved,
                              overallPct: overallPct,
                            ),
                            _GoalList(
                              goals: savings,
                              tc: tc,
                              emptyLabel: 'No savings goals',
                              onDelete: _deleteGoal,
                            ),
                            _GoalList(
                              goals: investments,
                              tc: tc,
                              emptyLabel: 'No investment goals',
                              onDelete: _deleteGoal,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Overview dashboard tab ────────────────────────────────────────────────────
class _GoalOverviewTab extends StatelessWidget {
  const _GoalOverviewTab({
    required this.tc,
    required this.displayGoals,
    required this.savings,
    required this.investments,
    required this.completed,
    required this.totalTarget,
    required this.totalSaved,
    required this.overallPct,
  });

  final ThemeColors tc;
  final List<GoalModel> displayGoals;
  final List<GoalModel> savings;
  final List<GoalModel> investments;
  final List<GoalModel> completed;
  final double totalTarget;
  final double totalSaved;
  final double overallPct;

  String _fmt(double v) {
    if (v >= 1e6) return 'Rs. ${(v / 1e6).toStringAsFixed(1)}M';
    if (v >= 1e3) return 'Rs. ${(v / 1e3).toStringAsFixed(1)}K';
    return 'Rs. ${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    if (displayGoals.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined, color: tc.text20, size: 56),
            const SizedBox(height: 14),
            Text(
              'No goals yet',
              style: GoogleFonts.manrope(
                color: tc.text70,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap + New Goal to start tracking',
              style: GoogleFonts.inter(color: tc.text40, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final savingsTarget = savings.fold(0.0, (s, g) => s + g.targetAmount);
    final savingsSaved  = savings.fold(0.0, (s, g) => s + g.savedAmount);
    final investTarget  = investments.fold(0.0, (s, g) => s + g.targetAmount);
    final investSaved   = investments.fold(0.0, (s, g) => s + g.savedAmount);
    final inProgress    = displayGoals.where((g) => !g.isCompleted).toList();

    // Sort spotlight goals by descending progress
    final spotlightGoals = List<GoalModel>.from(inProgress)
      ..sort((a, b) => b.progress.compareTo(a.progress));
    final topGoals = spotlightGoals.take(3).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      children: [
        // ── Hero progress card ─────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                tc.coreAction.withValues(alpha: isDark ? 0.22 : 0.10),
                tc.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: tc.coreAction.withValues(alpha: 0.25),
              width: 0.9,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: tc.coreAction.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Row(
            children: [
              _ArcProgressRing(pct: overallPct, size: 90, tc: tc),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Progress',
                      style: GoogleFonts.inter(
                        color: tc.text40,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _fmt(totalSaved),
                      style: GoogleFonts.manrope(
                        color: tc.coreAction,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'of ${_fmt(totalTarget)} target',
                      style: GoogleFonts.inter(
                        color: tc.text40,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Mini linear bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: overallPct),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (_, val, _) => LinearProgressIndicator(
                          value: val,
                          minHeight: 5,
                          backgroundColor: tc.text10,
                          valueColor:
                              AlwaysStoppedAnimation(tc.coreAction),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${completed.length} of ${displayGoals.length} goals completed',
                      style: GoogleFonts.inter(
                        color: tc.text70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Stat chips row ──────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _OverviewStatChip(
                tc: tc,
                icon: Icons.savings_rounded,
                iconColor: tc.coreAction,
                bgColor: tc.coreActionDim,
                label: 'Savings',
                value: '${savings.length}',
                sub: _fmt(savingsSaved),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _OverviewStatChip(
                tc: tc,
                icon: Icons.trending_up_rounded,
                iconColor: const Color(0xFF7C86F5),
                bgColor: const Color(0x1A7C86F5),
                label: 'Investments',
                value: '${investments.length}',
                sub: _fmt(investSaved),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _OverviewStatChip(
                tc: tc,
                icon: Icons.check_circle_rounded,
                iconColor: tc.intelligenceAccent,
                bgColor: tc.intelligenceAccentDim,
                label: 'Completed',
                value: '${completed.length}',
                sub: 'goals done',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _OverviewStatChip(
                tc: tc,
                icon: Icons.hourglass_empty_rounded,
                iconColor: tc.accentExpense,
                bgColor: tc.accentExpenseDim,
                label: 'In Progress',
                value: '${inProgress.length}',
                sub: 'active goals',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── Category split bar ──────────────────────────────────────────
        if (totalTarget > 0) ...[
          _SectionTitle(tc: tc, title: 'Target Breakdown'),
          const SizedBox(height: 12),
          _CategorySplitBar(
            tc: tc,
            savingsTarget: savingsTarget,
            investTarget: investTarget,
            totalTarget: totalTarget,
          ),
          const SizedBox(height: 20),
        ],

        // ── Top goals spotlight ─────────────────────────────────────────
        if (topGoals.isNotEmpty) ...[
          _SectionTitle(tc: tc, title: 'Closest to Goal'),
          const SizedBox(height: 12),
          ...topGoals.map(
            (g) => _SpotlightGoalRow(goal: g, tc: tc),
          ),
        ],

        // ── Savings breakdown ───────────────────────────────────────────
        if (savings.isNotEmpty) ...[
          const SizedBox(height: 10),
          _SectionTitle(tc: tc, title: 'Savings Breakdown'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tc.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: tc.border, width: 0.8),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Column(
              children: [
                _BreakdownRow(
                  tc: tc,
                  label: 'Total Saved',
                  value: _fmt(savingsSaved),
                  valueColor: tc.coreAction,
                ),
                Divider(height: 16, thickness: 0.5, color: tc.border),
                _BreakdownRow(
                  tc: tc,
                  label: 'Remaining',
                  value: _fmt(
                      (savingsTarget - savingsSaved).clamp(0.0, double.infinity)),
                  valueColor: tc.text70,
                ),
                Divider(height: 16, thickness: 0.5, color: tc.border),
                _BreakdownRow(
                  tc: tc,
                  label: 'Target',
                  value: _fmt(savingsTarget),
                  valueColor: tc.text40,
                ),
              ],
            ),
          ),
        ],

        // ── Investment breakdown ────────────────────────────────────────
        if (investments.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionTitle(tc: tc, title: 'Investment Breakdown'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tc.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: tc.border, width: 0.8),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Column(
              children: [
                _BreakdownRow(
                  tc: tc,
                  label: 'Total Invested',
                  value: _fmt(investSaved),
                  valueColor: const Color(0xFF7C86F5),
                ),
                Divider(height: 16, thickness: 0.5, color: tc.border),
                _BreakdownRow(
                  tc: tc,
                  label: 'Remaining',
                  value: _fmt(
                      (investTarget - investSaved).clamp(0.0, double.infinity)),
                  valueColor: tc.text70,
                ),
                Divider(height: 16, thickness: 0.5, color: tc.border),
                _BreakdownRow(
                  tc: tc,
                  label: 'Target',
                  value: _fmt(investTarget),
                  valueColor: tc.text40,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.tc, required this.title});
  final ThemeColors tc;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        color: tc.text40,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ── Stat chip ─────────────────────────────────────────────────────────────────
class _OverviewStatChip extends StatelessWidget {
  const _OverviewStatChip({
    required this.tc,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.label,
    required this.value,
    required this.sub,
  });

  final ThemeColors tc;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String label;
  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tc.border, width: 0.8),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.manrope(
                    color: tc.text100,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
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
                  sub,
                  style: GoogleFonts.inter(
                    color: iconColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category split bar ────────────────────────────────────────────────────────
class _CategorySplitBar extends StatelessWidget {
  const _CategorySplitBar({
    required this.tc,
    required this.savingsTarget,
    required this.investTarget,
    required this.totalTarget,
  });

  final ThemeColors tc;
  final double savingsTarget;
  final double investTarget;
  final double totalTarget;

  @override
  Widget build(BuildContext context) {
    final savingsFrac = totalTarget > 0 ? savingsTarget / totalTarget : 0.0;
    final investFrac  = totalTarget > 0 ? investTarget  / totalTarget : 0.0;

    return Column(
      children: [
        // Segmented bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, t, _) => SizedBox(
              height: 12,
              child: Row(
                children: [
                  if (savingsFrac > 0)
                    Flexible(
                      flex: (savingsFrac * 1000).round(),
                      child: Container(
                        color: tc.coreAction.withValues(alpha: 0.85 * t),
                      ),
                    ),
                  if (investFrac > 0)
                    Flexible(
                      flex: (investFrac * 1000).round(),
                      child: Container(
                        color: const Color(0xFF7C86F5).withValues(alpha: 0.85 * t),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Legend
        Row(
          children: [
            _LegendDot(color: tc.coreAction),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Savings',
                style: GoogleFonts.inter(
                  color: tc.text70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${(savingsFrac * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.manrope(
                color: tc.coreAction,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 20),
            _LegendDot(color: const Color(0xFF7C86F5)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Investments',
                style: GoogleFonts.inter(
                  color: tc.text70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${(investFrac * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.manrope(
                color: const Color(0xFF7C86F5),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ── Spotlight goal row ────────────────────────────────────────────────────────
class _SpotlightGoalRow extends StatelessWidget {
  const _SpotlightGoalRow({required this.goal, required this.tc});
  final GoalModel goal;
  final ThemeColors tc;

  Color get _accent =>
      goal.type == GoalType.savings ? tc.coreAction : const Color(0xFF7C86F5);

  @override
  Widget build(BuildContext context) {
    final pct = (goal.progress * 100).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tc.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.name,
                  style: GoogleFonts.inter(
                    color: tc.text100,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$pct%',
                style: GoogleFonts.manrope(
                  color: _accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: goal.progress),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, val, _) => LinearProgressIndicator(
                value: val,
                minHeight: 5,
                backgroundColor: tc.text10,
                valueColor: AlwaysStoppedAnimation(_accent),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Rs. ${goal.savedAmount.toStringAsFixed(0)} of Rs. ${goal.targetAmount.toStringAsFixed(0)}',
            style: GoogleFonts.inter(
              color: tc.text40,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Breakdown row ─────────────────────────────────────────────────────────────
class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.tc,
    required this.label,
    required this.value,
    required this.valueColor,
  });
  final ThemeColors tc;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: tc.text70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(
            color: valueColor,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Arc progress ring ─────────────────────────────────────────────────────────
class _ArcProgressRing extends StatelessWidget {
  const _ArcProgressRing({
    required this.pct,
    required this.size,
    required this.tc,
  });
  final double pct;
  final double size;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: pct),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, value, _) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _ArcPainter(
            pct: value,
            trackColor: tc.text10,
            progressColor: tc.coreAction,
            strokeWidth: 6,
          ),
          child: Center(
            child: Text(
              '${(value * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.manrope(
                color: tc.text100,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({
    required this.pct,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });
  final double pct;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * math.pi * pct,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.pct != pct || old.progressColor != progressColor;
}

// ── Tab bar ───────────────────────────────────────────────────────────────────
class _GoalTabBar extends StatelessWidget {
  const _GoalTabBar({required this.controller, required this.tc});
  final TabController controller;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
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
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        tabs: const [
          Tab(text: 'Overview', height: 34),
          Tab(text: 'Savings', height: 34),
          Tab(text: 'Invest', height: 34),
        ],
      ),
    );
  }
}

// ── Goal list ─────────────────────────────────────────────────────────────────
class _GoalList extends StatelessWidget {
  const _GoalList({
    required this.goals,
    required this.tc,
    required this.emptyLabel,
    required this.onDelete,
  });
  final List<GoalModel> goals;
  final ThemeColors tc;
  final String emptyLabel;
  final Future<void> Function(GoalModel) onDelete;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined, color: tc.text20, size: 48),
            const SizedBox(height: 12),
            Text(
              emptyLabel,
              style: GoogleFonts.inter(color: tc.text40, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap + New Goal to get started',
              style: GoogleFonts.inter(color: tc.text20, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      itemCount: goals.length,
      itemBuilder: (_, i) =>
          _GoalCard(goal: goals[i], tc: tc, onDelete: onDelete),
    );
  }
}

// ── Goal card ─────────────────────────────────────────────────────────────────
class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.tc,
    required this.onDelete,
  });
  final GoalModel goal;
  final ThemeColors tc;
  final Future<void> Function(GoalModel) onDelete;

  Color get _accentColor =>
      goal.type == GoalType.savings ? tc.coreAction : const Color(0xFF7C86F5);

  IconData get _typeIcon => goal.type == GoalType.savings
      ? Icons.savings_rounded
      : Icons.trending_up_rounded;

  String get _typeLabel =>
      goal.type == GoalType.savings ? 'Savings' : 'Investment';

  String _fmt(double v) => 'Rs. ${v.toStringAsFixed(0)}';

  void _openAddAmount(BuildContext context) {
    if (goal.isCompleted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          AddAmountToGoalSheet(goal: goal),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tc.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Delete Goal',
          style: GoogleFonts.manrope(
            color: tc.text100,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${goal.name}"?',
          style: GoogleFonts.inter(color: tc.text70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: tc.text40)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete(goal);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.inter(color: tc.accentExpense),
            ),
          ),
        ],
      ),
    );
  }

  void _editGoal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddGoalSheet(existing: goal),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: goal.isCompleted
              ? _accentColor.withValues(alpha: 0.3)
              : tc.border,
          width: 0.8,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openAddAmount(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Row 1: icon + name + menu ───────────────────────────
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_typeIcon, color: _accentColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.name,
                            style: GoogleFonts.inter(
                              color: tc.text100,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _accentColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  _typeLabel,
                                  style: GoogleFonts.inter(
                                    color: _accentColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              if (goal.isCompleted) ...[
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: _accentColor,
                                  size: 13,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Completed',
                                  style: GoogleFonts.inter(
                                    color: _accentColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: tc.text40,
                        size: 18,
                      ),
                      color: tc.surface2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onSelected: (v) {
                        if (v == 'add') _openAddAmount(context);
                        if (v == 'edit') _editGoal(context);
                        if (v == 'delete') _showDeleteDialog(context);
                      },
                      itemBuilder: (_) => [
                        if (!goal.isCompleted)
                          PopupMenuItem(
                            value: 'add',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add_rounded,
                                  color: tc.coreAction,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Add Amount',
                                  style: GoogleFonts.inter(color: tc.text100),
                                ),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                color: _accentColor,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Edit Goal',
                                style: GoogleFonts.inter(color: tc.text100),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: tc.accentExpense,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: GoogleFonts.inter(
                                  color: tc.accentExpense,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Progress bar ────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: goal.progress),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          builder: (_, value, _) => LinearProgressIndicator(
                            value: value,
                            minHeight: 6,
                            backgroundColor: tc.text10,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _accentColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${(goal.progress * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.manrope(
                        color: _accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Amounts row ─────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved',
                          style: GoogleFonts.inter(
                            color: tc.text40,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          _fmt(goal.savedAmount),
                          style: GoogleFonts.manrope(
                            color: _accentColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (!goal.isCompleted)
                      Row(
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            color: tc.text20,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_fmt(goal.remaining)} left',
                            style: GoogleFonts.inter(
                              color: tc.text20,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Target',
                          style: GoogleFonts.inter(
                            color: tc.text40,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          _fmt(goal.targetAmount),
                          style: GoogleFonts.manrope(
                            color: tc.text70,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
