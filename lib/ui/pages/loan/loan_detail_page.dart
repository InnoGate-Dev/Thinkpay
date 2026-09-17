import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';

import '../../../model/loan_model.dart';
import '../../../services/loan_service.dart';
import '../../../util/loan_format.dart';
import '../../component/arc_progress_ring.dart';
import '../../component/breakdown_card.dart';
import '../../component/info_card.dart';
import '../../component/metric_card.dart';
import '../../component/next_payment_card.dart';
import '../../component/section_header.dart';
import '../../component/status_badge.dart';
import 'add_payment_sheet.dart';


class LoanDetailPage extends StatefulWidget {
  LoanDetailPage({
    super.key,
    required this.loan,
    LoanService? service,
  }) : service = service ?? LoanService();

  final LoanModel loan;
  final LoanService service;

  @override
  State<LoanDetailPage> createState() => _LoanDetailPageState();
}

class _LoanDetailPageState extends State<LoanDetailPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this);
  late LoanModel _loan = widget.loan;
  bool _loadingPayments = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    try {
      final payments = await widget.service.fetchPayments(_loan.id);
      if (mounted) {
        setState(() {
          _loan = _loan.copyWith(payments: payments);
          _loadingPayments = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingPayments = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _recordPayment() async {
    final result = await showAddPaymentSheet(context: context, loan: _loan, service: widget.service);
    if (result != null) _loadPayments();
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.background,
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_loan_detail_${_loan.id}',
        onPressed: _recordPayment,
        backgroundColor: tc.coreAction,
        foregroundColor: tc.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.add_rounded, size: 24),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: tc.text100, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      _loan.purpose,
                      style: GoogleFonts.manrope(color: tc.text100, fontSize: 18, fontWeight: FontWeight.w800),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(status: _loan.status),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _DetailHeroCard(loan: _loan),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _LoanTabBar(controller: _tabController),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _DetailsTab(loan: _loan),
                  _RepaymentTab(loan: _loan, loading: _loadingPayments, onRecordPayment: _recordPayment),
                  _SummaryTab(loan: _loan),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailHeroCard extends StatelessWidget {
  const _DetailHeroCard({required this.loan});
  final LoanModel loan;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tc.coreAction.withValues(alpha: isDark ? 0.25 : 0.12), tc.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tc.coreAction.withValues(alpha: 0.25), width: 0.8),
        boxShadow: isDark
            ? null
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Payable', style: GoogleFonts.inter(color: tc.text40, fontSize: 11)),
                const SizedBox(height: 3),
                Text(
                  fmtRs(loan.totalPayable),
                  style: GoogleFonts.manrope(color: tc.text100, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                ),
                const SizedBox(height: 10),
                Text('Paid: ${fmtRs(loan.amountPaid)}', style: GoogleFonts.inter(color: tc.coreAction, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('Remaining: ${fmtRs(loan.remainingBalance)}', style: GoogleFonts.inter(color: tc.text40, fontSize: 12)),
              ],
            ),
          ),
          ArcProgressRing(pct: loan.progress, size: 80),
        ],
      ),
    );
  }
}

class _LoanTabBar extends StatelessWidget {
  const _LoanTabBar({required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Container(
      height: 40,
      decoration: BoxDecoration(color: tc.surface2, borderRadius: BorderRadius.circular(10), border: Border.all(color: tc.border, width: 0.5)),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(3),
        labelColor: tc.text100,
        unselectedLabelColor: tc.text40,
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 12),
        tabs: const [
          Tab(text: 'Details', height: 34),
          Tab(text: 'Repayment', height: 34),
          Tab(text: 'Summary', height: 34),
        ],
      ),
    );
  }
}

class _DetailsTab extends StatelessWidget {
  const _DetailsTab({required this.loan});
  final LoanModel loan;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      children: [
        const SectionHeader(title: 'Loan Details', icon: Icons.credit_card_rounded),
        const SizedBox(height: 10),
        InfoCard(children: [
          InfoRow(label: 'Loan Purpose', value: loan.purpose, icon: Icons.home_work_outlined),
          const AppDivider(),
          InfoRow(label: 'Principal Amount', value: fmtRs(loan.amount), icon: Icons.paid_outlined, valueColor: tc.coreAction, valueBold: true),
          const AppDivider(),
          InfoRow(label: 'Start Date', value: fmtDate(loan.startDate), icon: Icons.event_available_outlined),
        ]),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Interest', icon: Icons.percent_rounded),
        const SizedBox(height: 10),
        InfoCard(children: [
          InfoRow(
            label: 'Interest Rate',
            value: '${loan.interestRate.toStringAsFixed(2)}% p.a.',
            icon: Icons.trending_up_rounded,
            valueColor: tc.accentExpense,
            valueBold: true,
          ),
          const AppDivider(),
          InfoRow(label: 'Total Interest', value: fmtRs(loan.totalInterest), icon: Icons.calculate_outlined, valueColor: tc.accentExpense),
        ]),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Status', icon: Icons.info_outline_rounded),
        const SizedBox(height: 10),
        InfoCard(children: [
          InfoRow(label: 'Current Status', value: loan.status.label, icon: Icons.flag_outlined, valueBold: true),
        ]),
      ],
    );
  }
}

