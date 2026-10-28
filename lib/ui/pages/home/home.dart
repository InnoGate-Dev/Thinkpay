import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/core/repository/categoryRepo.dart';
import 'package:Thinkpay/core/repository/goalRepo.dart';
import 'package:Thinkpay/core/repository/trasectionRepo.dart';
import 'package:Thinkpay/model/categoryModel.dart';
import 'package:Thinkpay/model/goal_model.dart';
import 'package:Thinkpay/model/loan_model.dart';
import 'package:Thinkpay/model/transaction_model.dart';
import 'package:Thinkpay/providers/finance_provider.dart';
import 'package:Thinkpay/providers/user_profile_store.dart';
import 'package:Thinkpay/services/loan_service.dart';
import 'package:Thinkpay/ui/component/add_transaction_sheet.dart';
import 'package:Thinkpay/ui/component/navbar.dart';
import 'package:Thinkpay/ui/pages/Notification/Notification.dart';
import 'package:Thinkpay/ui/pages/home/balancecard.dart';
import 'package:Thinkpay/ui/pages/home/community_updates.dart';
import 'package:Thinkpay/ui/pages/home/empty_state.dart';
import 'package:Thinkpay/ui/pages/home/home_helpers.dart';
import 'package:Thinkpay/ui/pages/home/transaction_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _provider = FinanceProvider();
  final _profileStore = UserProfileStore();
  final _categoryRepo = CategoryRepository();
  final _transactionRepo = TransactionRepository();
  final _goalRepo = GoalRepository();
  final _loanService = LoanService();

  bool _isLoading = false;
  String _selectedFilter = 'All'; // 'All', 'Income', 'Expense'
  List<LoanModel> _loans = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _categoryRepo.getCategories().catchError((_) => <Category>[]),
        _transactionRepo.getTransactionsAsLocalModels().catchError((_) => <TransactionModel>[]),
        _goalRepo.getGoals().catchError((_) => <GoalModel>[]),
        _loanService.fetchLoans().catchError((_) => <LoanModel>[]),
        NotificationStore().fetchNotifications().catchError((_) {}),
      ]);

      final categories = results[0] as List<Category>;
      final transactions = results[1] as List<TransactionModel>;
      final goals = results[2] as List<GoalModel>;
      final loans = results[3] as List<LoanModel>;

      _provider.setBudgetCategories(
        categories.map((c) => c.toBudgetCategory()).toList(),
      );
      _provider.setTransactions(transactions);
      _provider.setGoals(goals);

      if (mounted) {
        setState(() {
          _loans = loans;
        });
      }
    } catch (e) {
      debugPrint('Error loading home data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openAddTransaction() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([_provider, _profileStore]),
      builder: (context, _) {
        final balance = _provider.balance;
        final income = _provider.totalIncome;
        final expenses = _provider.totalExpenses;
        final recent = _provider.recentTransactions;
        final goals = _provider.goals;
        final name = _profileStore.name.split(' ').first;
        final hour = DateTime.now().hour;
        final greeting = hour < 12
            ? 'Good morning'
            : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

        // Goal progress
        final goalProgress = goals.isEmpty
            ? 0.0
            : goals.fold(0.0, (s, g) => s + g.savedAmount) /
                goals.fold(0.0, (s, g) => s + (g.targetAmount <= 0 ? 1 : g.targetAmount));

        // Filter transactions for recent activity
        final filteredTxns = recent.where((t) {
          if (_selectedFilter == 'Income') return t.type == TransactionType.income;
          if (_selectedFilter == 'Expense') return t.type == TransactionType.expense;
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: tc.background,
          drawerEnableOpenDragGesture: false,
          floatingActionButton: FloatingActionButton(
            heroTag: 'fab_home',
            onPressed: _openAddTransaction,
            backgroundColor: tc.coreAction,
            foregroundColor: tc.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.add_rounded, size: 24),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
              ListenableBuilder(
                listenable: NotificationStore(),
                builder: (context, _) {
                  final unreadCount = NotificationStore().unreadCount;
                  return IconButton(
                    icon: Stack(
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          color: tc.text70,
                          size: 22,
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: tc.coreAction,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: tc.background,
                                  width: 1.2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/notification'),
                  );
                },
              ),
              IconButton(
                onPressed: () => appShellIndexNotifier.value = 2, // AI tab
                icon: Icon(
                  Icons.auto_awesome_rounded,
                  color: tc.intelligenceAccent,
                  size: 20,
                ),
                tooltip: 'AI Financial Assistant',
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _loadData,
            color: tc.coreAction,
            backgroundColor: tc.surface,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
              children: [
                if (_isLoading) ...[
                  LinearProgressIndicator(
                    minHeight: 2,
                    color: tc.coreAction,
                    backgroundColor: tc.surface2,
                  ),
                  const SizedBox(height: 8),
                ],
                // ── Net Worth & Balance Card ────────────────────────────────
                BalanceCard(
                  balance: balance,
                  income: income,
                  expenses: expenses,
                  goalProgress: goalProgress,
                  tc: tc,
                ),
                const SizedBox(height: 16),

                // ── Quick Actions Grid ─────────────────────────────────────
                _QuickActionsRow(
                  onAdd: _openAddTransaction,
                  tc: tc,
                ),
                const SizedBox(height: 20),

                // // ── Smart User Insight Card ─────────────────────────────────
                // _FinancialInsightCard(
                //   income: income,
                //   expenses: expenses,
                //   goals: goals,
                //   loans: _loans,
                //   expenseByCategory: _provider.expenseByCategory,
                //   tc: tc,
                // ),
                // const SizedBox(height: 20),

                // ── Financial Goals Section ─────────────────────────────────
                _HomeGoalsSection(
                  goals: goals,
                  tc: tc,
                ),
                const SizedBox(height: 20),

                // ── Active Loans Summary Section ────────────────────────────
                if (_loans.isNotEmpty) ...[
                  _HomeLoansSection(
                    loans: _loans,
                    tc: tc,
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Recent Activity / Transactions Section ──────────────────
                _RecentTransactionsHeader(
                  selectedFilter: _selectedFilter,
                  onFilterChanged: (filter) {
                    setState(() => _selectedFilter = filter);
                  },
                  tc: tc,
                ),
                const SizedBox(height: 12),

                if (filteredTxns.isEmpty)
                  EmptyState(
                    message: recent.isEmpty
                        ? 'No transactions recorded yet.\nTap + to add your first transaction.'
                        : 'No $_selectedFilter transactions found.',
                    tc: tc,
                  )
                else
                  TransactionList(transactions: filteredTxns, tc: tc),

                const SizedBox(height: 24),

                // // ── Community Updates Feed ──────────────────────────────────
                // CommunityUpdatesSection(tc: tc),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Quick Actions Row ─────────────────────────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.onAdd, required this.tc});
  final VoidCallback onAdd;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tc.border, width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionButton(
            icon: Icons.add_rounded,
            label: 'Add Txn',
            color: tc.coreAction,
            onTap: onAdd,
            tc: tc,
          ),
          _ActionButton(
            icon: Icons.analytics_outlined,
            label: 'Finance',
            color: const Color(0xFF6C63FF),
            onTap: () => appShellIndexNotifier.value = 1,
            tc: tc,
          ),
          _ActionButton(
            icon: Icons.handshake_outlined,
            label: 'Loans',
            color: const Color(0xFFF59E0B),
            onTap: () => appShellIndexNotifier.value = 3,
            tc: tc,
          ),
          _ActionButton(
            icon: Icons.flag_outlined,
            label: 'Goals',
            color: const Color(0xFF10B981),
            onTap: () => appShellIndexNotifier.value = 4,
            tc: tc,
          ),
          _ActionButton(
            icon: Icons.auto_awesome_rounded,
            label: 'Ask AI',
            color: tc.intelligenceAccent,
            onTap: () => appShellIndexNotifier.value = 2,
            tc: tc,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.tc,
  });

  final IconData icon;
  final String label;
  final Color color;
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: tc.text70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Financial Health & Insights Card ──────────────────────────────────────────
class _FinancialInsightCard extends StatelessWidget {
  const _FinancialInsightCard({
    required this.income,
    required this.expenses,
    required this.goals,
    required this.loans,
    required this.expenseByCategory,
    required this.tc,
  });

  final double income;
  final double expenses;
  final List<GoalModel> goals;
  final List<LoanModel> loans;
  final Map<String, double> expenseByCategory;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Insights derivation based exclusively on user data
    String insightTitle = 'Financial Overview';
    String insightBody = 'Track your income, expenses, and savings goals to build long-term wealth.';
    IconData insightIcon = Icons.insights_rounded;
    Color accentColor = tc.coreAction;

    if (income > 0) {
      final savingsRate = (((income - expenses) / income) * 100).clamp(-100.0, 100.0);
      if (savingsRate >= 20) {
        insightTitle = 'Healthy Savings (${savingsRate.toStringAsFixed(0)}%)';
        insightBody = 'You saved Rs. ${formatAmount(income - expenses)} from your total income this period. Great progress!';
        insightIcon = Icons.thumb_up_alt_rounded;
        accentColor = tc.coreAction;
      } else if (savingsRate > 0) {
        insightTitle = 'Moderate Savings (${savingsRate.toStringAsFixed(0)}%)';
        insightBody = 'You saved Rs. ${formatAmount(income - expenses)}. Try reducing top category expenses to reach 20%+ savings.';
        insightIcon = Icons.trending_up_rounded;
        accentColor = const Color(0xFFF59E0B);
      } else {
        insightTitle = 'Expenses Exceed Income';
        insightBody = 'Your expenses (Rs. ${formatAmount(expenses)}) exceed income (Rs. ${formatAmount(income)}). Check your monthly budget.';
        insightIcon = Icons.warning_amber_rounded;
        accentColor = tc.accentExpense;
      }
    } else if (expenses > 0) {
      insightTitle = 'Expense Tracking';
      insightBody = 'Total recorded expenses: Rs. ${formatAmount(expenses)}. Record your income to view savings rate insights.';
      insightIcon = Icons.receipt_long_rounded;
      accentColor = tc.accentExpense;
    }

    // Top category analysis
    String? topCategory;
    double topCategoryAmount = 0.0;
    if (expenseByCategory.isNotEmpty) {
      final sorted = expenseByCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topCategory = sorted.first.key;
      topCategoryAmount = sorted.first.value;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(insightIcon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI USER INSIGHT',
                      style: GoogleFonts.inter(
                        color: tc.text40,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      insightTitle,
                      style: GoogleFonts.manrope(
                        color: tc.text100,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => appShellIndexNotifier.value = 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: tc.intelligenceAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: tc.intelligenceAccent, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'Advisor',
                        style: GoogleFonts.inter(
                          color: tc.intelligenceAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insightBody,
            style: GoogleFonts.inter(
              color: tc.text70,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          if (topCategory != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: tc.surface2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(getCategoryIcon(topCategory), color: tc.accentExpense, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Highest spend: $topCategory',
                      style: GoogleFonts.inter(
                        color: tc.text70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    'Rs. ${formatAmount(topCategoryAmount)}',
                    style: GoogleFonts.manrope(
                      color: tc.text100,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Financial Goals Section ───────────────────────────────────────────────────
class _HomeGoalsSection extends StatelessWidget {
  const _HomeGoalsSection({required this.goals, required this.tc});
  final List<GoalModel> goals;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Financial Goals',
              style: GoogleFonts.manrope(
                color: tc.text100,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            GestureDetector(
              onTap: () => appShellIndexNotifier.value = 4,
              child: Text(
                'See all (${goals.length})',
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
        if (goals.isEmpty)
          GestureDetector(
            onTap: () => appShellIndexNotifier.value = 4,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tc.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: tc.border, width: 0.8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: tc.coreAction.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.flag_rounded, color: tc.coreAction, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set your first Financial Goal',
                          style: GoogleFonts.manrope(
                            color: tc.text100,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Save for emergencies, gadgets, or travel.',
                          style: GoogleFonts.inter(
                            color: tc.text40,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: tc.text40, size: 20),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: goals.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final goal = goals[index];
                final progress = goal.targetAmount > 0
                    ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0)
                    : 0.0;
                return Container(
                  width: 220,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: tc.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: tc.border, width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              goal.name,
                              style: GoogleFonts.manrope(
                                color: tc.text100,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: GoogleFonts.inter(
                              color: tc.coreAction,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: tc.surface2,
                              color: tc.coreAction,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Saved: Rs. ${formatAmount(goal.savedAmount)}',
                                style: GoogleFonts.inter(
                                  color: tc.text70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Target: Rs. ${formatAmount(goal.targetAmount)}',
                                style: GoogleFonts.inter(
                                  color: tc.text40,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ── Active Loans Summary Section ──────────────────────────────────────────────
class _HomeLoansSection extends StatelessWidget {
  const _HomeLoansSection({required this.loans, required this.tc});
  final List<LoanModel> loans;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final activeLoans = loans.where((l) => l.status != LoanStatus.paidOff).toList();
    final totalPayable = loans.fold<double>(0, (s, l) => s + l.totalPayable);
    final totalPaid = loans.fold<double>(0, (s, l) => s + l.amountPaid);
    final totalRemaining = loans.fold<double>(0, (s, l) => s + l.remainingBalance);
    final progress = totalPayable <= 0 ? 0.0 : (totalPaid / totalPayable).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Loans & Liabilities',
              style: GoogleFonts.manrope(
                color: tc.text100,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            GestureDetector(
              onTap: () => appShellIndexNotifier.value = 3,
              child: Text(
                'Manage',
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tc.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: tc.border, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${activeLoans.length} Active Loan${activeLoans.length == 1 ? '' : 's'}',
                        style: GoogleFonts.manrope(
                          color: tc.text100,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Remaining: Rs. ${formatAmount(totalRemaining)}',
                        style: GoogleFonts.inter(
                          color: tc.accentExpense,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: tc.coreAction.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(progress * 100).toInt()}% Paid',
                      style: GoogleFonts.manrope(
                        color: tc.coreAction,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: tc.surface2,
                  color: tc.coreAction,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Recent Transactions Header with Filters ───────────────────────────────────
class _RecentTransactionsHeader extends StatelessWidget {
  const _RecentTransactionsHeader({
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.tc,
  });

  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    return Row(
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
        Row(
          children: [
            for (final f in ['All', 'Income', 'Expense']) ...[
              GestureDetector(
                onTap: () => onFilterChanged(f),
                child: Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: selectedFilter == f ? tc.coreAction : tc.surface2,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    f,
                    style: GoogleFonts.inter(
                      color: selectedFilter == f ? tc.background : tc.text70,
                      fontSize: 11,
                      fontWeight: selectedFilter == f ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
