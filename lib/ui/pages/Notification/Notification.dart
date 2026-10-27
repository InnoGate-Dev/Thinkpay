import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/repository/notificationRepo.dart';
import '../../../model/notification_model.dart';
import 'package:lottie/lottie.dart';
// ── Notification store (singleton) ────────────────────────────────────────────
class NotificationStore extends ChangeNotifier {
  static final NotificationStore _i = NotificationStore._();
  factory NotificationStore() => _i;

  NotificationStore._() {
    _repository = NotificationRepository();
    fetchNotifications();
  }

  late final NotificationRepository _repository;

  List<NotificationModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;

  List<NotificationModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;

  /// Fetches notifications from backend API
  Future<void> fetchNotifications({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _repository.getNotifications();
      _items = list;
      _unreadCount = _items.where((n) => !n.isRead).length;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches unread count from API
  Future<void> fetchUnreadCount() async {
    try {
      final count = await _repository.getUnreadCount();
      _unreadCount = count;
      notifyListeners();
    } catch (_) {}
  }

  /// Marks a notification as read
  Future<void> markRead(int id) async {
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx != -1 && !_items[idx].isRead) {
      _items[idx] = _items[idx].copyWith(isRead: true);
      _unreadCount = _items.where((n) => !n.isRead).length;
      notifyListeners();

      try {
        await _repository.markAsRead(id);
      } catch (e) {
        // Silent rollback on fail
      }
    }
  }

  /// Marks all notifications as read
  Future<void> markAllRead() async {
    if (_items.every((n) => n.isRead)) return;

    _items = _items.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();

    try {
      await _repository.markAllAsRead();
    } catch (e) {
      // Refresh to restore accurate state on error
      fetchNotifications(forceRefresh: true);
    }
  }

  /// Deletes a notification by id
  Future<void> delete(int id) async {
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx != -1) {
      final removed = _items.removeAt(idx);
      _unreadCount = _items.where((n) => !n.isRead).length;
      notifyListeners();

      try {
        await _repository.deleteNotification(id);
      } catch (e) {
        // Rollback on fail
        _items.insert(idx, removed);
        _unreadCount = _items.where((n) => !n.isRead).length;
        notifyListeners();
      }
    }
  }
}

// ── Notification Page ──────────────────────────────────────────────────────────
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationStore _store = NotificationStore();

  @override
  void initState() {
    super.initState();
    _store.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final unread = _store.items.where((n) => !n.isRead).toList();
        final read = _store.items.where((n) => n.isRead).toList();

        return Scaffold(
          backgroundColor: tc.background,
          appBar: AppBar(
            backgroundColor: tc.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: tc.text70, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.manrope(
                    color: tc.text100,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                if (_store.unreadCount > 0)
                  Text(
                    '${_store.unreadCount} unread',
                    style: GoogleFonts.inter(
                      color: tc.coreAction,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
            actions: [
              if (_store.unreadCount > 0)
                TextButton(
                  onPressed: _store.markAllRead,
                  child: Text(
                    'Mark all read',
                    style: GoogleFonts.inter(
                      color: tc.coreAction,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          body: RefreshIndicator(
            color: tc.coreAction,
            backgroundColor: tc.surface,
            onRefresh: () => _store.fetchNotifications(forceRefresh: true),
            child: _buildBody(tc, unread, read, isDark),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    ThemeColors tc,
    List<NotificationModel> unread,
    List<NotificationModel> read,
    bool isDark,
  ) {
    if (_store.isLoading && _store.items.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: tc.coreAction),
      );
    }

    if (_store.errorMessage != null && _store.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  color: tc.accentExpense, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load notifications',
                style: GoogleFonts.manrope(
                  color: tc.text100,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _store.errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: tc.text40, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: tc.coreAction,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _store.fetchNotifications(forceRefresh: true),
                icon: Icon(Icons.refresh_rounded, color: tc.background, size: 18),
                label: Text(
                  'Retry',
                  style: GoogleFonts.inter(
                    color: tc.background,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_store.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: _EmptyState(tc: tc),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        if (unread.isNotEmpty) ...[
          _SectionHeader(title: 'New', count: unread.length, tc: tc),
          ...unread.map(
            (n) => _NotifTile(
              notif: n,
              store: _store,
              tc: tc,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (read.isNotEmpty) ...[
          _SectionHeader(title: 'Earlier', tc: tc),
          ...read.map(
            (n) => _NotifTile(
              notif: n,
              store: _store,
              tc: tc,
              isDark: isDark,
            ),
          ),
        ],
      ],
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
        child: Row(
          children: [
            Text(
              title.toUpperCase(),
              style: GoogleFonts.inter(
                color: tc.text40,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: tc.coreActionDim,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.inter(
                    color: tc.coreAction,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
}

// ── Notification tile ─────────────────────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.notif,
    required this.store,
    required this.tc,
    required this.isDark,
  });

  final NotificationModel notif;
  final NotificationStore store;
  final ThemeColors tc;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final icon = _iconFor(notif.type);
    final color = _colorFor(notif.type, tc);

    return Dismissible(
      key: Key('notif_${notif.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: tc.accentExpenseDim,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.delete_outline_rounded,
            color: tc.accentExpense, size: 20),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon badge ───────────────────────────────────────────────
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),

              // ── Content ──────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: GoogleFonts.inter(
                              color: tc.text100,
                              fontSize: 14,
                              fontWeight: notif.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notif.message,
                      style: GoogleFonts.inter(
                        color: tc.text70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _timeAgo(notif.createdAt),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(
                'lib/assets/animations/Empty Notifications.lottie',
                fit: BoxFit.contain,
                repeat: true,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.emoji_events_rounded,
                  color: tc.coreAction,
                  size: 60,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "You're all caught up!",
              style: GoogleFonts.manrope(
                color: tc.text100,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "No notifications at the moment.",
              style: GoogleFonts.inter(color: tc.text40, fontSize: 14),
            ),
          ],
        ),
      );
}

// ── Helpers ───────────────────────────────────────────────────────────────────
IconData _iconFor(NotifType t) {
  switch (t) {
    case NotifType.budgetAlert:
      return Icons.warning_amber_rounded;
    case NotifType.reminder:
      return Icons.alarm_rounded;
    case NotifType.goal:
      return Icons.track_changes_rounded;
    case NotifType.info:
      return Icons.info_outline_rounded;
    case NotifType.alert:
      return Icons.error_outline_rounded;
    case NotifType.system:
      return Icons.bar_chart_rounded;
  }
}

Color _colorFor(NotifType t, ThemeColors tc) {
  switch (t) {
    case NotifType.budgetAlert:
      return tc.accentExpense;
    case NotifType.reminder:
      return tc.coreAction;
    case NotifType.goal:
      return tc.intelligenceAccent;
    case NotifType.info:
      return tc.coreAction;
    case NotifType.alert:
      return tc.accentExpense;
    case NotifType.system:
      return const Color(0xFFFFB74D); // Soft orange
  }
}

String _timeAgo(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${d.day}/${d.month}/${d.year}';
}
