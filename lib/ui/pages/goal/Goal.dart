import 'package:flutter/material.dart';
import 'package:Thinkpay/constant/app_colors.dart';
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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        final allGoals    = _provider.goals;
        final savings     = allGoals.where((g) => g.type == GoalType.savings).toList();
        final investments = allGoals.where((g) => g.type == GoalType.investment).toList();
        final completed   = allGoals.where((g) => g.isCompleted).toList();

        final totalTarget = allGoals.fold(0.0, (s, g) => s + g.targetAmount);
        final totalSaved  = allGoals.fold(0.0, (s, g) => s + g.savedAmount);
        final overallPct  = totalTarget > 0 ? (totalSaved / totalTarget) : 0.0;

        return Scaffold(
          backgroundColor: tc.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Goals',
                        style: TextStyle(
                          color: tc.text100,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Track your savings & investments',
                        style: TextStyle(color: tc.text40, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Summary card ──────────────────────────────────────────
                if (allGoals.isNotEmpty)
                  _SummaryCard(
                    tc: tc,
                    totalTarget: totalTarget,
                    totalSaved: totalSaved,
                    overallPct: overallPct,
                    completedCount: completed.length,
                    totalCount: allGoals.length,
                  ),

                const SizedBox(height: 16),

                // ── Tabs ──────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _GoalTabBar(controller: _tabController, tc: tc),
                ),
                const SizedBox(height: 12),

                // ── Tab content ───────────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _GoalList(goals: allGoals,    tc: tc, emptyLabel: 'No goals yet'),
                      _GoalList(goals: savings,     tc: tc, emptyLabel: 'No savings goals'),
                      _GoalList(goals: investments, tc: tc, emptyLabel: 'No investment goals'),
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

// ── Summary card ──────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.tc,
    required this.totalTarget,
    required this.totalSaved,
    required this.overallPct,
    required this.completedCount,
    required this.totalCount,
  });

  final ThemeColors tc;
  final double totalTarget;
  final double totalSaved;
  final double overallPct;
  final int completedCount;
  final int totalCount;

  String _fmt(double v) {
    if (v >= 1e5) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [tc.cardGradientStart, tc.cardGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: tc.limeBorder),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overall Progress',
                        style: TextStyle(color: tc.text40, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Rs. ${_fmt(totalSaved)}',
                            style: TextStyle(
                                color: tc.lime,
                                fontSize: 22,
                                fontWeight: FontWeight.w800),
                          ),
                          TextSpan(
                            text: ' / Rs. ${_fmt(totalTarget)}',
                            style: TextStyle(
                                color: tc.text40,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tc.limeDim,
                    border: Border.all(color: tc.limeBorder, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '${(overallPct * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                          color: tc.lime,
                          fontSize: 14,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: overallPct,
                minHeight: 8,
                backgroundColor: tc.text10,
                valueColor: AlwaysStoppedAnimation<Color>(tc.lime),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$completedCount of $totalCount goals completed',
              style: TextStyle(color: tc.text40, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab bar ───────────────────────────────────────────────────────────────────
class _GoalTabBar extends StatelessWidget {
  const _GoalTabBar({required this.controller, required this.tc});
  final TabController controller;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tc.surface2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: tc.lime.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: tc.limeBorder),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: tc.lime,
        unselectedLabelColor: tc.text40,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Savings'),
          Tab(text: 'Investments'),
        ],
      ),
    );
  }
}

// ── Goal list ─────────────────────────────────────────────────────────────────
class _GoalList extends StatelessWidget {
  const _GoalList({required this.goals, required this.tc, required this.emptyLabel});
  final List<GoalModel> goals;
  final ThemeColors tc;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined, color: tc.text20, size: 52),
            const SizedBox(height: 12),
            Text(emptyLabel,
                style: TextStyle(color: tc.text40, fontSize: 15)),
            const SizedBox(height: 4),
            Text('Tap + New Goal to get started',
                style: TextStyle(color: tc.text20, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      itemCount: goals.length,
      itemBuilder: (_, i) => _GoalCard(goal: goals[i], tc: tc),
    );
  }
}

