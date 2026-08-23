import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constant/app_colors.dart';
import 'package:Thinkpay/model/transaction_model.dart';
import 'package:Thinkpay/providers/finance_provider.dart';

// ── Notification model ────────────────────────────────────────────────────────
enum NotifType { budgetAlert, newTransaction, tip, system }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotifType type;
  final DateTime time;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.time,
    this.isRead = false,
  });
}

// ── Notification store (singleton) ────────────────────────────────────────────
class NotificationStore extends ChangeNotifier {
  static final NotificationStore _i = NotificationStore._();
  factory NotificationStore() => _i;
  NotificationStore._() { _buildFromProvider(); }

  final List<AppNotification> _items = [];
  List<AppNotification> get items => List.unmodifiable(_items);
  int get unreadCount => _items.where((n) => !n.isRead).length;

  void _buildFromProvider() {
    final provider = FinanceProvider();
    final now = DateTime.now();

    // Budget alerts — check over-budget categories
    final expActual = provider.expenseByCategory;
    for (final budget in provider.budgets.where((b) => b.type == TransactionType.expense)) {
      final actual = expActual[budget.name] ?? 0;
      if (actual > budget.expectedAmount) {
        _items.add(AppNotification(
          id: 'budget_${budget.id}',
          title: '⚠️ Over Budget: ${budget.name}',
          body: 'You\'ve spent Rs. ${_fmt(actual)} on ${budget.name}, exceeding your Rs. ${_fmt(budget.expectedAmount)} budget.',
          type: NotifType.budgetAlert,
          time: now.subtract(const Duration(hours: 2)),
        ));
      }
    }

    // Recent transaction notifications
    for (final t in provider.transactions.take(3)) {
      final isIncome = t.type == TransactionType.income;
      _items.add(AppNotification(
        id: 'tx_${t.id}',
        title: isIncome ? '💰 Income Received' : '💸 Expense Recorded',
        body: '${t.title} — Rs. ${_fmt(t.amount)} in ${t.category}.',
        type: NotifType.newTransaction,
        time: t.date,
        isRead: !isIncome, // mark expense ones as read for demo variety
      ));
    }

    // Financial tips
    _items.addAll([
      AppNotification(
        id: 'tip_1',
        title: '💡 Tip of the Day',
        body: 'Set up automatic savings transfers on payday — pay yourself first before spending.',
        type: NotifType.tip,
        time: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      AppNotification(
        id: 'tip_2',
        title: '📊 Weekly Summary Ready',
        body: 'Your spending this week is 12% lower than last week. Keep it up!',
        type: NotifType.system,
        time: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
      AppNotification(
        id: 'tip_3',
        title: '🎯 Budget Goal Update',
        body: 'You\'re on track with 3 out of 5 budget categories this month.',
        type: NotifType.system,
        time: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
    ]);

    // Sort newest first
    _items.sort((a, b) => b.time.compareTo(a.time));
  }

  void markRead(String id) {
    final n = _items.firstWhere((n) => n.id == id, orElse: () => _items.first);
    if (!n.isRead) { n.isRead = true; notifyListeners(); }
  }

  void markAllRead() {
    for (final n in _items) { n.isRead = true; }
    notifyListeners();
  }

  void delete(String id) {
    _items.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}

// ── Page ──────────────────────────────────────────────────────────────────────
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = NotificationStore();
    final tc = ThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final unread = store.items.where((n) => !n.isRead).toList();
        final read   = store.items.where((n) =>  n.isRead).toList();

        return Scaffold(
          backgroundColor: tc.background,
          appBar: AppBar(
            backgroundColor: tc.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: tc.text70, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Notifications',
                style: GoogleFonts.manrope(color: tc.text100, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              if (store.unreadCount > 0)
                Text('${store.unreadCount} unread',
                  style: GoogleFonts.inter(color: tc.coreAction, fontSize: 11)),
            ]),
            actions: [
              if (store.unreadCount > 0)
                TextButton(
                  onPressed: store.markAllRead,
                  child: Text('Mark all read',
                    style: GoogleFonts.inter(color: tc.coreAction, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              const SizedBox(width: 4),
            ],
          ),
          body: store.items.isEmpty
            ? _EmptyState(tc: tc)
            : ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  if (unread.isNotEmpty) ...[
                    _SectionHeader(title: 'New', count: unread.length, tc: tc),
                    ...unread.map((n) => _NotifTile(notif: n, store: store, tc: tc, isDark: isDark)),
                    const SizedBox(height: 8),
                  ],
                  if (read.isNotEmpty) ...[
                    _SectionHeader(title: 'Earlier', tc: tc),
                    ...read.map((n) => _NotifTile(notif: n, store: store, tc: tc, isDark: isDark)),
                  ],
                ],
              ),
        );
      },
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.count, required this.tc});
  final String title;
  final int? count;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
    child: Row(children: [
      Text(title.toUpperCase(),
        style: GoogleFonts.inter(color: tc.text40, fontSize: 11,
          fontWeight: FontWeight.w700, letterSpacing: 1.0)),
      if (count != null) ...[
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: tc.coreActionDim, borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$count', style: GoogleFonts.inter(
            color: tc.coreAction, fontSize: 10, fontWeight: FontWeight.w800)),
        ),
      ],
    ]),
  );
}

