import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/providers/finance_provider.dart';
import 'package:Thinkpay/providers/user_profile_store.dart';
import 'package:Thinkpay/ui/component/add_transaction_sheet.dart';

import 'package:Thinkpay/ui/component/navbar.dart';
import 'package:Thinkpay/ui/pages/home/balancecard.dart';
import 'package:Thinkpay/ui/pages/home/community_updates.dart';
import 'package:Thinkpay/ui/pages/home/empty_state.dart';
import 'package:Thinkpay/ui/pages/home/transaction_list.dart';
import 'package:Thinkpay/ui/pages/transections/Trasections.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _provider = FinanceProvider();
  final _profileStore = UserProfileStore();

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
        final name = _profileStore.name.split(' ').first;
        final hour = DateTime.now().hour;
        final greeting = hour < 12
            ? 'Good morning'
            : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

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
              Row(
                children: [
                  IconButton(
                    icon: Stack(
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          color: tc.text70,
                          size: 22,
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 7,
                            height: 7,
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
              BalanceCard(
                balance: balance,
                income: income,
                expenses: expenses,
                goalProgress: _provider.goals.isEmpty
                    ? 0.0
                    : _provider.goals.fold(0.0, (s, g) => s + g.savedAmount) /
                          _provider.goals.fold(
                            0.0,
                            (s, g) => s + g.targetAmount,
                          ),
                tc: tc,
              ),
              const SizedBox(height: 10),

              CommunityUpdatesSection(tc: tc),

              const SizedBox(height: 10),

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
                      Navigator.pushNamed(context, '/transaction');
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
                EmptyState(
                  message: 'No transactions yet.\nTap + to record one.',
                  tc: tc,
                ),
              if (recent.isNotEmpty)
                TransactionList(transactions: recent, tc: tc),
            ],
          ),
        );
      },
    );
  }
}