// ── Goal card ─────────────────────────────────────────────────────────────────
class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.tc});
  final GoalModel goal;
  final ThemeColors tc;

  Color get _accentColor =>
      goal.type == GoalType.savings ? tc.lime : const Color(0xFF72B4FF);

  IconData get _typeIcon =>
      goal.type == GoalType.savings ? Icons.savings_rounded : Icons.trending_up_rounded;

  String get _typeLabel =>
      goal.type == GoalType.savings ? 'Savings' : 'Investment';

  String _fmt(double v) => 'Rs. ${v.toStringAsFixed(0)}';

  String? get _daysLeft {
    if (goal.targetDate == null) return null;
    final diff = goal.targetDate!.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Overdue';
    if (diff == 0) return 'Due today';
    return '$diff days left';
  }

  void _openAddAmount(BuildContext context) {
    if (goal.isCompleted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddAmountToGoalSheet(
        goalId: goal.id,
        goalName: goal.name,
      ),
    );
  }

  void _deleteGoal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tc.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Goal',
            style: TextStyle(color: tc.text100, fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to delete "${goal.name}"?',
          style: TextStyle(color: tc.text70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: tc.text40)),
          ),
          TextButton(
            onPressed: () {
              FinanceProvider().deleteGoal(goal.id);
              Navigator.pop(ctx);
            },
            child: Text('Delete', style: TextStyle(color: tc.red)),
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
    final days = _daysLeft;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: goal.isCompleted
              ? _accentColor.withValues(alpha: 0.4)
              : tc.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openAddAmount(context),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Row 1: icon + name + menu ───────────────────────────
                Row(
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: _accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_typeIcon, color: _accentColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.name,
                            style: TextStyle(
                                color: tc.text100,
                                fontSize: 15,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _accentColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _typeLabel,
                                  style: TextStyle(
                                      color: _accentColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (days != null) ...[
                                const SizedBox(width: 6),
                                Text(
                                  days,
                                  style: TextStyle(
                                      color: days == 'Overdue'
                                          ? tc.red
                                          : tc.text40,
                                      fontSize: 11),
                                ),
                              ],
                              if (goal.isCompleted) ...[
                                const SizedBox(width: 6),
                                Icon(Icons.check_circle_rounded,
                                    color: _accentColor, size: 14),
                                const SizedBox(width: 3),
                                Text('Completed',
                                    style: TextStyle(
                                        color: _accentColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, color: tc.text40),
                      color: tc.surface2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (v) {
                        if (v == 'add') _openAddAmount(context);
                        if (v == 'edit') _editGoal(context);
                        if (v == 'delete') _deleteGoal(context);
                      },
                      itemBuilder: (_) => [
                        if (!goal.isCompleted)
                          PopupMenuItem(
                            value: 'add',
                            child: Row(children: [
                              Icon(Icons.add_rounded, color: tc.lime, size: 18),
                              const SizedBox(width: 8),
                              Text('Add Amount', style: TextStyle(color: tc.text100)),
                            ]),
                          ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            Icon(Icons.edit_outlined, color: _accentColor, size: 18),
                            const SizedBox(width: 8),
                            Text('Edit Goal', style: TextStyle(color: tc.text100)),
                          ]),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            Icon(Icons.delete_outline_rounded, color: tc.red, size: 18),
                            const SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: tc.red)),
                          ]),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Progress bar ────────────────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: goal.progress),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, __) => LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      backgroundColor: tc.text10,
                      valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ── Amounts row ─────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Saved',
                            style: TextStyle(color: tc.text40, fontSize: 11)),
                        Text(
                          _fmt(goal.savedAmount),
                          style: TextStyle(
                              color: _accentColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('${(goal.progress * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                                color: tc.text70,
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Target',
                            style: TextStyle(color: tc.text40, fontSize: 11)),
                        Text(
                          _fmt(goal.targetAmount),
                          style: TextStyle(
                              color: tc.text100,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),

                // ── Tap-to-add hint ─────────────────────────────────────
                if (!goal.isCompleted) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.touch_app_rounded, color: tc.text20, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        'Tap to contribute • ${_fmt(goal.remaining)} remaining',
                        style: TextStyle(color: tc.text20, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
