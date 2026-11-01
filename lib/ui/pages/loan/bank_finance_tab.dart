import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
import '../../../model/loan_model.dart';
import '../../../services/loan_service.dart';
import '../../component/hero_overview_card.dart';
import '../../component/loan_card.dart';
import '../../component/pinned_fab.dart';
import 'add_loan_page.dart';
import 'loan_detail_page.dart';

/// **Bank & Finance** tab of the loan section.
///
/// Owns the loan portfolio: overview card, tappable loan list, add / detail /
/// swipe-to-delete actions. It intentionally has no [Scaffold] — the
/// surrounding `LoanHubPage` provides the page chrome.
class BankFinanceTab extends StatefulWidget {
  BankFinanceTab({super.key, LoanService? service})
      : service = service ?? LoanService();

  final LoanService service;

  @override
  State<BankFinanceTab> createState() => _BankFinanceTabState();
}

class _BankFinanceTabState extends State<BankFinanceTab> {
  late Future<List<LoanModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchLoansWithPayments();
  }

  Future<List<LoanModel>> _fetchLoansWithPayments() async {
    final loans = await widget.service.fetchLoans();
    final payments = await Future.wait(
      loans.map((loan) => widget.service.fetchPayments(loan.id)),
    );
    return [
      for (var i = 0; i < loans.length; i++)
        loans[i].copyWith(payments: payments[i]),
    ];
  }

  Future<void> _refresh() async {
    final loans = _fetchLoansWithPayments();
    setState(() {
      _future = loans;
    });
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
    // Always refresh — the loan may have been edited or deleted.
    _refresh();
  }

  /// Inline swipe-to-delete: confirms then calls the API; refreshes on success.
  Future<void> _swipeDelete(LoanModel loan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _SwipeDeleteDialog(loanPurpose: loan.purpose),
    );
    if (confirmed != true) {
      // User cancelled — force a list rebuild so the card snaps back.
      setState(() {});
      return;
    }
    try {
      await widget.service.deleteLoan(loan.id);
      _refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete the loan. Please try again.')),
      );
      setState(() {}); // snap card back
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        RefreshIndicator(
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
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                children: [
                  HeroOverviewCard(loans: loans),
                  const SizedBox(height: 20),
                  Text('Your Loans', style: GoogleFonts.manrope(color: tc.text100, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  for (final loan in loans)
                    _SwipeableLoanCard(
                      loan: loan,
                      onTap: () => _openDetail(loan),
                      onDelete: () => _swipeDelete(loan),
                    ),
                ],
              );
            },
          ),
        ),
        PinnedFab(
          heroTag: 'fab_loan',
          icon: Icons.add_rounded,
          onPressed: _openAddLoan,
        ),
      ],
    );
  }
}

// ── Swipeable wrapper around LoanCard ─────────────────────────────────────
class _SwipeableLoanCard extends StatelessWidget {
  const _SwipeableLoanCard({
    required this.loan,
    required this.onTap,
    required this.onDelete,
  });

  final LoanModel loan;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Dismissible(
      key: ValueKey('loan_${loan.id}'),
      direction: DismissDirection.endToStart,
      // Show the red delete background on swipe
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: tc.accentExpense.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tc.accentExpense.withValues(alpha: 0.3), width: 0.8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: tc.accentExpense, size: 22),
            const SizedBox(height: 4),
            Text('Delete', style: GoogleFonts.inter(color: tc.accentExpense, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        onDelete();
        // Return false here — _swipeDelete handles refresh/snackbar itself.
        return false;
      },
      child: LoanCard(loan: loan, onTap: onTap),
    );
  }
}

// ── Swipe-delete confirmation dialog ──────────────────────────────────────
class _SwipeDeleteDialog extends StatelessWidget {
  const _SwipeDeleteDialog({required this.loanPurpose});
  final String loanPurpose;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return AlertDialog(
      backgroundColor: tc.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Delete Loan?',
        style: GoogleFonts.manrope(color: tc.text100, fontSize: 17, fontWeight: FontWeight.w700),
      ),
      content: Text(
        'Permanently delete "$loanPurpose" and all its payment history?',
        style: GoogleFonts.inter(color: tc.text70, fontSize: 13, height: 1.5),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          style: OutlinedButton.styleFrom(
            foregroundColor: tc.text70,
            side: BorderSide(color: tc.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('Cancel', style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: tc.accentExpense,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('Delete', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
        ),
      ],
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
        SizedBox(height: MediaQuery.of(context).size.height * 0.12),
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
        SizedBox(height: MediaQuery.of(context).size.height * 0.12),
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
