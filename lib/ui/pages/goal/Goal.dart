import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
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

  void _openAddGoal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddGoalSheet(),
    );
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
          drawerEnableOpenDragGesture: false,
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_goal',
            onPressed: _openAddGoal,
            backgroundColor: tc.coreAction,
            foregroundColor: tc.background,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(
              'New Goal',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────────
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
                                  color: tc.text40, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      // Completed badge
                      if (completed.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: tc.coreActionDim,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: tc.limeBorder, width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_rounded,
                                  color: tc.coreAction, size: 13),
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

                // ── Summary card ──────────────────────────────────────────
                if (allGoals.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _SummaryCard(
                      tc: tc,
                      totalTarget: totalTarget,
                      totalSaved: totalSaved,
                      overallPct: overallPct,
                      completedCount: completed.length,
                      totalCount: allGoals.length,
                    ),
                  ),

                const SizedBox(height: 16),

                // ── Segmented tabs ────────────────────────────────────────
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
                      _GoalList(
                          goals: allGoals,
                          tc: tc,
                          emptyLabel: 'No goals yet'),
                      _GoalList(
                          goals: savings,
                          tc: tc,
                          emptyLabel: 'No savings goals'),
                      _GoalList(
                          goals: investments,
                          tc: tc,
                          emptyLabel: 'No investment goals'),
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

// ── Summary card with arc progress ring ──────────────────────────────────────
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
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Arc progress ring
          _ArcProgressRing(
            pct: overallPct,
            size: 80,
            tc: tc,
          ),
          const SizedBox(width: 20),

          // Text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Progress',
                  style: GoogleFonts.inter(
                      color: tc.text40,
                      fontSize: 11,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rs. ${_fmt(totalSaved)}',
                  style: GoogleFonts.manrope(
                    color: tc.coreAction,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'of Rs. ${_fmt(totalTarget)} target',
                  style: GoogleFonts.inter(
                      color: tc.text40, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Text(
                  '$completedCount of $totalCount goals completed',
                  style: GoogleFonts.inter(
                    color: tc.text70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
      builder: (_, value, __) => SizedBox(
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
          Tab(text: 'All', height: 34),
          Tab(text: 'Savings', height: 34),
          Tab(text: 'Invest', height: 34),
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
            Icon(Icons.flag_outlined, color: tc.text20, size: 48),
            const SizedBox(height: 12),
            Text(emptyLabel,
                style: GoogleFonts.inter(color: tc.text40, fontSize: 14)),
            const SizedBox(height: 4),
            Text('Tap + New Goal to get started',
                style: GoogleFonts.inter(color: tc.text20, fontSize: 12)),
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
      goal.type == GoalType.savings ? tc.coreAction : const Color(0xFF7C86F5);

  IconData get _typeIcon =>
      goal.type == GoalType.savings
          ? Icons.savings_rounded
          : Icons.trending_up_rounded;

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Delete Goal',
            style: GoogleFonts.manrope(
                color: tc.text100, fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to delete "${goal.name}"?',
          style: GoogleFonts.inter(color: tc.text70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: tc.text40)),
          ),
          TextButton(
            onPressed: () {
              FinanceProvider().deleteGoal(goal.id);
              Navigator.pop(ctx);
            },
            child: Text('Delete',
                style: GoogleFonts.inter(color: tc.accentExpense)),
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
    final days = _daysLeft;

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
                )
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
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      _accentColor.withValues(alpha: 0.1),
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
                              if (days != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  days,
                                  style: GoogleFonts.inter(
                                    color: days == 'Overdue'
                                        ? tc.accentExpense
                                        : tc.text40,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                              if (goal.isCompleted) ...[
                                const SizedBox(width: 6),
                                Icon(Icons.check_circle_rounded,
                                    color: _accentColor, size: 13),
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
                      icon: Icon(Icons.more_vert_rounded,
                          color: tc.text40, size: 18),
                      color: tc.surface2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
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
                              Icon(Icons.add_rounded,
                                  color: tc.coreAction, size: 16),
                              const SizedBox(width: 8),
                              Text('Add Amount',
                                  style: GoogleFonts.inter(color: tc.text100)),
                            ]),
                          ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            Icon(Icons.edit_outlined,
                                color: _accentColor, size: 16),
                            const SizedBox(width: 8),
                            Text('Edit Goal',
                                style: GoogleFonts.inter(color: tc.text100)),
                          ]),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            Icon(Icons.delete_outline_rounded,
                                color: tc.accentExpense, size: 16),
                            const SizedBox(width: 8),
                            Text('Delete',
                                style:
                                    GoogleFonts.inter(color: tc.accentExpense)),
                          ]),
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
                          builder: (_, value, __) => LinearProgressIndicator(
                            value: value,
                            minHeight: 6,
                            backgroundColor: tc.text10,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(_accentColor),
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
                        Text('Saved',
                            style: GoogleFonts.inter(
                                color: tc.text40, fontSize: 10)),
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
                          Icon(Icons.touch_app_rounded,
                              color: tc.text20, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            _fmt(goal.remaining) + ' left',
                            style: GoogleFonts.inter(
                                color: tc.text20, fontSize: 11),
                          ),
                        ],
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Target',
                            style: GoogleFonts.inter(
                                color: tc.text40, fontSize: 10)),
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
