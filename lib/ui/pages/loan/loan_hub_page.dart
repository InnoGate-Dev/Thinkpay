import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
import '../../../services/creditCardService.dart';
import '../../../services/loan_service.dart';
import '../../component/segmented_tab_bar.dart';
import 'bank_finance_tab.dart';
import 'credit_card_tab.dart';

/// Entry point for the Loans section of the app shell.
///
/// The section is split into two tabs:
///  • **Bank & Finance** — the loan portfolio ([BankFinanceTab])
///  • **Credit Card**    — the credit card portfolio ([CreditCardTab])
///
/// The hub owns the page chrome (title, tab bar, layout). Each tab owns its own
/// data, actions and primary button, so they can be reused or reordered freely.
class LoanHubPage extends StatefulWidget {
  LoanHubPage({
    super.key,
    LoanService? loanService,
    CreditCardService? creditCardService,
  })  : loanService = loanService ?? LoanService(),
        creditCardService = creditCardService ?? CreditCardService();

  final LoanService loanService;
  final CreditCardService creditCardService;

  @override
  State<LoanHubPage> createState() => _LoanHubPageState();
}

class _LoanHubPageState extends State<LoanHubPage> with SingleTickerProviderStateMixin {
  static const _tabs = ['Bank & Finance', 'Credit Card'];

  late final TabController _tabController = TabController(length: _tabs.length, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.background,
      drawerEnableOpenDragGesture: false,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Loans',
                    style: GoogleFonts.manrope(color: tc.text100, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 2),
                  Text('Loans & credit cards in one place', style: GoogleFonts.inter(color: tc.text40, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SegmentedTabBar(
                controller: _tabController,
                tabs: _tabs,
                height: 42,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  BankFinanceTab(service: widget.loanService),
                  CreditCardTab(service: widget.creditCardService),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