// ── Notification tile ─────────────────────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.notif, required this.store, required this.tc, required this.isDark});
  final AppNotification notif;
  final NotificationStore store;
  final ThemeColors tc;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final icon  = _iconFor(notif.type);
    final color = _colorFor(notif.type, tc);

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: tc.accentExpenseDim,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.delete_outline_rounded, color: tc.accentExpense, size: 20),
      ),
      onDismissed: (_) => store.delete(notif.id),
      child: GestureDetector(
        onTap: () => store.markRead(notif.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tc.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: notif.isRead ? tc.border : color.withValues(alpha: 0.35),
              width: notif.isRead ? 0.8 : 1.2,
            ),
            boxShadow: isDark
                ? null
                : [
                    if (!notif.isRead)
                      BoxShadow(
                        color: color.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                  ],
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Icon badge ───────────────────────────────────────────────
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),

            // ── Content ──────────────────────────────────────────────────
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Text(notif.title,
                      style: GoogleFonts.inter(
                        color: tc.text100,
                        fontSize: 14,
                        fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                      )),
                  ),
                  if (!notif.isRead)
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                ]),
                const SizedBox(height: 6),
                Text(notif.body,
                  style: GoogleFonts.inter(color: tc.text70, fontSize: 13, height: 1.4)),
                const SizedBox(height: 8),
                Text(_timeAgo(notif.time),
                  style: GoogleFonts.inter(color: tc.text40, fontSize: 11)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.tc});
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(color: tc.coreActionDim, shape: BoxShape.circle,
          border: Border.all(color: tc.coreAction.withValues(alpha: 0.2))),
        child: Icon(Icons.notifications_none_rounded, color: tc.coreAction, size: 36),
      ),
      const SizedBox(height: 20),
      Text("You're all caught up!",
        style: GoogleFonts.manrope(color: tc.text100, fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Text("No new notifications at the moment.",
        style: GoogleFonts.inter(color: tc.text40, fontSize: 14)),
    ]),
  );
}

// ── Helpers ───────────────────────────────────────────────────────────────────
IconData _iconFor(NotifType t) {
  switch (t) {
    case NotifType.budgetAlert:    return Icons.warning_amber_rounded;
    case NotifType.newTransaction: return Icons.receipt_long_rounded;
    case NotifType.tip:            return Icons.lightbulb_outline_rounded;
    case NotifType.system:         return Icons.bar_chart_rounded;
  }
}

Color _colorFor(NotifType t, ThemeColors tc) {
  switch (t) {
    case NotifType.budgetAlert:    return tc.accentExpense;
    case NotifType.newTransaction: return tc.coreAction;
    case NotifType.tip:            return tc.intelligenceAccent;
    case NotifType.system:         return const Color(0xFFFFB74D); // Soft orange
  }
}

String _timeAgo(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
  if (diff.inHours   < 24)  return '${diff.inHours}h ago';
  if (diff.inDays    < 7)   return '${diff.inDays}d ago';
  return '${d.day}/${d.month}/${d.year}';
}

String _fmt(double v) {
  if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
  if (v >= 1000)   return '${(v / 1000).toStringAsFixed(1)}K';
  return v.toStringAsFixed(0);
}
