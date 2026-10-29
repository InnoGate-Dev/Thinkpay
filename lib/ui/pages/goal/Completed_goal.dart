import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/core/repository/goalRepo.dart';
import 'package:Thinkpay/model/goal_model.dart';
import 'package:Thinkpay/providers/finance_provider.dart';
import 'package:Thinkpay/ui/component/add_goal_sheet.dart';

class CompletedGoalPage extends StatefulWidget {
  const CompletedGoalPage({super.key, this.isEmbedded = false});

  /// If true, header back button will not be shown (used when embedded as a tab).
  final bool isEmbedded;

  @override
  State<CompletedGoalPage> createState() => _CompletedGoalPageState();
}

class _CompletedGoalPageState extends State<CompletedGoalPage> {
  final _provider = FinanceProvider();
  final _repo = GoalRepository();
  bool _isLoading = false;
  String? _error;

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

  Future<void> _deleteGoal(GoalModel goal) async {
    _provider.deleteGoal(goal.id);
    try {
      await _repo.deleteGoal(goal.id);
    } catch (e) {
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

  String _fmt(double v) {
    if (v >= 1e6) return 'Rs. ${(v / 1e6).toStringAsFixed(1)}M';
    if (v >= 1e3) return 'Rs. ${(v / 1e3).toStringAsFixed(1)}K';
    return 'Rs. ${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    Widget content = ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        final allGoals = _provider.goals;
        final displayGoals = allGoals.where((g) {
          final cleanId = g.id.trim().toUpperCase();
          return g.type != GoalType.debt && !cleanId.endsWith('_L');
        }).toList();

        final completedGoals =
            displayGoals.where((g) => g.isCompleted).toList();

        final totalCompletedSaved =
            completedGoals.fold(0.0, (s, g) => s + g.savedAmount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header (if standalone screen) ───────────────────────
            if (!widget.isEmbedded)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: tc.text100,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Completed Goals',
                            style: GoogleFonts.manrope(
                              color: tc.text100,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Achieved financial milestones',
                            style: GoogleFonts.inter(
                              color: tc.text40,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: tc.text40,
                        size: 22,
                      ),
                      onPressed: _loadGoals,
                    ),
                  ],
                ),
              ),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

            // ── Body Content ─────────────────────────────────────────
            Expanded(
              child: _isLoading && completedGoals.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(color: tc.coreAction),
                    )
                  : completedGoals.isEmpty
                      ? _buildEmptyState(tc)
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                          children: [
                            _buildSummaryBanner(
                                tc, completedGoals.length, totalCompletedSaved),
                            const SizedBox(height: 16),
                            Text(
                              'ALL COMPLETED GOALS (${completedGoals.length})',
                              style: GoogleFonts.inter(
                                color: tc.text40,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...completedGoals.map(
                              (goal) => _CompletedGoalCard(
                                goal: goal,
                                tc: tc,
                                onDelete: _deleteGoal,
                                onRefresh: _loadGoals,
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        );
      },
    );

    if (widget.isEmbedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: tc.background,
      body: SafeArea(child: content),
    );
  }

  Widget _buildSummaryBanner(ThemeColors tc, int count, double totalSaved) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tc.intelligenceAccent.withValues(alpha: isDark ? 0.25 : 0.12),
            tc.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: tc.intelligenceAccent.withValues(alpha: 0.3),
          width: 0.9,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: tc.intelligenceAccent.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: tc.intelligenceAccentDim,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              color: tc.intelligenceAccent,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count ${count == 1 ? 'Goal' : 'Goals'} Accomplished',
                  style: GoogleFonts.manrope(
                    color: tc.text100,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total saved: ${_fmt(totalSaved)}',
                  style: GoogleFonts.inter(
                    color: tc.intelligenceAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Congratulations on achieving your financial targets!',
                  style: GoogleFonts.inter(
                    color: tc.text40,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeColors tc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: tc.intelligenceAccentDim,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_outlined,
                color: tc.intelligenceAccent,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No completed goals yet',
              style: GoogleFonts.manrope(
                color: tc.text100,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When you reach your savings or investment target, your finished goals will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: tc.text40,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Completed goal card ────────────────────────────────────────────────────────
class _CompletedGoalCard extends StatelessWidget {
  const _CompletedGoalCard({
    required this.goal,
    required this.tc,
    required this.onDelete,
    required this.onRefresh,
  });

  final GoalModel goal;
  final ThemeColors tc;
  final Future<void> Function(GoalModel) onDelete;
  final Future<void> Function() onRefresh;

  Color get _accentColor => tc.intelligenceAccent;

  IconData get _typeIcon => goal.type == GoalType.savings
      ? Icons.savings_rounded
      : Icons.trending_up_rounded;

  String get _typeLabel =>
      goal.type == GoalType.savings ? 'Savings' : 'Investment';

  String _fmt(double v) => 'Rs. ${v.toStringAsFixed(0)}';

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tc.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Delete Completed Goal',
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
    ).then((_) => onRefresh());
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
          color: _accentColor.withValues(alpha: 0.35),
          width: 0.9,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: _accentColor.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: Icon, Name, Completed Badge, Menu ───────────────
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
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
                        style: GoogleFonts.inter(
                          color: tc.text100,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                          const SizedBox(width: 8),
                          Icon(
                            Icons.check_circle_rounded,
                            color: _accentColor,
                            size: 14,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Completed',
                            style: GoogleFonts.inter(
                              color: _accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: tc.text40,
                    size: 20,
                  ),
                  color: tc.surface2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onSelected: (v) {
                    if (v == 'edit') _editGoal(context);
                    if (v == 'delete') _showDeleteDialog(context);
                  },
                  itemBuilder: (_) => [
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

            // ── 100% Progress Bar ─────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 1.0,
                      minHeight: 6,
                      backgroundColor: tc.text10,
                      valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '100%',
                  style: GoogleFonts.manrope(
                    color: _accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Amounts ────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Achieved Amount',
                      style: GoogleFonts.inter(
                        color: tc.text40,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      _fmt(goal.savedAmount),
                      style: GoogleFonts.manrope(
                        color: _accentColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Target Goal',
                      style: GoogleFonts.inter(
                        color: tc.text40,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      _fmt(goal.targetAmount),
                      style: GoogleFonts.manrope(
                        color: tc.text70,
                        fontSize: 14,
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
    );
  }
}
