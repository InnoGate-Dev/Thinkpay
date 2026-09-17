import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
import '../../../model/loan_model.dart';
import '../../../services/loan_service.dart';
import '../../component/hero_overview_card.dart';
import '../../component/loan_card.dart';
import 'add_loan_page.dart';
import 'loan_detail_page.dart';

/// Entry point for the Loans feature. Replaces the old single-loan
/// `LoanPage` — this now supports any number of loans, with a portfolio
/// overview at the top and a tappable list of individual loans below.
/// The FAB opens the Add Loan form.
class LoanListPage extends StatefulWidget {
  LoanListPage({super.key, LoanService? service})
      : service = service ?? LoanService();
  final LoanService service;

  @override
  State<LoanListPage> createState() => _LoanListPageState();
}

class _LoanListPageState extends State<LoanListPage> {
  late Future<List<LoanModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.service.fetchLoans();
  }

  Future<void> _refresh() async {
    final loans = widget.service.fetchLoans();
    setState(() => _future = loans);
    await loans;
  }

  Future<void> _openAddLoan() async {
    final created = await Navigator.push<LoanModel>(
      context,
      MaterialPageRoute(builder: (_) => AddLoanPage(service: widget.service)),
    );
    if (created != null) _refresh();
  }

  Future<void> _openDetail(LoanModel loan) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoanDetailPage(loan: loan, service: widget.service)),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.background,
      drawerEnableOpenDragGesture: false,
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_loan',
        onPressed: _openAddLoan,
        backgroundColor: tc.coreAction,
        foregroundColor: tc.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.add_rounded, size: 24),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                  Text('Track & manage your loans', style: GoogleFonts.inter(color: tc.text40, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: tc.coreAction,
                child: FutureBuilder<List<LoanModel>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return _ErrorState(onRetry: _refresh);
                    }
                    final loans = snapshot.data ?? const [];
                    if (loans.isEmpty) {
                      return _EmptyState(onAddLoan: _openAddLoan);
                    }
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      children: [
                        HeroOverviewCard(loans: loans),
                        const SizedBox(height: 20),
                        Text('Your Loans', style: GoogleFonts.manrope(color: tc.text100, fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        for (final loan in loans) LoanCard(loan: loan, onTap: () => _openDetail(loan)),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddLoan});
  final VoidCallback onAddLoan;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        Icon(Icons.account_balance_outlined, size: 56, color: tc.text20),
        const SizedBox(height: 16),
        Center(child: Text('No loans yet', style: GoogleFonts.manrope(color: tc.text100, fontSize: 16, fontWeight: FontWeight.w700))),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Add your first loan to start tracking repayments and interest.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: tc.text40, fontSize: 13),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: onAddLoan,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Loan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: tc.coreAction,
              foregroundColor: tc.background,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        Icon(Icons.error_outline_rounded, size: 48, color: tc.accentExpense),
        const SizedBox(height: 16),
        Center(child: Text('Could not load loans', style: GoogleFonts.manrope(color: tc.text100, fontSize: 15, fontWeight: FontWeight.w700))),
        const SizedBox(height: 6),
        Center(child: Text('Check your connection and try again.', style: GoogleFonts.inter(color: tc.text40, fontSize: 13))),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton(
            onPressed: () => onRetry(),
            style: OutlinedButton.styleFrom(foregroundColor: tc.coreAction, side: BorderSide(color: tc.coreAction.withValues(alpha: 0.4))),
            child: const Text('Retry'),
          ),
        ),
      ],
    );
  }
}