class _RepaymentTab extends StatelessWidget {
  const _RepaymentTab({required this.loan, required this.loading, required this.onRecordPayment});
  final LoanModel loan;
  final bool loading;
  final VoidCallback onRecordPayment;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      children: [
        const SectionHeader(title: 'Repayment Plan', icon: Icons.schedule_rounded),
        const SizedBox(height: 10),
        InfoCard(children: [
          InfoRow(label: 'Loan Period', value: '${loan.loanDurationMonths} months', icon: Icons.date_range_outlined, valueBold: true),
          const AppDivider(),
          InfoRow(label: 'Monthly Payment', value: fmtRs(loan.monthlyPayment), icon: Icons.payments_outlined, valueBold: true),
          const AppDivider(),
          InfoRow(label: 'Payment Day', value: '${loan.paymentDay}${daySuffix(loan.paymentDay)} of every month', icon: Icons.event_outlined),
          const AppDivider(),
          InfoRow(label: 'Payments Made', value: '${loan.paymentsMadeCount} of ${loan.loanDurationMonths}', icon: Icons.check_circle_outline_rounded),
        ]),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Upcoming Payment', icon: Icons.notifications_outlined),
        const SizedBox(height: 10),
        NextPaymentCard(loan: loan, onAddPayment: onRecordPayment),
        if (loan.payments.isNotEmpty) ...[
          const SizedBox(height: 16),
          const SectionHeader(title: 'Payment History', icon: Icons.history_rounded),
          const SizedBox(height: 10),
          InfoCard(
            children: [
              for (int i = 0; i < loan.payments.length; i++) ...[
                if (i != 0) const AppDivider(),
                InfoRow(
                  label: fmtDate(loan.payments[i].paidAt),
                  value: fmtRs(loan.payments[i].amount),
                  icon: Icons.check_circle_outline_rounded,
                ),
              ],
            ],
          ),
        ] else if (!loading) ...[
          const SizedBox(height: 16),
          Center(child: Text('No payments recorded yet', style: GoogleFonts.inter(color: tc.text40, fontSize: 12))),
        ],
      ],
    );
  }
}

class _SummaryTab extends StatelessWidget {
  const _SummaryTab({required this.loan});
  final LoanModel loan;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      children: [
        const SectionHeader(title: 'Auto-computed Summary', icon: Icons.auto_graph_rounded),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: MetricCard(label: 'Total Amount Payable', value: fmtRs(loan.totalPayable), icon: Icons.account_balance_wallet_outlined, accentColor: tc.coreAction)),
          const SizedBox(width: 10),
          Expanded(child: MetricCard(label: 'Total Interest', value: fmtRs(loan.totalInterest), icon: Icons.percent_rounded, accentColor: tc.accentExpense)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: MetricCard(label: 'Amount Paid', value: fmtRs(loan.amountPaid), icon: Icons.check_circle_outline_rounded, accentColor: tc.intelligenceAccent)),
          const SizedBox(width: 10),
          Expanded(child: MetricCard(label: 'Remaining Balance', value: fmtRs(loan.remainingBalance), icon: Icons.hourglass_bottom_rounded, accentColor: tc.text70)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: MetricCard(label: 'Remaining Period', value: '${loan.remainingMonths} months', icon: Icons.timer_outlined, accentColor: tc.coreAction)),
          const SizedBox(width: 10),
          Expanded(child: MetricCard(label: 'Next Payment', value: fmtRs(loan.monthlyPayment), icon: Icons.payments_outlined, accentColor: tc.intelligenceAccent)),
        ]),
        const SizedBox(height: 10),
        InfoCard(children: [
          InfoRow(label: 'Next Payment Date', value: fmtDate(loan.nextPaymentDate), icon: Icons.calendar_today_outlined, valueColor: tc.coreAction, valueBold: true),
        ]),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Payment Breakdown', icon: Icons.pie_chart_outline_rounded),
        const SizedBox(height: 10),
        BreakdownCard(loan: loan),
      ],
    );
  }
}
